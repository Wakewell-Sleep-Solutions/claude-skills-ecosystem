---
name: swift-apple
description: Unified Swift & Apple platform skill — SwiftUI patterns, Swift 6.2 Approachable Concurrency, actor persistence, protocol DI & testing, Liquid Glass (iOS 26), and FoundationModels on-device LLM.
origin: ECC
---

# Swift & Apple Platform Development

Comprehensive patterns for modern Swift development across Apple platforms. Covers SwiftUI architecture, Swift 6.2 concurrency, actor-based persistence, protocol DI with testing, Liquid Glass design, and on-device AI with FoundationModels.

## When to Activate

- Building SwiftUI views, state management, navigation, or performance optimization
- Working with Swift 6.2 concurrency (`@concurrent`, isolated conformances, MainActor defaults)
- Designing actor-based persistence or thread-safe shared state
- Writing testable Swift code with protocol-based dependency injection
- Implementing Liquid Glass UI for iOS 26+
- Using Apple FoundationModels for on-device AI features

---

## 1. SwiftUI Patterns

### Property Wrapper Selection

| Wrapper | Use Case |
|---------|----------|
| `@State` | View-local value types (toggles, form fields, sheet presentation) |
| `@Binding` | Two-way reference to parent's `@State` |
| `@Observable` class + `@State` | Owned model with multiple properties |
| `@Bindable` | Two-way binding to an `@Observable` property |
| `@Environment` | Shared dependencies injected via `.environment()` |

### @Observable ViewModel

Use `@Observable` (not `ObservableObject`) — tracks property-level changes so SwiftUI only re-renders views reading the changed property:

```swift
@Observable
final class ItemListViewModel {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    var searchText = ""
    private let repository: any ItemRepository

    init(repository: any ItemRepository = DefaultItemRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        items = (try? await repository.fetchAll()) ?? []
    }
}

struct ItemListView: View {
    @State private var viewModel: ItemListViewModel

    init(viewModel: ItemListViewModel = ItemListViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.items) { item in ItemRow(item: item) }
            .searchable(text: $viewModel.searchText)
            .overlay { if viewModel.isLoading { ProgressView() } }
            .task { await viewModel.load() }
    }
}
```

### Environment Injection

Replace `@EnvironmentObject` with `@Environment`:

```swift
ContentView().environment(authManager)

struct ProfileView: View {
    @Environment(AuthManager.self) private var auth
    var body: some View { Text(auth.currentUser?.name ?? "Guest") }
}
```

### Type-Safe NavigationStack

```swift
@Observable
final class Router {
    var path = NavigationPath()
    func navigate(to destination: Destination) { path.append(destination) }
    func popToRoot() { path = NavigationPath() }
}

enum Destination: Hashable {
    case detail(Item.ID), settings, profile(User.ID)
}

struct RootView: View {
    @State private var router = Router()
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Destination.self) { dest in
                    switch dest {
                    case .detail(let id): ItemDetailView(itemID: id)
                    case .settings: SettingsView()
                    case .profile(let id): ProfileView(userID: id)
                    }
                }
        }
        .environment(router)
    }
}
```

### Performance Rules

- Use `LazyVStack`/`LazyHStack` for large collections
- Use stable, unique IDs in `ForEach` (never array indices)
- Never perform I/O or heavy computation in `body` — use `.task {}`
- Conform to `Equatable` for views with expensive bodies
- Minimize `.shadow()`, `.blur()`, `.mask()` in scroll views
- Extract subviews to limit invalidation scope

### SwiftUI Anti-Patterns

- `ObservableObject`/`@Published`/`@StateObject`/`@EnvironmentObject` in new code — use `@Observable`
- `AnyView` type erasure — prefer `@ViewBuilder` or `Group`
- Async work in `body` or `init` — use `.task {}`
- Ignoring `Sendable` requirements across actor boundaries

---

## 2. Swift 6.2 Concurrency

### Core Change: Single-Threaded by Default

Swift 6.2 async functions stay on the calling actor by default — no implicit background offloading. Code that caused data-race errors in 6.1 just works:

