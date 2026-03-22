---
name: kotlin
description: Comprehensive Kotlin skill — idiomatic patterns, coroutines & Flows, testing (Kotest/MockK), Compose Multiplatform UI, and Android Clean Architecture. Activates for any Kotlin, KMP, Android, Compose, coroutine, Flow, Kotest, or MockK work.
origin: ECC
---

# Kotlin Development

Unified reference for idiomatic Kotlin, structured concurrency, testing, Compose Multiplatform UI, and Clean Architecture.

## When to Use

- Writing, reviewing, or refactoring Kotlin code
- Async work with coroutines, Flow, StateFlow, SharedFlow
- Testing with Kotest, MockK, property-based testing, Kover coverage
- Building Compose UI (Jetpack Compose or Compose Multiplatform / KMP)
- Structuring Android or KMP projects (modules, layers, DI)
- Configuring Gradle Kotlin DSL builds

---

## 1. Idiomatic Patterns

### Null Safety

```kotlin
// Prefer non-nullable types; use safe calls + Elvis for nullable
fun getUserEmail(userId: String): String =
    userRepository.findById(userId)?.email ?: "unknown@example.com"

// Never use !! — throw explicitly instead
fun getUser(id: String): User =
    userRepository.findById(id) ?: throw UserNotFoundException("User $id not found")
```

### Immutability

- `val` over `var`, immutable collections by default
- Transform with `copy()` on data classes
- Use `value class` for zero-overhead type safety:

```kotlin
@JvmInline
value class UserId(val value: String) {
    init { require(value.isNotBlank()) { "UserId cannot be blank" } }
}
```

### Expression Bodies & When

```kotlin
fun isAdult(age: Int): Boolean = age >= 18

fun statusMessage(code: Int): String = when (code) {
    200 -> "OK"; 404 -> "Not Found"; 500 -> "Internal Server Error"
    else -> "Unknown status: $code"
}
```

### Sealed Classes/Interfaces

```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Failure(val error: AppError) : Result<Nothing>()
    data object Loading : Result<Nothing>()
}

fun <T> Result<T>.getOrNull(): T? = when (this) {
    is Result.Success -> data
    is Result.Failure -> null
    is Result.Loading -> null
}
```

### Scope Functions Quick Guide

| Function | Receiver | Returns | Use for |
|----------|----------|---------|---------|
| `let` | `it` | lambda result | Transform nullable / scoped result |
| `apply` | `this` | object | Configure an object |
| `also` | `it` | object | Side effects (logging) |
| `run` | `this` | lambda result | Execute block with receiver |
| `with` | `this` | lambda result | Non-extension form of run |

Anti-pattern: nested scope functions. Use safe-call chains instead: `user?.address?.city?.let { process(it) }`

### Extension Functions

```kotlin
fun String.toSlug(): String =
    lowercase().replace(Regex("[^a-z0-9\\s-]"), "").replace(Regex("\\s+"), "-").trim('-')

// Scope extensions to avoid polluting global namespace
class UserService {
    private fun User.isActive(): Boolean =
        status == Status.ACTIVE && lastLogin.isAfter(Instant.now().minus(30, ChronoUnit.DAYS))
}
```

### DSL Builders

```kotlin
@DslMarker annotation class HtmlDsl

@HtmlDsl
class HTML { /* children, head {}, body {} */ }
fun html(init: HTML.() -> Unit): HTML = HTML().apply(init)
```

### Error Handling

```kotlin
// require for argument validation, check for state validation
fun withdraw(account: Account, amount: Money): Account {
    require(amount.value > 0) { "Amount must be positive" }
    check(account.balance >= amount) { "Insufficient balance" }
    return account.copy(balance = account.balance - amount)
}
```

### Sequences for Lazy Evaluation

```kotlin
val result = users.asSequence()
    .filter { it.isActive }
    .map { it.email }
    .take(10)
    .toList()
```

### Delegation

```kotlin
// Interface delegation — decorate without boilerplate
class LoggingRepo(private val delegate: UserRepository) : UserRepository by delegate {
    override suspend fun findById(id: String): User? {
        logger.info("Finding user: $id")
        return delegate.findById(id)
    }
}
```

---

## 2. Coroutines & Flows

### Structured Concurrency

```kotlin
// Always use structured scopes, never GlobalScope
suspend fun loadDashboard(): Dashboard = coroutineScope {
    val items = async { itemRepo.getRecent() }
    val stats = async { statsRepo.getToday() }
    Dashboard(items = items.await(), stats = stats.await())
}

// supervisorScope when children can fail independently
suspend fun syncAll() = supervisorScope {
    launch { syncItems() }   // failure won't cancel siblings
    launch { syncStats() }
}
```

