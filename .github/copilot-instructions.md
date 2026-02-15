# AI Agent Instructions: Workout Tracking & Coaching App

## Project Overview

Bilingual (Hebrew RTL + English) mobile workout tracking app for coaches and trainees. Features dark-mode-first design system with neon green accents, exercise library, rest timers, PR detection, streaks & gamification, body measurements, nutrition tracking, goals, messaging, and coach marketplace. Built with Expo (managed workflow), TypeScript strict, Supabase (PostgreSQL + Edge Functions), Clerk (auth), TanStack Query (server state), Zustand (UI state only), NativeWind (styling), react-native-reusables (UI components), React Native Reanimated (animations), and expo-haptics (tactile feedback). Monetized via coach-first pricing with RevenueCat. Currently in planning phase with PRD-driven development using autonomous "Ralph" agent workflow.

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
  _layout.tsx           # Root layout (Clerk + Supabase + TanStack Query providers)
  (auth)/               # Auth screens (sign-in, sign-up)
    sign-in.tsx
    sign-up.tsx
    paywall.tsx          # RevenueCat paywall
  (coach)/              # Coach tab group
    _layout.tsx          # Coach bottom tabs
    dashboard.tsx
    programs/
      index.tsx          # Programs list
      [id].tsx           # Program detail
      form.tsx           # Create/edit program
      workout-form.tsx   # Create/edit workout
      exercise-editor.tsx
    clients/
      index.tsx          # Clients list
      [id].tsx           # Client detail
      invite.tsx         # Invite flow
      logs.tsx           # Log viewer
      progress.tsx       # Client progress charts
    settings.tsx
  (trainee)/            # Trainee tab group
    _layout.tsx          # Trainee bottom tabs
    programs/
      index.tsx          # Assigned programs
      [programId].tsx    # Workout selection
      log.tsx            # Workout logging
    history/
      index.tsx          # History list
      [id].tsx           # History detail
    progress.tsx
    settings.tsx
components/
  ui/                   # react-native-reusables (copied, not npm installed)
    Button.tsx
    Card.tsx
    Text.tsx
    Input.tsx
    Label.tsx
    Separator.tsx
    index.ts             # Barrel export
  LineChart.tsx
  BarChart.tsx
  SkeletonCard.tsx
  EmptyState.tsx
  ErrorBoundary.tsx
  CalendarHeatmap.tsx
  RestTimer.tsx
  PRCelebration.tsx
  WorkoutSummary.tsx
  StreakCounter.tsx
  AchievementBadge.tsx
lib/
  supabase.ts           # Supabase client + Clerk JWT wrapper (useSupabaseClient hook)
  validations/          # Zod schemas
    user.ts
    program.ts
    exercise.ts
    log.ts
  i18n/
    index.ts             # i18n-js setup, t() export
    en.json
    he.json
  utils/
    chartData.ts
  services/
    programs.ts          # Supabase CRUD for programs
    workouts.ts          # Supabase CRUD for workouts
    exercises.ts         # Supabase CRUD for exercises + alternatives
    assignments.ts       # Program assignment service
    invites.ts           # Invite code service
    logs.ts              # Workout log query service
    notifications.ts     # Push token registration + deep linking
    exerciseLibrary.ts   # Exercise library CRUD + search
    streaks.ts           # Streak tracking service
    achievements.ts      # Achievement unlocking service
    measurements.ts      # Body measurements CRUD
    goals.ts             # Goals CRUD + auto-progress
    foodItems.ts         # Food item search + CRUD
    mealLogs.ts          # Meal logging service
    messages.ts          # Direct messaging service
    marketplace.ts       # Marketplace listings service
hooks/
  usePrograms.ts         # TanStack Query hooks for programs
  useWorkouts.ts         # TanStack Query hooks for workouts
  useExercises.ts        # TanStack Query hooks for exercises
  useAssignments.ts      # TanStack Query hooks for assignments
  useEntitlements.ts     # RevenueCat premium check (useIsPremium, useCoachTier)
  useRealtimeLogs.ts     # Supabase Realtime subscriptions
  useExerciseLibrary.ts  # Exercise library queries
  useStreaks.ts           # Streak tracking hooks
  useAchievements.ts     # Achievement hooks
  useMeasurements.ts     # Body measurement hooks
  useGoals.ts            # Goals hooks
  useNutrition.ts        # Food + meal log hooks
  useMessages.ts         # Messaging hooks + Realtime
  useMarketplace.ts      # Marketplace hooks
  useRestTimer.ts        # Rest timer state + haptics
stores/
  uiStore.ts             # Zustand — UI-only state (cached role, language pref)
types/
  database.ts            # Auto-generated: supabase gen types typescript
supabase/
  migrations/            # SQL migration files (version-controlled)
  functions/
    clerk-webhook/       # Clerk → Supabase user sync (Deno)
    notify-comment/      # Push notification on coach comment (Deno)
    workout-reminder/    # Daily workout reminder (Deno, cron)
  config.toml
