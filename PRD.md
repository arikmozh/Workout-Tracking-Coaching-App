# PRD: AI Personal Trainer App

## Introduction

An AI-powered personal trainer app that generates personalized workout programs, tracks progress, and adapts over time. No human coach needed. English-first, Hebrew added post-launch. Goal: maximum revenue, minimum development cost.

The AI generates tailored multi-week training programs based on a deep onboarding quiz, then adapts the program weekly based on logged performance. Users log workouts via a checklist-style interface, get automatic PR detection with celebrations, track streaks, and share beautiful workout summary cards for organic growth.

Built with Expo (managed workflow), Supabase (PostgreSQL + Edge Functions), Clerk (auth), TanStack Query (server state), Zustand (UI state), Uniwind (styling), react-native-reusables (UI components), React Native Reanimated (animations), and expo-haptics (tactile feedback). AI generation powered by Google Gemini API (free tier) via Supabase Edge Functions. Monetized via a Free + Pro model with RevenueCat subscriptions.

## Goals

- Generate personalized AI workout programs based on user profile (goals, experience, equipment, injuries, training style)
- Allow users to freely pick which workout to do on any day and log it via a checklist UI
- Adapt programs weekly via AI analysis of logged performance (Pro feature)
- Provide full workout history with search, filtering, and progress charts (Pro)
- Auto-detect and celebrate personal records with gold confetti and haptic feedback
- Track workout streaks and achievements to drive retention
- Enable social sharing of workout summaries for organic growth
- Deliver a 7-day free trial with smart paywall triggers to maximize conversion
- Support offline-capable logging via TanStack Query persistence
- Ship a working MVP in 8 weeks that can generate revenue immediately
- Monetize via RevenueCat subscriptions: Free + Pro ($6.99/mo, $49.99/yr, $99.99 lifetime)
- Provide 5 pre-built program templates for immediate value without AI generation
- Drive App Store reviews via smart review prompt system
- Enable referral-based viral growth

## Revenue Model

### Free + Pro Pricing

| Feature | Free | Pro ($6.99/mo or $49.99/yr or $99.99 lifetime) |
|---------|------|------------------------------------------------|
| AI program generation | 1 free program | Unlimited + regenerate anytime |
| Workout logging | Yes | Yes |
| History | Last 30 days | Unlimited |
| Progress charts | No | Yes |
| PR tracking | Basic (shows PR badge) | Full history, PR charts |
| AI weekly adaptation | No | Yes (the killer feature) |
| Streaks & achievements | Basic streak counter | Full achievement system |
| Rest timer | Yes | Yes |
| Social sharing | With app watermark | Clean cards |
| Export data | No | CSV export |

**Why this pricing:**
- $49.99/year: higher than dumb trackers (Strong $29.99) because AI adds coaching value, lower than premium AI apps (Fitbod $79.99) to win market share
- Lifetime at $99.99 drives impulse purchases
- Monthly at $6.99 captures users who won't commit to annual
- 7-day free trial on all paid options (median conversion: 39.9%)

RevenueCat handles all subscriptions. Entitlement checks via `useIsPro()` hook and `<ProGate>` wrapper component.

**AI API costs:**
- Google Gemini 2.5 Flash free tier: 250 requests/day, 10 RPM, 250K tokens/minute
- Google Gemini 2.5 Flash-Lite free tier fallback: 1,000 requests/day, 15 RPM
- Cost during development and early growth: **$0/month** (free tier)
- At scale (paid tier): ~$0.003/generation (Gemini 2.5 Flash at $0.15/M input tokens)
- Margin: 99%+ (effectively 100% until free tier limits are hit)

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Expo (managed workflow) + TypeScript strict |
| Auth | Clerk (Google + Apple OAuth) |
| Database | Supabase PostgreSQL (relational) |
| Serverless | Supabase Edge Functions (Deno) |
| Security | Supabase RLS (Row Level Security) |
| AI | Google Gemini API (2.5 Flash free tier, 2.5 Flash-Lite fallback) |
| Navigation | Expo Router (file-based) |
| Server State | TanStack Query |
| Client State | Zustand (UI-only) |
| Forms | React Hook Form + Zod |
| Lists | FlashList |
| Styling | Uniwind (Tailwind CSS, 2.5x faster than NativeWind) |
| UI Components | react-native-reusables (shadcn/ui-inspired, copy-paste) |
| Animations | React Native Reanimated |
| Haptics | expo-haptics |
| Gestures | React Native Gesture Handler |
| Error Monitoring | Sentry |
| Payments | RevenueCat |
| Validation | Zod |
| Charts | Victory Native or react-native-chart-kit |
| Sharing | react-native-view-shot + expo-sharing |
| Review Prompts | expo-store-review |

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
| Set completed | Checkbox scale bounce (1->1.2->1) + row green flash | Light impact |
| PR detected | Gold confetti burst + "NEW PR" badge slide-in + number glow | Heavy impact |
| Workout saved | Checkmark draw + card flip to summary | Medium impact |
| Rest timer 3-2-1 | Number scale pulse + circular ring progress | Tick per second |
| Timer expired | "Next Set" button pulsing green glow | Notification |
| Exercise expand/collapse | Spring height animation (300ms) | Selection |
| Streak milestone | Fire particle burst + counter increment animation | Success |
| Achievement unlocked | Full-screen badge reveal with radial glow | Success |
| Pull to refresh | Custom spring pull indicator | None |
| Swipe to delete | Row slides, red bg reveal, bounce-back on cancel | Warning |
| AI generating | Animated loading with pulsing dots + progress messages | None |
| Quiz transition | Slide left/right between quiz screens | Selection |

### Screen-by-Screen UX Highlights

**AI Onboarding Quiz (the conversion funnel — 8 screens):**
- Full-screen cards with large visual icons for each option
- Progress bar at top showing quiz completion
- Smooth slide transitions between screens
- Back button to revisit previous answers
- "Skip" option only on non-critical screens (injuries, body stats)
- After quiz: animated "Creating your program..." screen