### StateFlow for UI State

```kotlin
class DashboardViewModel(observeProgress: ObserveUserProgressUseCase) : ViewModel() {
    val progress: StateFlow<UserProgress> = observeProgress()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), UserProgress.EMPTY)
}
```

`WhileSubscribed(5_000)` keeps upstream alive 5s after last subscriber — survives config changes.

### Flow Operators

```kotlin
// Debounced search
searchQuery
    .debounce(300).distinctUntilChanged()
    .flatMapLatest { query -> repository.search(query) }
    .catch { emit(emptyList()) }

// Retry with exponential backoff
flow { emit(api.fetch()) }
    .retryWhen { cause, attempt ->
        cause is IOException && attempt < 3 && run { delay(1000L * (1 shl attempt.toInt())); true }
    }
```

### SharedFlow for One-Time Events

```kotlin
private val _effects = MutableSharedFlow<Effect>()
val effects: SharedFlow<Effect> = _effects.asSharedFlow()

sealed interface Effect {
    data class ShowSnackbar(val message: String) : Effect
    data class NavigateTo(val route: String) : Effect
}
```

### Combining Flows

```kotlin
val uiState: StateFlow<HomeState> = combine(
    itemRepo.observeItems(), settingsRepo.observeTheme(), userRepo.observeProfile()
) { items, theme, profile -> HomeState(items, theme, profile) }
    .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), HomeState())
```

### Dispatchers

| Dispatcher | Use for |
|------------|---------|
| `Default` | CPU-intensive (parsing, sorting) |
| `IO` | Blocking I/O (JVM/Android only) |
| `Main` | UI updates |

KMP: use `Default` and `Main` on all platforms. `IO` is JVM-only — provide via DI on other platforms.

### Cancellation

```kotlin
suspend fun processItems(items: List<Item>) = coroutineScope {
    for (item in items) {
        ensureActive()  // cooperative cancellation check
        process(item)
    }
}

// Cleanup that must run even on cancellation
try { resource.process() }
finally { withContext(NonCancellable) { resource.release() } }
```

### Anti-Patterns

- `GlobalScope` — leaks coroutines
- Catching `CancellationException` — let it propagate
- `MutableStateFlow` with mutable collections — always use immutable copies via `copy()`
- `flowOn(Dispatchers.Main)` to collect — collection runs on caller's dispatcher

---

## 3. Testing (Kotest & MockK)

### TDD Cycle

```
RED   -> Write a failing test first
GREEN -> Write minimal code to pass
REFACTOR -> Improve while keeping tests green
```

### Kotest Spec Styles

```kotlin
// StringSpec — simplest
class CalcTest : StringSpec({
    "add two numbers" { Calculator.add(2, 3) shouldBe 5 }
})

// FunSpec — JUnit-like
class UserServiceTest : FunSpec({
    test("getUser returns user") { /* ... */ }
})

// BehaviorSpec — BDD
class OrderTest : BehaviorSpec({
    Given("a valid order") {
        When("placed") {
            Then("should be confirmed") { /* ... */ }
        }
    }
})
```

### Key Matchers

```kotlin
result shouldBe expected
name shouldContain "lic"
list shouldHaveSize 3
list.shouldContainAll("a", "b")
result.shouldNotBeNull()
result.shouldBeInstanceOf<User>()
shouldThrow<IllegalArgumentException> { validateAge(-1) }.message shouldBe "Age must be positive"
```

### MockK

```kotlin
val repo = mockk<UserRepository>()
every { repo.findById("1") } returns user           // sync
coEvery { repo.findById("1") } returns user          // suspend
verify(exactly = 1) { repo.findById("1") }           // sync verify
coVerify { repo.findById("1") }                       // suspend verify

// Argument capture
val slot = slot<User>()
coEvery { repo.save(capture(slot)) } returns Unit
slot.captured.name shouldBe "Alice"

// Relaxed mock (returns defaults)
val logger = mockk<Logger>(relaxed = true)

beforeTest { clearMocks(repo) }
```

### Coroutine Testing

```kotlin
test("concurrent fetches") {
    runTest {
        val result = service.fetchAllData()
        result.users.shouldNotBeEmpty()
    }
}

// TestDispatcher for time control
runTest {
    launch { delay(1000); completed = true }
    completed shouldBe false
    advanceTimeBy(1000)
    completed shouldBe true
}
```

### Testing Flows (with Turbine)