```

**Data Model (PostgreSQL — relational):**
- `users` — id (from Clerk), email, display_name, role (coach | trainee | admin), coach_id (FK → users), language
- `programs` — coach-created workout templates
- `workouts` — belong to programs, ordered by sort_order
- `exercises` — belong to workouts (separate table, not nested array), with type-based fields
- `exercise_alternatives` — belong to choice exercises, with choice_reason
- `exercises_library` — shared exercise database (name, muscle_group, equipment, description, video_url, is_custom, created_by)
- `workout_logs` — trainee workout entries with notes and coach_comment
- `completed_exercises` — belong to logs, reference exercise, optional chosen_alternative_id
- `completed_sets` — belong to completed_exercises, with reps/weight/duration/distance/rpe, is_pr
- `assignments` — links programs to trainees (unique constraint on trainee_id + program_id)
- `invites` — coach invitation flow (6-char alphanumeric codes)
- `push_tokens` — device tokens for Expo Push API
- `streaks` — workout streak tracking (user_id, current_streak, longest_streak, last_workout_date)
- `achievements` — gamification badges (user_id, achievement_type, unlocked_at)
- `body_measurements` — body_weight, body_fat_pct, chest, waist, hips, biceps (gated: Trainee Pro)
- `goals` — title, goal_type, target_value, current_value, unit, deadline, status
- `food_items` — food database with macros (gated: Trainee Pro)
- `meal_logs` + `meal_log_items` — daily nutrition tracking (gated: Trainee Pro)
- `messages` — direct messaging (sender_id, receiver_id, content, read_at, Supabase Realtime)
- `marketplace_listings` — coach program marketplace (program_id, price, description, is_published) (gated: Coach Business)

## Development Conventions

### TypeScript Strictness
- **Every story requires typecheck pass**: `npx tsc --noEmit`
- Use Supabase generated types (`Database` generic on client)
- Validate inputs with Zod schemas

### Data Fetching Pattern
```
Supabase service (lib/services/) → TanStack Query hook (hooks/) → Component
```
- Services handle raw Supabase queries (typed)
- TanStack Query hooks wrap services with caching, invalidation, mutations
- Components consume hooks — never call Supabase directly

### Auth Pattern
```
Clerk (auth provider) → JWT (supabase template) → Supabase client (RLS enforcement)
```
- `useSupabaseClient()` hook creates client with Clerk JWT
- RLS policies use `auth.uid()` to identify user
- User sync via Clerk webhook → Edge Function → `users` table

### Forms Pattern
```
React Hook Form + Zod schema → useForm({ resolver: zodResolver(schema) })
```
- All forms use React Hook Form for state management
- Zod schemas for validation (defined in `lib/validations/`)
- Form errors displayed inline using react-native-reusables `Input` + `Label`

### Styling & Design System
- **NativeWind** (Tailwind CSS) for all styling via `className` prop
- **Dark mode first** — default theme is dark (`#0F0F14` background, `#F0F0F5` text)
- **Neon green accent** — primary accent `#22C55E`, pressed `#16A34A`, glow `#22C55E33`
- **Inter font** via `@expo-google-fonts/inter`, text scale: hero/h1/h2/h3/body/caption
- **Component rules:** Cards use `bg-card rounded-2xl p-4`, no borders, 48px min tap targets, bottom sheets for secondary actions
- **Micro-interactions:** Reanimated animations + expo-haptics for set completion, PR detection, workout save, rest timer, streaks
- **react-native-reusables** for base UI components (Button, Card, Input, etc.)
- Components are copy-pasted into `components/ui/`, not npm installed
- RTL support via NativeWind `rtl:` prefix utilities
- Gold (`#FFD700`) for PR celebrations and achievements
- All number displays use `tabular-nums` font-variant

### Lists
- **FlashList** for all list screens (drop-in FlatList replacement)
- Always set `estimatedItemSize` for optimal performance

### State Management
- **TanStack Query** for ALL server/async state (fetching, caching, mutations)
- **Zustand** for UI-only state (cached user role, language preference, form UI toggles)
- Never use Zustand for server data — always TanStack Query

### i18n & RTL
- **ALL user-facing strings must use `t()` from `lib/i18n/index.ts`**
- Support Hebrew RTL via `I18nManager.forceRTL(true/false)` when locale changes
- Default language detected from `expo-localization`
- Keys must exist in both `en.json` and `he.json`
- NativeWind `rtl:` prefix for RTL-specific styles

### Story Sizing
- Each user story fits in **one AI context window (~10 minutes)**
- Examples: add one field, create one component, modify one endpoint
- If a story can't be described in 2-3 sentences, it's too large

### Dependency Ordering
Stories are sequenced to prevent forward dependencies:
1. SQL migrations → 2. Types generation → 3. Zod schemas → 4. Services → 5. TanStack Query hooks → 6. UI components

### Parallel Execution Strategy
The `ralph-parallel.sh` orchestrator runs phases in waves:

