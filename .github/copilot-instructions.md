# AI Agent Instructions: AI Personal Trainer App

## Project Overview

AI-powered personal trainer app that generates personalized workout programs, tracks progress, and adapts over time. English-first mobile app with dark-mode-first design system and neon green accents. Features AI program generation via Google Gemini API (free tier), workout logging with PR detection and celebrations, streaks & gamification, social sharing cards, and smart paywall. Built with Expo (managed workflow), TypeScript strict, Supabase (PostgreSQL + Edge Functions), Clerk (auth via Google + Apple OAuth), TanStack Query (server state), Zustand (UI state only), Uniwind (styling, 2.5x faster than NativeWind), react-native-reusables (UI components), React Native Reanimated (animations), and expo-haptics (tactile feedback). Monetized via Free + Pro model with RevenueCat. Currently in planning phase with PRD-driven development using autonomous "Ralph" agent workflow.

## Ralph Workflow (CRITICAL)

This project uses an **autonomous agent pipeline** where each cycle executes exactly ONE task from PRD.md:

1. **Find the first unchecked `[ ]` task** in PRD.md
2. **Read progress context**:
   - If assigned to a phase: read `progress-phase-{N}.txt` first, then `progress.txt`
   - Otherwise: read `progress.txt` only
3. **Implement ONLY that task** — nothing more
4. **Validate** with typecheck: `npx tsc --noEmit`
5. **On SUCCESS**:
   - Mark task `[x]` in PRD.md
   - Commit: `feat: [task description]`
   - Log learnings to your assigned progress file
6. **On FAILURE**:
   - Do NOT mark complete or commit
   - Log failure details to progress file
   - Output `<status>FAILED</status>`

### Question Protocol

When ambiguous requirements arise, output `<question>Specific, actionable question here</question>` and STOP immediately. Do not guess.

### Completion Signals

- Phase complete: `<promise>PHASE_COMPLETE</promise>`
- All tasks done: `<promise>COMPLETE</promise>`

## Architecture

```
app/                    # Expo Router file-based routing
  _layout.tsx           # Root layout (Clerk + Supabase + TanStack Query + RevenueCat providers)
  (auth)/               # Auth screens
    sign-in.tsx         # OAuth (Google + Apple)
    onboarding/         # 8-screen quiz
      _layout.tsx       # Quiz navigation
      goal.tsx          # Step 1: What's your goal?
      experience.tsx    # Step 2: Experience level
      frequency.tsx     # Step 3: Training frequency
      duration.tsx      # Step 4: Session duration
      equipment.tsx     # Step 5: Equipment available
      injuries.tsx      # Step 6: Injuries/limitations
      body-stats.tsx    # Step 7: Age, height, weight
      training-style.tsx # Step 8: Training style preference
    generating.tsx      # AI program generation loading screen
    paywall.tsx         # Post-onboarding paywall
  (app)/                # Main app (single group, no role split)
    _layout.tsx         # Bottom tabs (Dashboard, Workout, History, Progress, Settings)
    dashboard.tsx       # Today's workout, streak, recent PRs, AI suggestions
    workout/            # Logging screens
      index.tsx         # Current program / workout selection
      [workoutId].tsx   # Workout logging screen
      summary.tsx       # Post-workout summary + sharing
    history/            # Past workouts
      index.tsx         # History list (30-day limit for Free)
      [id].tsx          # History detail
    progress.tsx        # Charts (Pro gated)
    settings.tsx        # Account, subscription, referral, sign out
    program.tsx         # Current program display
    paywall.tsx         # In-app paywall (triggered by feature gates)
components/
  ui/                   # react-native-reusables (copied, not npm installed)
    Button.tsx
    Card.tsx
    Text.tsx
    Input.tsx
    Label.tsx
    Separator.tsx
    index.ts             # Barrel export
  PRCelebration.tsx     # Gold confetti PR animation
  RestTimer.tsx         # Floating rest timer overlay
  StreakCounter.tsx      # Flame counter with animation
  AchievementBadge.tsx  # Achievement badge display
  ShareCard.tsx         # Social sharing card generator
  SkeletonCard.tsx      # Loading placeholder
  EmptyState.tsx        # Empty state with CTA
  ErrorBoundary.tsx     # Sentry error boundary
  ProGate.tsx           # Paywall wrapper for Pro features
  LineChart.tsx         # Progress line chart
  BarChart.tsx          # Progress bar chart
lib/
  supabase.ts           # Supabase client + Clerk JWT wrapper (useSupabaseClient hook)
  validations/          # Zod schemas
    quiz.ts             # Onboarding quiz validation
    program.ts
    exercise.ts
    log.ts
  utils/
    haptics.ts          # Haptic wrappers
    chartData.ts        # Chart transformation utilities
    sharing.ts          # Social share card generation
    reviewPrompt.ts     # App Store review prompt logic
  services/
    programs.ts         # Supabase CRUD for programs
    workouts.ts         # Supabase CRUD for workouts
    exercises.ts        # Supabase CRUD for exercises
    exerciseLibrary.ts  # Exercise library CRUD + search
    logs.ts             # Workout log query service
    ai.ts               # AI generation + adaptation service
    userProfile.ts      # User profile / quiz data service
    streaks.ts          # Streak tracking service
    achievements.ts     # Achievement unlocking service
    referrals.ts        # Referral code service
hooks/
  usePrograms.ts        # TanStack Query hooks for programs
  useWorkouts.ts        # TanStack Query hooks for workouts
  useExercises.ts       # TanStack Query hooks for exercises
  useExerciseLibrary.ts # Exercise library queries
  useLogs.ts            # Workout log hooks
  useAI.ts              # AI generation + suggestions hooks
  useUserProfile.ts     # User profile hooks
  useEntitlements.ts    # RevenueCat gating (useIsPro)
  useRestTimer.ts       # Rest timer state + haptics
  useStreaks.ts         # Streak tracking hooks
  useAchievements.ts    # Achievement hooks
  useReferrals.ts       # Referral hooks
stores/
  uiStore.ts            # Zustand — UI-only state (theme, active workout, rest timer)
types/
  database.ts           # Auto-generated: supabase gen types typescript
supabase/
  migrations/           # SQL migration files (version-controlled)
  functions/
    clerk-webhook/      # Clerk -> Supabase user sync (Deno)
    generate-program/   # AI program generation via Gemini (Deno)
    generate-suggestions/ # AI weekly adaptation via Gemini (Deno)
  config.toml
```