```kotlin
viewModel.state.test {
    assertEquals(InitialState, awaitItem())
    viewModel.onSearch("query")
    assertTrue(awaitItem().isLoading)
    assertFalse(awaitItem().isLoading)
}
```

### Property-Based Testing

```kotlin
forAll<String> { s -> s.reversed().reversed() == s }

forAll(Arb.list(Arb.int())) { list -> list.sorted() == list.sorted().sorted() }

// Custom generator
val userArb: Arb<User> = Arb.bind(Arb.string(1..50), Arb.email(), Arb.enum<Role>()) { n, e, r ->
    User(name = n, email = Email(e), role = r)
}
```

### Data-Driven Testing

```kotlin
context("parsing valid dates") {
    withData("2026-01-15" to LocalDate(2026, 1, 15), "2026-12-31" to LocalDate(2026, 12, 31)) { (input, expected) ->
        parseDate(input) shouldBe expected
    }
}
```

### Kover Coverage

```kotlin
// build.gradle.kts
plugins { id("org.jetbrains.kotlinx.kover") version "0.9.7" }
kover {
    reports {
        verify { rule { minBound(80) } }
        filters { excludes { classes("*.generated.*", "*.config.*") } }
    }
}
```

| Code Type | Coverage Target |
|-----------|----------------|
| Critical business logic | 100% |
| Public APIs | 90%+ |
| General code | 80%+ |
| Generated / config | Exclude |

### Ktor testApplication

```kotlin
test("GET /users returns list") {
    testApplication {
        application { configureRouting(); configureSerialization() }
        val response = client.get("/users")
        response.status shouldBe HttpStatusCode.OK
        response.body<List<UserResponse>>().shouldNotBeEmpty()
    }
}
```

### Testing Best Practices

**DO:** Write tests first (TDD), use `coEvery`/`coVerify` for suspend functions, use `runTest` for coroutines, test behavior not implementation, use property-based testing for pure functions.

**DON'T:** Mix frameworks, mock data classes (use real instances), use `Thread.sleep()` in coroutine tests (use `advanceTimeBy`), test private functions directly.

---

## 4. Compose Multiplatform

### ViewModel + Single State Object

```kotlin
data class ItemListState(
    val items: List<Item> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

class ItemListViewModel(private val getItems: GetItemsUseCase) : ViewModel() {
    private val _state = MutableStateFlow(ItemListState())
    val state: StateFlow<ItemListState> = _state.asStateFlow()

    fun onSearch(query: String) {
        viewModelScope.launch {
            _state.update { it.copy(isLoading = true) }
            getItems(query).fold(
                onSuccess = { items -> _state.update { it.copy(items = items, isLoading = false) } },
                onFailure = { e -> _state.update { it.copy(error = e.message, isLoading = false) } }
            )
        }
    }
}
```

### Collecting State in Compose

```kotlin
@Composable
fun ItemListScreen(viewModel: ItemListViewModel = koinViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    ItemListContent(state = state, onSearch = viewModel::onSearch)
}
```

### Event Sink Pattern

For complex screens, use a sealed interface for events instead of many lambdas:

```kotlin
sealed interface ItemListEvent {
    data class Search(val query: String) : ItemListEvent
    data class Delete(val itemId: String) : ItemListEvent
    data object Refresh : ItemListEvent
}

// Single lambda: onEvent = viewModel::onEvent
```

### Type-Safe Navigation (2.8+)

```kotlin
@Serializable data object HomeRoute
@Serializable data class DetailRoute(val id: String)

NavHost(navController, startDestination = HomeRoute) {
    composable<HomeRoute> { HomeScreen(onDetail = { navController.navigate(DetailRoute(it)) }) }
    composable<DetailRoute> { DetailScreen(id = it.toRoute<DetailRoute>().id) }
}
```

### Performance Checklist

- Mark UI models `@Immutable` or `@Stable` when all properties are stable
- Use `key = { it.id }` in `LazyColumn` items for stable keys
- Use `derivedStateOf` to defer reads: `val show by remember { derivedStateOf { listState.firstVisibleItemIndex > 5 } }`
- Use `remember(items)` for filtered/mapped collections
- Never pass `NavController` deep into composables — use lambda callbacks

### KMP Platform-Specific

```kotlin
// commonMain
@Composable expect fun PlatformStatusBar(darkIcons: Boolean)

// androidMain / iosMain
@Composable actual fun PlatformStatusBar(darkIcons: Boolean) { /* platform impl */ }
```

### Modifier Ordering

Apply in sequence: layout (padding) -> shape (clip) -> drawing (background) -> interaction (clickable).

---

## 5. Android Clean Architecture