| Wave | Mode | Phases | Description |
|------|------|---------|-------------|
| A | sequential | 1-7 | Foundation + Design System + Exercise Library + Auth/Onboarding |
| B | parallel | 8, 9, 14, 15 | Monitoring + Trainee Programs + Settings + RevenueCat |
| C | parallel | 10, 13 | Logging (+ Timer + PRs) + Push Notifications |
| D | sequential | 11 | History (+ Calendar Heatmap) |
| E | sequential | 12 | Charts |
| F | sequential | 16, 17 | Polish + Haptics + Streaks & Gamification |
| G | parallel | 18, 19, 20 | Body Measurements + Goals + Nutrition |
| H | parallel | 21, 22 | Messaging + Marketplace |

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
- Use `expo-notifications` for push, `expo-localization` for i18n
- Expo Router for file-based navigation (not React Navigation)
- Web target is bonus, not required

### Supabase
- PostgreSQL relational database (not NoSQL)
- RLS (Row Level Security) enforces access control at the database level
- Edge Functions use **Deno runtime** (not Node.js)
- SQL migrations version-controlled in `supabase/migrations/`
- Types auto-generated via `supabase gen types`
- Realtime subscriptions for live updates (workout_logs table)

### Clerk
- Auth provider — handles sign-in, sign-up, session management
- JWT template "supabase" must be configured in Clerk Dashboard (manual step)
- User role stored in `unsafeMetadata.role`
- User sync to Supabase via webhook → Edge Function
- `expo-secure-store` for token caching

### TanStack Query
- Server state management (replaces Zustand for async data)
- Caching, background refetching, optimistic updates, mutation invalidation
- Persistence via AsyncStorage for offline support
- Configure `staleTime` and `gcTime` per query type

### Zustand
- **UI-only state** — never for server data
- Examples: cached user role, language preference, UI toggles
- Lightweight, no boilerplate

### NativeWind
- Tailwind CSS utility classes via `className` prop
- `tailwind.config.js` for theme customization
- `rtl:` prefix for RTL-specific styles
- `global.css` with Tailwind directives

### react-native-reusables
- shadcn/ui-inspired components for React Native
- **Copy-paste model** — components live in `components/ui/`, not npm installed
- Base components: Button, Card, Text, Input, Label, Separator
- Styled with NativeWind

### React Hook Form + Zod
- All forms use `useForm({ resolver: zodResolver(schema) })`
- Zod schemas in `lib/validations/`
- Schemas export inferred types via `z.infer<>`
- Inline validation errors displayed in forms

### RevenueCat
- Subscription/payment management with coach-first pricing model
- Tiers: Trainee Free, Trainee Pro ($9.99/mo), Coach Starter ($19.99/mo), Coach Pro ($49.99/mo), Coach Business ($99.99/mo)
- SDK initialized in root layout
- `useIsPremium()` hook for trainee entitlement checking
- `useCoachTier()` hook for coach tier checking
- `<PremiumGate>` component for feature gating
- Gated features: nutrition (Pro), body measurements (Pro), marketplace (Coach Business)
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
- Gesture Handler for drag-to-reorder exercises, swipe-to-delete
- expo-haptics for tactile feedback: `lib/utils/haptics.ts` wrapper functions
- Haptic moments defined in design system: set completion (light), PR (heavy), workout save (medium), timer (notification), streaks (success)
- Web platform gracefully no-ops for haptics

## Critical Anti-Patterns

❌ **Do NOT:**
- Implement multiple stories in one cycle
- Mark tasks complete without validation passing
- Hardcode user-facing strings (must use `t()`)
- Guess at ambiguous requirements (use question protocol)
- Create oversized stories (split if needed)
- Use Zustand for server/async data (use TanStack Query)
- Call Supabase directly from components (use service → hook pattern)
- Use FlatList (use FlashList)
- Use React Navigation (use Expo Router)
- Use StyleSheet (use NativeWind `className`)
- Install react-native-reusables via npm (copy components into `components/ui/`)
- Run in Expo Go (use EAS dev builds)
- Write Edge Functions in Node.js (use Deno)
- Add code for deferred features (wearables, AI coaching, social feed, leaderboards)
- Skip haptic feedback on interaction moments defined in the design system
- Use pure white (#FFFFFF) for text — use off-white (#F0F0F5) instead
- Use borders in dark mode — use background color layers for depth

## When You're Uncertain

1. **Check PRD.md** for acceptance criteria details
2. **Read progress files** for past learnings and traps
3. **Ask a question** using `<question>` tags if still unclear
4. **Reference the .claude/skills/prd/SKILL.md** for PRD creation guidelines (not for implementation)

## Current State

📋 **Planning phase** — PRD complete (~122 user stories across 22 phases), no source code yet. First implementation cycle starts with US-001 (Initialize Expo project with Expo Router). Revenue model defined (coach-first pricing with 5 tiers). Dark-mode-first design system specified with neon green accent palette.