```swift
@MainActor
final class StickerModel {
    let photoProcessor = PhotoProcessor()
    func extractSticker(_ item: PhotosPickerItem) async throws -> Sticker? {
        guard let data = try await item.loadTransferable(type: Data.self) else { return nil }
        return await photoProcessor.extractSticker(data: data, with: item.itemIdentifier)
    }
}
```

### Isolated Conformances

MainActor types can conform to non-isolated protocols safely:

```swift
extension StickerModel: @MainActor Exportable {
    func export() { photoProcessor.exportAsPNG() }
}
```

### @concurrent for Background Work

Explicitly offload CPU-intensive work (requires Approachable Concurrency build settings):

```swift
nonisolated final class PhotoProcessor {
    private var cachedStickers: [String: Sticker] = [:]

    func extractSticker(data: Data, with id: String) async -> Sticker {
        if let sticker = cachedStickers[id] { return sticker }
        let sticker = await Self.extractSubject(from: data)
        cachedStickers[id] = sticker
        return sticker
    }

    @concurrent
    static func extractSubject(from data: Data) async -> Sticker { /* ... */ }
}
```

### MainActor Default Inference

Opt-in mode for app targets — no manual `@MainActor` annotations needed on classes, properties, or conformances.

### Migration Steps

1. Enable in Xcode Build Settings > Swift Compiler > Concurrency
2. Enable MainActor inference for app targets
3. Add `@concurrent` only where profiling shows CPU bottlenecks
4. Use isolated conformances instead of `nonisolated` workarounds

### Concurrency Anti-Patterns

