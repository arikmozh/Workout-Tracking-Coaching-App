# PRD: Workout Tracking & Coaching App

## Introduction

A mobile app that enables personal trainers (coaches) to create and assign workout programs to their clients (trainees), and lets trainees log workouts flexibly — not tied to specific days of the week. Coaches get full visibility into client progress with commenting and charting. Trainees follow a checklist-style interface, log sets/reps/weights/time/distance, add notes, and see history and progress charts.

The app features a dark-mode-first design system with neon green accents, an exercise library, rest timers, PR auto-detection with celebrations, streaks & gamification, body measurements, nutrition tracking, goals, direct messaging, and a coach marketplace. It is bilingual (Hebrew + English) with full RTL support from day one.

Built with Expo (managed workflow), Supabase (PostgreSQL + Edge Functions), Clerk (auth), TanStack Query (server state), Zustand (UI state), NativeWind (styling), react-native-reusables (UI components), React Native Reanimated (animations), and expo-haptics (tactile feedback). Monetized via a coach-first pricing model with RevenueCat subscriptions.

## Goals

- Enable coaches to create flexible, reusable workout programs with choice exercises and coach notes
- Allow trainees to freely pick which workout to do on any day and log it via a checklist UI
- Provide full workout history with search, filtering, and progress charts for both roles
- Support Hebrew (RTL) and English from launch
- Deliver push notifications for engagement (workout reminders, coach comments, milestones)
- Ensure offline-capable logging via TanStack Query persistence
- Ship a working MVP that the founder can validate with existing clients
- Monetize via RevenueCat subscriptions with coach-first pricing model
- Provide streaks, achievements, and gamification to drive retention
- Support nutrition tracking, body measurements, and goals for holistic fitness
- Enable direct messaging between coaches and trainees
- Offer a coach marketplace for selling programs

## Revenue Model

### Coach-First Pricing (Trainerize/TrueCoach model)

| Tier | Price | Access |
|------|-------|--------|
| **Trainee Free** | $0 | Log workouts, view programs, basic history |
| **Trainee Pro** | $9.99/mo | Nutrition tracking, progress charts, body measurements, streaks, unlimited history |
| **Coach Starter** | $19.99/mo | Up to 5 clients, program builder, monitoring |
| **Coach Pro** | $49.99/mo | Up to 25 clients, analytics, push notifications |
| **Coach Business** | $99.99/mo | Unlimited clients, marketplace, branded experience |

RevenueCat (Phase 15) handles all subscriptions. Entitlement checks via `useIsPremium()` and `useCoachTier()`.

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Expo (managed workflow) + TypeScript strict |
| Auth | Clerk |
| Database | Supabase PostgreSQL (relational) |
| Serverless | Supabase Edge Functions (Deno) |
| Security | Supabase RLS (Row Level Security) |
| Push Notifications | Expo Push Notifications + Supabase |
| Navigation | Expo Router (file-based) |
| Server State | TanStack Query |
| Client State | Zustand (UI-only) |
| Forms | React Hook Form + Zod |
| Lists | FlashList |
| Styling | NativeWind (Tailwind CSS) |
| UI Components | react-native-reusables (shadcn/ui-inspired, copy-paste) |
| Animations | React Native Reanimated |
| Haptics | expo-haptics |
| Gestures | React Native Gesture Handler |
| Error Monitoring | Sentry |
| Payments | RevenueCat |
| Validation | Zod |
| i18n | i18n-js + expo-localization |
| Charts | Victory Native or react-native-chart-kit |

## UX Design System

### Color Palette — Dark + Neon Green

Dark mode with neon green: most popular in gym fitness apps, saves battery on OLED screens, reduces glare in dimly-lit gyms, and green signals "go/progress/growth."

```
tailwind.config.js theme:

colors: {
  background: {
    DEFAULT: '#0F0F14',     // Deep dark — main screen bg
    card: '#1A1A24',         // Cards, list items
    elevated: '#252532',     // Bottom sheets, modals
    input: '#2A2A3A',        // Text input backgrounds
  },
  foreground: {
    DEFAULT: '#F0F0F5',      // Primary text (off-white, NOT pure white)
    muted: '#9CA3AF',        // Secondary text, descriptions
    subtle: '#6B7280',       // Timestamps, hints, placeholders
  },
  accent: {
    DEFAULT: '#22C55E',      // Primary green — buttons, progress, active
    pressed: '#16A34A',      // Pressed/hover state
    glow: '#22C55E33',       // 20% opacity glow behind accent elements
  },
  gold: '#FFD700',            // PR celebrations, achievements
  destructive: '#EF4444',    // Delete, errors
  warning: '#F59E0B',        // Streaks approaching, limits
  info: '#3B82F6',           // Links, informational badges
}
```

### Typography — Inter

```
fontFamily: {
  sans: ['Inter'],
}

Text scale:
  hero:     text-4xl font-bold    (36px — PR numbers, timer display)
  h1:       text-2xl font-semibold (24px — screen titles)
  h2:       text-xl font-semibold  (20px — section headers)
  h3:       text-base font-semibold (16px — card titles)
  body:     text-sm font-normal    (14px — descriptions)
  caption:  text-xs font-normal    (12px — timestamps, hints)

All numbers use tabular-nums (digits don't shift as values change)
```

### Component Design Rules

1. **Cards** — `bg-card rounded-2xl p-4` — no borders, just background contrast
2. **Bottom sheets** — All secondary actions (pickers, filters, confirmations). Never full-screen modals.
3. **Tap targets** — 48px minimum, 56px+ during workout logging
4. **One-thumb operation** — Primary actions always in bottom half of screen
5. **Oversized numbers** — Weight/rep displays use hero size (36px bold)
6. **Generous spacing** — 16px card padding, 24px section gaps
7. **Gradient CTAs** — Primary buttons: subtle green-to-emerald gradient
8. **No borders in dark mode** — Use background color layers for depth instead

### Micro-Interactions (Reanimated + expo-haptics)

| Moment | Animation | Haptic |
|--------|-----------|--------|
| Set completed | Checkbox scale bounce (1→1.2→1) + row green flash | Light impact |
| PR detected | Gold confetti burst + "NEW PR" badge slide-in + number glow | Heavy impact |
| Workout saved | Checkmark draw + card flip to summary | Medium impact |
| Rest timer 3-2-1 | Number scale pulse + circular ring progress | Tick per second |
| Timer expired | "Next Set" button pulsing green glow | Notification |
| Exercise expand/collapse | Spring height animation (300ms) | Selection |
| Streak milestone | Fire particle burst + counter increment animation | Success |
| Achievement unlocked | Full-screen badge reveal with radial glow | Success |
| Pull to refresh | Custom spring pull indicator | None |
| Swipe to delete | Row slides, red bg reveal, bounce-back on cancel | Warning |

### Screen-by-Screen UX Highlights