**Data Model (PostgreSQL — relational):**
- `users` — id (from Clerk), email, display_name, language, onboarding_completed
- `user_profiles` — quiz answers: goal, experience_level, training_frequency, session_duration, equipment, injuries, age, height, weight, training_style, unit_preference
- `programs` — user workout programs with is_ai_generated, is_template, is_active flags
- `workouts` — belong to programs, ordered by sort_order
- `exercises` — belong to workouts (separate table, not nested array), with type-based fields
- `exercises_library` — shared exercise database (name, muscle_group, equipment, description, is_custom, created_by)
- `workout_logs` — user workout entries with duration_seconds and notes
- `completed_exercises` — belong to logs, reference exercise
- `completed_sets` — belong to completed_exercises, with reps/weight/duration/distance/rpe, is_pr
- `ai_generations` — log of AI API calls (model, tokens, cost, generation_type)
- `ai_suggestions` — pending AI adaptation suggestions (suggestion_type, suggestion_data JSONB, status)
- `streaks` — workout streak tracking (user_id, current_streak, longest_streak, last_workout_date)
- `achievements` — gamification badges, 5 types: first_workout, streak_7, streak_30, streak_100, prs_10
- `referrals` — referral codes and bonus tracking

## Development Conventions

### TypeScript Strictness
- **Every story requires typecheck pass**: `npx tsc --noEmit`
- Use Supabase generated types (`Database` generic on client)
- Validate inputs with Zod schemas

### Data Fetching Pattern
```
Supabase service (lib/services/) -> TanStack Query hook (hooks/) -> Component
```
- Services handle raw Supabase queries (typed)
- TanStack Query hooks wrap services with caching, invalidation, mutations
- Components consume hooks — never call Supabase directly

### Auth Pattern
```
Clerk (Google + Apple OAuth) -> JWT (supabase template) -> Supabase client (RLS enforcement)
```
- `useSupabaseClient()` hook creates client with Clerk JWT
- RLS policies use `auth.uid()` to identify user
- User sync via Clerk webhook -> Edge Function -> `users` table
- No email/password auth in MVP — OAuth only

### Forms Pattern
```
React Hook Form + Zod schema -> useForm({ resolver: zodResolver(schema) })
```
- All forms use React Hook Form for state management
- Zod schemas for validation (defined in `lib/validations/`)
- Form errors displayed inline using react-native-reusables `Input` + `Label`

