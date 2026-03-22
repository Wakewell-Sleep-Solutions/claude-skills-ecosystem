---
name: frontend-design
description: "Create distinctive, production-grade frontend interfaces with exceptional design quality, React/Next.js patterns, composition architecture, and performance optimization. Use when user says 'build a page', 'create a component', 'make this look good', 'design a UI', 'landing page', 'dashboard', 'responsive layout', 'make it beautiful', 'visual polish', 'redesign this', 'styled component', 'CSS', 'Tailwind', 'React component', 'make this look professional', 'UI/UX', 'web page design', or any frontend task needing visual craft. Also triggers on React composition patterns, compound components, render props, context providers, component architecture, boolean prop refactoring, reusable component APIs, React/Next.js performance optimization, bundle optimization, data fetching, Server Components, re-render optimization, code splitting, and UI code review for Web Interface Guidelines compliance ('review my UI', 'check accessibility', 'audit design', 'review UX')."
license: Complete terms in LICENSE.txt
origin: ECC
---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. It covers visual design, React/Next.js patterns, composition architecture, and performance optimization.

## 1. Design Quality

### Design Workflow (Spec -> Code -> Verify)

**Pre-code design spec (complete before writing any code):**
1. **Tokens:** Define color palette, type scale, spacing scale, border radii, shadows
2. **Hierarchy:** Map the visual hierarchy -- what does the user see first, second, third?
3. **Responsive states:** Define breakpoints and what changes at each (mobile, tablet, desktop)
4. **Motion rules:** Which elements animate? On load, scroll, hover, or interaction? Duration/easing?
5. **Aesthetic direction:** Pick ONE bold direction and commit

**Post-code verification:**
- [ ] Matches design spec tokens (colors, spacing, typography)
- [ ] Visual hierarchy reads correctly at each breakpoint
- [ ] Motion feels intentional, not random
- [ ] WCAG 2.2 AA passes (see accessibility section)
- [ ] Performance budgets met (LCP < 2.5s, CLS < 0.1, INP < 200ms)
- [ ] Looks distinctive -- would a designer say "this was designed" not "this was generated"?

### Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc.
- **Constraints**: Technical requirements (framework, performance, accessibility/WCAG).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work -- the key is intentionality, not intensity.

### Aesthetics Guidelines

- **Typography**: Choose distinctive fonts, not generic (Arial, Inter, Roboto). Pair a distinctive display font with a refined body font.
- **Color & Theme**: Use CSS variables. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **Motion**: Prioritize CSS-only for HTML, Motion library for React. One well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise. Always respect `prefers-reduced-motion`.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, grain overlays.

NEVER use generic AI aesthetics: overused font families, cliched color schemes (purple gradients on white), predictable layouts, cookie-cutter design. Vary between light/dark themes, different fonts, different aesthetics across projects.

Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate animations/effects. Minimalist designs need restraint, precision, careful spacing and typography.

### Accessibility (WCAG 2.2 AA -- Non-Negotiable)

Every interface must meet these minimums:
- Semantic HTML (`nav`, `main`, `article`, `button` -- not div soup)
- ARIA labels on all interactive elements without visible text
- Keyboard navigation: all interactive elements focusable, logical tab order, visible focus indicators
- Color contrast: 4.5:1 for normal text, 3:1 for large text
- Alt text on all images (decorative images get `alt=""`)
- Form inputs linked to labels, error messages announced to screen readers
- Touch targets minimum 24x24px CSS (44x44px recommended)
- Focus Not Obscured (2.4.11): focus indicator must not be fully hidden
- Focus Appearance (2.4.13): focus indicator minimum 2px outline, 3:1 contrast
- Dragging Movements (2.5.7): drag-and-drop must have non-dragging alternative

## 2. React & Next.js Patterns

### Component Patterns

**Composition over inheritance** -- build with composable sub-components:
```typescript
function Card({ children, variant = 'default' }: CardProps) {
  return <div className={`card card-${variant}`}>{children}</div>
}
function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="card-header">{children}</div>
}
```

**Compound components** -- shared context for complex UI:
```typescript
const TabsContext = createContext<TabsContextValue | undefined>(undefined)
function Tabs({ children, defaultTab }) {
  const [activeTab, setActiveTab] = useState(defaultTab)
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      {children}
    </TabsContext.Provider>
  )
}
```

**Render props** -- flexible data/render decoupling:
```typescript
function DataLoader<T>({ url, children }: DataLoaderProps<T>) {
  const [data, setData] = useState<T | null>(null)
  // fetch logic...
  return <>{children(data, loading, error)}</>
}
```

### Custom Hooks

- **useToggle**: Simple boolean state with stable toggle callback
- **useDebounce**: Delay value updates for search/filter inputs
- **useQuery**: Async data fetching with loading/error/refetch (or use SWR/React Query)

### State Management

**Context + Reducer** for app-level state:
```typescript
type Action = { type: 'SET_ITEMS'; payload: Item[] } | { type: 'SELECT'; payload: Item }
function reducer(state: State, action: Action): State { /* switch cases */ }
const AppContext = createContext<{ state: State; dispatch: Dispatch<Action> } | undefined>(undefined)
```

Provider is the only place that knows how state is managed -- consumers use a generic interface with state, actions, meta. This allows swapping zustand/redux/context without changing consumers.