**Workout Logging (the money screen — max 3 taps from app open):**
- Exercise cards: muted "Last: 80kg x 8" above inputs
- Pre-filled set values from last workout
- One-tap set completion with checkbox bounce
- Floating rest timer overlay (doesn't block logging)
- Progress bar at top fills green as exercises complete
- Sticky "Save Workout" button at bottom showing live volume total

**Dashboard:**
- Streak flame counter at top (animated)
- "Today's Workout" suggestion card (from current program)
- Recent PRs horizontal carousel (gold badges)
- "AI Coach Suggestions" card (Pro — accept/reject adaptations)
- Quick-start button for next workout

**History:**
- Date-grouped list
- Cards: workout name, exercise count, total volume, PR badges
- Search bar + program filter chips
- 30-day limit for Free users (paywall trigger)

**Progress (Pro):**
- Swipeable chart cards (strength, volume, frequency)
- Time range chips (1W / 1M / 3M / 6M / 1Y)
- "Best Lifts" summary at top (exercise -> max weight)

**Workout Summary (post-workout):**
- Stats card: duration, volume, sets, PRs
- Social sharing card generator
- Review prompt (after 3rd workout)
- "Done" or "Share" CTAs

## Data Model (PostgreSQL)

Relational tables with foreign keys:

- `users` — id (from Clerk), email, display_name, language (default 'en'), onboarding_completed (bool), created_at, updated_at
- `user_profiles` — id, user_id (FK -> users, unique), goal (text), experience_level (text), training_frequency (int), session_duration (int), equipment (text), injuries (text[] nullable), age (int nullable), height (numeric nullable), weight (numeric nullable), training_style (text), unit_preference (text default 'metric'), created_at, updated_at
- `programs` — id, user_id (FK -> users), name, description, is_ai_generated (bool default false), is_template (bool default false), is_active (bool default true), created_at, updated_at
- `workouts` — id, program_id (FK -> programs ON DELETE CASCADE), name, sort_order, created_at, updated_at
- `exercises` — id, workout_id (FK -> workouts ON DELETE CASCADE), name, type (text check strength/cardio/timed), sets (int), reps (int nullable), weight (numeric nullable), duration (int nullable), distance (numeric nullable), rest_seconds (int nullable), notes (text nullable), sort_order (int)
- `exercises_library` — id, name, muscle_group (text), equipment (text), description, is_custom (bool default false), created_by (uuid FK -> users, nullable), created_at
- `workout_logs` — id, user_id (FK -> users), program_id (FK -> programs), workout_id (FK -> workouts), date (date), duration_seconds (int nullable), notes (text nullable), created_at
- `completed_exercises` — id, log_id (FK -> workout_logs ON DELETE CASCADE), exercise_id (FK -> exercises), exercise_name (text), notes (text nullable), sort_order (int)
- `completed_sets` — id, completed_exercise_id (FK -> completed_exercises ON DELETE CASCADE), set_number (int), reps (int nullable), weight (numeric nullable), duration (int nullable), distance (numeric nullable), rpe (int nullable check 1-10), completed (bool default false), is_pr (bool default false), notes (text nullable)
- `ai_generations` — id, user_id (FK -> users), prompt_hash (text), model (text), input_tokens (int), output_tokens (int), cost_cents (numeric), program_id (FK -> programs, nullable), generation_type (text check 'program'/'adaptation'), created_at
- `ai_suggestions` — id, user_id (FK -> users), program_id (FK -> programs), suggestion_type (text check 'increase_weight'/'add_set'/'swap_exercise'/'deload'), suggestion_data (jsonb), status (text check 'pending'/'accepted'/'rejected' default 'pending'), created_at, resolved_at (timestamptz nullable)
- `streaks` — id, user_id (FK -> users, unique), current_streak (int default 0), longest_streak (int default 0), last_workout_date (date nullable), updated_at
- `achievements` — id, user_id (FK -> users), achievement_type (text), unlocked_at (timestamptz default now())
- `referrals` — id, referrer_id (FK -> users), invitee_id (FK -> users, nullable), referral_code (text unique), bonus_days_granted (bool default false), created_at

## Project Structure

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
  ui/                   # react-native-reusables (copied, not npm)
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
  supabase.ts           # Supabase client + Clerk JWT wrapper
  theme/
    ThemeProvider.tsx    # Dark/light mode context
  validations/          # Zod schemas
    user.ts
    program.ts
    exercise.ts
    log.ts
    quiz.ts             # Onboarding quiz validation
  utils/
    haptics.ts          # Haptic wrappers
    chartData.ts        # Chart transformation utilities
    sharing.ts          # Social share card generation
    reviewPrompt.ts     # App Store review prompt logic
  services/
    programs.ts
    workouts.ts
    exercises.ts
    exerciseLibrary.ts
    logs.ts
    ai.ts               # AI generation + adaptation service
    streaks.ts
    achievements.ts
    referrals.ts
hooks/
  usePrograms.ts
  useWorkouts.ts
  useExercises.ts
  useExerciseLibrary.ts
  useLogs.ts
  useAI.ts              # AI generation + suggestions hooks
  useRestTimer.ts
  useStreaks.ts
  useAchievements.ts
  useEntitlements.ts    # RevenueCat gating (useIsPro)
  useReferrals.ts
stores/
  uiStore.ts            # Zustand (UI state only: theme, active workout)
types/
  database.ts           # Auto-generated from Supabase
supabase/
  migrations/           # SQL migration files
  functions/
    clerk-webhook/      # Clerk user sync
    generate-program/   # AI program generation via Gemini
    generate-suggestions/ # AI weekly adaptation via Gemini
```

## User Stories

---

### Phase 1: Foundation (Week 1)

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

### US-002: Configure Uniwind

**Description:** As a developer, I want to install and configure Uniwind (Tailwind CSS for React Native, from the creators of Unistyles) so that all components can use Tailwind utility classes with 2.5x faster styling resolution than NativeWind.

**Acceptance Criteria:**
- [ ] `uniwind` installed and configured
- [ ] `metro.config.js` configured with Uniwind transformer
- [ ] `global.css` with Tailwind directives imported in root layout
- [ ] `uniwind-types.d.ts` generated for `className` type support
- [ ] A test component renders correctly with Uniwind `className` prop
- [ ] Typecheck passes

---

### US-003: Set up react-native-reusables

**Description:** As a developer, I want to copy base UI components from react-native-reusables into `components/ui/` so that the app has consistent, accessible primitives styled with Uniwind. Use the `minimal-uniwind` template for Uniwind-compatible components.

**Acceptance Criteria:**
- [ ] Initialize with `npx @react-native-reusables/cli@latest init -t minimal-uniwind`
- [ ] `components/ui/` directory created with base components: `Button`, `Card`, `Text`, `Input`, `Label`, `Separator`
- [ ] Components use Uniwind `className` for styling
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
- [ ] ESLint + Prettier configured with a React Native-compatible ruleset
- [ ] Path alias `@/` resolves to project root in both `tsconfig.json` and bundler config
- [ ] Folder structure created: `components/ui/`, `lib/services/`, `lib/validations/`, `lib/utils/`, `hooks/`, `stores/`, `types/`, `supabase/migrations/`, `supabase/functions/`
- [ ] `npm run lint` passes with zero errors
- [ ] Typecheck passes

---

### US-008: Configure dark mode design system

**Description:** As a developer, I want to configure the Uniwind theme with the full dark mode color palette, Inter font, and text scale so that all subsequent UI work uses consistent design tokens.

**Acceptance Criteria:**
- [ ] Uniwind theme config extended with full color token set: `background` (DEFAULT `#0F0F14`, card `#1A1A24`, elevated `#252532`, input `#2A2A3A`), `foreground` (DEFAULT `#F0F0F5`, muted `#9CA3AF`, subtle `#6B7280`), `accent` (DEFAULT `#22C55E`, pressed `#16A34A`, glow `#22C55E33`), `gold` (`#FFD700`), `destructive` (`#EF4444`), `warning` (`#F59E0B`), `info` (`#3B82F6`)
- [ ] Font family set to Inter: `fontFamily: { sans: ['Inter'] }`
- [ ] Text scale utilities defined: `hero` (text-4xl font-bold), `h1` (text-2xl font-semibold), `h2` (text-xl font-semibold), `h3` (text-base font-semibold), `body` (text-sm font-normal), `caption` (text-xs font-normal)
- [ ] `@expo-google-fonts/inter` installed and loaded in root layout
- [ ] `global.css` updated with dark mode as default
- [ ] All number displays configured with `tabular-nums` font-variant
- [ ] Typecheck passes

---

### US-009: Add expo-haptics to project dependencies

**Description:** As a developer, I want `expo-haptics` installed and a utility wrapper created so that haptic feedback can be triggered throughout the app.

**Acceptance Criteria:**
- [ ] `expo-haptics` installed via `npx expo install expo-haptics`
- [ ] `lib/utils/haptics.ts` exports wrapper functions: `hapticLight()`, `hapticMedium()`, `hapticHeavy()`, `hapticSelection()`, `hapticSuccess()`, `hapticWarning()`, `hapticNotification()`
- [ ] Each wrapper calls the corresponding `Haptics.impactAsync()` or `Haptics.notificationAsync()` method
- [ ] Web platform gracefully no-ops (no crash if haptics not supported)
- [ ] Typecheck passes

---

### Phase 2: Database Schema & Types (Week 1-2)

---

### US-010: Create SQL migrations for users table

**Description:** As a developer, I want a Supabase SQL migration for the `users` table so that user accounts are stored. Simplified for AI trainer app — no roles, no coach_id.

**Acceptance Criteria:**
- [ ] Migration file creates `users` table with columns: `id` (uuid PK), `email` (text unique), `display_name` (text), `language` (text default 'en'), `onboarding_completed` (bool default false), `created_at` (timestamptz), `updated_at` (timestamptz)
- [ ] `updated_at` trigger for auto-update
- [ ] Migration runs successfully against Supabase: `supabase db push`
- [ ] Typecheck passes

---

### US-011: Create SQL migration for user_profiles table

**Description:** As a developer, I want a `user_profiles` table to store onboarding quiz answers so that AI program generation has user data to work with.

**Acceptance Criteria:**
- [ ] Migration creates `user_profiles` table with columns: `id` (uuid PK), `user_id` (uuid FK -> users, unique), `goal` (text not null check 'build_muscle'/'lose_fat'/'get_stronger'/'improve_endurance'/'general_fitness'), `experience_level` (text not null check 'never'/'beginner'/'intermediate'/'advanced'/'expert'), `training_frequency` (int not null check 2-6), `session_duration` (int not null check in 30/45/60/90), `equipment` (text not null check 'full_gym'/'home_dumbbells'/'bodyweight'/'resistance_bands'), `injuries` (text[] nullable), `age` (int nullable), `height` (numeric nullable), `weight` (numeric nullable), `training_style` (text not null check 'ppl'/'upper_lower'/'full_body'/'bro_split'/'ai_decide'), `unit_preference` (text default 'metric' check 'metric'/'imperial'), `created_at` (timestamptz), `updated_at` (timestamptz)
- [ ] RLS policy: users can SELECT/INSERT/UPDATE their own profile only (`user_id = auth.uid()`)
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-012: Create SQL migrations for programs, workouts, and exercises tables

**Description:** As a developer, I want SQL migrations for `programs`, `workouts`, and `exercises` tables so that AI-generated and template programs can be stored.

**Acceptance Criteria:**
- [ ] Migration creates `programs` table with columns: `id` (uuid PK), `user_id` (uuid FK -> users), `name` (text not null), `description` (text), `is_ai_generated` (bool default false), `is_template` (bool default false), `is_active` (bool default true), `created_at` (timestamptz), `updated_at` (timestamptz)
- [ ] Migration creates `workouts` table with columns: `id` (uuid PK), `program_id` (uuid FK -> programs ON DELETE CASCADE), `name` (text not null), `sort_order` (int), `created_at` (timestamptz), `updated_at` (timestamptz)
- [ ] Migration creates `exercises` table with columns: `id` (uuid PK), `workout_id` (uuid FK -> workouts ON DELETE CASCADE), `name` (text not null), `type` (text check strength/cardio/timed), `sets` (int), `reps` (int nullable), `weight` (numeric nullable), `duration` (int nullable), `distance` (numeric nullable), `rest_seconds` (int nullable), `notes` (text nullable), `sort_order` (int)
- [ ] All tables have `updated_at` trigger for auto-update
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-013: Create SQL migrations for logging tables

**Description:** As a developer, I want SQL migrations for `workout_logs`, `completed_exercises`, and `completed_sets` tables so that workout data is stored relationally.

**Acceptance Criteria:**
- [ ] Migration creates `workout_logs` table with columns: `id` (uuid PK), `user_id` (uuid FK -> users), `program_id` (uuid FK -> programs), `workout_id` (uuid FK -> workouts), `date` (date not null), `duration_seconds` (int nullable), `notes` (text nullable), `created_at` (timestamptz)
- [ ] Migration creates `completed_exercises` table with columns: `id` (uuid PK), `log_id` (uuid FK -> workout_logs ON DELETE CASCADE), `exercise_id` (uuid FK -> exercises), `exercise_name` (text), `notes` (text nullable), `sort_order` (int)
- [ ] Migration creates `completed_sets` table with columns: `id` (uuid PK), `completed_exercise_id` (uuid FK -> completed_exercises ON DELETE CASCADE), `set_number` (int), `reps` (int nullable), `weight` (numeric nullable), `duration` (int nullable), `distance` (numeric nullable), `rpe` (int nullable check 1-10), `completed` (bool default false), `is_pr` (bool default false), `notes` (text nullable)
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-014: Create SQL migrations for AI tables

**Description:** As a developer, I want `ai_generations` and `ai_suggestions` tables to log AI calls and store pending program adaptations.

**Acceptance Criteria:**
- [ ] Migration creates `ai_generations` table with columns: `id` (uuid PK), `user_id` (uuid FK -> users), `prompt_hash` (text), `model` (text), `input_tokens` (int), `output_tokens` (int), `cost_cents` (numeric), `program_id` (uuid FK -> programs nullable), `generation_type` (text check 'program'/'adaptation'), `created_at` (timestamptz)
- [ ] Migration creates `ai_suggestions` table with columns: `id` (uuid PK), `user_id` (uuid FK -> users), `program_id` (uuid FK -> programs), `suggestion_type` (text check 'increase_weight'/'add_set'/'swap_exercise'/'deload'), `suggestion_data` (jsonb not null), `status` (text check 'pending'/'accepted'/'rejected' default 'pending'), `created_at` (timestamptz), `resolved_at` (timestamptz nullable)
- [ ] RLS: users can SELECT their own rows; only Edge Functions (service role) can INSERT
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-015: Create SQL migration for exercises_library table

**Description:** As a developer, I want an `exercises_library` table so that the app has a shared database of exercises that AI and users can reference.

**Acceptance Criteria:**
- [ ] Migration creates `exercises_library` table with columns: `id` (uuid PK), `name` (text not null), `muscle_group` (text not null), `equipment` (text), `description` (text), `is_custom` (bool default false), `created_by` (uuid FK -> users, nullable), `created_at` (timestamptz)
- [ ] Index on `muscle_group` for filtered queries
- [ ] Index on `name` for search queries
- [ ] RLS policy: all authenticated users can SELECT; users can INSERT/UPDATE/DELETE only rows where `created_by = auth.uid()` and `is_custom = true`
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-016: Seed exercises_library with common exercises

**Description:** As a developer, I want the exercises library seeded with ~50 common exercises so that the AI has a reference set and users have a useful starting library.

**Acceptance Criteria:**
- [ ] Seed migration inserts ~50 exercises covering major muscle groups: chest (bench press, incline press, dumbbell fly, push-up, cable crossover), back (pull-up, barbell row, seated row, lat pulldown, deadlift), shoulders (overhead press, lateral raise, face pull, front raise, arnold press), legs (squat, leg press, lunges, leg curl, leg extension, calf raise, Romanian deadlift), arms (bicep curl, hammer curl, tricep pushdown, skull crusher, dip), core (plank, crunch, hanging leg raise, Russian twist, ab wheel)
- [ ] Each exercise has `name`, `muscle_group`, `equipment` (barbell/dumbbell/cable/machine/bodyweight), and `description`
- [ ] `is_custom` is false for all seeded exercises
- [ ] `created_by` is null for all seeded exercises
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-017: Create SQL migrations for streaks, achievements, and referrals tables

**Description:** As a developer, I want database tables for streaks, achievements, and referrals so that gamification and viral growth features have persistent storage.

**Acceptance Criteria:**
- [ ] Migration creates `streaks` table with columns: `id` (uuid PK), `user_id` (uuid FK -> users, unique), `current_streak` (int default 0), `longest_streak` (int default 0), `last_workout_date` (date nullable), `updated_at` (timestamptz)
- [ ] Migration creates `achievements` table with columns: `id` (uuid PK), `user_id` (uuid FK -> users), `achievement_type` (text not null), `unlocked_at` (timestamptz default now())
- [ ] Unique constraint on `achievements(user_id, achievement_type)` to prevent duplicates
- [ ] Migration creates `referrals` table with columns: `id` (uuid PK), `referrer_id` (uuid FK -> users), `invitee_id` (uuid FK -> users, nullable), `referral_code` (text unique not null), `bonus_days_granted` (bool default false), `created_at` (timestamptz)
- [ ] RLS policies: users can SELECT/UPDATE their own streak; users can SELECT their own achievements; users can SELECT/INSERT their own referrals
- [ ] Achievement types documented: `first_workout`, `streak_7`, `streak_30`, `streak_100`, `prs_10`
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-018: Add RLS policies for all tables

**Description:** As a developer, I want RLS enabled on all tables with policies so that users can only access their own data.

**Acceptance Criteria:**
- [ ] Migration enables RLS on all tables: `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`
- [ ] `users` table: users can SELECT/UPDATE their own row (`auth.uid() = id`)
- [ ] `programs` table: users can CRUD their own programs (`user_id = auth.uid()`); all users can SELECT template programs (`is_template = true`)
- [ ] `workouts` table: access inherits through `program_id` -> `programs.user_id`
- [ ] `exercises` table: access inherits through `workout_id` -> `workouts.program_id` -> `programs.user_id`
- [ ] `workout_logs` table: users can INSERT/SELECT their own logs
- [ ] `completed_exercises` / `completed_sets`: access inherits through log chain
- [ ] Helper function created: `auth.uid()` extracts user ID from Supabase JWT (Clerk-issued)
- [ ] Unauthenticated requests return zero rows
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-019: Generate TypeScript types from Supabase

**Description:** As a developer, I want auto-generated TypeScript types from the Supabase schema so that all database queries are type-safe.

**Acceptance Criteria:**
- [ ] `supabase gen types typescript --local > types/database.ts` generates types
- [ ] `types/database.ts` exports `Database` type with all table definitions
- [ ] Helper types exported: `Tables<T>`, `Enums<T>`, `TablesInsert<T>`, `TablesUpdate<T>`
- [ ] Supabase client in `lib/supabase.ts` uses `Database` generic parameter
- [ ] Script added to `package.json`: `"db:types": "supabase gen types typescript --local > types/database.ts"`
- [ ] Typecheck passes

---

### US-020: Create Zod validation schemas

**Description:** As a developer, I want Zod schemas for form validation and API input validation so that data integrity is enforced at the application layer.

**Acceptance Criteria:**
- [ ] `lib/validations/quiz.ts` exports: `goalSchema`, `experienceSchema`, `frequencySchema`, `durationSchema`, `equipmentSchema`, `injuriesSchema`, `bodyStatsSchema`, `trainingStyleSchema`, `fullQuizSchema` (combines all)
- [ ] `lib/validations/program.ts` exports: `programSchema` (name required, description optional), `workoutSchema` (name required)
- [ ] `lib/validations/exercise.ts` exports: `exerciseSchema` (name, type, sets required; reps/weight/duration/distance conditional on type)
- [ ] `lib/validations/log.ts` exports: `completedSetSchema`, `completedExerciseSchema`, `workoutLogSchema`
- [ ] All schemas export inferred TypeScript types via `z.infer<>`
- [ ] Typecheck passes

---

### Phase 3: Auth + Onboarding (Week 2)

---

### US-021: Set up Clerk provider

**Description:** As a developer, I want to wrap the app in a Clerk provider so that authentication is available throughout the component tree.

**Acceptance Criteria:**
- [ ] `@clerk/clerk-expo` installed
- [ ] Root `_layout.tsx` wraps children in `<ClerkProvider publishableKey={...}>`
- [ ] Clerk publishable key loaded from environment variable
- [ ] `expo-secure-store` configured as Clerk's token cache
- [ ] App launches without errors with Clerk provider active
- [ ] Typecheck passes

---

### US-022: Build Sign In screen with Google and Apple OAuth

**Description:** As a user, I want to sign in with Google or Apple so that onboarding is fast and frictionless. No email/password for MVP.

**Acceptance Criteria:**
- [ ] `app/(auth)/sign-in.tsx` renders "Continue with Google" and "Continue with Apple" buttons
- [ ] Uses Clerk's `useOAuth` hook with `strategy: 'oauth_google'` and `strategy: 'oauth_apple'`
- [ ] Apple sign-in button only shown on iOS
- [ ] OAuth flow completes and creates user in Clerk, triggering webhook sync to Supabase
- [ ] On first sign-in, redirects to onboarding quiz
- [ ] On returning sign-in, redirects to main app (if onboarding completed)
- [ ] Error states handled (cancelled, network error)
- [ ] Buttons styled per platform guidelines (Apple: black button, Google: white with logo)
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-023: Create Clerk-to-Supabase JWT wrapper

**Description:** As a developer, I want an authenticated Supabase client that uses Clerk JWTs so that RLS policies can identify the current user.

**Acceptance Criteria:**
- [ ] `lib/supabase.ts` exports `useSupabaseClient()` hook that creates a Supabase client with Clerk's JWT token in the Authorization header
- [ ] Uses Clerk's `useAuth().getToken({ template: 'supabase' })` to fetch JWT
- [ ] **Manual step documented:** Clerk Dashboard -> JWT Templates -> create "supabase" template with Supabase JWT secret
- [ ] Supabase client uses `auth.getUser()` to confirm JWT is valid
- [ ] Typecheck passes

---

### US-024: Create user sync webhook (Edge Function)

**Description:** As a developer, I want a Supabase Edge Function that receives Clerk webhooks and upserts users into the `users` table so that auth and database stay in sync.

**Acceptance Criteria:**
- [ ] `supabase/functions/clerk-webhook/index.ts` (Deno) handles Clerk `user.created` and `user.updated` webhook events
- [ ] Verifies webhook signature using Clerk's `svix` library
- [ ] Upserts into `users` table: id (from Clerk user ID), email, display_name
- [ ] Returns 200 on success, 400 on invalid payload, 401 on bad signature
- [ ] Edge Function deploys: `supabase functions deploy clerk-webhook`
- [ ] Typecheck passes

---

### US-025: Add auth-gated Expo Router groups

**Description:** As a developer, I want the root layout to show auth screens when not logged in and the main app when logged in so that unauthenticated users cannot access the app.

**Acceptance Criteria:**
- [ ] Root `_layout.tsx` checks `useAuth().isSignedIn` from Clerk
- [ ] If not signed in, renders `(auth)` group (sign-in screen)
- [ ] If signed in and onboarding not completed, redirects to onboarding quiz
- [ ] If signed in and onboarding completed, redirects to `(app)` group
- [ ] Shows a loading spinner while auth state is initializing (`isLoaded === false`)
- [ ] Styled with Uniwind
- [ ] Typecheck passes

---

### US-026: Build AI onboarding quiz — Goal screen

**Description:** As a new user, I want to select my fitness goal so that the AI can generate an appropriate program.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding/goal.tsx` renders 5 goal options with visual icons: Build Muscle, Lose Fat, Get Stronger, Improve Endurance, General Fitness
- [ ] Each option is a selectable card with icon and brief description
- [ ] Single-select — tapping one deselects others
- [ ] "Next" button enabled only when an option is selected
- [ ] Progress bar at top showing step 1/8
- [ ] Selection stored in local quiz state (Zustand or React state)
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-027: Build AI onboarding quiz — Experience screen

**Description:** As a new user, I want to select my experience level so that the AI calibrates exercise selection and volume.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding/experience.tsx` renders 5 options: Never Trained, Beginner (<6mo), Intermediate (6mo-2yr), Advanced (2yr+), Expert (5yr+)
- [ ] Each option shows level name and description of what it means
- [ ] Single-select card UI
- [ ] "Next" and "Back" navigation
- [ ] Progress bar showing step 2/8
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-028: Build AI onboarding quiz — Frequency screen

**Description:** As a new user, I want to select how many times per week I can train so that the AI generates the right number of workouts.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding/frequency.tsx` renders options: 2x, 3x, 4x, 5x, 6x per week
- [ ] Each option is a selectable pill/card
- [ ] Single-select
- [ ] "Next" and "Back" navigation
- [ ] Progress bar showing step 3/8
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-029: Build AI onboarding quiz — Duration screen

**Description:** As a new user, I want to select my preferred session duration so that the AI generates workouts that fit my time.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding/duration.tsx` renders options: 30 min, 45 min, 60 min, 90 min
- [ ] Each option is a selectable pill/card
- [ ] Single-select
- [ ] "Next" and "Back" navigation
- [ ] Progress bar showing step 4/8
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-030: Build AI onboarding quiz — Equipment screen

**Description:** As a new user, I want to select my available equipment so that the AI only prescribes exercises I can do.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding/equipment.tsx` renders options with icons: Full Gym, Home with Dumbbells, Bodyweight Only, Resistance Bands
- [ ] Each option has a brief description (e.g., "Full Gym: Barbells, dumbbells, cables, machines")
- [ ] Single-select
- [ ] "Next" and "Back" navigation
- [ ] Progress bar showing step 5/8
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-031: Build AI onboarding quiz — Injuries screen

**Description:** As a new user, I want to select any injuries or limitations so that the AI avoids exercises that could cause pain.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding/injuries.tsx` renders multi-select options: Shoulder, Knee, Lower Back, Wrist, Hip, Neck, None
- [ ] Selecting "None" deselects all others; selecting any injury deselects "None"
- [ ] Multi-select card UI
- [ ] "Next" and "Back" navigation
- [ ] Progress bar showing step 6/8
- [ ] "Skip" option available (defaults to "None")
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-032: Build AI onboarding quiz — Body Stats screen

**Description:** As a new user, I want to enter my age, height, and weight so that the AI can calculate appropriate starting weights and track body stats.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding/body-stats.tsx` renders inputs for: Age (number), Height (number + unit toggle cm/ft-in), Weight (number + unit toggle kg/lbs)
- [ ] All fields optional (skip-friendly) but encouraged with helper text
- [ ] Unit toggle persists to quiz state as `unit_preference`
- [ ] Input validation via Zod: age 13-99, height 100-250cm, weight 30-300kg
- [ ] "Next" and "Back" navigation
- [ ] Progress bar showing step 7/8
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-033: Build AI onboarding quiz — Training Style screen

**Description:** As a new user, I want to select my preferred training style so that the AI structures the program accordingly.

**Acceptance Criteria:**
- [ ] `app/(auth)/onboarding/training-style.tsx` renders 5 options with brief explanations: Push/Pull/Legs ("Muscles grouped by movement"), Upper/Lower ("Alternate upper and lower body"), Full Body ("Hit everything each session"), Bro Split ("One muscle group per day"), Let AI Decide ("We'll pick the best split for your goals")
- [ ] Single-select card UI
- [ ] "Generate My Program" button (instead of "Next") — navigates to AI generation screen
- [ ] Progress bar showing step 8/8
- [ ] On submit: saves all quiz data to `user_profiles` table via Supabase
- [ ] Sets `users.onboarding_completed = true`
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-034: Save onboarding data to user_profiles table

**Description:** As a developer, I want the quiz completion to persist all answers to the database so that AI generation can use them.

**Acceptance Criteria:**
- [ ] `lib/services/userProfile.ts` exports `createUserProfile(data)` and `getUserProfile(userId)`
- [ ] `hooks/useUserProfile.ts` exports `useUserProfile(userId)` and `useCreateUserProfile`
- [ ] Quiz completion triggers `createUserProfile` with all 8 screens of data
- [ ] Validates data against `fullQuizSchema` before insert
- [ ] `users.onboarding_completed` set to `true` after successful profile creation
- [ ] TanStack Query cache updated
- [ ] Typecheck passes

---

### Phase 4: AI Program Generation (Week 3)

---

### US-035: Build AI system prompt for program generation

**Description:** As a developer, I want a detailed system prompt that encodes training principles so that Gemini generates high-quality, personalized workout programs.

**Acceptance Criteria:**
- [ ] System prompt stored in `supabase/functions/generate-program/system-prompt.ts` (can be updated without app deploy)
- [ ] Prompt encodes: progressive overload principles, volume recommendations per muscle group (10-20 sets/week), exercise selection hierarchy (compounds first, then isolations), injury modifications (e.g., no overhead press for shoulder injuries, no deep squats for knee injuries), rest period guidelines (60-90s hypertrophy, 2-3min strength), RPE targets by experience level, periodization basics
- [ ] Prompt specifies JSON output schema: `{ programName: string, description: string, workouts: [{ name: string, exercises: [{ name: string, type: string, sets: number, reps: number, weight: number | null, restSeconds: number, notes: string }] }] }`
- [ ] Prompt references exercise library names for consistency
- [ ] Prompt handles all combinations of goals x experience x equipment x injuries x training styles
- [ ] Typecheck passes

---

### US-036: Create Supabase Edge Function for AI program generation

**Description:** As a developer, I want a Supabase Edge Function that calls Google Gemini API to generate a personalized workout program and returns structured JSON.

**Acceptance Criteria:**
- [ ] `supabase/functions/generate-program/index.ts` (Deno) accepts POST with `{ userId: string }`
- [ ] Fetches user profile from `user_profiles` table
- [ ] Constructs prompt from system prompt + user profile data
- [ ] Calls Google Gemini API (`@google/generative-ai` SDK) with structured JSON output (JSON Schema)
- [ ] Uses Gemini 2.5 Flash as primary model, falls back to Gemini 2.5 Flash-Lite if rate limited
- [ ] Validates AI response against expected schema
- [ ] Logs generation to `ai_generations` table (model, tokens, cost)
- [ ] Returns validated program JSON
- [ ] Error handling: rate limiting (fallback to Flash-Lite), API failures, invalid output (retry once)
- [ ] GEMINI_API_KEY stored as Supabase Edge Function secret
- [ ] Edge Function deploys: `supabase functions deploy generate-program`
- [ ] Typecheck passes

---

### US-037: Build "generating your program" loading screen

**Description:** As a user, I want an animated loading screen while my program is being generated so that I feel engaged during the AI processing time.

**Acceptance Criteria:**
- [ ] `app/(auth)/generating.tsx` shows animated loading UI
- [ ] Animated elements: pulsing AI icon, rotating progress ring, cycling motivational messages ("Analyzing your goals...", "Selecting exercises...", "Optimizing your program...", "Almost there...")
- [ ] Messages cycle every 2-3 seconds with fade transitions
- [ ] Screen calls the `generate-program` Edge Function
- [ ] On success: navigates to program display screen
- [ ] On error: shows retry button with error message
- [ ] Minimum display time of 3 seconds (even if AI is faster) to build anticipation
- [ ] Styled with Uniwind dark theme + accent green for progress elements
- [ ] Typecheck passes

---

### US-038: Save AI-generated program to database

**Description:** As a developer, I want the AI-generated program JSON to be saved to the programs/workouts/exercises tables so that it persists and can be used for logging.

**Acceptance Criteria:**
- [ ] `lib/services/ai.ts` exports `saveGeneratedProgram(userId, programJson)` that atomically inserts into `programs`, `workouts`, and `exercises` tables
- [ ] Uses a Supabase RPC function for transactional insert
- [ ] Program marked with `is_ai_generated = true`
- [ ] Any existing active program for the user is set to `is_active = false`
- [ ] Returns the created program ID
- [ ] TanStack Query cache invalidated for programs
- [ ] Typecheck passes

---

### US-039: Build program display screen

**Description:** As a user, I want to see my AI-generated program with all workouts and exercises so that I know what I'll be doing.

**Acceptance Criteria:**
- [ ] `app/(app)/program.tsx` displays the active program: name, description, list of workouts
- [ ] Each workout expandable to show exercises with prescribed sets/reps/weight/rest
- [ ] "Start Workout" button on each workout card
- [ ] "Regenerate Program" option (Pro only — shows paywall for Free users after first generation)
- [ ] Empty state if no program exists: "Generate your first program" CTA
- [ ] Accordion animations for workout expansion (Reanimated)
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-040: Create exercise library service and hooks

**Description:** As a developer, I want a service module and TanStack Query hooks for the exercise library so that screens and AI can search and reference exercises.

**Acceptance Criteria:**
- [ ] `lib/services/exerciseLibrary.ts` exports `getExercises(filters?)`, `searchExercises(query)`, `getExercisesByMuscleGroup(group)`, `createCustomExercise(data)`, `deleteCustomExercise(id)`
- [ ] `hooks/useExerciseLibrary.ts` exports `useExercises(filters?)`, `useSearchExercises(query)`, `useExercisesByMuscleGroup(group)`, `useCreateCustomExercise`, `useDeleteCustomExercise`
- [ ] Search supports partial name matching (ILIKE)
- [ ] Mutations invalidate `['exercises_library']` query key
- [ ] All functions use the authenticated Supabase client
- [ ] Typecheck passes

---

### Phase 5: Workout Tracking (Week 4-5)

---

### US-041: Build trainee dashboard

**Description:** As a user, I want a dashboard showing today's suggested workout, my streak, recent PRs, and AI suggestions so that I can quickly start training.

**Acceptance Criteria:**
- [ ] `app/(app)/dashboard.tsx` displays:
  - Streak flame counter at top (animated, from `useStreak`)
  - "Today's Workout" card (next workout in active program rotation) with "Start" button
  - Recent PRs horizontal scroll (gold badges, last 5 PRs)
  - AI Coach Suggestions card (Pro only — shows pending suggestions with accept/reject)
- [ ] Quick-start tapping "Start" navigates directly to workout logging screen
- [ ] If no active program: shows "Generate Your Program" or "Browse Templates" CTAs
- [ ] All data fetched via TanStack Query hooks
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-042: Build workout logging screen — checklist UI

**Description:** As a user, I want a checklist-style interface showing all exercises in my chosen workout so that I can track completion visually.

**Acceptance Criteria:**
- [ ] `app/(app)/workout/[workoutId].tsx` lists exercises as checklist items via `useExercisesByWorkout`
- [ ] Each exercise shows name, prescribed sets/reps/weight in a Card
- [ ] Exercises can be expanded to show set-by-set input (accordion-style)
- [ ] A progress bar at top fills green as exercises are completed
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-043: Add set input fields to logging screen

**Description:** As a user, I want to input reps, weight, RPE for each set so that my workout is fully recorded.

**Acceptance Criteria:**
- [ ] Each expanded exercise shows rows for each prescribed set
- [ ] Input fields managed by React Hook Form — adapt to exercise type: strength shows reps + weight, cardio shows duration + distance, timed shows duration
- [ ] RPE is an optional selector (1-10)
- [ ] Marking a set as completed toggles its checkbox with scale bounce animation + `hapticLight()`
- [ ] All inputs use react-native-reusables `Input` component with oversized tap targets (56px+)
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-044: Add per-exercise and per-workout notes

**Description:** As a user, I want to add notes to individual exercises or the entire workout so that I can record how I felt.

**Acceptance Criteria:**
- [ ] Each exercise section has an optional "Add note" text input (collapsible)
- [ ] The bottom of the logging screen has a "Workout notes" text input
- [ ] Notes stored in form state managed by React Hook Form
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-045: Show previous workout data

**Description:** As a user, I want to see my last logged values for each exercise while logging so that I know what to aim for.

**Acceptance Criteria:**
- [ ] When opening the logging screen, fetch the most recent log for the same workout
- [ ] For each exercise, display "Last: X reps @ Y kg" in muted text above the input fields
- [ ] If no previous data exists, show nothing
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-046: Save workout log (transactional)

**Description:** As a user, I want to save my completed workout atomically so that it is persisted consistently.

**Acceptance Criteria:**
- [ ] "Save Workout" button at the bottom of the logging screen
- [ ] Calls a Supabase RPC function (`save_workout_log`) that atomically inserts into `workout_logs`, `completed_exercises`, and `completed_sets` within a transaction
- [ ] RPC function created via SQL migration
- [ ] Records `duration_seconds` (time from screen open to save)
- [ ] Button is disabled if no sets are marked as completed
- [ ] TanStack Query cache invalidated after save (logs, streaks, achievements)
- [ ] After save, triggers streak update and achievement check
- [ ] Navigates to workout summary screen on success
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-047: Build rest timer

**Description:** As a user, I want a rest timer that auto-starts after completing a set so that I can track rest periods without leaving the logging screen.

**Acceptance Criteria:**
- [ ] Rest timer component renders as a floating overlay at the bottom of the logging screen (doesn't block exercise inputs)
- [ ] Timer auto-starts when a set is marked as completed
- [ ] Preset buttons: 30s, 60s, 90s, 120s
- [ ] Default rest time taken from the exercise's `rest_seconds` field
- [ ] Circular ring progress animation (Reanimated) shows time remaining
- [ ] Last 3 seconds: number scale pulse animation + `hapticSelection()` per tick
- [ ] On timer expiry: "Next Set" button pulses with green glow, `hapticNotification()` fires
- [ ] Timer can be dismissed, paused, or reset manually
- [ ] Timer state managed by `useRestTimer` hook (Zustand for UI state)
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-048: Add PR auto-detection

**Description:** As a user, I want the app to automatically detect when I set a personal record so that PRs are tracked without manual input.

**Acceptance Criteria:**
- [ ] When a set is completed, compare the weight to the user's historical max for the same exercise name at the same or lower rep count
- [ ] Historical max queried via service function `getExercisePR(userId, exerciseName)`
- [ ] If current weight > historical max, flag the set with `is_pr = true`
- [ ] PR detection runs client-side during logging (compare against cached history)
- [ ] PR flag is saved when workout is saved via the `save_workout_log` RPC
- [ ] Typecheck passes

---

### US-049: Add PR celebration animation

**Description:** As a user, I want a celebration animation when I hit a new PR so that the achievement feels rewarding.

**Acceptance Criteria:**
- [ ] When `is_pr = true` is detected on a completed set, trigger celebration:
  - Gold confetti burst animation (Reanimated)
  - "NEW PR" badge slides in from right with gold glow (`#FFD700`)
  - Weight number briefly glows gold
- [ ] `hapticHeavy()` fires on PR detection
- [ ] Celebration animation is non-blocking (logging can continue)
- [ ] Animation duration: ~2 seconds, then fades
- [ ] `components/PRCelebration.tsx` is a reusable component accepting the PR value
- [ ] Styled with Uniwind dark theme + gold accent
- [ ] Typecheck passes

---

### US-050: Build workout summary screen

**Description:** As a user, I want a summary screen after saving a workout showing key stats so that I can review what I accomplished.

**Acceptance Criteria:**
- [ ] `app/(app)/workout/summary.tsx` shows after workout save
- [ ] Summary displays: total workout duration, total volume (sum of sets x reps x weight), total sets completed, number of PRs hit
- [ ] If any PRs were hit, show gold PR badges with exercise name and weight
- [ ] Checkmark draw animation on load (Reanimated) + `hapticMedium()`
- [ ] "Share" button to generate and share social card (see US-058)
- [ ] "Done" button navigates back to dashboard
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-051: Add Reanimated animations to logging

**Description:** As a user, I want smooth animations when expanding exercises and completing sets so that the logging experience feels polished.

**Acceptance Criteria:**
- [ ] `react-native-reanimated` installed and configured
- [ ] Exercise expand/collapse uses `Layout` animations (entering/exiting)
- [ ] Set completion checkbox has a scale + checkmark animation
- [ ] Progress bar animates smoothly as exercises are completed
- [ ] Animations do not cause layout jumps
- [ ] Typecheck passes

---

### US-052: Create workout log services and hooks

**Description:** As a developer, I want service modules and TanStack Query hooks for workout logging so that screens can fetch and mutate log data.

**Acceptance Criteria:**
- [ ] `lib/services/logs.ts` exports `getUserLogs(userId, options?)`, `getLogWithDetails(logId)`, `getExerciseLogs(userId, exerciseName)`, `getExercisePR(userId, exerciseName)`, `getRecentPRs(userId, limit)`
- [ ] `hooks/useLogs.ts` exports `useUserLogs(options?)`, `useLogWithDetails(logId)`, `useExerciseLogs(exerciseName)`, `useRecentPRs(limit)`
- [ ] Options support: date range filtering, program filtering, limit/offset pagination
- [ ] All functions use the authenticated Supabase client
- [ ] Typecheck passes

---

### US-053: Create program and workout services and hooks

**Description:** As a developer, I want service modules and TanStack Query hooks for programs, workouts, and exercises so that screens can fetch and display program data.

**Acceptance Criteria:**
- [ ] `lib/services/programs.ts` exports `getUserPrograms(userId)`, `getActiveProgram(userId)`, `getProgram(id)`, `setActiveProgram(userId, programId)`, `deleteProgram(id)`
- [ ] `lib/services/workouts.ts` exports `getWorkoutsByProgram(programId)`, `getWorkout(id)`
- [ ] `lib/services/exercises.ts` exports `getExercisesByWorkout(workoutId)`
- [ ] `hooks/usePrograms.ts` exports `useActiveProgram()`, `useProgram(id)`, `useSetActiveProgram`, `useDeleteProgram`
- [ ] `hooks/useWorkouts.ts` exports `useWorkoutsByProgram(programId)`, `useWorkout(id)`
- [ ] `hooks/useExercises.ts` exports `useExercisesByWorkout(workoutId)`
- [ ] All functions use the authenticated Supabase client
- [ ] Mutations invalidate relevant query keys
- [ ] Typecheck passes

---

### Phase 6: History + Progress (Week 5-6)

---

### US-054: Build history list screen

**Description:** As a user, I want to see a chronological list of my past workouts so that I can review my training.

**Acceptance Criteria:**
- [ ] `app/(app)/history/index.tsx` fetches logs via `useUserLogs`
- [ ] List rendered with `FlashList`
- [ ] Each item shows date, workout name, exercise count, total volume, PR badges (using Card)
- [ ] List sorted by date descending (newest first)
- [ ] Tapping an item navigates to history detail screen
- [ ] **Free tier:** Only shows last 30 days. Trying to scroll past triggers paywall.
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-055: Build history detail screen

**Description:** As a user, I want to see the full details of a past workout including all sets and notes so that I can reflect on my performance.

**Acceptance Criteria:**
- [ ] `app/(app)/history/[id].tsx` fetches log with details via `useLogWithDetails`
- [ ] Shows workout name, date, duration, and all completed exercises with their sets
- [ ] Each exercise shows sets with reps, weight, RPE, PR badges
- [ ] Exercise-level and workout-level notes displayed
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-056: Add search and filter to history

**Description:** As a user, I want to filter my history by exercise name or date range so that I can find specific workouts.

**Acceptance Criteria:**
- [ ] History list screen has a search bar that filters by exercise name
- [ ] Date range picker to narrow results
- [ ] Filters combine (AND logic) and update the query
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-057: Create chart data utilities

**Description:** As a developer, I want utility functions that transform workout logs into chart-ready data series so that chart components receive clean input.

**Acceptance Criteria:**
- [ ] `lib/utils/chartData.ts` exports `getExerciseProgressData(logs, exerciseName)` returning `{ date: string, value: number }[]` for max weight over time
- [ ] Exports `getVolumeProgressData(logs, exerciseName)` returning total volume (sets x reps x weight) over time
- [ ] Handles missing or partial data gracefully (skips entries without weight)
- [ ] Typecheck passes

---

### US-058: Build chart components

**Description:** As a developer, I want reusable line chart and bar chart components wrapping a charting library so that screens can render progress visuals.

**Acceptance Criteria:**
- [ ] `components/LineChart.tsx` renders a line chart given `{ date: string, value: number }[]` data and axis labels
- [ ] `components/BarChart.tsx` renders a bar chart given `{ label: string, value: number }[]` data
- [ ] Charts are responsive to screen width
- [ ] Charts use accent green for data lines, gold for PR markers
- [ ] Styled with Uniwind dark theme for surrounding elements
- [ ] Typecheck passes

---

### US-059: Build progress screen (Pro)

**Description:** As a Pro user, I want a progress screen showing charts of my exercise improvements over time so that I can see my gains.

**Acceptance Criteria:**
- [ ] `app/(app)/progress.tsx` lets the user pick an exercise from a dropdown (populated from logged exercise names)
- [ ] Displays a line chart of weight progression and a bar chart of volume over time
- [ ] Time range chips: 1W, 1M, 3M, 6M, 1Y
- [ ] "Best Lifts" summary at top showing exercise -> max weight for top 5 exercises
- [ ] Shows "No data yet" empty state if the exercise has no logged history
- [ ] **Gated behind Pro subscription** via `<ProGate>` — Free users see paywall
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### Phase 7: Monetization (Week 6-7)

---

### US-060: Set up RevenueCat SDK

**Description:** As a developer, I want to install and configure the RevenueCat SDK so that the app can manage subscriptions and in-app purchases.

**Acceptance Criteria:**
- [ ] `react-native-purchases` installed
- [ ] RevenueCat configured in root layout with API key from environment variable
- [ ] User identified with Clerk user ID via `Purchases.logIn(userId)`
- [ ] **Requires EAS dev build** — not compatible with Expo Go
- [ ] Typecheck passes

---

### US-061: Build paywall screen

**Description:** As a user, I want a paywall screen presenting subscription options so that I can upgrade to Pro.

**Acceptance Criteria:**
- [ ] `app/(app)/paywall.tsx` displays available subscription packages from RevenueCat
- [ ] Shows three options: Monthly ($6.99/mo), Annual ($49.99/yr — "40% savings" badge), Lifetime ($99.99)
- [ ] 7-day free trial prominently displayed for monthly and annual
- [ ] Feature comparison section (Free vs Pro table)
- [ ] Social proof: "Join 10,000+ lifters training with AI"
- [ ] "Subscribe" button calls `Purchases.purchasePackage(package)`
- [ ] Handles purchase success, cancellation, and error states
- [ ] On success: dismiss paywall and unlock feature
- [ ] "Restore Purchases" link at bottom
- [ ] Styled with Uniwind dark theme + gradient CTA button
- [ ] Typecheck passes

---

### US-062: Implement entitlement gating

**Description:** As a developer, I want to gate premium features behind RevenueCat entitlements so that only paying users can access them.

**Acceptance Criteria:**
- [ ] `hooks/useEntitlements.ts` exports `useIsPro()` hook that checks RevenueCat entitlements
- [ ] `useIsPro()` returns `{ isPro: boolean, isLoading: boolean }`
- [ ] `components/ProGate.tsx` wrapper component shows paywall when user is not Pro
- [ ] Features gated: progress charts, history beyond 30 days, AI regeneration (after first free), AI suggestions, full achievement system, CSV export, clean social sharing cards
- [ ] Typecheck passes

---

### US-063: Restore purchases

**Description:** As a user, I want a "Restore Purchases" button so that I can recover my subscription on a new device.

**Acceptance Criteria:**
- [ ] Settings screen and paywall screen include a "Restore Purchases" button
- [ ] Calls `Purchases.restorePurchases()` on tap
- [ ] Shows success/failure feedback via toast or alert
- [ ] Updates `useIsPro()` state after restore
- [ ] Typecheck passes

---

### US-064: Add subscription status to settings

**Description:** As a user, I want to see my current subscription status in settings so that I know my plan.

**Acceptance Criteria:**
- [ ] Settings screen shows subscription status: "Free" or "Pro (expires [date])" or "Pro (Lifetime)"
- [ ] If free, shows "Upgrade to Pro" button that navigates to paywall
- [ ] Data from RevenueCat via `Purchases.getCustomerInfo()`
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-065: Implement smart paywall triggers

**Description:** As a developer, I want paywall triggers at strategic moments so that free users are nudged to upgrade when they feel the value.

**Acceptance Criteria:**
- [ ] Paywall triggered when:
  - Free user tries to view history beyond 30 days
  - Free user taps on progress charts tab
  - Free user tries to regenerate AI program (after first free generation)
  - After AI generates suggestions (show suggestions preview, paywall to apply them)
  - After hitting a PR: celebration + subtle "Unlock AI to keep progressing" prompt
- [ ] Each trigger point navigates to paywall with context-specific messaging
- [ ] Track paywall trigger source for analytics (store in paywall route params)
- [ ] Typecheck passes

---

### Phase 8: Engagement + Polish (Week 7-8)

---

### US-066: Track workout streaks

**Description:** As a user, I want my workout streaks automatically tracked so that I can see how many consecutive days I've been training.

**Acceptance Criteria:**
- [ ] `lib/services/streaks.ts` exports `updateStreak(userId)` called after each workout save
- [ ] Streak logic: if `last_workout_date` is yesterday or today, increment `current_streak`; if more than 1 day gap, reset `current_streak` to 1; update `longest_streak` if current exceeds it
- [ ] `hooks/useStreaks.ts` exports `useStreak(userId)` query hook and `useUpdateStreak` mutation hook
- [ ] Streak update integrated into the `save_workout_log` flow
- [ ] Streak row auto-created on first workout save if not exists
- [ ] Typecheck passes

---

### US-067: Build achievement system (simplified — 5 types)

**Description:** As a user, I want to earn achievement badges for key milestones so that I have additional motivation.

**Acceptance Criteria:**
- [ ] `lib/services/achievements.ts` exports `checkAndUnlockAchievements(userId)` that evaluates 5 achievement conditions:
  - `first_workout`: 1+ total workouts
  - `streak_7`: current streak reaches 7 days
  - `streak_30`: current streak reaches 30 days
  - `streak_100`: current streak reaches 100 days
  - `prs_10`: total PR count reaches 10
- [ ] Called after each workout save
- [ ] Newly unlocked achievements returned so UI can trigger celebration
- [ ] `hooks/useAchievements.ts` exports `useAchievements(userId)` and `useCheckAchievements`
- [ ] Full achievement system (all 5 types) requires Pro; Free users only see streak counter
- [ ] Typecheck passes

---

### US-068: Build streak counter and achievement display

**Description:** As a user, I want to see my streak counter on the dashboard and achievements in settings so that my progress is visible.

**Acceptance Criteria:**
- [ ] `components/StreakCounter.tsx` shows current streak number with flame icon, animated increment on new streak day
- [ ] Streak counter placed at top of dashboard
- [ ] Fire particle burst animation (Reanimated) + `hapticSuccess()` on streak milestones (7, 30, 100)
- [ ] `components/AchievementBadge.tsx` renders individual badge with icon and name
- [ ] Achievement showcase grid on settings screen showing all 5 badges (locked = gray, unlocked = colored)
- [ ] Full-screen badge reveal animation when new achievement unlocked
- [ ] Styled with Uniwind dark theme + gold accent for achievements
- [ ] Typecheck passes

---

### US-069: Build social sharing card generator

**Description:** As a user, I want to share a beautiful workout summary card on social media so that I can show off my progress and organically promote the app.

**Acceptance Criteria:**
- [ ] `components/ShareCard.tsx` renders a dark-mode card with: app logo, workout name + "COMPLETE", duration, total volume, sets count, PR count, streak counter
- [ ] `react-native-view-shot` captures the card as an image
- [ ] `expo-sharing` opens the share sheet to Instagram Stories, WhatsApp, etc.
- [ ] **Free users:** Card includes app name watermark and "Get your AI trainer" text
- [ ] **Pro users:** Clean card without promotional text
- [ ] Share button available on workout summary screen (US-050)
- [ ] Styled with Uniwind dark theme + accent colors
- [ ] Typecheck passes

---

### US-070: Build review prompt system

**Description:** As a developer, I want a smart review prompt that asks engaged users to rate the app at the optimal moment for maximum positive reviews.

**Acceptance Criteria:**
- [ ] `lib/utils/reviewPrompt.ts` exports `maybePromptReview()` that:
  - Only triggers after the user's 3rd completed workout
  - Only triggers once per 60 days
  - Only triggers right after workout summary celebration (user feels accomplished)
  - Uses `expo-store-review` to call `StoreReview.requestReview()`
  - Tracks last prompt date in AsyncStorage
- [ ] Called from workout summary screen after celebration animation
- [ ] Typecheck passes

---

### US-071: Seed pre-built program templates

**Description:** As a developer, I want 5 pre-built program templates seeded in the database so that users can start training immediately without waiting for AI.

**Acceptance Criteria:**
- [ ] SQL migration seeds 5 template programs (marked `is_template = true`, `user_id = null or system user`):
  1. **PPL 3-Day:** Push (bench, OHP, tricep), Pull (row, pulldown, bicep), Legs (squat, RDL, leg curl)
  2. **Upper/Lower 4-Day:** Upper A (bench, row), Upper B (OHP, pulldown), Lower A (squat, calf), Lower B (deadlift, lunge)
  3. **Full Body 3-Day:** Compound-focused (squat, bench, row day 1; deadlift, OHP, pulldown day 2; squat variation, incline, row variation day 3)
  4. **5x5 Strength:** Classic 5x5 on squat, bench, row, OHP, deadlift
  5. **Beginner Basics:** 3-day full body with machine exercises and simple progressions
- [ ] Each program has complete workouts with exercises, sets, reps, and rest times
- [ ] Template programs visible to all users via RLS (`is_template = true`)
- [ ] Users can "Start Template" which copies the program to their account
- [ ] Migration runs successfully: `supabase db push`
- [ ] Typecheck passes

---

### US-072: Build settings screen

**Description:** As a user, I want a settings screen where I can manage my account, subscription, referrals, and sign out.

**Acceptance Criteria:**
- [ ] `app/(app)/settings.tsx` renders:
  - Profile section: display name, email (read-only from Clerk)
  - Subscription status + "Upgrade" or "Manage" button
  - Achievement showcase (5 badges, Pro gated for full display)
  - "Invite a Friend" (referral link)
  - "Restore Purchases" button
  - "Sign Out" button (calls Clerk's `signOut()` and redirects to auth)
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-073: Build app tab layout

**Description:** As a developer, I want the main app bottom tab navigator so that users can navigate between core features.

**Acceptance Criteria:**
- [ ] `app/(app)/_layout.tsx` defines a bottom tab layout using Expo Router `Tabs`
- [ ] Five tabs: Dashboard, Workout, History, Progress, Settings
- [ ] Tab icons present (Lucide or compatible icon library)
- [ ] Progress tab shows lock icon for Free users
- [ ] Active tab uses accent green color
- [ ] Tab bar uses `bg-background-elevated` background
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-074: Enable TanStack Query persistence for offline support

**Description:** As a user, I want my workout data to be available offline so that I can view programs and log workouts in the gym without cell service.

**Acceptance Criteria:**
- [ ] `@tanstack/query-async-storage-persister` and `@tanstack/react-query-persist-client` installed
- [ ] TanStack Query configured with `AsyncStorage` persister in root layout
- [ ] Program and workout data available offline after initial fetch
- [ ] Mutations queue while offline and execute when connectivity returns
- [ ] Typecheck passes

---

### US-075: Add loading skeletons

**Description:** As a user, I want skeleton loading placeholders on list screens so that I see feedback while data loads.

**Acceptance Criteria:**
- [ ] `components/SkeletonCard.tsx` renders a pulsing placeholder card using Reanimated for animation
- [ ] Dashboard, history list, and program screen show skeletons while TanStack Query `isLoading` is true
- [ ] Skeletons match the approximate layout of the real content
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-076: Add empty state components

**Description:** As a user, I want friendly empty states on list screens so that I know what to do when there's no data yet.

**Acceptance Criteria:**
- [ ] `components/EmptyState.tsx` component accepts `title`, `message`, and optional `actionLabel` / `onAction` props
- [ ] Used on: program screen ("No program yet — generate one!"), history list ("No workouts logged yet"), dashboard PRs ("Hit your first PR!")
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-077: Add Sentry error boundaries

**Description:** As a developer, I want Sentry error boundaries wrapping key screens so that crashes are reported with component context.

**Acceptance Criteria:**
- [ ] `components/ErrorBoundary.tsx` wraps screens with Sentry's `ErrorBoundary` or a custom one that calls `Sentry.captureException`
- [ ] Fallback UI shows "Something went wrong" with a "Retry" button
- [ ] Error boundaries added to root layout and tab group layout
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

### US-078: Add haptic feedback system

**Description:** As a user, I want haptic feedback on key interactions throughout the app so that the interface feels tactile and responsive.

**Acceptance Criteria:**
- [ ] Haptic feedback integrated at all interaction points:
  - Set completion: `hapticLight()` on checkbox tap
  - PR detected: `hapticHeavy()` on PR celebration
  - Workout saved: `hapticMedium()` on save confirmation
  - Rest timer tick: `hapticSelection()` on each countdown second in last 3 seconds
  - Rest timer expired: `hapticNotification()` on timer completion
  - Exercise expand/collapse: `hapticSelection()` on accordion toggle
  - Button press: `hapticLight()` on primary action buttons
  - Streak milestone: `hapticSuccess()` on streak achievement
  - Achievement unlocked: `hapticSuccess()` on badge reveal
- [ ] All haptics use the `lib/utils/haptics.ts` wrapper functions (from US-009)
- [ ] Haptics gracefully disabled on web platform
- [ ] Typecheck passes

---

### US-079: Build referral system

**Description:** As a user, I want to invite friends and earn free Pro days so that growth is incentivized virally.

**Acceptance Criteria:**
- [ ] `lib/services/referrals.ts` exports `createReferralCode(userId)`, `getReferralCode(userId)`, `redeemReferral(code, inviteeId)`
- [ ] `hooks/useReferrals.ts` exports `useReferralCode()`, `useRedeemReferral`
- [ ] Each user gets a unique referral code (generated on first request)
- [ ] "Invite a Friend" in settings generates a shareable link containing the referral code
- [ ] When invitee signs up with referral code: both referrer and invitee get 7 bonus days of Pro
- [ ] Bonus tracked in `referrals` table; actual entitlement extension handled via RevenueCat promotional offers or a manual check in `useIsPro`
- [ ] Styled with Uniwind dark theme
- [ ] Typecheck passes

---

## Non-Goals (MVP)

- **Wearable integrations** — no Apple Watch, Fitbit, etc.
- **Hebrew / RTL** — English-first. Hebrew added in v1.1
- **Coach features** — no coach role, client management, or monitoring. Added in v2.
- **Nutrition tracking** — MyFitnessPal dominates. Added in v3.
- **Direct messaging** — no coaches = no one to message
- **Coach marketplace** — no coaches in MVP
- **Progress photos** — complex storage. Added in v2.
- **Goals system** — streaks provide motivation. Added in v2.
- **Body measurements** — added in v1.1 as Pro feature
- **Calendar heatmap** — simple history list for now. Heatmap in v1.1.
- **Super Admin panel** — founder uses Supabase Dashboard
- **Exercise video hosting** — `video_url` field supports external links only
- **Web app** — mobile only (iOS + Android)
- **AI weekly adaptation** — post-launch v1.2 (tables and Edge Function scaffolded but adaptation logic deferred)

## Technical Notes

- **Framework:** Expo (managed workflow) with TypeScript strict mode
- **Navigation:** Expo Router (file-based routing)
- **Server state:** TanStack Query (caching, invalidation, persistence)
- **Client state:** Zustand (UI-only: theme, active workout state, rest timer)
- **Auth:** Clerk (Google + Apple OAuth) -> JWT -> Supabase RLS
- **Database:** Supabase PostgreSQL (relational, with RLS)
- **Serverless:** Supabase Edge Functions (Deno runtime)
- **AI:** Google Gemini API (2.5 Flash free tier) via Supabase Edge Functions (system prompt stored server-side)
- **Styling:** Uniwind (Tailwind CSS for React Native, 2.5x faster than NativeWind)
- **UI components:** react-native-reusables (copy-paste, not npm — lives in `components/ui/`)
- **Forms:** React Hook Form + Zod validation
- **Lists:** FlashList (drop-in FlatList replacement)
- **Animations:** React Native Reanimated
- **Haptics:** expo-haptics (tactile feedback on key interactions)
- **Gestures:** React Native Gesture Handler
- **Payments:** RevenueCat (Free + Pro tiers)
- **Error monitoring:** Sentry
- **Charts:** Victory Native or react-native-chart-kit
- **Sharing:** react-native-view-shot + expo-sharing
- **Offline:** TanStack Query persistence with AsyncStorage
- **Target platforms:** iOS + Android (web as bonus via Expo)
- **EAS dev builds required** — Expo Go not supported (Clerk, Sentry, RevenueCat need native modules)
- **Every story must pass typecheck** — TypeScript strict mode enforced
- **English-only for MVP** — no i18n infrastructure needed yet, plain strings OK
- **Story size:** Each story is designed to be completable in a single AI iteration (~10 min)

## Phase Dependencies

| Phase | Depends On | Can Parallel With |
|-------|-----------|-------------------|
| 1 | None | None |
| 2 | 1 | None |
| 3 | 2 | None |
| 4 | 3 | None |
| 5 | 4 | 6 (partially) |
| 6 | 5 | 7 |
| 7 | 5 | 6 |
| 8 | 5, 6, 7 | None |

### Wave Execution Plan

| Wave | Phases | Mode | Description |
|------|--------|------|-------------|
| A | 1-4 | Sequential | Foundation + DB + Auth + AI Generation |
| B | 5 | Sequential | Workout Tracking (the money screen) |
| C | 6, 7 | Parallel | History/Progress + Monetization |
| D | 8 | Sequential | Engagement, Polish, and Launch Prep |

## Post-Launch Roadmap

| Version | Timeline | Features | Revenue Impact |
|---------|----------|----------|---------------|
| **v1.0** | Week 8 | AI trainer + logging + Pro subscription | Baseline |
| **v1.1** | Week 10 | Hebrew localization + Israeli ASO push | +50-100% downloads in Israel |
| **v1.2** | Week 12 | AI weekly adaptation (Pro killer feature) | +30% retention |
| **v1.3** | Month 3 | Body measurements + calendar heatmap | +10% Pro conversion |
| **v2.0** | Month 4 | Coach tier (coaches can manage clients) | New $29.99/mo revenue stream |
| **v2.1** | Month 5 | Nutrition tracking (Pro feature) | +15% Pro conversion |
| **v2.2** | Month 6 | Apple Watch widget + Live Activities | Retention + press coverage |
| **v3.0** | Month 8 | Coach marketplace | Platform revenue (commission) |

## App Store Optimization

**App Name:** "[AppName] - AI Workout Planner"
**Subtitle:** "Smart Programs. Track PRs." (30 char limit)
**Category:** Health & Fitness (primary)
**Keywords:** ai workout planner, gym tracker, personal trainer ai, strength training, progressive overload, workout log, pr tracker, exercise planner, fitness ai, gym log

**Screenshots (6):**
1. Onboarding quiz ("Tell us about your goals")
2. AI-generated program ("Your personalized plan")
3. Workout logging screen (the money shot)
4. PR celebration (gold confetti)
5. Progress charts
6. Dark mode beauty shot / streak counter

**App preview video (30 sec):**
Quiz flow -> AI generation animation -> logging a set -> PR celebration -> sharing card