### Styling & Design System
- **Uniwind** (Tailwind CSS, 2.5x faster than NativeWind) for all styling via `className` prop
- **Dark mode first** — default theme is dark (`#0F0F14` background, `#F0F0F5` text)
- **Neon green accent** — primary accent `#22C55E`, pressed `#16A34A`, glow `#22C55E33`
- **Inter font** via `@expo-google-fonts/inter`, text scale: hero/h1/h2/h3/body/caption
- **Component rules:** Cards use `bg-card rounded-2xl p-4`, no borders, 48px min tap targets, bottom sheets for secondary actions
- **Micro-interactions:** Reanimated animations + expo-haptics for set completion, PR detection, workout save, rest timer, streaks
- **react-native-reusables** for base UI components (Button, Card, Input, etc.)
- Components are copy-pasted into `components/ui/`, not npm installed
- Gold (`#FFD700`) for PR celebrations and achievements
- All number displays use `tabular-nums` font-variant

### Lists
- **FlashList** for all list screens (drop-in FlatList replacement)
- Always set `estimatedItemSize` for optimal performance

### State Management
- **TanStack Query** for ALL server/async state (fetching, caching, mutations)
- **Zustand** for UI-only state (theme, active workout state, rest timer)
- Never use Zustand for server data — always TanStack Query

### English-Only for MVP
- **Plain English strings OK** — no i18n infrastructure needed yet
- Hebrew + RTL support added in v1.1 post-launch
- Keep strings descriptive and user-friendly

### Story Sizing
- Each user story fits in **one AI context window (~10 minutes)**
- Examples: add one field, create one component, modify one endpoint
- If a story can't be described in 2-3 sentences, it's too large

### Dependency Ordering
Stories are sequenced to prevent forward dependencies:
1. SQL migrations -> 2. Types generation -> 3. Zod schemas -> 4. Services -> 5. TanStack Query hooks -> 6. UI components

### Parallel Execution Strategy
The `ralph-parallel.sh` orchestrator runs phases in waves:

| Wave | Mode | Phases | Description |
|------|------|---------|-------------|
| A | sequential | 1-4 | Foundation + DB + Auth + AI Generation |
| B | sequential | 5 | Workout Tracking (the money screen) |
| C | parallel | 6, 7 | History/Progress + Monetization |
| D | sequential | 8 | Engagement, Polish, Launch Prep |

Each phase runs in a separate git worktree when parallel execution is active.

## Key Commands

```bash
# Type checking (required for every story)
npx tsc --noEmit

# Start dev (requires EAS dev build, NOT Expo Go)
npx expo start --dev-client

# Run single Ralph iteration
./ralph.sh

# Run parallel orchestrator
./ralph-parallel.sh --start-wave A

# Supabase commands
supabase start                              # Local dev
supabase db push                            # Apply migrations
supabase gen types typescript --local > types/database.ts  # Regenerate types
supabase functions deploy <function-name>   # Deploy Edge Function
supabase functions serve                    # Local Edge Function dev

# EAS builds
eas build --profile development --platform ios
eas build --profile development --platform android

# Lint
npm run lint
```

## Progress Tracking

**Never modify PRD.md directly except to mark tasks `[x]`.**

Log learnings to appropriate progress file:
```markdown
## Iteration [N] — [Task Name]
- What was done
- Files affected
- Learnings for next cycles:
  - Patterns: [successful approaches]
  - Traps: [pitfalls to avoid]
  - Helpful context: [references]
---
```

## Technology-Specific Notes

### Expo
- Managed workflow (no native code modifications)
- **EAS dev builds required** — Expo Go NOT supported (Clerk, Sentry, RevenueCat need native modules)
- Use `expo-haptics` for tactile feedback, `expo-sharing` for social sharing
- Expo Router for file-based navigation (not React Navigation)
- Web target is bonus, not required

### Supabase
- PostgreSQL relational database (not NoSQL)
- RLS (Row Level Security) enforces access control at the database level
- Edge Functions use **Deno runtime** (not Node.js)
- SQL migrations version-controlled in `supabase/migrations/`
- Types auto-generated via `supabase gen types`
- AI Edge Functions call Google Gemini API (`@google/generative-ai` SDK for Deno)

### Clerk
- Auth provider — handles Google + Apple OAuth
- JWT template "supabase" must be configured in Clerk Dashboard (manual step)
- No email/password auth in MVP — OAuth only for faster UX
- User sync to Supabase via webhook -> Edge Function
- `expo-secure-store` for token caching

### Google Gemini API (AI)
- Program generation via Supabase Edge Function (`generate-program`)
- System prompt stored server-side (updatable without app deploy)
- **Primary:** Gemini 2.5 Flash (free tier: 250 req/day, 10 RPM)
- **Fallback:** Gemini 2.5 Flash-Lite (free tier: 1,000 req/day, 15 RPM)
- Native structured JSON output (JSON Schema support)
- Cost: **$0/generation** on free tier; ~$0.003/generation on paid tier ($0.15/M input tokens)
- `@google/generative-ai` SDK for Deno Edge Functions
- GEMINI_API_KEY stored as Edge Function secret