### Module Structure

```
app/              -> DI wiring, Application class
core/             -> Shared utilities, base classes, error types
domain/           -> UseCases, domain models, repository interfaces (PURE KOTLIN)
data/             -> Repository impls, DataSources, DB, network
presentation/     -> Screens, ViewModels, UI models, navigation
design-system/    -> Reusable Compose components, theme
feature/          -> Feature modules (auth/, settings/, profile/)
```

### Dependency Rules

```
app -> presentation, domain, data, core
presentation -> domain, design-system, core
data -> domain, core
domain -> core (NO framework dependencies)
```

### UseCase Pattern

```kotlin
class GetItemsByCategoryUseCase(private val repository: ItemRepository) {
    suspend operator fun invoke(category: String): Result<List<Item>> =
        repository.getItemsByCategory(category)
}
```

### Repository Pattern

```kotlin
// Interface in domain
interface ItemRepository {
    suspend fun getItemsByCategory(category: String): Result<List<Item>>
    fun observeItems(): Flow<List<Item>>
}

// Implementation in data — coordinates local + remote
class ItemRepositoryImpl(
    private val local: ItemLocalDataSource,
    private val remote: ItemRemoteDataSource
) : ItemRepository {
    override suspend fun getItemsByCategory(category: String) = runCatching {
        val items = remote.fetchItems(category)
        local.insertItems(items.map { it.toEntity() })
        local.getByCategory(category).map { it.toDomain() }
    }
}
```

### Mapper Pattern

```kotlin
fun ItemEntity.toDomain() = Item(id = id, title = title, tags = tags.split("|"), ...)
fun ItemDto.toEntity() = ItemEntity(id = id, title = title, tags = tags.joinToString("|"), ...)
```

### DI with Koin (KMP)

```kotlin
val domainModule = module { factory { GetItemsByCategoryUseCase(get()) } }
val dataModule = module { single<ItemRepository> { ItemRepositoryImpl(get(), get()) } }
val presentationModule = module { viewModelOf(::ItemListViewModel) }
```

### DI with Hilt (Android)

```kotlin
@Module @InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds abstract fun bindItemRepository(impl: ItemRepositoryImpl): ItemRepository
}
```

### Architecture Anti-Patterns

- Importing Android classes in `domain` — keep it pure Kotlin
- Exposing entities/DTOs to UI — always map to domain models
- Business logic in ViewModels — extract to UseCases
- Fat repositories — split into focused DataSources
- Circular module dependencies

---

## 6. Gradle Kotlin DSL

```kotlin
plugins {
    kotlin("jvm") version "2.3.10"
    kotlin("plugin.serialization") version "2.3.10"
    id("io.ktor.plugin") version "3.4.0"
    id("org.jetbrains.kotlinx.kover") version "0.9.7"
    id("io.gitlab.arturbosch.detekt") version "1.23.8"
}

kotlin { jvmToolchain(21) }

dependencies {
    implementation("io.ktor:ktor-server-core:3.4.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
    implementation("io.insert-koin:koin-ktor:4.2.0")
    testImplementation("io.kotest:kotest-runner-junit5:6.1.4")
    testImplementation("io.kotest:kotest-assertions-core:6.1.4")
    testImplementation("io.mockk:mockk:1.14.9")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.10.2")
}

tasks.withType<Test> { useJUnitPlatform() }
```

### KMP Convention Plugin

```kotlin
// build-logic/src/main/kotlin/kmp-library.gradle.kts
plugins { id("org.jetbrains.kotlin.multiplatform") }
kotlin {
    androidTarget(); iosX64(); iosArm64(); iosSimulatorArm64()
    sourceSets { commonMain.dependencies { /* shared */ } }
}

// Apply: plugins { id("kmp-library") }
```

---

## Quick Reference: Idioms

| Idiom | Description |
|-------|-------------|
| `val` over `var` | Prefer immutable |
| `data class` | Value objects with equals/hashCode/copy |
| `sealed class/interface` | Restricted type hierarchies |
| `value class` | Type-safe wrappers (zero overhead) |
| `when` expression | Exhaustive pattern matching |
| `?.` / `?:` | Safe call / Elvis |
| Scope functions | `let`/`apply`/`also`/`run`/`with` |
| `by` delegation | Interface + property delegation |
| `coroutineScope` + `async` | Parallel structured concurrency |
| `StateFlow` | UI state holder |
| `SharedFlow` | One-time events |
| `runTest` | Coroutine test harness |
| `@Immutable` | Skippable recomposition |
| UseCase `operator fun invoke` | Clean call-site domain operations |