**Workout Logging (the money screen — max 3 taps from app open):**
- Exercise cards: muted "Last: 80kg × 8" above inputs
- Pre-filled set values from last workout
- One-tap set completion with checkbox bounce
- Floating rest timer overlay (doesn't block logging)
- Progress bar at top fills green as exercises complete
- Sticky "Save Workout" button at bottom showing live volume total

**Dashboard:**
- Streak flame counter at top (animated)
- "Today's Workout" suggestion card (from assigned program)
- Weekly activity rings (Apple Watch-inspired)
- Recent PRs horizontal carousel (gold badges)
- Unread coach comments notification card

**History:**
- Calendar heatmap at top (green squares = workout days, like GitHub)
- Date-grouped list below
- Cards: workout name, exercise count, total volume, PR badges
- Search bar + program filter chips

**Progress:**
- Swipeable chart cards (strength, volume, frequency)
- Time range chips (1W / 1M / 3M / 6M / 1Y)
- "Best Lifts" summary at top (exercise → max weight)
- Body measurement trends tab (if Pro)

## Data Model (PostgreSQL)

Relational tables with foreign keys:

- `users` — id (from Clerk), email, display_name, role (coach | trainee | admin), coach_id (FK → users), language, created_at, updated_at
- `programs` — id, coach_id (FK → users), name, description, created_at, updated_at
- `workouts` — id, program_id (FK → programs), name, sort_order, created_at, updated_at
- `exercises` — id, workout_id (FK → workouts), name, type (strength | cardio | timed), sets, reps, weight, duration, distance, rest_seconds, notes, is_choice, sort_order
- `exercise_alternatives` — id, exercise_id (FK → exercises), name, sets, reps, weight, duration, distance, choice_reason, sort_order
- `assignments` — id, trainee_id (FK → users), program_id (FK → programs), coach_id (FK → users), assigned_at
- `invites` — id, code (unique), coach_id (FK → users), used, trainee_id (FK → users, nullable), created_at
- `workout_logs` — id, trainee_id (FK → users), program_id (FK → programs), workout_id (FK → workouts), date, notes, coach_comment, created_at
- `completed_exercises` — id, log_id (FK → workout_logs), exercise_id (FK → exercises), exercise_name, chosen_alternative_id (FK → exercise_alternatives, nullable), notes, sort_order
- `completed_sets` — id, completed_exercise_id (FK → completed_exercises), set_number, reps, weight, duration, distance, rpe, completed, is_pr (bool default false), notes
- `push_tokens` — id, user_id (FK → users), token, platform, created_at
- `exercises_library` — id, name, muscle_group (text), equipment (text), description, video_url, is_custom (bool default false), created_by (uuid FK → users, nullable), created_at
- `streaks` — id, user_id (FK → users), current_streak (int), longest_streak (int), last_workout_date (date), updated_at
- `achievements` — id, user_id (FK → users), achievement_type (text), unlocked_at (timestamptz)
- `body_measurements` — id, user_id (FK → users), date, body_weight (numeric), body_fat_pct (numeric), chest (numeric), waist (numeric), hips (numeric), biceps (numeric), created_at
- `goals` — id, user_id (FK → users), title, goal_type (text check strength/measurement/habit/custom), target_value (numeric), current_value (numeric), unit (text), deadline (date nullable), status (text check active/completed/abandoned), created_at, updated_at
- `food_items` — id, name, calories (numeric), protein (numeric), carbs (numeric), fat (numeric), serving_size (text), is_custom (bool default false), created_by (uuid FK → users, nullable), created_at
- `meal_logs` — id, user_id (FK → users), date, meal_type (text check breakfast/lunch/dinner/snack), created_at
- `meal_log_items` — id, meal_log_id (FK → meal_logs ON DELETE CASCADE), food_item_id (FK → food_items), quantity (numeric), calories (numeric), protein (numeric), carbs (numeric), fat (numeric)
- `messages` — id, sender_id (FK → users), receiver_id (FK → users), content (text), read_at (timestamptz nullable), created_at
- `marketplace_listings` — id, program_id (FK → programs), coach_id (FK → users), price (numeric), description (text), is_published (bool default false), preview_image (text nullable), created_at, updated_at

## Project Structure

```
app/                    # Expo Router file-based routing
  _layout.tsx           # Root layout (Clerk + Supabase + TanStack Query providers)
  (auth)/               # Auth screens (sign-in, sign-up)
  (coach)/              # Coach tab group
    _layout.tsx          # Coach bottom tabs
    dashboard.tsx
    programs/
    clients/
    messages/             # Direct messaging
    marketplace/          # Coach marketplace (Coach Business)
    settings.tsx
  (trainee)/            # Trainee tab group
    _layout.tsx          # Trainee bottom tabs
    programs/
    history/
    progress.tsx
    measurements/         # Body measurements (Trainee Pro)
    nutrition/            # Nutrition tracking (Trainee Pro)
    goals/                # Goals system
    messages/             # Direct messaging
    settings.tsx
components/
  ui/                   # react-native-reusables (copied, not npm)
lib/
  supabase.ts           # Supabase client + Clerk JWT wrapper
  validations/          # Zod schemas
  i18n/                 # i18n-js setup, en.json, he.json
  utils/                # chartData.ts, etc.
  services/             # Supabase service modules
hooks/                  # TanStack Query hooks
stores/                 # Zustand (UI state only)
types/                  # Generated from Supabase (supabase gen types)
supabase/
  migrations/           # SQL migration files
  functions/            # Edge Functions (Deno)
```

## User Stories

---

### Phase 1: Project Setup

---

### US-001: Initialize Expo project with Expo Router

**Description:** As a developer, I want to scaffold a new Expo project with TypeScript and Expo Router so that the team has a clean starting point with file-based routing.

**Acceptance Criteria:**
- [ ] Run `npx create-expo-app` with the Expo Router TypeScript template
- [ ] Project runs on iOS, Android, and web with the default screen
- [ ] `tsconfig.json` is present with strict mode enabled
- [ ] `app/` directory exists with `_layout.tsx` and `index.tsx`
- [ ] Expo Router file-based navigation works (navigating between two screens)
- [ ] Typecheck passes

---

### US-002: Configure NativeWind

**Description:** As a developer, I want to install and configure NativeWind (Tailwind CSS for React Native) so that all components can use Tailwind utility classes.

**Acceptance Criteria:**
- [ ] `nativewind` and `tailwindcss` installed and configured
- [ ] `tailwind.config.js` created with content paths pointing to `app/`, `components/`, `lib/`
- [ ] Babel preset configured for NativeWind
- [ ] `global.css` with Tailwind directives imported in root layout
- [ ] A test component renders correctly with NativeWind `className` prop
- [ ] Typecheck passes

---

### US-003: Set up react-native-reusables

**Description:** As a developer, I want to copy base UI components from react-native-reusables into `components/ui/` so that the app has consistent, accessible primitives styled with NativeWind.

**Acceptance Criteria:**
- [ ] `components/ui/` directory created with base components: `Button`, `Card`, `Text`, `Input`, `Label`, `Separator`
- [ ] Components use NativeWind `className` for styling
- [ ] Components export from `components/ui/index.ts` barrel file
- [ ] A test screen renders each component without errors
- [ ] Typecheck passes

---

### US-004: Configure Supabase client

**Description:** As a developer, I want to initialize the Supabase client with a config module so that all services share a single Supabase instance.

**Acceptance Criteria:**
- [ ] `@supabase/supabase-js` installed
- [ ] `lib/supabase.ts` exports a configured Supabase client
- [ ] Supabase URL and anon key loaded from environment variables (no secrets committed)
- [ ] `.env.local` added to `.gitignore`
- [ ] Importing `lib/supabase.ts` does not crash the app
- [ ] Typecheck passes

---

### US-005: Initialize Sentry

**Description:** As a developer, I want to set up Sentry error monitoring so that runtime errors are captured and reported automatically.

**Acceptance Criteria:**
- [ ] `@sentry/react-native` installed
- [ ] Sentry initialized in root layout with DSN from environment variable
- [ ] EAS build plugin configured in `app.config.ts` for source maps
- [ ] A test error is captured and visible in the Sentry dashboard
- [ ] Typecheck passes

---

### US-006: Set up EAS development builds

**Description:** As a developer, I want to configure EAS Build with a development profile so that native modules (Clerk, Sentry, RevenueCat) work on physical devices.

**Acceptance Criteria:**
- [ ] `eas.json` created with `development`, `preview`, and `production` build profiles
- [ ] `npx eas build --profile development --platform ios` (or android) runs without config errors
- [ ] Development build installs on a registered device and launches
- [ ] Note in README: Expo Go is NOT supported — use EAS dev builds
- [ ] Typecheck passes

---

### US-007: Set up linting, path aliases, and project structure

**Description:** As a developer, I want ESLint, Prettier, and path aliases configured so that the codebase stays consistent and imports are clean.

**Acceptance Criteria:**
- [ ] ESLint + Prettier configured with a React Native–compatible ruleset
- [ ] Path alias `@/` resolves to project root in both `tsconfig.json` and bundler config
- [ ] Folder structure created: `components/ui/`, `lib/services/`, `lib/validations/`, `lib/i18n/`, `lib/utils/`, `hooks/`, `stores/`, `types/`, `supabase/migrations/`, `supabase/functions/`
- [ ] `npm run lint` passes with zero errors
- [ ] Typecheck passes

---

### US-082: Configure dark mode design system

**Description:** As a developer, I want to configure the NativeWind/Tailwind theme with the full dark mode color palette, Inter font, and text scale so that all subsequent UI work uses consistent design tokens.

**Acceptance Criteria:**
- [ ] `tailwind.config.js` extended with full color token set: `background` (DEFAULT `#0F0F14`, card `#1A1A24`, elevated `#252532`, input `#2A2A3A`), `foreground` (DEFAULT `#F0F0F5`, muted `#9CA3AF`, subtle `#6B7280`), `accent` (DEFAULT `#22C55E`, pressed `#16A34A`, glow `#22C55E33`), `gold` (`#FFD700`), `destructive` (`#EF4444`), `warning` (`#F59E0B`), `info` (`#3B82F6`)
- [ ] Font family set to Inter: `fontFamily: { sans: ['Inter'] }`
- [ ] Text scale utilities defined: `hero` (text-4xl font-bold), `h1` (text-2xl font-semibold), `h2` (text-xl font-semibold), `h3` (text-base font-semibold), `body` (text-sm font-normal), `caption` (text-xs font-normal)
- [ ] `@expo-google-fonts/inter` installed and loaded in root layout
- [ ] `global.css` updated with dark mode as default
- [ ] All number displays configured with `tabular-nums` font-variant
- [ ] Typecheck passes

---

### US-083: Add expo-haptics to project dependencies

**Description:** As a developer, I want `expo-haptics` installed and a utility wrapper created so that haptic feedback can be triggered throughout the app.

**Acceptance Criteria:**
- [ ] `expo-haptics` installed via `npx expo install expo-haptics`
- [ ] `lib/utils/haptics.ts` exports wrapper functions: `hapticLight()`, `hapticMedium()`, `hapticHeavy()`, `hapticSelection()`, `hapticSuccess()`, `hapticWarning()`, `hapticNotification()`
- [ ] Each wrapper calls the corresponding `Haptics.impactAsync()` or `Haptics.notificationAsync()` method
- [ ] Web platform gracefully no-ops (no crash if haptics not supported)
- [ ] Typecheck passes

---

### US-084: Create theme provider with dark/light toggle support

**Description:** As a developer, I want a theme context provider that supports dark and light modes so that users can switch themes and the app defaults to dark mode.

**Acceptance Criteria:**
- [ ] `lib/theme/ThemeProvider.tsx` exports a React context provider wrapping the app
- [ ] Provides `theme` (dark | light), `toggleTheme()`, and `isDark` boolean
- [ ] Default theme is `dark`
- [ ] Theme preference persisted via AsyncStorage
- [ ] NativeWind `dark:` prefix utilities work correctly based on current theme
- [ ] Provider added to root `_layout.tsx`
- [ ] Typecheck passes

---

### Phase 2: Database Schema & Types

---

### US-008: Create SQL migrations for user and program tables

**Description:** As a developer, I want Supabase SQL migrations for `users`, `programs`, and `workouts` tables so that the relational schema is version-controlled.

**Acceptance Criteria:**
- [ ] Migration file creates `users` table with columns: `id` (uuid PK), `email` (text unique), `display_name` (text), `role` (text check coach/trainee/admin), `coach_id` (uuid FK → users, nullable), `language` (text default 'en'), `created_at` (timestamptz), `updated_at` (timestamptz)
- [ ] Migration creates `programs` table with columns: `id` (uuid PK), `coach_id` (uuid FK → users), `name` (text not null), `description` (text), `created_at`, `updated_at`
- [ ] Migration creates `workouts` table with columns: `id` (uuid PK), `program_id` (uuid FK → programs ON DELETE CASCADE), `name` (text not null), `sort_order` (int), `created_at`, `updated_at`
- [ ] All tables have `updated_at` trigger for auto-update
- [ ] Migration runs successfully against Supabase: `supabase db push`
- [ ] Typecheck passes

---

### US-009: Create SQL migrations for exercise tables

**Description:** As a developer, I want SQL migrations for `exercises` and `exercise_alternatives` tables so that workout structure is fully relational.

**Acceptance Criteria:**
- [ ] Migration creates `exercises` table with columns: `id` (uuid PK), `workout_id` (uuid FK → workouts ON DELETE CASCADE), `name` (text not null), `type` (text check strength/cardio/timed), `sets` (int), `reps` (int nullable), `weight` (numeric nullable), `duration` (int nullable), `distance` (numeric nullable), `rest_seconds` (int nullable), `notes` (text nullable), `is_choice` (bool default false), `sort_order` (int)
- [ ] Migration creates `exercise_alternatives` table with columns: `id` (uuid PK), `exercise_id` (uuid FK → exercises ON DELETE CASCADE), `name` (text not null), `sets` (int), `reps` (int nullable), `weight` (numeric nullable), `duration` (int nullable), `distance` (numeric nullable), `choice_reason` (text nullable), `sort_order` (int)
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-010: Create SQL migrations for logging tables

**Description:** As a developer, I want SQL migrations for `workout_logs`, `completed_exercises`, and `completed_sets` tables so that trainee workout data is stored relationally.

**Acceptance Criteria:**
- [ ] Migration creates `workout_logs` table with columns: `id` (uuid PK), `trainee_id` (uuid FK → users), `program_id` (uuid FK → programs), `workout_id` (uuid FK → workouts), `date` (date not null), `notes` (text nullable), `coach_comment` (text nullable), `created_at` (timestamptz)
- [ ] Migration creates `completed_exercises` table with columns: `id` (uuid PK), `log_id` (uuid FK → workout_logs ON DELETE CASCADE), `exercise_id` (uuid FK → exercises), `exercise_name` (text), `chosen_alternative_id` (uuid FK → exercise_alternatives nullable), `notes` (text nullable), `sort_order` (int)
- [ ] Migration creates `completed_sets` table with columns: `id` (uuid PK), `completed_exercise_id` (uuid FK → completed_exercises ON DELETE CASCADE), `set_number` (int), `reps` (int nullable), `weight` (numeric nullable), `duration` (int nullable), `distance` (numeric nullable), `rpe` (int nullable check 1-10), `completed` (bool default false), `notes` (text nullable)
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-011: Create SQL migrations for assignment, invite, and push token tables

**Description:** As a developer, I want SQL migrations for `assignments`, `invites`, and `push_tokens` tables so that coach–trainee relationships and notifications are supported.

**Acceptance Criteria:**
- [ ] Migration creates `assignments` table with columns: `id` (uuid PK), `trainee_id` (uuid FK → users), `program_id` (uuid FK → programs), `coach_id` (uuid FK → users), `assigned_at` (timestamptz)
- [ ] Migration creates `invites` table with columns: `id` (uuid PK), `code` (text unique not null), `coach_id` (uuid FK → users), `used` (bool default false), `trainee_id` (uuid FK → users nullable), `created_at` (timestamptz)
- [ ] Migration creates `push_tokens` table with columns: `id` (uuid PK), `user_id` (uuid FK → users), `token` (text not null), `platform` (text), `created_at` (timestamptz)
- [ ] Unique constraint on `assignments(trainee_id, program_id)`
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-012: Generate TypeScript types from Supabase

**Description:** As a developer, I want auto-generated TypeScript types from the Supabase schema so that all database queries are type-safe.

**Acceptance Criteria:**
- [ ] `supabase gen types typescript --local > types/database.ts` generates types
- [ ] `types/database.ts` exports `Database` type with all table definitions
- [ ] Helper types exported: `Tables<T>`, `Enums<T>`, `TablesInsert<T>`, `TablesUpdate<T>`
- [ ] Supabase client in `lib/supabase.ts` uses `Database` generic parameter
- [ ] Script added to `package.json`: `"db:types": "supabase gen types typescript --local > types/database.ts"`
- [ ] Typecheck passes

---

### US-085: Create SQL migration for exercises_library table

**Description:** As a developer, I want an `exercises_library` table so that the app has a shared database of exercises that coaches and trainees can browse and pick from.

**Acceptance Criteria:**
- [ ] Migration creates `exercises_library` table with columns: `id` (uuid PK), `name` (text not null), `muscle_group` (text not null), `equipment` (text), `description` (text), `video_url` (text nullable), `is_custom` (bool default false), `created_by` (uuid FK → users, nullable), `created_at` (timestamptz)
- [ ] Index on `muscle_group` for filtered queries
- [ ] Index on `name` for search queries
- [ ] RLS policy: all authenticated users can SELECT; users can INSERT/UPDATE/DELETE only rows where `created_by = auth.uid()` and `is_custom = true`
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-086: Seed exercises_library with common exercises

**Description:** As a developer, I want the exercises library seeded with ~50 common exercises so that coaches and trainees have a useful starting set.

**Acceptance Criteria:**
- [ ] Seed migration inserts ~50 exercises covering major muscle groups: chest (bench press, incline press, dumbbell fly, push-up, cable crossover), back (pull-up, barbell row, seated row, lat pulldown, deadlift), shoulders (overhead press, lateral raise, face pull, front raise, arnold press), legs (squat, leg press, lunges, leg curl, leg extension, calf raise, Romanian deadlift), arms (bicep curl, hammer curl, tricep pushdown, skull crusher, dip), core (plank, crunch, hanging leg raise, Russian twist, ab wheel)
- [ ] Each exercise has `name`, `muscle_group`, `equipment` (barbell/dumbbell/cable/machine/bodyweight), and `description`
- [ ] `is_custom` is false for all seeded exercises
- [ ] `created_by` is null for all seeded exercises
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-087: Create exercise library Supabase service and TanStack Query hooks

**Description:** As a developer, I want a service module and TanStack Query hooks for the exercise library so that screens can search, filter, and display exercises.

**Acceptance Criteria:**
- [ ] `lib/services/exerciseLibrary.ts` exports `getExercises(filters?)`, `searchExercises(query)`, `getExercisesByMuscleGroup(group)`, `createCustomExercise(data)`, `deleteCustomExercise(id)`
- [ ] `hooks/useExerciseLibrary.ts` exports `useExercises(filters?)`, `useSearchExercises(query)`, `useExercisesByMuscleGroup(group)`, `useCreateCustomExercise`, `useDeleteCustomExercise`
- [ ] Search supports partial name matching (ILIKE)
- [ ] Mutations invalidate `['exercises_library']` query key
- [ ] All functions use the authenticated Supabase client
- [ ] Typecheck passes

---

### US-013: Create Zod validation schemas

**Description:** As a developer, I want Zod schemas for form validation and API input validation so that data integrity is enforced at the application layer.

**Acceptance Criteria:**
- [ ] `lib/validations/user.ts` exports Zod schemas: `signUpSchema` (email, password, displayName, role), `profileUpdateSchema`
- [ ] `lib/validations/program.ts` exports: `programSchema` (name required, description optional), `workoutSchema` (name required)
- [ ] `lib/validations/exercise.ts` exports: `exerciseSchema` (name, type, sets required; reps/weight/duration/distance conditional on type), `alternativeSchema`
- [ ] `lib/validations/log.ts` exports: `completedSetSchema`, `completedExerciseSchema`, `workoutLogSchema`
- [ ] All schemas export inferred TypeScript types via `z.infer<>`
- [ ] Typecheck passes

---

### Phase 3: Authentication

---

### US-014: Set up Clerk provider

**Description:** As a developer, I want to wrap the app in a Clerk provider so that authentication is available throughout the component tree.

**Acceptance Criteria:**
- [ ] `@clerk/clerk-expo` installed
- [ ] Root `_layout.tsx` wraps children in `<ClerkProvider publishableKey={...}>`
- [ ] Clerk publishable key loaded from environment variable
- [ ] `expo-secure-store` configured as Clerk's token cache
- [ ] App launches without errors with Clerk provider active
- [ ] Typecheck passes

---

### US-015: Build Sign In screen with Clerk

**Description:** As a user, I want a sign-in screen with email and password fields so that I can access my account.

**Acceptance Criteria:**
- [ ] `app/(auth)/sign-in.tsx` renders email input, password input, and "Sign In" button using react-native-reusables components
- [ ] Uses Clerk's `useSignIn` hook to authenticate
- [ ] Shows inline error on failure (invalid credentials, network error)
- [ ] "Don't have an account? Sign Up" link navigates to sign-up screen
- [ ] All visible strings use i18n keys (placeholder keys OK — i18n configured in Phase 4)
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-016: Build Sign Up screen with Clerk

**Description:** As a new user, I want a sign-up screen where I choose my role (coach or trainee) so that the system knows my capabilities.

**Acceptance Criteria:**
- [ ] `app/(auth)/sign-up.tsx` renders email, password, display name, and role selector (Coach / Trainee) using react-native-reusables components
- [ ] Uses Clerk's `useSignUp` hook to create an account
- [ ] Role stored in Clerk user metadata (`unsafeMetadata.role`)
- [ ] Shows inline error on failure
- [ ] "Already have an account? Sign In" link navigates back
- [ ] Validated with Zod `signUpSchema` via React Hook Form
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-017: Create Clerk-to-Supabase JWT wrapper

**Description:** As a developer, I want an authenticated Supabase client that uses Clerk JWTs so that RLS policies can identify the current user.

**Acceptance Criteria:**
- [ ] `lib/supabase.ts` exports `useSupabaseClient()` hook that creates a Supabase client with Clerk's JWT token in the Authorization header
- [ ] Uses Clerk's `useAuth().getToken({ template: 'supabase' })` to fetch JWT
- [ ] **Manual step documented:** Clerk Dashboard → JWT Templates → create "supabase" template with Supabase JWT secret
- [ ] Supabase client uses `auth.getUser()` to confirm JWT is valid
- [ ] Typecheck passes

---

### US-018: Create user sync webhook (Edge Function)

**Description:** As a developer, I want a Supabase Edge Function that receives Clerk webhooks and upserts users into the `users` table so that auth and database stay in sync.

**Acceptance Criteria:**
- [ ] `supabase/functions/clerk-webhook/index.ts` (Deno) handles Clerk `user.created` and `user.updated` webhook events
- [ ] Verifies webhook signature using Clerk's `svix` library
- [ ] Upserts into `users` table: id (from Clerk user ID), email, display_name, role (from `unsafeMetadata.role`)
- [ ] Returns 200 on success, 400 on invalid payload, 401 on bad signature
- [ ] Edge Function deploys: `supabase functions deploy clerk-webhook`
- [ ] Typecheck passes

---

### US-019: Add auth-gated Expo Router groups

**Description:** As a developer, I want the root layout to show auth screens when not logged in and the main app when logged in so that unauthenticated users cannot access the app.

**Acceptance Criteria:**
- [ ] Root `_layout.tsx` checks `useAuth().isSignedIn` from Clerk
- [ ] If not signed in, renders `(auth)` group (sign-in + sign-up screens)
- [ ] If signed in, redirects to `(coach)` or `(trainee)` group (placeholder screens for now)
- [ ] Shows a loading spinner while auth state is initializing (`isLoaded === false`)
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-020: Add basic RLS policies for authenticated access

**Description:** As a developer, I want RLS enabled on all tables with basic policies so that unauthenticated users have no access and users can read their own profile.

**Acceptance Criteria:**
- [ ] Migration enables RLS on all tables: `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`
- [ ] `users` table: users can SELECT their own row (`auth.uid() = id`)
- [ ] All other tables: authenticated users have basic SELECT access (will be tightened in later phases)
- [ ] Helper function created: `auth.uid()` extracts user ID from Supabase JWT (Clerk-issued)
- [ ] Unauthenticated requests return zero rows
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-088: Build onboarding wizard

**Description:** As a new user, I want a quick onboarding flow after sign-up that captures my role, optional trainer code, fitness goal, and unit preference so that the app is personalized from the start.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding.tsx` renders a 4-step wizard: (1) Role selection (Coach/Trainee), (2) Trainer code entry (optional, for trainees to link to a coach), (3) Goal quick-pick (build muscle, lose fat, get stronger, stay active, custom), (4) Unit preference (metric kg/cm or imperial lbs/in)
- [ ] Each step is a single screen with clear "Next" / "Back" navigation
- [ ] Total flow completable in under 60 seconds
- [ ] Goal and unit preference saved to Supabase `users` table (new columns: `goal`, `unit_preference`)
- [ ] If trainer code entered, calls `redeemInviteCode` to link trainee to coach
- [ ] Skip option available for optional steps
- [ ] Wizard triggers after first sign-up, before entering main app
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-089: Add Google and Apple OAuth sign-in options

**Description:** As a user, I want to sign in with Google or Apple in addition to email/password so that onboarding is faster and more convenient.

**Acceptance Criteria:**
- [ ] Sign-in and sign-up screens include "Continue with Google" and "Continue with Apple" buttons
- [ ] Uses Clerk's `useOAuth` hook with `strategy: 'oauth_google'` and `strategy: 'oauth_apple'`
- [ ] Apple sign-in button only shown on iOS
- [ ] OAuth flow completes and creates user in Clerk, triggering the existing webhook sync to Supabase
- [ ] On first OAuth sign-in, redirects to onboarding wizard (US-088)
- [ ] Error states handled (cancelled, network error)
- [ ] Buttons styled per platform guidelines (Apple: black button, Google: white with logo)
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 4: i18n & RTL

---

### US-021: Set up i18n with Hebrew and English

**Description:** As a user, I want the app to display in my preferred language (Hebrew or English) so that I can use the app comfortably.

**Acceptance Criteria:**
- [ ] `lib/i18n/index.ts` initializes `i18n-js` with `he` and `en` translation objects
- [ ] `lib/i18n/en.json` and `lib/i18n/he.json` contain initial keys for auth screens (signIn, signUp, email, password, etc.)
- [ ] Default language detected from device locale via `expo-localization`
- [ ] `t()` helper exported for use in components
- [ ] Typecheck passes

---

### US-022: Enable RTL toggle

**Description:** As a Hebrew-speaking user, I want the app to render in RTL layout when Hebrew is selected so that the UI feels natural.

**Acceptance Criteria:**
- [ ] `I18nManager.forceRTL(true)` called when locale is `he`
- [ ] `I18nManager.forceRTL(false)` called when locale is `en`
- [ ] Layout direction visually flips (navigation, text alignment, icons) when language changes
- [ ] NativeWind RTL utilities work correctly (`rtl:` prefix)
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 5: Navigation Shell

---

### US-023: Build Coach tab layout

**Description:** As a coach, I want a bottom tab navigator with tabs for Dashboard, Programs, Clients, and Settings so that I can navigate between coach features.

**Acceptance Criteria:**
- [ ] `app/(coach)/_layout.tsx` defines a bottom tab layout using Expo Router `Tabs`
- [ ] Four tabs: Dashboard, Programs, Clients, Settings — each with placeholder screen content
- [ ] Tab labels use i18n keys
- [ ] Tab icons are present (Lucide or any icon library compatible with react-native-reusables)
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-024: Build Trainee tab layout

**Description:** As a trainee, I want a bottom tab navigator with tabs for My Programs, History, Progress, and Settings so that I can navigate between trainee features.

**Acceptance Criteria:**
- [ ] `app/(trainee)/_layout.tsx` defines a bottom tab layout using Expo Router `Tabs`
- [ ] Four tabs: My Programs, History, Progress, Settings — each with placeholder screen content
- [ ] Tab labels use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-025: Route to correct tabs by role

**Description:** As a developer, I want the root layout to route authenticated users to the Coach or Trainee tab group based on their role so that each role sees only relevant screens.

**Acceptance Criteria:**
- [ ] Root layout reads user role from Supabase `users` table after Clerk auth
- [ ] Coach users are redirected to `/(coach)/dashboard`
- [ ] Trainee users are redirected to `/(trainee)/programs`
- [ ] Role is fetched once on auth and cached in a Zustand UI store
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 6: Coach – Program CRUD

---

### US-026: Create program Supabase service

**Description:** As a developer, I want a service module for CRUD operations on programs in Supabase so that screens can call simple functions.

**Acceptance Criteria:**
- [ ] `lib/services/programs.ts` exports `createProgram`, `getProgram`, `getCoachPrograms`, `updateProgram`, `deleteProgram`
- [ ] All functions use the authenticated Supabase client (from `useSupabaseClient`)
- [ ] `getCoachPrograms` filters by `coach_id`
- [ ] Functions return typed data using generated Supabase types
- [ ] Typecheck passes

---

### US-027: Create workout Supabase service

**Description:** As a developer, I want a service module for CRUD operations on workouts in Supabase so that the workout editor can persist data.

**Acceptance Criteria:**
- [ ] `lib/services/workouts.ts` exports `createWorkout`, `getWorkout`, `getWorkoutsByProgram`, `updateWorkout`, `deleteWorkout`
- [ ] `getWorkoutsByProgram` orders by `sort_order`
- [ ] All functions use the authenticated Supabase client
- [ ] Typecheck passes

---

### US-028: Create exercise Supabase service

**Description:** As a developer, I want a service module for CRUD operations on exercises and exercise alternatives in Supabase so that the exercise editor can persist data.

**Acceptance Criteria:**
- [ ] `lib/services/exercises.ts` exports `createExercise`, `getExercisesByWorkout`, `updateExercise`, `deleteExercise`, `reorderExercises`
- [ ] `lib/services/exercises.ts` also exports `createAlternative`, `getAlternatives`, `updateAlternative`, `deleteAlternative`
- [ ] `getExercisesByWorkout` orders by `sort_order` and includes alternatives
- [ ] All functions use the authenticated Supabase client
- [ ] Typecheck passes

---

### US-029: Create TanStack Query hooks for programs

**Description:** As a developer, I want TanStack Query hooks for programs so that components can fetch and mutate program data with automatic caching and invalidation.

**Acceptance Criteria:**
- [ ] `@tanstack/react-query` installed and `QueryClientProvider` added to root layout
- [ ] `hooks/usePrograms.ts` exports `useCoachPrograms(coachId)` query hook
- [ ] `hooks/usePrograms.ts` exports `useProgram(id)` query hook
- [ ] `hooks/usePrograms.ts` exports `useCreateProgram`, `useUpdateProgram`, `useDeleteProgram` mutation hooks
- [ ] Mutations invalidate the `['programs']` query key on success
- [ ] Typecheck passes

---

### US-030: Create TanStack Query hooks for workouts and exercises

**Description:** As a developer, I want TanStack Query hooks for workouts and exercises so that the workout editor has reactive data.

**Acceptance Criteria:**
- [ ] `hooks/useWorkouts.ts` exports `useWorkoutsByProgram(programId)`, `useWorkout(id)`, `useCreateWorkout`, `useUpdateWorkout`, `useDeleteWorkout`
- [ ] `hooks/useExercises.ts` exports `useExercisesByWorkout(workoutId)`, `useCreateExercise`, `useUpdateExercise`, `useDeleteExercise`, `useReorderExercises`
- [ ] `hooks/useExercises.ts` exports `useCreateAlternative`, `useUpdateAlternative`, `useDeleteAlternative`
- [ ] Mutations invalidate relevant query keys
- [ ] Typecheck passes

---

### US-031: Build Programs list screen (coach)

**Description:** As a coach, I want to see a list of my programs so that I can manage and edit them.

**Acceptance Criteria:**
- [ ] `app/(coach)/programs/index.tsx` fetches and displays programs via `useCoachPrograms`
- [ ] List rendered with `FlashList` for performance
- [ ] Each list item shows program name and workout count (using react-native-reusables `Card`)
- [ ] A floating action button (FAB) navigates to the create form
- [ ] Tapping a program navigates to the program detail screen
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-032: Build Program create/edit form

**Description:** As a coach, I want a form to create or edit a program (name, description) so that I can define new training plans.

**Acceptance Criteria:**
- [ ] `app/(coach)/programs/form.tsx` renders name and description inputs using react-native-reusables `Input` and `Label`
- [ ] Form managed by React Hook Form with Zod `programSchema` validation
- [ ] In create mode, calls `useCreateProgram` mutation and navigates back on success
- [ ] In edit mode, pre-fills fields and calls `useUpdateProgram`
- [ ] Validates that name is non-empty before saving; shows inline validation errors
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-033: Build Program detail screen

**Description:** As a coach, I want a detail screen for a program that lists its workouts so that I can add, edit, or remove workouts.

**Acceptance Criteria:**
- [ ] `app/(coach)/programs/[id].tsx` shows program name, description, and list of workouts via `useWorkoutsByProgram`
- [ ] Workouts rendered with `FlashList`
- [ ] "Add Workout" button navigates to the workout form
- [ ] Tapping a workout navigates to the workout detail/exercise editor
- [ ] Delete workout option with confirmation dialog
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-034: Build Workout create/edit form

**Description:** As a coach, I want a form to create or edit a workout (name) within a program so that I can define individual training sessions.

**Acceptance Criteria:**
- [ ] `app/(coach)/programs/workout-form.tsx` renders a name input using React Hook Form + Zod `workoutSchema`
- [ ] In create mode, calls `useCreateWorkout` with the parent `programId`
- [ ] In edit mode, pre-fills name and calls `useUpdateWorkout`
- [ ] Navigates back to program detail on success
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-035: Build Exercise editor within workout

**Description:** As a coach, I want to add, edit, reorder, and remove exercises within a workout so that I can define the workout structure.

**Acceptance Criteria:**
- [ ] `app/(coach)/programs/exercise-editor.tsx` lists exercises via `useExercisesByWorkout`
- [ ] "Add Exercise" opens the exercise library picker (from `useExercises`) where coach can search/filter by muscle group, then select an exercise — or create a custom one
- [ ] Selected exercise auto-fills name and type from the library entry
- [ ] Fallback: coach can still type a custom exercise name if library doesn't have it (creates a custom library entry with `is_custom = true`)
- [ ] Inline form shows fields: type, sets, reps, weight, duration, distance, rest, notes — using React Hook Form + Zod `exerciseSchema`
- [ ] Input fields adapt to exercise type: strength shows reps + weight, cardio shows duration + distance, timed shows duration
- [ ] Exercises can be reordered via drag handle (React Native Gesture Handler) or up/down buttons
- [ ] Exercises can be deleted with confirmation
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-036: Add choice exercise support and RLS policies for programs

**Description:** As a coach, I want to mark an exercise as a "choice" and add alternatives. Also, RLS policies must restrict program/workout/exercise access to the owning coach.

**Acceptance Criteria:**
- [ ] Toggle "Choice exercise" switch on an exercise in the editor
- [ ] When enabled, shows an "Alternatives" section where coach can add 2–4 alternatives using `useCreateAlternative`
- [ ] Each alternative has name, sets/reps fields, and a `choice_reason` text field
- [ ] RLS policy on `programs`: coach can only CRUD their own programs (`coach_id = auth.uid()`)
- [ ] RLS policy on `workouts`: inherits access through `program_id` → `programs.coach_id`
- [ ] RLS policy on `exercises`: inherits access through `workout_id` → `workouts.program_id` → `programs.coach_id`
- [ ] RLS policy on `exercise_alternatives`: inherits access through `exercise_id` → `exercises`
- [ ] Trainees with assignments can SELECT programs/workouts/exercises (read-only)
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 7: Coach – Client Management

---

### US-037: Create invite code service

**Description:** As a developer, I want a service that generates and validates invite codes so that coaches can invite trainees.

**Acceptance Criteria:**
- [ ] `lib/services/invites.ts` exports `createInviteCode(coachId)` and `redeemInviteCode(code, traineeId)`
- [ ] `createInviteCode` generates a unique 6-character alphanumeric code and inserts into `invites` table
- [ ] `redeemInviteCode` marks the invite as used, sets `trainee_id`, and updates the trainee's `coach_id` in the `users` table
- [ ] Validates that the code exists and is not already used
- [ ] Typecheck passes

---

### US-038: Create program assignment service

**Description:** As a developer, I want a service to assign/unassign programs to trainees so that coaches can manage client programs.

**Acceptance Criteria:**
- [ ] `lib/services/assignments.ts` exports `assignProgram(traineeId, programId, coachId)`, `unassignProgram(assignmentId)`, `getTraineeAssignments(traineeId)`, `getProgramTrainees(programId)`
- [ ] `assignProgram` inserts into `assignments` table
- [ ] Duplicate assignment prevented by unique constraint
- [ ] All functions use the authenticated Supabase client
- [ ] Typecheck passes

---

### US-039: Build Client list screen

**Description:** As a coach, I want to see a list of my clients so that I can manage them and view their progress.

**Acceptance Criteria:**
- [ ] `app/(coach)/clients/index.tsx` fetches trainees where `coach_id` matches current user from `users` table
- [ ] List rendered with `FlashList`
- [ ] Each item shows trainee display name and email (using react-native-reusables `Card`)
- [ ] Tapping a client navigates to the client detail screen
- [ ] "Invite Client" button in header navigates to invite flow
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-040: Build Invite Client flow

**Description:** As a coach, I want to generate an invite code and share it so that new trainees can connect to me.

**Acceptance Criteria:**
- [ ] `app/(coach)/clients/invite.tsx` calls `createInviteCode` on mount and displays the generated code
- [ ] Code displayed in large, copyable text within a react-native-reusables `Card`
- [ ] "Copy" button copies to clipboard; "Share" button opens device share sheet
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-041: Build Client detail screen with program assignment

**Description:** As a coach, I want to view a client's profile and assign/unassign programs so that I can customize their training.

**Acceptance Criteria:**
- [ ] `app/(coach)/clients/[id].tsx` shows trainee display name, email, and list of assigned programs
- [ ] "Assign Program" button opens a picker listing the coach's programs (from `useCoachPrograms`)
- [ ] Selecting a program calls `assignProgram` mutation
- [ ] Coach can unassign a program with confirmation (calls `unassignProgram`)
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-042: Add RLS policies for clients, assignments, and invites

**Description:** As a developer, I want RLS policies that restrict client management data so that coaches only see their own clients and trainees only see their own assignments.

**Acceptance Criteria:**
- [ ] RLS on `invites`: coaches can INSERT/SELECT their own invites; trainees can UPDATE (redeem) unused invites
- [ ] RLS on `assignments`: coaches can CRUD assignments for their own programs; trainees can SELECT their own assignments
- [ ] RLS on `users` (refined): coaches can SELECT trainees where `coach_id = auth.uid()`; trainees can SELECT their own coach
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### Phase 8: Coach – Monitoring

---

### US-043: Create workout log query service

**Description:** As a developer, I want a service to query workout logs with joined exercise and set data so that both coach monitoring and trainee history can use it.

**Acceptance Criteria:**
- [ ] `lib/services/logs.ts` exports `getTraineeLogs(traineeId)`, `getLogWithDetails(logId)`, `getProgramLogs(traineeId, programId)`, `getExerciseLogs(traineeId, exerciseName)`
- [ ] `getLogWithDetails` returns log with nested `completed_exercises` and their `completed_sets` (Supabase nested select)
- [ ] Queries support ordering by date descending
- [ ] All functions use the authenticated Supabase client
- [ ] Typecheck passes

---

### US-044: Build Log viewer screen (coach)

**Description:** As a coach, I want to view a client's workout logs so that I can see what they did and how they performed.

**Acceptance Criteria:**
- [ ] `app/(coach)/clients/logs.tsx` shows a list of logs for a selected trainee via `getTraineeLogs`
- [ ] List rendered with `FlashList`
- [ ] Each log item shows date, workout name, and exercise count
- [ ] Tapping a log navigates to full detail view showing exercises, sets, weights, reps, notes
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-045: Add coach comment to log

**Description:** As a coach, I want to add a comment to a trainee's workout log so that I can give feedback visible to the trainee.

**Acceptance Criteria:**
- [ ] Log detail screen (coach view) has a text input and "Add Comment" button at the bottom
- [ ] Saving updates the `coach_comment` field on the `workout_logs` row via Supabase
- [ ] Existing comment is displayed and editable
- [ ] TanStack Query cache invalidated after comment save
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-046: Build Coach dashboard screen

**Description:** As a coach, I want a dashboard showing recent client activity so that I get a quick overview when I open the app.

**Acceptance Criteria:**
- [ ] `app/(coach)/dashboard.tsx` displays total client count and total logs this week
- [ ] Shows a "Recent Activity" list: last 10 logs across all clients, each showing trainee name, workout name, and date
- [ ] List rendered with `FlashList`
- [ ] Tapping an activity item navigates to the log detail
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-047: Add RLS policies for workout logs

**Description:** As a developer, I want RLS policies on logging tables so that trainees can only access their own logs and coaches can access their trainees' logs.

**Acceptance Criteria:**
- [ ] RLS on `workout_logs`: trainees can INSERT/SELECT their own logs; coaches can SELECT/UPDATE (for `coach_comment`) logs of their trainees
- [ ] RLS on `completed_exercises`: access mirrors `workout_logs` through `log_id`
- [ ] RLS on `completed_sets`: access mirrors through `completed_exercise_id` → `completed_exercises` → `workout_logs`
- [ ] Coach cannot modify trainee's exercise data — only `coach_comment` on `workout_logs`
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### Phase 9: Trainee – View Programs

---

### US-048: Build Trainee programs list screen

**Description:** As a trainee, I want to see the programs my coach has assigned to me so that I can pick a workout.

**Acceptance Criteria:**
- [ ] `app/(trainee)/programs/index.tsx` fetches assigned programs via `getTraineeAssignments` joined with program data
- [ ] List rendered with `FlashList`
- [ ] Each item shows program name and number of workouts
- [ ] Tapping a program navigates to the workout selection screen
- [ ] Empty state shown if no programs are assigned (using react-native-reusables)
- [ ] TanStack Query hook for trainee assignments created in `hooks/useAssignments.ts`
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-049: Build Workout selection screen (trainee)

**Description:** As a trainee, I want to see the workouts within a program and freely choose which one to do today so that I'm not locked into a schedule.

**Acceptance Criteria:**
- [ ] `app/(trainee)/programs/[programId].tsx` lists workouts for the selected program via `useWorkoutsByProgram`
- [ ] List rendered with `FlashList`
- [ ] Each item shows workout name and exercise count
- [ ] Shows the date of the last time each workout was logged (if any) via a Supabase query
- [ ] Tapping a workout navigates to the workout logging screen
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 10: Trainee – Logging

---

### US-050: Build workout logging screen – checklist UI

**Description:** As a trainee, I want a checklist-style interface showing all exercises in my chosen workout so that I can track completion visually.

**Acceptance Criteria:**
- [ ] `app/(trainee)/programs/log.tsx` lists exercises as checklist items via `useExercisesByWorkout`
- [ ] Each exercise shows name, prescribed sets/reps/weight in a react-native-reusables `Card`
- [ ] Exercises can be expanded to show set-by-set input (accordion-style)
- [ ] A progress bar or counter shows completed vs total exercises
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-051: Add set input fields to logging screen

**Description:** As a trainee, I want to input reps, weight, duration, distance, and RPE for each set so that my workout is fully recorded.

**Acceptance Criteria:**
- [ ] Each expanded exercise shows rows for each prescribed set
- [ ] Input fields managed by React Hook Form — adapt to exercise type: strength shows reps + weight, cardio shows duration + distance, timed shows duration
- [ ] RPE is an optional selector (1–10)
- [ ] Per-set note field available
- [ ] Marking a set as completed toggles its checkbox
- [ ] All inputs use react-native-reusables `Input` component
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-052: Handle choice exercises in logging

**Description:** As a trainee, I want to see alternatives for choice exercises and pick one before logging so that I can choose what suits me.

**Acceptance Criteria:**
- [ ] Choice exercises display a selection UI with alternatives and coach's `choice_reason` for each
- [ ] Trainee selects one alternative; the chosen option becomes the active exercise to log
- [ ] The `chosen_alternative_id` is saved in the completed exercise data
- [ ] Selection UI uses react-native-reusables components
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-053: Add per-exercise and per-workout notes

**Description:** As a trainee, I want to add a note to an individual exercise or to the entire workout so that I can record how I felt.

**Acceptance Criteria:**
- [ ] Each exercise section has an optional "Add note" text input (collapsible)
- [ ] The bottom of the logging screen has a "Workout notes" text input
- [ ] Notes are stored in form state managed by React Hook Form
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-054: Show previous workout data

**Description:** As a trainee, I want to see my last logged values for each exercise while logging so that I know what to aim for.

**Acceptance Criteria:**
- [ ] When opening the logging screen, fetch the most recent log for the same workout via `getLogWithDetails`
- [ ] For each exercise, display "Last time: X reps @ Y kg" (or equivalent) in a muted NativeWind style above the input fields
- [ ] If no previous data exists, show nothing
- [ ] Coach comment from the previous log is shown if present (highlighted card)
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-055: Save workout log (transactional)

**Description:** As a trainee, I want to save my completed workout atomically so that it is persisted consistently and visible to my coach.

**Acceptance Criteria:**
- [ ] "Save Workout" button at the bottom of the logging screen
- [ ] Calls a Supabase RPC function (`save_workout_log`) that atomically inserts into `workout_logs`, `completed_exercises`, and `completed_sets` within a transaction
- [ ] RPC function created via SQL migration
- [ ] Shows a success message and navigates back to the programs list
- [ ] Button is disabled if no exercises are marked as completed
- [ ] TanStack Query cache invalidated after save
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-056: Add Reanimated animations to logging

**Description:** As a trainee, I want smooth animations when expanding exercises and completing sets so that the logging experience feels polished.

**Acceptance Criteria:**
- [ ] `react-native-reanimated` installed and configured
- [ ] Exercise expand/collapse uses `Layout` animations (entering/exiting)
- [ ] Set completion checkbox has a scale + checkmark animation
- [ ] Progress bar animates smoothly as exercises are completed
- [ ] Animations do not cause layout jumps
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-090: Add rest timer

**Description:** As a trainee, I want a rest timer that auto-starts after completing a set so that I can track rest periods without leaving the logging screen.

**Acceptance Criteria:**
- [ ] Rest timer component renders as a floating overlay at the bottom of the logging screen (doesn't block exercise inputs)
- [ ] Timer auto-starts when a set is marked as completed
- [ ] Preset buttons: 30s, 60s, 90s, 120s, and a custom time input
- [ ] Default rest time taken from the exercise's `rest_seconds` field (if set by coach)
- [ ] Circular ring progress animation (Reanimated) shows time remaining
- [ ] Last 3 seconds: number scale pulse animation
- [ ] On timer expiry: "Next Set" button pulses with green glow, `hapticNotification()` fires
- [ ] Timer can be dismissed, paused, or reset manually
- [ ] Timer state managed by `useRestTimer` hook (Zustand for UI state)
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-091: Add PR auto-detection

**Description:** As a trainee, I want the app to automatically detect when I set a personal record so that PRs are tracked without manual input.

**Acceptance Criteria:**
- [ ] When a set is completed, compare the weight to the user's historical max for the same exercise at the same rep count
- [ ] Historical max queried via `getExerciseLogs` service (or a new `getExercisePR(exerciseName, repCount)` function)
- [ ] If current weight > historical max, flag the `completed_set` with `is_pr = true` (new column added via migration)
- [ ] `completed_sets` table migration adds `is_pr` (bool default false) column
- [ ] PR detection runs client-side during logging (compare against cached history)
- [ ] PR flag is saved when workout is saved via the `save_workout_log` RPC
- [ ] Typecheck passes

---

### US-092: Add PR celebration animation

**Description:** As a trainee, I want a celebration animation when I hit a new PR so that the achievement feels rewarding and memorable.

**Acceptance Criteria:**
- [ ] When `is_pr = true` is detected on a completed set, trigger celebration:
  - Gold confetti burst animation (Reanimated + particle system or lottie)
  - "NEW PR" badge slides in from right with gold glow (`#FFD700`)
  - Weight number briefly glows gold
- [ ] `hapticHeavy()` fires on PR detection
- [ ] Celebration animation is non-blocking (logging can continue)
- [ ] Animation duration: ~2 seconds, then fades
- [ ] `components/PRCelebration.tsx` is a reusable component accepting the PR value
- [ ] Styled with NativeWind dark theme + gold accent
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-093: Add workout summary screen

**Description:** As a trainee, I want a summary screen after saving a workout showing key stats so that I can review what I accomplished.

**Acceptance Criteria:**
- [ ] After "Save Workout" succeeds, navigate to `app/(trainee)/programs/summary.tsx` instead of directly back to programs list
- [ ] Summary shows: total workout duration (calculated from log creation time to save time), total volume (sum of sets × reps × weight across all exercises), total sets completed, number of PRs hit
- [ ] If any PRs were hit, show gold PR badges with exercise name and weight
- [ ] Checkmark draw animation on load (Reanimated) + `hapticMedium()` on save
- [ ] "Done" button navigates back to programs list
- [ ] Optional "Share" button to share summary (stretch goal)
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 11: Trainee – History

---

### US-057: Build History list screen

**Description:** As a trainee, I want to see a chronological list of my past workouts so that I can review my training.

**Acceptance Criteria:**
- [ ] `app/(trainee)/history/index.tsx` fetches logs via TanStack Query hook wrapping `getTraineeLogs`
- [ ] List rendered with `FlashList`
- [ ] Each item shows date, workout name, and number of exercises completed (using react-native-reusables `Card`)
- [ ] List is sorted by date descending (newest first)
- [ ] Tapping an item navigates to the history detail screen
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-058: Build History detail screen

**Description:** As a trainee, I want to see the full details of a past workout including all sets, notes, and coach comments so that I can reflect on my performance.

**Acceptance Criteria:**
- [ ] `app/(trainee)/history/[id].tsx` fetches log with details via `getLogWithDetails`
- [ ] Shows workout name, date, and all completed exercises with their sets
- [ ] Each exercise shows sets with reps, weight, duration, etc.
- [ ] Exercise-level and workout-level notes displayed
- [ ] Coach comment displayed in a highlighted card if present
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-059: Add search and filter to history

**Description:** As a trainee, I want to filter my history by program, exercise name, or date range so that I can find specific workouts.

**Acceptance Criteria:**
- [ ] History list screen has a search bar that filters by exercise name (Supabase text search on `completed_exercises.exercise_name`)
- [ ] Filter chips or dropdown for program name
- [ ] Date range picker to narrow results
- [ ] Filters combine (AND logic) and update the Supabase query
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 12: Progress Charts

---

### US-060: Create chart data utilities

**Description:** As a developer, I want utility functions that transform workout logs into chart-ready data series so that chart components receive clean input.

**Acceptance Criteria:**
- [ ] `lib/utils/chartData.ts` exports `getExerciseProgressData(logs, exerciseName)` returning `{ date: string, value: number }[]` for max weight over time
- [ ] Exports `getVolumeProgressData(logs, exerciseName)` returning total volume (sets x reps x weight) over time
- [ ] Handles missing or partial data gracefully (skips entries without weight)
- [ ] Typecheck passes

---

### US-061: Build chart components

**Description:** As a developer, I want reusable line chart and bar chart components wrapping a charting library so that screens can render progress visuals.

**Acceptance Criteria:**
- [ ] `components/LineChart.tsx` renders a line chart given `{ date: string, value: number }[]` data and axis labels
- [ ] `components/BarChart.tsx` renders a bar chart given `{ label: string, value: number }[]` data
- [ ] Charts are responsive to screen width
- [ ] RTL layout does not break chart rendering
- [ ] Styled with NativeWind for surrounding elements
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-062: Build Trainee progress screen

**Description:** As a trainee, I want a progress screen showing charts of my exercise improvements over time so that I can see my gains.

**Acceptance Criteria:**
- [ ] `app/(trainee)/progress.tsx` lets the user pick an exercise from a dropdown (populated from logged exercise names)
- [ ] Displays a line chart of weight progression and a bar chart of volume over time
- [ ] Shows "No data yet" empty state if the exercise has no logged history
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-063: Build Coach progress view for a client

**Description:** As a coach, I want to see progress charts for a specific client's exercise so that I can track their improvement.

**Acceptance Criteria:**
- [ ] `app/(coach)/clients/progress.tsx` accessible from the client detail screen
- [ ] Exercise picker dropdown populated from the client's logged exercises via `getExerciseLogs`
- [ ] Displays the same line + bar charts as the trainee progress screen
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 13: Push Notifications

---

### US-064: Register push token

**Description:** As a developer, I want the app to request notification permissions and save the device push token to Supabase so that Edge Functions can send targeted notifications.

**Acceptance Criteria:**
- [ ] `lib/services/notifications.ts` exports `registerPushToken()` that requests permissions via `expo-notifications`
- [ ] On approval, saves the Expo push token to `push_tokens` table in Supabase
- [ ] Called on app launch after auth is confirmed
- [ ] Existing tokens are upserted (no duplicates per device)
- [ ] Typecheck passes

---

### US-065: Create Edge Function for coach comment notification

**Description:** As a developer, I want a Supabase Edge Function that sends a push notification to a trainee when their coach adds a comment so that the trainee is alerted.

**Acceptance Criteria:**
- [ ] `supabase/functions/notify-comment/index.ts` (Deno) is triggered via Supabase Database Webhook on `workout_logs` UPDATE when `coach_comment` changes
- [ ] Looks up the trainee's push tokens from `push_tokens` table
- [ ] Sends notification via Expo Push API (`https://exp.host/--/api/v2/push/send`)
- [ ] Notification title: "Coach left you a note" (localized based on user's language)
- [ ] Notification body: first 100 characters of the comment
- [ ] Notification payload includes `{ screen: "history-detail", logId }` for deep linking
- [ ] Edge Function deploys: `supabase functions deploy notify-comment`
- [ ] Typecheck passes

---

### US-066: Create Edge Function for workout reminder

**Description:** As a developer, I want a scheduled Edge Function that sends a daily push notification reminding trainees to work out so that engagement increases.

**Acceptance Criteria:**
- [ ] `supabase/functions/workout-reminder/index.ts` (Deno) runs on a cron schedule (configurable, default 9:00 AM UTC)
- [ ] Queries trainees who haven't logged a workout today
- [ ] Sends Expo push notifications to those trainees
- [ ] Notification text is encouraging and localized based on user's `language` field
- [ ] Cron schedule configured via `supabase/config.toml` or pg_cron
- [ ] Edge Function deploys: `supabase functions deploy workout-reminder`
- [ ] Typecheck passes

---

### US-067: Handle notification deep linking

**Description:** As a user, I want tapping a notification to open the relevant screen in the app so that I can quickly act on it.

**Acceptance Criteria:**
- [ ] Notification payload includes a `url` field compatible with Expo Router deep linking (e.g., `/(trainee)/history/[logId]`)
- [ ] `lib/services/notifications.ts` listens for notification responses via `expo-notifications` and uses Expo Router's `router.push()` to navigate
- [ ] Deep link works when app is in foreground, background, and killed state
- [ ] Expo Router linking config handles the notification URL scheme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-068: Set up Supabase Realtime subscriptions

**Description:** As a developer, I want real-time updates for key tables so that coaches see new logs and trainees see new comments without manual refresh.

**Acceptance Criteria:**
- [ ] `hooks/useRealtimeLogs.ts` subscribes to `workout_logs` changes for the current user (coach sees trainee logs, trainee sees own logs)
- [ ] On INSERT/UPDATE, TanStack Query cache is invalidated to trigger refetch
- [ ] Subscription is cleaned up on component unmount
- [ ] Supabase Realtime enabled on `workout_logs` table in migration
- [ ] Typecheck passes

---

### Phase 14: Settings

---

### US-069: Build Settings screen

**Description:** As a user, I want a settings screen where I can switch language, view my profile info, and sign out so that I can manage my account.

**Acceptance Criteria:**
- [ ] `app/(coach)/settings.tsx` and `app/(trainee)/settings.tsx` render the same shared `SettingsScreen` component
- [ ] Shows display name, email, and role (read-only) — fetched from Clerk via `useUser()` hook
- [ ] Language toggle (Hebrew / English) updates i18n locale and persists to `users.language` in Supabase
- [ ] "Sign Out" button calls Clerk's `signOut()` and redirects to `(auth)` group
- [ ] RTL layout updates immediately when language changes
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind using react-native-reusables components
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 15: RevenueCat Payments

---

### US-070: Set up RevenueCat SDK

**Description:** As a developer, I want to install and configure the RevenueCat SDK so that the app can manage subscriptions and in-app purchases.

**Acceptance Criteria:**
- [ ] `react-native-purchases` installed
- [ ] RevenueCat configured in root layout with API key from environment variable
- [ ] User identified with Clerk user ID via `Purchases.logIn(userId)`
- [ ] **Requires EAS dev build** — not compatible with Expo Go
- [ ] Typecheck passes

---

### US-071: Build paywall screen

**Description:** As a user, I want to see a paywall screen presenting subscription options so that I can upgrade to a premium plan.

**Acceptance Criteria:**
- [ ] `app/(auth)/paywall.tsx` (or modal route) displays available subscription packages from RevenueCat
- [ ] Uses `Purchases.getOfferings()` to fetch current offerings
- [ ] Each package shows name, price, and description
- [ ] "Subscribe" button calls `Purchases.purchasePackage(package)`
- [ ] Handles purchase success, cancellation, and error states
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-072: Implement entitlement gating

**Description:** As a developer, I want to gate premium features behind RevenueCat entitlements so that only paying users can access them.

**Acceptance Criteria:**
- [ ] `hooks/useEntitlements.ts` exports `useIsPremium()` hook that checks RevenueCat entitlements
- [ ] `useIsPremium()` returns `{ isPremium: boolean, isLoading: boolean }`
- [ ] A `<PremiumGate>` wrapper component shows paywall when user is not premium
- [ ] At least one feature is gated (e.g., progress charts, unlimited programs — configurable)
- [ ] Typecheck passes

---

### US-073: Restore purchases

**Description:** As a user, I want a "Restore Purchases" button so that I can recover my subscription on a new device.

**Acceptance Criteria:**
- [ ] Settings screen includes a "Restore Purchases" button
- [ ] Calls `Purchases.restorePurchases()` on tap
- [ ] Shows success/failure feedback via toast or alert
- [ ] Updates `useIsPremium()` state after restore
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-074: Add subscription status to profile

**Description:** As a user, I want to see my current subscription status in settings so that I know my plan and expiry date.

**Acceptance Criteria:**
- [ ] Settings screen shows subscription status: "Free" or "Premium (expires [date])"
- [ ] If free, shows "Upgrade to Premium" link that navigates to paywall
- [ ] Data from RevenueCat via `Purchases.getCustomerInfo()`
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 16: Polish & Hardening

---

### US-075: Enable TanStack Query persistence for offline support

**Description:** As a trainee, I want my workout data to be available offline so that I can view programs and log workouts in the gym without cell service.

**Acceptance Criteria:**
- [ ] `@tanstack/query-async-storage-persister` and `@tanstack/react-query-persist-client` installed
- [ ] TanStack Query configured with `AsyncStorage` persister in root layout
- [ ] Program and workout data available offline after initial fetch
- [ ] Mutations queue while offline and execute when connectivity returns
- [ ] Typecheck passes

---

### US-076: Add loading skeletons

**Description:** As a user, I want skeleton loading placeholders on list screens so that I see feedback while data loads.

**Acceptance Criteria:**
- [ ] `components/SkeletonCard.tsx` renders a pulsing placeholder card using Reanimated for animation
- [ ] Programs list, clients list, history list, and dashboard screens show skeletons while TanStack Query `isLoading` is true
- [ ] Skeletons match the approximate layout of the real content
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-077: Add empty state components

**Description:** As a user, I want friendly empty states on list screens so that I know what to do when there's no data yet.

**Acceptance Criteria:**
- [ ] `components/EmptyState.tsx` component accepts `title`, `message`, and optional `actionLabel` / `onAction` props
- [ ] Used on programs list ("No programs yet"), clients list ("No clients yet"), history list ("No workouts logged yet")
- [ ] Styled with NativeWind using react-native-reusables components
- [ ] All text uses i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-078: Run RLS security audit

**Description:** As a developer, I want a full audit of all RLS policies to ensure data isolation so that coaches only see their own clients' data and trainees only see their own.

**Acceptance Criteria:**
- [ ] Review all RLS policies across all tables (users, programs, workouts, exercises, exercise_alternatives, workout_logs, completed_exercises, completed_sets, assignments, invites, push_tokens)
- [ ] Verify: coaches can only read/write their own programs and their clients' data
- [ ] Verify: trainees can only read their own assigned programs and read/write their own logs
- [ ] Verify: unauthenticated users have no access to any table
- [ ] Verify: `push_tokens` — users can only manage their own tokens
- [ ] Fix any gaps found; document policies in a `SECURITY.md` file
- [ ] Typecheck passes

---

### US-079: Run full i18n audit

**Description:** As a developer, I want every user-facing string to use i18n keys so that the app is fully translatable.

**Acceptance Criteria:**
- [ ] Search all `.tsx` files for hardcoded user-facing strings (not in `t()` calls)
- [ ] Replace any found hardcoded strings with i18n keys
- [ ] Add missing keys to both `en.json` and `he.json`
- [ ] Visually verify app in both English and Hebrew
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-080: Add Sentry error boundaries

**Description:** As a developer, I want Sentry error boundaries wrapping key screens so that crashes are reported with component context.

**Acceptance Criteria:**
- [ ] `components/ErrorBoundary.tsx` wraps screens with Sentry's `ErrorBoundary` or a custom one that calls `Sentry.captureException`
- [ ] Fallback UI shows "Something went wrong" with a "Retry" button
- [ ] Error boundaries added to root layout and each tab group layout
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-081: Performance optimization pass

**Description:** As a developer, I want to audit and optimize list performance and component rendering so that the app feels snappy on lower-end devices.

**Acceptance Criteria:**
- [ ] All list screens confirmed using `FlashList` with `estimatedItemSize` set
- [ ] Heavy computations wrapped in `useMemo` / `useCallback` where appropriate
- [ ] TanStack Query `staleTime` and `gcTime` tuned for each query type
- [ ] No unnecessary re-renders identified via React DevTools profiler
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-094: Add haptic feedback system

**Description:** As a user, I want haptic feedback on key interactions throughout the app so that the interface feels tactile and responsive.

**Acceptance Criteria:**
- [ ] Haptic feedback integrated at all interaction points defined in the design system:
  - Set completion: `hapticLight()` on checkbox tap
  - PR detected: `hapticHeavy()` on PR celebration
  - Workout saved: `hapticMedium()` on save confirmation
  - Rest timer tick: `hapticSelection()` on each countdown second in last 3 seconds
  - Rest timer expired: `hapticNotification()` on timer completion
  - Exercise expand/collapse: `hapticSelection()` on accordion toggle
  - Button press: `hapticLight()` on primary action buttons
  - Streak milestone: `hapticSuccess()` on streak achievement
  - Achievement unlocked: `hapticSuccess()` on badge reveal
  - Swipe to delete: `hapticWarning()` on delete confirmation
- [ ] All haptics use the `lib/utils/haptics.ts` wrapper functions (from US-083)
- [ ] Haptics gracefully disabled on web platform
- [ ] Typecheck passes
- [ ] Verify changes work on physical device

---

### US-095: Add calendar heatmap to history screen

**Description:** As a trainee, I want a GitHub-style calendar heatmap at the top of my history screen so that I can visualize my workout frequency at a glance.

**Acceptance Criteria:**
- [ ] `components/CalendarHeatmap.tsx` renders a contribution-graph-style grid (7 rows × N weeks)
- [ ] Each cell represents one day; color intensity based on number of workouts logged that day
- [ ] Color scale: no workout = `bg-background-card`, 1 workout = light green, 2+ workouts = full accent green (`#22C55E`)
- [ ] Data sourced from workout logs query grouped by date
- [ ] Shows last 3 months by default, scrollable horizontally for more history
- [ ] Tapping a day cell filters the history list below to that date
- [ ] Current day highlighted with accent border
- [ ] Month labels shown above the grid
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 17: Streaks & Gamification

---

### US-096: Create streaks and achievements tables

**Description:** As a developer, I want database tables for tracking workout streaks and achievements so that the gamification system has persistent storage.

**Acceptance Criteria:**
- [ ] Migration creates `streaks` table with columns: `id` (uuid PK), `user_id` (uuid FK → users, unique), `current_streak` (int default 0), `longest_streak` (int default 0), `last_workout_date` (date nullable), `updated_at` (timestamptz)
- [ ] Migration creates `achievements` table with columns: `id` (uuid PK), `user_id` (uuid FK → users), `achievement_type` (text not null), `unlocked_at` (timestamptz default now())
- [ ] Unique constraint on `achievements(user_id, achievement_type)` to prevent duplicates
- [ ] RLS policy: users can SELECT/UPDATE their own streak row; users can SELECT their own achievements
- [ ] Streak row auto-created for new users (via trigger or on first workout save)
- [ ] Achievement types enum documented: `first_workout`, `streak_7`, `streak_30`, `streak_60`, `streak_100`, `workouts_10`, `workouts_50`, `workouts_100`, `first_pr`, `prs_10`, `prs_25`, `volume_1000kg`, `volume_10000kg`, `early_bird`, `night_owl`
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-097: Track workout streaks

**Description:** As a trainee, I want my workout streaks automatically tracked so that I can see how many consecutive days/weeks I've been training.

**Acceptance Criteria:**
- [ ] `lib/services/streaks.ts` exports `updateStreak(userId)` called after each workout save
- [ ] Streak logic: if `last_workout_date` is yesterday or today, increment `current_streak`; if more than 1 day gap, reset `current_streak` to 1; update `longest_streak` if current exceeds it
- [ ] `hooks/useStreaks.ts` exports `useStreak(userId)` query hook and `useUpdateStreak` mutation hook
- [ ] Streak update integrated into the `save_workout_log` flow (called after successful save)
- [ ] Typecheck passes

---

### US-098: Build achievement system

**Description:** As a trainee, I want to earn achievement badges for milestones so that I have additional motivation to keep training.

**Acceptance Criteria:**
- [ ] `lib/services/achievements.ts` exports `checkAndUnlockAchievements(userId)` that evaluates all achievement conditions
- [ ] Achievement conditions checked after each workout save:
  - `first_workout`: 1+ total workouts
  - `streak_7/30/60/100`: current streak reaches threshold
  - `workouts_10/50/100`: total workout count reaches threshold
  - `first_pr`: 1+ PR recorded
  - `prs_10/25`: total PR count reaches threshold
  - `volume_1000kg/10000kg`: cumulative volume reaches threshold
  - `early_bird`: workout logged before 7 AM
  - `night_owl`: workout logged after 10 PM
- [ ] Newly unlocked achievements returned so UI can trigger celebration
- [ ] `hooks/useAchievements.ts` exports `useAchievements(userId)` and `useCheckAchievements` mutation
- [ ] Typecheck passes

---

### US-099: Build streak counter and achievement showcase

**Description:** As a trainee, I want to see my streak counter on the dashboard and my achievements on my profile so that my progress is visible and motivating.

**Acceptance Criteria:**
- [ ] `components/StreakCounter.tsx` shows current streak number with flame icon, animated increment on new streak day
- [ ] Streak counter placed at top of trainee dashboard (or coach dashboard showing "your clients' streaks" summary)
- [ ] Fire particle burst animation (Reanimated) + `hapticSuccess()` on streak milestone (7, 30, 60, 100 days)
- [ ] `components/AchievementBadge.tsx` renders individual badge with icon, name, and unlock date
- [ ] Achievement showcase grid on settings/profile screen showing all badges (locked = gray, unlocked = colored)
- [ ] Full-screen badge reveal animation with radial glow + `hapticSuccess()` when new achievement unlocked
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme + gold accent for achievements
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 18: Body Measurements & Progress Photos

---

### US-100: Create body_measurements table

**Description:** As a developer, I want a database table for body measurements so that trainees can track physical changes over time.

**Acceptance Criteria:**
- [ ] Migration creates `body_measurements` table with columns: `id` (uuid PK), `user_id` (uuid FK → users), `date` (date not null), `body_weight` (numeric nullable), `body_fat_pct` (numeric nullable), `chest` (numeric nullable), `waist` (numeric nullable), `hips` (numeric nullable), `biceps` (numeric nullable), `created_at` (timestamptz)
- [ ] RLS policy: users can CRUD their own measurements only
- [ ] Index on `(user_id, date)` for time-series queries
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-101: Build measurement entry form and history

**Description:** As a trainee, I want to log body measurements and see my measurement history so that I can track physical changes.

**Acceptance Criteria:**
- [ ] `app/(trainee)/measurements/index.tsx` shows measurement history list (date, body weight, key stats)
- [ ] "Add Measurement" button opens a form with fields for each measurement type (all optional — user logs what they want)
- [ ] Form uses React Hook Form + Zod validation (numeric values, reasonable ranges)
- [ ] `lib/services/measurements.ts` exports `createMeasurement`, `getMeasurements(userId)`, `deleteMeasurement`
- [ ] `hooks/useMeasurements.ts` wraps service with TanStack Query
- [ ] Feature gated behind Trainee Pro subscription via `<PremiumGate>`
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-102: Build measurement charts

**Description:** As a trainee, I want line charts showing each measurement type over time so that I can visualize my body composition trends.

**Acceptance Criteria:**
- [ ] `app/(trainee)/measurements/charts.tsx` shows line charts for each measurement type
- [ ] User can toggle between measurement types (body weight, body fat, chest, waist, hips, biceps)
- [ ] Time range chips: 1M, 3M, 6M, 1Y, All
- [ ] Charts use the same charting library as progress charts (Victory Native or react-native-chart-kit)
- [ ] "No data yet" empty state for measurement types with no entries
- [ ] Feature gated behind Trainee Pro subscription
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-103: Build progress photos with before/after comparison

**Description:** As a trainee, I want to take and compare progress photos so that I can see visual changes in my physique over time.

**Acceptance Criteria:**
- [ ] `app/(trainee)/measurements/photos.tsx` allows uploading photos from camera or gallery
- [ ] Photos stored in Supabase Storage bucket (`progress-photos`) with path `{userId}/{date}-{timestamp}.jpg`
- [ ] Photo metadata stored in a `progress_photos` table: `id`, `user_id`, `date`, `storage_path`, `created_at`
- [ ] Before/after comparison view: two photos side-by-side, user picks dates from a picker
- [ ] Swipe between photos chronologically
- [ ] Photos compressed client-side before upload (max 1MB)
- [ ] Feature gated behind Trainee Pro subscription
- [ ] RLS on storage: users can only access their own photos
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-104: Allow coaches to view client measurements

**Description:** As a coach, I want to see my client's body measurements and progress photos so that I can adjust their programs based on physical progress.

**Acceptance Criteria:**
- [ ] Client detail screen (coach) has a "Measurements" tab/button linking to `app/(coach)/clients/measurements.tsx`
- [ ] Shows the client's measurement history and charts (read-only)
- [ ] Shows the client's progress photos (read-only)
- [ ] RLS policy allows coaches to SELECT measurements/photos of their trainees (where `trainee.coach_id = auth.uid()`)
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 19: Goals System

---

### US-105: Create goals table

**Description:** As a developer, I want a database table for user goals so that trainees can set and track fitness objectives.

**Acceptance Criteria:**
- [ ] Migration creates `goals` table with columns: `id` (uuid PK), `user_id` (uuid FK → users), `title` (text not null), `goal_type` (text check strength/measurement/habit/custom), `target_value` (numeric), `current_value` (numeric default 0), `unit` (text), `deadline` (date nullable), `status` (text check active/completed/abandoned, default 'active'), `created_at` (timestamptz), `updated_at` (timestamptz)
- [ ] RLS policy: users can CRUD their own goals only
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-106: Build goals CRUD and service layer

**Description:** As a developer, I want a service module and hooks for goals so that the goals screen can create, read, update, and delete goals.

**Acceptance Criteria:**
- [ ] `lib/services/goals.ts` exports `createGoal`, `getGoals(userId)`, `updateGoal`, `deleteGoal`, `completeGoal`, `abandonGoal`
- [ ] `hooks/useGoals.ts` exports `useGoals(userId)`, `useCreateGoal`, `useUpdateGoal`, `useDeleteGoal`
- [ ] Mutations invalidate `['goals']` query key
- [ ] All functions use the authenticated Supabase client
- [ ] Typecheck passes

---

### US-107: Add auto-progress for goals from logged data

**Description:** As a trainee, I want my strength and habit goals to auto-update based on my logged workouts so that I don't have to manually track goal progress.

**Acceptance Criteria:**
- [ ] After workout save, check active goals and update `current_value`:
  - **Strength goals**: if a new PR is set for the goal's target exercise, update `current_value` to the new max weight
  - **Habit goals**: increment `current_value` by 1 for each workout logged (tracks workout frequency)
- [ ] **Measurement goals**: update when a new body measurement is logged (if goal type matches a measurement field)
- [ ] Auto-complete goal when `current_value >= target_value` (set status to `completed`)
- [ ] Goal completion triggers celebration animation and achievement check
- [ ] `lib/services/goals.ts` exports `autoProgressGoals(userId, workoutData)` called after workout save
- [ ] Typecheck passes

---

### US-108: Build goals screen with progress visualization

**Description:** As a trainee, I want a goals screen showing my active goals with progress bars and countdowns so that I can see how close I am to each objective.

**Acceptance Criteria:**
- [ ] `app/(trainee)/goals/index.tsx` lists active goals with progress bars (current_value / target_value)
- [ ] Each goal card shows: title, goal type icon, progress bar (accent green fill), percentage, deadline countdown (if set)
- [ ] "Add Goal" button opens a creation form with fields: title, goal type (picker), target value, unit, optional deadline
- [ ] Goal type presets: "Bench Press 100kg" (strength), "Work out 4x/week" (habit), "Reach 80kg body weight" (measurement), custom
- [ ] Completed goals section (collapsible) with celebration badges
- [ ] Abandoned goals can be reactivated
- [ ] Completion celebration animation + `hapticSuccess()` when goal is achieved
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 20: Nutrition Tracking

---

### US-109: Create food_items table and seed common foods

**Description:** As a developer, I want a food items database table seeded with common foods so that trainees can log their nutrition.

**Acceptance Criteria:**
- [ ] Migration creates `food_items` table with columns: `id` (uuid PK), `name` (text not null), `calories` (numeric not null), `protein` (numeric), `carbs` (numeric), `fat` (numeric), `serving_size` (text), `is_custom` (bool default false), `created_by` (uuid FK → users, nullable), `created_at` (timestamptz)
- [ ] Seed migration inserts ~30 common foods (chicken breast, rice, egg, banana, oats, whey protein, salmon, sweet potato, broccoli, avocado, almonds, Greek yogurt, etc.) with approximate macro values per standard serving
- [ ] Index on `name` for search queries
- [ ] RLS policy: all authenticated users can SELECT; users can INSERT/UPDATE/DELETE only rows where `created_by = auth.uid()` and `is_custom = true`
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-110: Create meal_logs and meal_log_items tables

**Description:** As a developer, I want database tables for meal logging so that trainees can track what they eat throughout the day.

**Acceptance Criteria:**
- [ ] Migration creates `meal_logs` table with columns: `id` (uuid PK), `user_id` (uuid FK → users), `date` (date not null), `meal_type` (text check breakfast/lunch/dinner/snack), `created_at` (timestamptz)
- [ ] Migration creates `meal_log_items` table with columns: `id` (uuid PK), `meal_log_id` (uuid FK → meal_logs ON DELETE CASCADE), `food_item_id` (uuid FK → food_items), `quantity` (numeric default 1), `calories` (numeric), `protein` (numeric), `carbs` (numeric), `fat` (numeric)
- [ ] RLS policy: users can CRUD their own meal logs only
- [ ] Index on `(user_id, date)` for daily queries
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-111: Build food search screen

**Description:** As a trainee, I want to search for foods in the database so that I can quickly find items to log in my meals.

**Acceptance Criteria:**
- [ ] `app/(trainee)/nutrition/food-search.tsx` shows a search bar and results list
- [ ] `lib/services/foodItems.ts` exports `searchFoodItems(query)`, `createCustomFoodItem(data)`
- [ ] `hooks/useNutrition.ts` exports `useSearchFoodItems(query)`, `useCreateCustomFoodItem`
- [ ] Search supports partial name matching (ILIKE)
- [ ] Each result shows food name, calories, and macro summary per serving
- [ ] "Add Custom Food" button for foods not in the database
- [ ] Selecting a food returns it to the meal logging screen with quantity picker
- [ ] Feature gated behind Trainee Pro subscription
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-112: Build meal logging screen

**Description:** As a trainee, I want to log meals by type (breakfast, lunch, dinner, snack) so that I can track my daily food intake.

**Acceptance Criteria:**
- [ ] `app/(trainee)/nutrition/index.tsx` shows today's meals grouped by meal type
- [ ] Each meal type section has "Add Food" button that navigates to food search
- [ ] `lib/services/mealLogs.ts` exports `createMealLog`, `getMealLogsByDate(userId, date)`, `addMealLogItem`, `removeMealLogItem`, `deleteMealLog`
- [ ] `hooks/useNutrition.ts` exports `useMealLogsByDate(date)`, `useCreateMealLog`, `useAddMealLogItem`, `useRemoveMealLogItem`
- [ ] Macro totals calculated per meal and per day
- [ ] Swipe to delete individual food items from a meal
- [ ] Date picker to view/edit past days
- [ ] Feature gated behind Trainee Pro subscription
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-113: Build daily nutrition summary card

**Description:** As a trainee, I want a daily summary showing my calorie and macro intake with circular progress rings so that I can see how my nutrition stacks up against my targets.

**Acceptance Criteria:**
- [ ] `components/NutritionSummary.tsx` shows circular progress rings for calories, protein, carbs, and fat
- [ ] Rings fill based on consumed / target ratio (green when on track, yellow when close, red when over)
- [ ] Summary card placed at top of nutrition screen and optionally on dashboard
- [ ] Shows numeric values: "1,850 / 2,200 cal" format
- [ ] Animated ring fill on data load (Reanimated)
- [ ] Feature gated behind Trainee Pro subscription
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-114: Add nutrition goals with daily targets

**Description:** As a trainee, I want to set daily calorie and macro targets so that the nutrition tracking has meaningful benchmarks.

**Acceptance Criteria:**
- [ ] Nutrition settings screen allows setting daily targets: calories, protein (g), carbs (g), fat (g)
- [ ] Targets saved to `users` table (new columns: `calorie_target`, `protein_target`, `carbs_target`, `fat_target`) or a separate `nutrition_goals` table
- [ ] Default targets suggested based on user's goal (from onboarding): build muscle → high protein, lose fat → calorie deficit
- [ ] Targets used by the daily summary card (US-113) for ring calculations
- [ ] Feature gated behind Trainee Pro subscription
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 21: Direct Messaging

---

### US-115: Create messages table

**Description:** As a developer, I want a database table for direct messages so that coaches and trainees can communicate within the app.

**Acceptance Criteria:**
- [ ] Migration creates `messages` table with columns: `id` (uuid PK), `sender_id` (uuid FK → users not null), `receiver_id` (uuid FK → users not null), `content` (text not null), `read_at` (timestamptz nullable), `created_at` (timestamptz default now())
- [ ] Index on `(sender_id, receiver_id, created_at)` for conversation queries
- [ ] Index on `(receiver_id, read_at)` for unread count queries
- [ ] RLS policy: users can INSERT messages where `sender_id = auth.uid()`; users can SELECT messages where they are sender or receiver; users can UPDATE `read_at` on messages where `receiver_id = auth.uid()`
- [ ] Supabase Realtime enabled on `messages` table
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-116: Build conversation list screen

**Description:** As a user, I want to see a list of my message conversations so that I can pick a conversation to open.

**Acceptance Criteria:**
- [ ] `app/(trainee)/messages/index.tsx` and `app/(coach)/messages/index.tsx` show conversation list
- [ ] Each conversation shows: other person's display name, last message preview (truncated), timestamp, unread message count badge
- [ ] `lib/services/messages.ts` exports `getConversations(userId)`, `getMessages(userId, otherUserId)`, `sendMessage`, `markAsRead`
- [ ] `hooks/useMessages.ts` exports `useConversations(userId)`, `useMessages(otherUserId)`, `useSendMessage`, `useMarkAsRead`
- [ ] Conversations sorted by most recent message
- [ ] List rendered with `FlashList`
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-117: Build chat screen with Realtime

**Description:** As a user, I want a chat screen with real-time message delivery so that conversations feel instant and responsive.

**Acceptance Criteria:**
- [ ] `app/(trainee)/messages/[userId].tsx` and `app/(coach)/messages/[userId].tsx` render a chat interface
- [ ] Messages displayed in chronological order with sender alignment (own messages right, others left)
- [ ] Text input at bottom with send button
- [ ] Supabase Realtime subscription for live message delivery (new messages appear instantly without polling)
- [ ] Messages marked as read when chat screen is focused (`markAsRead` called on mount and on new message received)
- [ ] Auto-scroll to bottom on new message
- [ ] Loading state shows message history skeleton
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme (message bubbles use `bg-accent` for own, `bg-background-elevated` for others)
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-118: Add unread message badge to tab bar

**Description:** As a user, I want to see an unread message count badge on the messages tab so that I know when I have new messages without opening the messages screen.

**Acceptance Criteria:**
- [ ] Tab bar icon for Messages tab shows a red badge with unread count when > 0
- [ ] Unread count queried from `messages` table: `WHERE receiver_id = auth.uid() AND read_at IS NULL`
- [ ] Count updates in real-time via Supabase Realtime subscription
- [ ] Badge hidden when count is 0
- [ ] `hooks/useUnreadCount.ts` exports `useUnreadMessageCount()` using TanStack Query + Realtime invalidation
- [ ] Push notification sent for new messages (integrate with existing push notification system)
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 22: Coach Marketplace

---

### US-119: Create marketplace_listings table

**Description:** As a developer, I want a database table for marketplace listings so that coaches can list their programs for sale.

**Acceptance Criteria:**
- [ ] Migration creates `marketplace_listings` table with columns: `id` (uuid PK), `program_id` (uuid FK → programs not null), `coach_id` (uuid FK → users not null), `price` (numeric not null check > 0), `description` (text), `is_published` (bool default false), `preview_image` (text nullable), `created_at` (timestamptz), `updated_at` (timestamptz)
- [ ] Unique constraint on `program_id` (one listing per program)
- [ ] RLS policy: all authenticated users can SELECT published listings; coaches can CRUD their own listings
- [ ] Feature gated behind Coach Business subscription
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-120: Build marketplace browse screen

**Description:** As a trainee, I want to browse and search the marketplace for programs so that I can find and purchase training programs from coaches.

**Acceptance Criteria:**
- [ ] `app/(trainee)/marketplace/index.tsx` (or shared route) shows published marketplace listings
- [ ] `lib/services/marketplace.ts` exports `getPublishedListings(filters?)`, `searchListings(query)`, `getListingDetail(id)`
- [ ] `hooks/useMarketplace.ts` exports `usePublishedListings(filters?)`, `useSearchListings(query)`, `useListingDetail(id)`
- [ ] Each listing card shows: program name, coach name, price, description preview, workout count
- [ ] Search bar + filter chips (price range, muscle focus)
- [ ] Tapping a listing opens detail view with full description and workout preview
- [ ] List rendered with `FlashList`
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-121: Build marketplace purchase flow

**Description:** As a trainee, I want to purchase a program from the marketplace so that it gets added to my assigned programs.

**Acceptance Criteria:**
- [ ] Listing detail screen has "Purchase" button showing the price
- [ ] Purchase handled via RevenueCat consumable IAP (one-time purchase per listing)
- [ ] On successful purchase: create an `assignment` linking the trainee to the program, mark purchase in a `marketplace_purchases` table
- [ ] Migration creates `marketplace_purchases` table: `id`, `listing_id` (FK), `buyer_id` (FK → users), `purchased_at`
- [ ] Duplicate purchase prevented (check before purchase flow)
- [ ] Error handling for failed/cancelled purchases
- [ ] Success screen with "Start Training" button navigating to the purchased program
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-122: Build coach earnings dashboard

**Description:** As a coach, I want to see my marketplace earnings so that I can track revenue from program sales.

**Acceptance Criteria:**
- [ ] `app/(coach)/marketplace/earnings.tsx` shows earnings summary: total revenue, sales count, top-selling programs
- [ ] Revenue data aggregated from `marketplace_purchases` joined with `marketplace_listings`
- [ ] Time range filter: This Month, Last Month, All Time
- [ ] Individual program earnings breakdown (bar chart)
- [ ] "Manage Listings" link to the coach's listing management screen
- [ ] `app/(coach)/marketplace/index.tsx` shows coach's own listings with published/draft status toggle
- [ ] Feature gated behind Coach Business subscription
- [ ] All visible strings use i18n keys
- [ ] Styled with NativeWind dark theme
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

## Non-Goals

- **Wearable integrations** — no Apple Watch, Fitbit, etc. in this version
- **Advanced AI features** — no AI-generated programs or auto-coaching
- **Social features** — no leaderboards, social feed, or community features
- **Super Admin panel** — founder uses Supabase Dashboard directly for now
- **Exercise video hosting** — `video_url` field supports external links only; no in-app video upload/hosting
- **Group coaching** — one-to-one coach–trainee only (group features deferred)
- **Web app** — mobile only (iOS + Android); web via Expo is a bonus, not a requirement
- **Advanced analytics** — basic charts only; no AI insights, periodization analysis, or training load calculations

## Technical Notes

- **Framework:** Expo (managed workflow) with TypeScript strict mode
- **Navigation:** Expo Router (file-based routing)
- **Server state:** TanStack Query (caching, invalidation, persistence)
- **Client state:** Zustand (UI-only: role cache, form UI state)
- **Auth:** Clerk → JWT → Supabase RLS
- **Database:** Supabase PostgreSQL (relational, with RLS)
- **Serverless:** Supabase Edge Functions (Deno runtime)
- **Styling:** NativeWind (Tailwind CSS for React Native)
- **UI components:** react-native-reusables (copy-paste, not npm — lives in `components/ui/`)
- **Forms:** React Hook Form + Zod validation
- **Lists:** FlashList (drop-in FlatList replacement)
- **Animations:** React Native Reanimated
- **Haptics:** expo-haptics (tactile feedback on key interactions)
- **Gestures:** React Native Gesture Handler
- **Push:** Expo Push Notifications + Supabase Edge Functions
- **Payments:** RevenueCat
- **Error monitoring:** Sentry
- **i18n:** i18n-js + expo-localization; RTL via `I18nManager`
- **Charts:** Victory Native or react-native-chart-kit
- **Offline:** TanStack Query persistence with AsyncStorage
- **Target platforms:** iOS + Android (web as bonus via Expo)
- **EAS dev builds required** — Expo Go not supported (Clerk, Sentry, RevenueCat need native modules)
- **Every story must pass typecheck** — TypeScript strict mode enforced
- **i18n convention:** All UI strings must go through `t()` — no hardcoded visible text
- **Story size:** Each story is designed to be completable in a single AI iteration (~10 min)

## Phase Dependencies

Phase execution order with parallelization opportunities:

| Phase | Depends On | Can Parallel With |
|-------|-----------|-------------------|
| 1-7   | Previous phase | None (sequential) |
| 8     | 7 | 9, 14, 15 |
| 9     | 7 | 8, 14, 15 |
| 10    | 9 | 13 |
| 11    | 10 | — |
| 12    | 11 | — |
| 13    | 8 | 10 |
| 14    | 5 | 8, 9, 15 |
| 15    | 5 | 8, 9, 14 |
| 16    | 15 | 17 |
| 17    | 16 | — |
| 18    | 16 | 19, 20 |
| 19    | 16 | 18, 20 |
| 20    | 16 | 18, 19 |
| 21    | 16 | 22 |
| 22    | 15, 16 | 21 |

### Wave Execution Plan

| Wave | Phases | Mode | Description |
|------|--------|------|-------------|
| A | 1-7 | Sequential | Foundation + Design System + Exercise Library + Auth/Onboarding |
| B | 8, 9, 14, 15 | Parallel | Monitoring + Trainee Programs + Settings + RevenueCat |
| C | 10, 13 | Parallel | Logging (+ Timer + PRs) + Push Notifications |
| D | 11 | Sequential | History (+ Calendar Heatmap) |
| E | 12 | Sequential | Charts |
| F | 16, 17 | Sequential | Polish + Haptics + Streaks & Gamification |
| G | 18, 19, 20 | Parallel | Body Measurements + Goals + Nutrition |
| H | 21, 22 | Parallel | Messaging + Marketplace |