### TanStack Query
- Server state management (replaces Zustand for async data)
- Caching, background refetching, optimistic updates, mutation invalidation
- Persistence via AsyncStorage for offline support
- Configure `staleTime` and `gcTime` per query type

### Zustand
- **UI-only state** — never for server data
- Examples: theme preference, active workout state, rest timer state
- Lightweight, no boilerplate

### Uniwind
- Tailwind CSS utility classes via `className` prop (2.5x faster than NativeWind)
- From the creators of Unistyles — proven, stable, high-performance CSS parser
- Tailwind 4 syntax support
- `metro.config.js` for Uniwind transformer configuration
- `global.css` with Tailwind directives
- `uniwind-types.d.ts` for `className` type support
- Use `withUniwind()` wrapper for third-party components (instead of `cssInterop()`)
- Built-in light/dark mode support + CSS variables

### react-native-reusables
- shadcn/ui-inspired components for React Native
- **Copy-paste model** — components live in `components/ui/`, not npm installed
- Initialize with `npx @react-native-reusables/cli@latest init -t minimal-uniwind` for Uniwind-compatible setup
- CLI auto-detects Uniwind when `uniwind-types.d.ts` is present
- Base components: Button, Card, Text, Input, Label, Separator
- Styled with Uniwind

### React Hook Form + Zod
- All forms use `useForm({ resolver: zodResolver(schema) })`
- Zod schemas in `lib/validations/`
- Schemas export inferred types via `z.infer<>`
- Inline validation errors displayed in forms

### RevenueCat
- Subscription/payment management with Free + Pro pricing model
- Tiers: Free, Pro ($6.99/mo, $49.99/yr, $99.99 lifetime)
- 7-day free trial on paid tiers
- SDK initialized in root layout
- `useIsPro()` hook for entitlement checking
- `<ProGate>` component for feature gating
- Gated features: progress charts, unlimited history, AI regeneration, AI suggestions, full achievements, CSV export, clean social cards
- Requires EAS dev build (native module)

### Sentry
- Error monitoring and crash reporting
- Initialized in root layout
- Error boundaries on key screens
- EAS build plugin for source maps

### FlashList
- Drop-in FlatList replacement for performance
- Always set `estimatedItemSize`
- Used on all list screens

### React Native Reanimated + Gesture Handler + expo-haptics
- Reanimated for layout animations (expand/collapse, progress bar, celebrations, confetti)
- Gesture Handler for swipe-to-delete
- expo-haptics for tactile feedback: `lib/utils/haptics.ts` wrapper functions
- Haptic moments defined in design system: set completion (light), PR (heavy), workout save (medium), timer (notification), streaks (success)
- Web platform gracefully no-ops for haptics

## Critical Anti-Patterns

**Do NOT:**
- Implement multiple stories in one cycle
- Mark tasks complete without validation passing
- Guess at ambiguous requirements (use question protocol)
- Create oversized stories (split if needed)
- Use Zustand for server/async data (use TanStack Query)
- Call Supabase directly from components (use service -> hook pattern)
- Use FlatList (use FlashList)
- Use React Navigation (use Expo Router)
- Use StyleSheet (use Uniwind `className`)
- Use NativeWind (use Uniwind instead — same `className` API, 2.5x faster)
- Install react-native-reusables via npm (copy components into `components/ui/`)
- Run in Expo Go (use EAS dev builds)
- Write Edge Functions in Node.js (use Deno)
- Add code for deferred features (coach features, nutrition, messaging, marketplace, Hebrew/RTL)
- Skip haptic feedback on interaction moments defined in the design system
- Use pure white (#FFFFFF) for text — use off-white (#F0F0F5) instead
- Use borders in dark mode — use background color layers for depth
- Add i18n infrastructure (English-only for MVP, plain strings OK)

## When You're Uncertain

1. **Check PRD.md** for acceptance criteria details
2. **Read progress files** for past learnings and traps
3. **Ask a question** using `<question>` tags if still unclear

## Current State

Planning phase — PRD complete (~79 user stories across 8 phases), no source code yet. First implementation cycle starts with US-001 (Initialize Expo project with Expo Router). Revenue model: Free + Pro ($6.99/mo, $49.99/yr, $99.99 lifetime). Dark-mode-first design system with neon green accent palette. AI program generation via Google Gemini API (free tier) as core differentiator. Styling via Uniwind (2.5x faster than NativeWind, same Tailwind `className` API).