### Error Boundaries

Wrap app sections in ErrorBoundary components. Provide retry button in fallback UI.

### Form Handling

Controlled forms with validation. Validate on submit, show inline errors. Use Zod schemas for complex validation. Link every input to a label.

### Animations (Framer Motion / Motion)

```typescript
<AnimatePresence>
  {items.map(item => (
    <motion.div key={item.id}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      transition={{ duration: 0.3 }}
    />
  ))}
</AnimatePresence>
```

### Accessibility Patterns

- **Keyboard navigation**: Handle ArrowDown/Up/Enter/Escape in dropdowns, listboxes, menus
- **Focus management**: Save previous focus on modal open, restore on close. Use `tabIndex={-1}` + `ref.focus()` for programmatic focus. `aria-modal="true"` on dialogs.

## 3. Composition Patterns

Avoid boolean prop proliferation. These patterns make codebases easier to scale.

### Architecture Rules (HIGH priority)

- **Avoid boolean props** for behavior customization -- use composition instead. A component with `showHeader`, `showFooter`, `isCompact`, `isDark` is a code smell.
- **Compound components** with shared context for complex multi-part UI.

### State Rules (MEDIUM priority)

- **Decouple implementation** -- Provider is the only place that knows state internals
- **Context interface** -- generic `{ state, actions, meta }` for dependency injection
- **Lift state** into provider components when siblings need shared access

### Implementation Rules (MEDIUM priority)

- **Explicit variants** -- create `CompactCard` / `FullCard` instead of `<Card isCompact />`
- **Children over render props** -- prefer `children` composition over `renderHeader` props

### React 19 APIs

> React 19+ only. Skip for React 18.

- No `forwardRef` needed -- ref is a regular prop
- Use `use()` instead of `useContext()` for reading context

## 4. Performance

### Priority Categories

| Priority | Category | Impact |
|----------|----------|--------|
| 1 | Eliminating Waterfalls | CRITICAL |
| 2 | Bundle Size | CRITICAL |
| 3 | Server-Side Performance | HIGH |
| 4 | Client-Side Data Fetching | MEDIUM-HIGH |
| 5 | Re-render Optimization | MEDIUM |
| 6 | Rendering Performance | MEDIUM |
| 7 | JavaScript Performance | LOW-MEDIUM |

### Eliminating Waterfalls (CRITICAL)

- **Defer await**: Move `await` into branches where actually used
- **Parallel fetching**: `Promise.all()` for independent operations
- **Suspense boundaries**: Stream content with `<Suspense>` to avoid blocking

### Bundle Size (CRITICAL)

- **No barrel imports**: Import directly from module files, not index.ts
- **Dynamic imports**: `next/dynamic` or `lazy()` for heavy components
- **Defer third-party**: Load analytics/logging after hydration
- **Conditional loading**: Load modules only when feature is activated
- **Preload on hover**: Preload routes/components on hover/focus

### Server-Side Performance (HIGH)

- **Auth server actions** like API routes (never trust client)
- **React.cache()** for per-request deduplication
- **LRU cache** for cross-request caching
- **Minimize serialization**: Don't pass full objects to client components
- **Parallel server fetches**: Restructure component tree to parallelize
- **after()** for non-blocking operations (logging, analytics)

### Re-render Optimization (MEDIUM)

- **useMemo** for expensive computations; **useCallback** for stable function refs
- **React.memo** for pure components receiving stable props
- **Primitive dependencies** in effects (not objects/arrays)
- **Derived state during render**, not in effects
- **Functional setState**: `setValue(prev => prev + 1)` for stable callbacks
- **No inline component definitions** inside other components
- **startTransition** for non-urgent updates

### Rendering Performance (MEDIUM)

- **content-visibility: auto** for long lists (CSS containment)
- **Hoist static JSX** outside components
- **Conditional render**: Use ternary `? :`, not `&&` (avoids rendering `0`)

### JavaScript Performance (LOW-MEDIUM)

- **Map/Set** for O(1) lookups instead of array.find/includes
- **Combine iterations**: Single loop instead of chained filter/map
- **Early return** from functions
- **toSorted()/flatMap()** for immutable transforms

### Performance Budgets (Non-Negotiable)

- LCP: < 2.5s | CLS: < 0.1 | INP: < 200ms | Bundle: < 200KB initial JS
- INP fixes: break long tasks with `setTimeout`/`requestIdleCallback`, defer third-party scripts
- CSS 2026: container queries, `:has()`, native nesting, scroll-driven animations reduce JS

### Virtualization

For long lists (100+ items), use `@tanstack/react-virtual` with `useVirtualizer`.

### Code Splitting

```typescript
const HeavyChart = lazy(() => import('./HeavyChart'))
<Suspense fallback={<ChartSkeleton />}><HeavyChart data={data} /></Suspense>
```

## 5. Web Design Guidelines Review

When asked to review UI code for compliance:
1. Fetch latest guidelines from `https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md`
2. Read the specified files (or prompt user for files/pattern)
3. Check against all rules in the fetched guidelines
4. Output findings in the terse `file:line` format

## Related Skills

- **frontend-slides:** HTML presentation builder (ECC)
- **page-cro:** Conversion optimization for the pages we design
- **owasp-security:** Input validation and XSS prevention for forms/dynamic content