- `@concurrent` on every async function (most don't need background)
- `nonisolated` to suppress errors without understanding isolation
- Legacy `DispatchQueue` when actors provide same safety
- Assuming all async code runs in background (6.2 default: stays on caller)

---

## 3. Actor Persistence

### Actor-Based Repository

Compiler-enforced thread safety with in-memory cache + file-backed storage:

```swift
public actor LocalRepository<T: Codable & Identifiable> where T.ID == String {
    private var cache: [String: T] = [:]
    private let fileURL: URL

    public init(directory: URL = .documentsDirectory, filename: String = "data.json") {
        self.fileURL = directory.appendingPathComponent(filename)
        self.cache = Self.loadSynchronously(from: fileURL)
    }

    public func save(_ item: T) throws {
        cache[item.id] = item
        try persistToFile()
    }

    public func delete(_ id: String) throws { cache[id] = nil; try persistToFile() }
    public func find(by id: String) -> T? { cache[id] }
    public func loadAll() -> [T] { Array(cache.values) }

    private func persistToFile() throws {
        let data = try JSONEncoder().encode(Array(cache.values))
        try data.write(to: fileURL, options: .atomic)
    }

    private static func loadSynchronously(from url: URL) -> [String: T] {
        guard let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([T].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }
}
```

Key decisions: actor (not class + lock), synchronous init loading, `.atomic` writes, generic over `Codable & Identifiable`, O(1) dictionary lookups.

---

## 4. Protocol DI & Testing

### Pattern: Small Focused Protocols + Default Params + Swift Testing

```swift
// 1. Protocol per concern
public protocol FileAccessorProviding: Sendable {
    func read(from url: URL) throws -> Data
    func write(_ data: Data, to url: URL) throws
    func fileExists(at url: URL) -> Bool
}

// 2. Production default
public struct DefaultFileAccessor: FileAccessorProviding { /* real implementations */ }

// 3. Mock with configurable errors
public final class MockFileAccessor: FileAccessorProviding, @unchecked Sendable {
    public var files: [URL: Data] = [:]
    public var readError: Error?
    public func read(from url: URL) throws -> Data {
        if let error = readError { throw error }
        guard let data = files[url] else { throw CocoaError(.fileReadNoSuchFile) }
        return data
    }
    // ...
}

// 4. Inject with defaults
public actor SyncManager {
    private let fileAccessor: FileAccessorProviding
    public init(fileAccessor: FileAccessorProviding = DefaultFileAccessor()) {
        self.fileAccessor = fileAccessor
    }
}

// 5. Test with Swift Testing
@Test("Handles read errors gracefully")
func testReadError() async {
    let mock = MockFileAccessor()
    mock.readError = CocoaError(.fileReadCorruptFile)
    let manager = SyncManager(fileAccessor: mock)
    await #expect(throws: SyncError.self) { try await manager.sync() }
}
```

Rules: single-responsibility protocols, `Sendable` conformance for actor boundaries, only mock external boundaries (file system, network, APIs), avoid god protocols.

---

## 5. Liquid Glass (iOS 26)

### SwiftUI

```swift
// Basic glass
Text("Hello").padding().glassEffect()

// Customized
Text("Hello").padding()
    .glassEffect(.regular.tint(.orange).interactive(), in: .rect(cornerRadius: 16))

// Button styles
Button("Click") { }.buttonStyle(.glass)
Button("Important") { }.buttonStyle(.glassProminent)

// Container for multiple glass views (required for morphing + performance)
GlassEffectContainer(spacing: 40) {
    HStack(spacing: 40) {
        Image(systemName: "pencil").frame(width: 80, height: 80).glassEffect()
        Image(systemName: "eraser").frame(width: 80, height: 80).glassEffect()
    }
}
```

### Morphing Transitions

Use `@Namespace` + `.glassEffectID()` for smooth morphing when glass elements appear/disappear. Use `.glassEffectUnion()` to merge multiple views into a single glass shape.

### UIKit

Use `UIGlassEffect` with `UIVisualEffectView`. Set `tintColor`, `isInteractive`, `cornerRadius`, `clipsToBounds`. Use `UIGlassContainerEffect` for multiple elements.

### WidgetKit

Check `widgetRenderingMode` for `.accented` vs full color. Use `.widgetAccentable()` for accent groups. Use `.widgetAccentedRenderingMode(.monochrome)` for images.

### Liquid Glass Rules

- Always use `GlassEffectContainer` for multiple sibling glass views
- Apply `.glassEffect()` after other appearance modifiers
- Use `.interactive()` only on elements responding to user interaction
- Don't nest too many glass effects or apply to every view
- Test across light, dark, and accented/tinted modes

---

## 6. FoundationModels (On-Device LLM)

### Availability Check (Required)

```swift
let model = SystemLanguageModel.default
switch model.availability {
case .available: ContentView()
case .unavailable(.deviceNotEligible): Text("Device not eligible")
case .unavailable(.appleIntelligenceNotEnabled): Text("Enable Apple Intelligence")
case .unavailable(.modelNotReady): Text("Model downloading")
case .unavailable(let other): Text("Unavailable: \(other)")
}
```

### Guided Generation with @Generable

```swift
@Generable(description: "Cat profile")
struct CatProfile {
    var name: String
    @Guide(description: "Age of the cat", .range(0...20))
    var age: Int
    @Guide(description: "One sentence personality profile")
    var profile: String
}

let response = try await session.respond(to: "Generate a rescue cat", generating: CatProfile.self)
print(response.content.name) // Always .content, never .output
```

### Tool Calling

```swift
struct RecipeSearchTool: Tool {
    let name = "recipe_search"
    let description = "Search recipes by term"
    @Generable struct Arguments { var searchTerm: String; var numberOfResults: Int }
    func call(arguments: Arguments) async throws -> ToolOutput { /* ... */ }
}
let session = LanguageModelSession(tools: [RecipeSearchTool()])
```

### Snapshot Streaming for SwiftUI

```swift
let stream = session.streamResponse(to: prompt, generating: TripIdeas.self)
for try await partial in stream {
    partialResult = partial // TripIdeas.PartiallyGenerated (all properties Optional)
}
```

### FoundationModels Rules

- Always check `model.availability` before creating sessions
- Access results via `response.content` (not `.output`)
- 4,096 token limit (instructions + prompt + output combined)
- One request per session (`isResponding` guard); create multiple sessions for parallelism
- Use `@Generable` for structured output over raw string parsing
