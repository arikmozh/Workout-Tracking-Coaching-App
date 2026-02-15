# PRD: Workout Tracking & Coaching App

## Introduction

A mobile app that enables personal trainers (coaches) to create and assign workout programs to their clients (trainees), and lets trainees log workouts flexibly — not tied to specific days of the week. Coaches get full visibility into client progress with commenting and charting. Trainees follow a checklist-style interface, log sets/reps/weights/time/distance, add notes, and see history and progress charts.

The app is bilingual (Hebrew + English) with full RTL support from day one. Built with Expo (React Native), Firebase, and Zustand. Focus is exclusively on workouts — no nutrition tracking in v1, no payments in MVP.

## Goals

- Enable coaches to create flexible, reusable workout programs with choice exercises and coach notes
- Allow trainees to freely pick which workout to do on any day and log it via a checklist UI
- Provide full workout history with search, filtering, and progress charts for both roles
- Support Hebrew (RTL) and English from launch
- Deliver push notifications for engagement (workout reminders, coach comments, milestones)
- Ensure offline-first logging via Firestore persistence
- Ship a working MVP that the founder can validate with existing clients

## User Stories

---

### Phase 1: Project Setup

---

### US-001: Initialize Expo project

**Description:** As a developer, I want to scaffold a new Expo (managed workflow) project with TypeScript so that the team has a clean starting point.

**Acceptance Criteria:**
- [ ] Run `npx create-expo-app` with TypeScript template
- [ ] Project runs on iOS, Android, and web with the default screen
- [ ] `tsconfig.json` is present and strict mode is enabled
- [ ] Typecheck passes

---

### US-002: Install core dependencies

**Description:** As a developer, I want to install and configure the core dependencies (React Navigation, Zustand, Firebase JS SDK, i18n-js, expo-localization) so that subsequent stories can import them.

**Acceptance Criteria:**
- [ ] `@react-navigation/native`, `@react-navigation/bottom-tabs`, `@react-navigation/native-stack` installed
- [ ] `zustand` installed
- [ ] `firebase` (JS SDK v9+) installed
- [ ] `i18n-js` and `expo-localization` installed
- [ ] `react-native-safe-area-context` and `react-native-screens` installed
- [ ] App still compiles and runs without errors
- [ ] Typecheck passes

---

### US-003: Configure Firebase project

**Description:** As a developer, I want to initialize the Firebase app with a config module so that all services (Auth, Firestore, Messaging) share a single Firebase instance.

**Acceptance Criteria:**
- [ ] `src/config/firebase.ts` exports initialized Firebase app, auth, and db instances
- [ ] Firebase config values are loaded from environment variables or a config file (no secrets committed)
- [ ] Importing `firebase.ts` does not crash the app
- [ ] Typecheck passes

---

### US-004: Set up linting, path aliases, and project structure

**Description:** As a developer, I want ESLint, Prettier, and path aliases (`@/` → `src/`) configured so that the codebase stays consistent and imports are clean.

**Acceptance Criteria:**
- [ ] ESLint + Prettier configured with a React Native–compatible ruleset
- [ ] Path alias `@/` resolves to `src/` in both `tsconfig.json` and bundler config
- [ ] Folder structure created: `src/{components,screens,services,stores,types,config,i18n,utils,navigation}`
- [ ] `npm run lint` passes with zero errors
- [ ] Typecheck passes

---

### Phase 2: Type Definitions

---

### US-005: Define User types

**Description:** As a developer, I want TypeScript types for users (Coach, Trainee, SuperAdmin roles) so that all modules share a consistent user shape.

**Acceptance Criteria:**
- [ ] `src/types/user.ts` exports `User` type with fields: `uid`, `email`, `displayName`, `role` (`"coach" | "trainee" | "admin"`), `coachId?` (for trainees), `language` (`"he" | "en"`), `createdAt`, `updatedAt`
- [ ] `UserRole` union type exported
- [ ] Typecheck passes

---

### US-006: Define Program and Workout types

**Description:** As a developer, I want TypeScript types for programs, workouts, and exercises so that coach-side features have a well-defined schema.

**Acceptance Criteria:**
- [ ] `src/types/program.ts` exports `Program` type with: `id`, `coachId`, `name`, `description`, `workoutIds`, `createdAt`, `updatedAt`
- [ ] `src/types/workout.ts` exports `Workout` type with: `id`, `programId`, `name`, `exercises` (array of `Exercise`)
- [ ] `Exercise` type includes: `id`, `name`, `type` (`"strength" | "cardio" | "timed"`), `sets`, `reps?`, `weight?`, `duration?`, `distance?`, `restSeconds?`, `notes?`, `isChoice`, `alternatives?` (array of `Exercise`), `choiceReason?`
- [ ] Typecheck passes

---

### US-007: Define WorkoutLog types

**Description:** As a developer, I want TypeScript types for workout logs so that trainee logging and coach monitoring features share a consistent data shape.

**Acceptance Criteria:**
- [ ] `src/types/log.ts` exports `WorkoutLog` type with: `id`, `traineeId`, `programId`, `workoutId`, `date`, `completedExercises` (array of `CompletedExercise`), `notes?`, `coachComment?`, `createdAt`
- [ ] `CompletedExercise` type includes: `exerciseId`, `exerciseName`, `sets` (array of `CompletedSet`), `notes?`, `chosenAlternativeId?`
- [ ] `CompletedSet` type includes: `setNumber`, `reps?`, `weight?`, `duration?`, `distance?`, `rpe?`, `completed`, `notes?`
- [ ] Typecheck passes

---

### US-008: Create Firestore converters

**Description:** As a developer, I want Firestore data converters for User, Program, Workout, and WorkoutLog so that reads/writes are type-safe.

**Acceptance Criteria:**
- [ ] `src/services/converters.ts` exports `withConverter`-compatible converters for `User`, `Program`, `Workout`, `WorkoutLog`
- [ ] Converters handle `Timestamp` ↔ `Date` conversion for date fields
- [ ] Converters strip `undefined` fields before writing
- [ ] Typecheck passes

---

### Phase 3: Authentication

---

### US-009: Create auth service

**Description:** As a developer, I want an auth service module wrapping Firebase Auth (email/password sign-up, sign-in, sign-out, onAuthStateChanged) so that screens can call simple functions.

**Acceptance Criteria:**
- [ ] `src/services/auth.ts` exports `signUp(email, password, role)`, `signIn(email, password)`, `signOut()`, `onAuthChange(callback)`
- [ ] `signUp` creates a Firestore user document with the chosen role after Firebase Auth account creation
- [ ] Functions throw typed errors (e.g., `AuthError`) that callers can handle
- [ ] Typecheck passes

---

### US-010: Create auth Zustand store

**Description:** As a developer, I want a Zustand store that tracks the current user, loading state, and auth errors so that any component can reactively access auth status.

**Acceptance Criteria:**
- [ ] `src/stores/authStore.ts` exports `useAuthStore` with state: `user: User | null`, `loading: boolean`, `error: string | null`
- [ ] Store subscribes to `onAuthChange` on init and updates `user` accordingly
- [ ] `signIn`, `signUp`, `signOut` actions exposed on the store
- [ ] Typecheck passes

---

### US-011: Build Sign In screen

**Description:** As a trainee or coach, I want a sign-in screen with email and password fields so that I can access my account.

**Acceptance Criteria:**
- [ ] `src/screens/auth/SignInScreen.tsx` renders email input, password input, and "Sign In" button
- [ ] Calls `useAuthStore.signIn` on submit; shows inline error on failure
- [ ] "Don't have an account? Sign Up" link navigates to Sign Up screen
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-012: Build Sign Up screen

**Description:** As a new user, I want a sign-up screen where I choose my role (coach or trainee) so that the system knows my capabilities.

**Acceptance Criteria:**
- [ ] `src/screens/auth/SignUpScreen.tsx` renders email, password, display name, and role selector (Coach / Trainee)
- [ ] Calls `useAuthStore.signUp` on submit; shows inline error on failure
- [ ] "Already have an account? Sign In" link navigates back
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-013: Add auth-gated navigation

**Description:** As a developer, I want the root navigator to show auth screens when not logged in and the main app when logged in so that unauthenticated users cannot access the app.

**Acceptance Criteria:**
- [ ] `src/navigation/RootNavigator.tsx` checks `useAuthStore.user`
- [ ] If `user` is `null`, renders `AuthStack` (SignIn + SignUp screens)
- [ ] If `user` exists, renders the main app navigator (placeholder screen for now)
- [ ] Shows a loading spinner while auth state is initializing
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 4: i18n & RTL

---

### US-014: Set up i18n with Hebrew and English

**Description:** As a user, I want the app to display in my preferred language (Hebrew or English) so that I can use the app comfortably.

**Acceptance Criteria:**
- [ ] `src/i18n/index.ts` initializes `i18n-js` with `he` and `en` translation objects
- [ ] `src/i18n/en.json` and `src/i18n/he.json` contain initial keys for auth screens (signIn, signUp, email, password, etc.)
- [ ] Default language detected from device locale via `expo-localization`
- [ ] `t()` helper exported for use in components
- [ ] Typecheck passes

---

### US-015: Enable RTL toggle

**Description:** As a Hebrew-speaking user, I want the app to render in RTL layout when Hebrew is selected so that the UI feels natural.

**Acceptance Criteria:**
- [ ] `I18nManager.forceRTL(true)` called when locale is `he`
- [ ] `I18nManager.forceRTL(false)` called when locale is `en`
- [ ] Layout direction visually flips (navigation, text alignment, icons) when language changes
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 5: Navigation Shell

---

### US-016: Build Coach tab navigator

**Description:** As a coach, I want a bottom tab navigator with tabs for Dashboard, Programs, Clients, and Settings so that I can navigate between coach features.

**Acceptance Criteria:**
- [ ] `src/navigation/CoachTabs.tsx` renders a bottom tab navigator with four tabs
- [ ] Each tab shows a placeholder screen with its name
- [ ] Tab labels use i18n keys
- [ ] Tab icons are present (any icon library)
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-017: Build Trainee tab navigator

**Description:** As a trainee, I want a bottom tab navigator with tabs for My Programs, History, Progress, and Settings so that I can navigate between trainee features.

**Acceptance Criteria:**
- [ ] `src/navigation/TraineeTabs.tsx` renders a bottom tab navigator with four tabs
- [ ] Each tab shows a placeholder screen with its name
- [ ] Tab labels use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-018: Route to correct tabs by role

**Description:** As a developer, I want the root navigator to route authenticated users to CoachTabs or TraineeTabs based on their role so that each role sees only relevant screens.

**Acceptance Criteria:**
- [ ] `RootNavigator` reads `user.role` from `useAuthStore`
- [ ] Coach users see `CoachTabs`, trainee users see `TraineeTabs`
- [ ] Changing roles (e.g., in Firestore) and re-logging in routes to the correct tabs
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 6: Coach – Program CRUD

---

### US-019: Create program service (Firestore)

**Description:** As a developer, I want a service module for creating, reading, updating, and deleting programs in Firestore so that screens can call simple CRUD functions.

**Acceptance Criteria:**
- [ ] `src/services/programs.ts` exports `createProgram`, `getProgram`, `getCoachPrograms`, `updateProgram`, `deleteProgram`
- [ ] All functions use the Firestore converter from US-008
- [ ] `getCoachPrograms` queries by `coachId`
- [ ] Typecheck passes

---

### US-020: Create workout service (Firestore)

**Description:** As a developer, I want a service module for creating, reading, updating, and deleting workouts in Firestore so that the workout editor can persist data.

**Acceptance Criteria:**
- [ ] `src/services/workouts.ts` exports `createWorkout`, `getWorkout`, `getWorkoutsByProgram`, `updateWorkout`, `deleteWorkout`
- [ ] All functions use the Firestore converter
- [ ] Typecheck passes

---

### US-021: Build Programs list screen (coach)

**Description:** As a coach, I want to see a list of my programs so that I can manage and edit them.

**Acceptance Criteria:**
- [ ] `src/screens/coach/ProgramsListScreen.tsx` fetches and displays programs via `getCoachPrograms`
- [ ] Each list item shows program name and workout count
- [ ] A floating action button (FAB) navigates to the create/edit form
- [ ] Tapping a program navigates to the program detail screen
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-022: Build Program create/edit form

**Description:** As a coach, I want a form to create or edit a program (name, description) so that I can define new training plans.

**Acceptance Criteria:**
- [ ] `src/screens/coach/ProgramFormScreen.tsx` renders name and description inputs
- [ ] In create mode, calls `createProgram` and navigates back on success
- [ ] In edit mode, pre-fills fields and calls `updateProgram`
- [ ] Validates that name is non-empty before saving
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-023: Build Program detail screen

**Description:** As a coach, I want a detail screen for a program that lists its workouts so that I can add, edit, or remove workouts.

**Acceptance Criteria:**
- [ ] `src/screens/coach/ProgramDetailScreen.tsx` shows program name, description, and a list of workouts
- [ ] "Add Workout" button navigates to the workout form
- [ ] Tapping a workout navigates to the workout detail/exercise editor
- [ ] Delete workout option with confirmation dialog
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-024: Build Workout create/edit form

**Description:** As a coach, I want a form to create or edit a workout (name) within a program so that I can define individual training sessions.

**Acceptance Criteria:**
- [ ] `src/screens/coach/WorkoutFormScreen.tsx` renders a name input and save button
- [ ] In create mode, calls `createWorkout` with the parent `programId`
- [ ] In edit mode, pre-fills and calls `updateWorkout`
- [ ] Navigates back to program detail on success
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-025: Build Exercise editor within workout

**Description:** As a coach, I want to add, edit, reorder, and remove exercises within a workout so that I can define the workout structure.

**Acceptance Criteria:**
- [ ] `src/screens/coach/ExerciseEditorScreen.tsx` lists exercises for a workout
- [ ] "Add Exercise" opens an inline form with fields: name, type, sets, reps, weight, duration, distance, rest, notes
- [ ] Exercises can be reordered via up/down buttons
- [ ] Exercises can be deleted with confirmation
- [ ] Changes are saved to Firestore via `updateWorkout`
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-026: Add choice exercise support in editor

**Description:** As a coach, I want to mark an exercise as a "choice" and add 2–4 alternatives with explanations so that trainees can pick the best option for them.

**Acceptance Criteria:**
- [ ] Toggle "Choice exercise" checkbox on an exercise in the editor
- [ ] When enabled, shows an "Alternatives" section where coach can add 2–4 alternatives
- [ ] Each alternative has name, sets/reps fields, and a `choiceReason` text field
- [ ] Data saved to the `alternatives` and `choiceReason` fields on the `Exercise` type
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 7: Coach – Client Management

---

### US-027: Create invite code service

**Description:** As a developer, I want a service that generates and validates invite codes so that coaches can invite trainees.

**Acceptance Criteria:**
- [ ] `src/services/invites.ts` exports `createInviteCode(coachId)` and `redeemInviteCode(code, traineeId)`
- [ ] Invite codes stored in Firestore `invites` collection with fields: `code`, `coachId`, `used`, `traineeId?`, `createdAt`
- [ ] `createInviteCode` generates a unique 6-character alphanumeric code
- [ ] `redeemInviteCode` marks the code as used and sets `coachId` on the trainee's user doc
- [ ] Typecheck passes

---

### US-028: Create program assignment service

**Description:** As a developer, I want a service to assign/unassign programs to trainees so that coaches can manage client programs.

**Acceptance Criteria:**
- [ ] `src/services/assignments.ts` exports `assignProgram(traineeId, programId)`, `unassignProgram(traineeId, programId)`, `getTraineePrograms(traineeId)`, `getProgramTrainees(programId)`
- [ ] Assignments stored in Firestore `assignments` collection with: `traineeId`, `programId`, `coachId`, `assignedAt`
- [ ] Typecheck passes

---

### US-029: Build Client list screen

**Description:** As a coach, I want to see a list of my clients so that I can manage them and view their progress.

**Acceptance Criteria:**
- [ ] `src/screens/coach/ClientsListScreen.tsx` fetches trainees where `coachId` matches current user
- [ ] Each item shows trainee name and email
- [ ] Tapping a client navigates to the client detail screen
- [ ] "Invite Client" button opens an invite flow (shows generated code)
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-030: Build Invite Client flow

**Description:** As a coach, I want to generate an invite code and share it so that new trainees can connect to me.

**Acceptance Criteria:**
- [ ] Pressing "Invite Client" on the clients list calls `createInviteCode`
- [ ] Displays the generated code in a modal with a "Copy" button
- [ ] Uses the device share sheet (or clipboard) to share the code
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-031: Build Client detail screen with program assignment

**Description:** As a coach, I want to view a client's profile and assign/unassign programs so that I can customize their training.

**Acceptance Criteria:**
- [ ] `src/screens/coach/ClientDetailScreen.tsx` shows trainee name, email, and assigned programs
- [ ] "Assign Program" button opens a picker listing the coach's programs
- [ ] Coach can unassign a program with confirmation
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 8: Coach – Monitoring

---

### US-032: Create workout log service

**Description:** As a developer, I want a service to create, read, and query workout logs in Firestore so that both trainee logging and coach monitoring can use it.

**Acceptance Criteria:**
- [ ] `src/services/logs.ts` exports `createLog`, `getLog`, `getTraineeLogs(traineeId)`, `getProgramLogs(traineeId, programId)`, `getExerciseLogs(traineeId, exerciseName)`
- [ ] All functions use the Firestore converter
- [ ] Queries support ordering by date descending
- [ ] Typecheck passes

---

### US-033: Build Log viewer screen (coach)

**Description:** As a coach, I want to view a client's workout logs so that I can see what they did and how they performed.

**Acceptance Criteria:**
- [ ] `src/screens/coach/LogViewerScreen.tsx` shows a list of logs for a selected trainee
- [ ] Each log item shows date, workout name, and exercise count
- [ ] Tapping a log shows full details: exercises, sets, weights, reps, notes
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-034: Add coach comment to log

**Description:** As a coach, I want to add a comment to a trainee's workout log so that I can give feedback visible to the trainee.

**Acceptance Criteria:**
- [ ] Log detail screen (coach) has a text input and "Add Comment" button
- [ ] Saving updates the `coachComment` field on the log document
- [ ] Existing comment is displayed and editable
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-035: Build Coach dashboard screen

**Description:** As a coach, I want a dashboard showing recent client activity so that I get a quick overview when I open the app.

**Acceptance Criteria:**
- [ ] `src/screens/coach/DashboardScreen.tsx` displays total client count and total logs this week
- [ ] Shows a "Recent Activity" list: last 10 logs across all clients, each showing trainee name, workout name, and date
- [ ] Tapping an activity item navigates to the log detail
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 9: Trainee – View Programs

---

### US-036: Build Trainee programs list screen

**Description:** As a trainee, I want to see the programs my coach has assigned to me so that I can pick a workout.

**Acceptance Criteria:**
- [ ] `src/screens/trainee/ProgramsListScreen.tsx` fetches assigned programs via `getTraineePrograms`
- [ ] Each item shows program name and number of workouts
- [ ] Tapping a program navigates to the workout selection screen
- [ ] Empty state shown if no programs are assigned
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-037: Build Workout selection screen (trainee)

**Description:** As a trainee, I want to see the workouts within a program and freely choose which one to do today so that I'm not locked into a schedule.

**Acceptance Criteria:**
- [ ] `src/screens/trainee/WorkoutSelectionScreen.tsx` lists workouts for the selected program
- [ ] Each item shows workout name and exercise count
- [ ] Tapping a workout navigates to the workout logging screen
- [ ] Shows the date of the last time each workout was logged (if any)
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 10: Trainee – Logging

---

### US-038: Build workout logging screen – checklist UI

**Description:** As a trainee, I want a checklist-style interface showing all exercises in my chosen workout so that I can track completion visually.

**Acceptance Criteria:**
- [ ] `src/screens/trainee/WorkoutLoggingScreen.tsx` lists exercises as checklist items
- [ ] Each exercise shows name, prescribed sets/reps/weight
- [ ] Exercises can be expanded to show set-by-set input
- [ ] A progress bar or counter shows completed vs total exercises
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-039: Add set input fields to logging screen

**Description:** As a trainee, I want to input reps, weight, duration, distance, and RPE for each set so that my workout is fully recorded.

**Acceptance Criteria:**
- [ ] Each expanded exercise shows rows for each prescribed set
- [ ] Input fields adapt to exercise type: strength shows reps + weight, cardio shows duration + distance, timed shows duration
- [ ] RPE is an optional dropdown (1–10)
- [ ] Per-set note field available
- [ ] Marking a set as completed toggles its checkbox
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-040: Handle choice exercises in logging

**Description:** As a trainee, I want to see alternatives for choice exercises and pick one before logging so that I can choose what suits me.

**Acceptance Criteria:**
- [ ] Choice exercises display a selection UI with alternatives and coach's `choiceReason` for each
- [ ] Trainee selects one alternative; the chosen option becomes the active exercise to log
- [ ] The `chosenAlternativeId` is saved in the completed exercise data
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-041: Add per-exercise and per-workout notes

**Description:** As a trainee, I want to add a note to an individual exercise or to the entire workout so that I can record how I felt.

**Acceptance Criteria:**
- [ ] Each exercise section has an optional "Add note" text input
- [ ] The bottom of the logging screen has a "Workout notes" text input
- [ ] Notes are saved to the respective fields in `CompletedExercise.notes` and `WorkoutLog.notes`
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-042: Show previous workout data

**Description:** As a trainee, I want to see my last logged values for each exercise while logging so that I know what to aim for.

**Acceptance Criteria:**
- [ ] When opening the logging screen, fetch the most recent log for the same workout
- [ ] For each exercise, display "Last time: X reps @ Y kg" (or equivalent) in a muted style above the input fields
- [ ] If no previous data exists, show nothing
- [ ] Coach comment from the previous log is shown if present
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-043: Save workout log

**Description:** As a trainee, I want to save my completed workout so that it is persisted and visible to my coach.

**Acceptance Criteria:**
- [ ] "Save Workout" button at the bottom of the logging screen
- [ ] Calls `createLog` with all completed exercises, sets, notes, and date
- [ ] Shows a success message and navigates back to the programs list
- [ ] Button is disabled if no exercises are marked as completed
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 11: Trainee – History

---

### US-044: Build History list screen

**Description:** As a trainee, I want to see a chronological list of my past workouts so that I can review my training.

**Acceptance Criteria:**
- [ ] `src/screens/trainee/HistoryListScreen.tsx` fetches logs via `getTraineeLogs`
- [ ] Each item shows date, workout name, and number of exercises completed
- [ ] List is sorted by date descending (newest first)
- [ ] Tapping an item navigates to the history detail screen
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-045: Build History detail screen

**Description:** As a trainee, I want to see the full details of a past workout including all sets, notes, and coach comments so that I can reflect on my performance.

**Acceptance Criteria:**
- [ ] `src/screens/trainee/HistoryDetailScreen.tsx` shows workout name, date, and all completed exercises
- [ ] Each exercise shows sets with reps, weight, duration, etc.
- [ ] Exercise-level and workout-level notes displayed
- [ ] Coach comment displayed in a highlighted card if present
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-046: Add search and filter to history

**Description:** As a trainee, I want to filter my history by program, exercise name, or date range so that I can find specific workouts.

**Acceptance Criteria:**
- [ ] History list screen has a search bar that filters by exercise name (client-side or Firestore query)
- [ ] Filter chips or dropdown for program name
- [ ] Date range picker to narrow results
- [ ] Filters combine (AND logic)
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 12: Progress Charts

---

### US-047: Create chart data utilities

**Description:** As a developer, I want utility functions that transform workout logs into chart-ready data series so that chart components receive clean input.

**Acceptance Criteria:**
- [ ] `src/utils/chartData.ts` exports `getExerciseProgressData(logs, exerciseName)` returning `{ date, value }[]` for weight over time
- [ ] Exports `getVolumeProgressData(logs, exerciseName)` returning total volume (sets × reps × weight) over time
- [ ] Handles missing or partial data gracefully (skips entries without weight)
- [ ] Typecheck passes

---

### US-048: Build chart components

**Description:** As a developer, I want reusable line chart and bar chart components wrapping a charting library so that screens can render progress visuals.

**Acceptance Criteria:**
- [ ] `src/components/LineChart.tsx` renders a line chart given `{ date, value }[]` data and axis labels
- [ ] `src/components/BarChart.tsx` renders a bar chart given `{ label, value }[]` data
- [ ] Charts are responsive to screen width
- [ ] RTL layout does not break chart rendering
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-049: Build Trainee progress screen

**Description:** As a trainee, I want a progress screen showing charts of my exercise improvements over time so that I can see my gains.

**Acceptance Criteria:**
- [ ] `src/screens/trainee/ProgressScreen.tsx` lets the user pick an exercise from a dropdown
- [ ] Displays a line chart of weight progression and a bar chart of volume over time
- [ ] Shows "No data yet" state if the exercise has no logged history
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-050: Build Coach progress view for a client

**Description:** As a coach, I want to see progress charts for a specific client's exercise so that I can track their improvement.

**Acceptance Criteria:**
- [ ] `src/screens/coach/ClientProgressScreen.tsx` accessible from the client detail screen
- [ ] Exercise picker dropdown populated from the client's logged exercises
- [ ] Displays the same line + bar charts as the trainee progress screen
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 13: Push Notifications

---

### US-051: Register push token

**Description:** As a developer, I want the app to request notification permissions and save the device push token to Firestore so that Cloud Functions can send targeted notifications.

**Acceptance Criteria:**
- [ ] `src/services/notifications.ts` exports `registerPushToken()` that requests permissions via `expo-notifications`
- [ ] On approval, saves the token to `users/{uid}/pushTokens` subcollection
- [ ] Called on app launch after auth is confirmed
- [ ] Typecheck passes

---

### US-052: Create Cloud Function for coach comment notification

**Description:** As a developer, I want a Cloud Function that sends a push notification to a trainee when their coach adds a comment so that the trainee is alerted.

**Acceptance Criteria:**
- [ ] `functions/src/onCoachComment.ts` triggers on Firestore write to `logs/{logId}` when `coachComment` changes
- [ ] Looks up the trainee's push tokens and sends a notification via FCM
- [ ] Notification title: "Coach left you a note" (localized)
- [ ] Notification body: first 100 characters of the comment
- [ ] Typecheck passes

---

### US-053: Create Cloud Function for workout reminder

**Description:** As a developer, I want a scheduled Cloud Function that sends a daily push notification reminding trainees to work out so that engagement increases.

**Acceptance Criteria:**
- [ ] `functions/src/workoutReminder.ts` runs on a daily schedule (configurable time)
- [ ] Sends a notification to trainees who haven't logged a workout today
- [ ] Notification text is encouraging and localized
- [ ] Respects user's language preference for notification text
- [ ] Typecheck passes

---

### US-054: Handle notification deep linking

**Description:** As a user, I want tapping a notification to open the relevant screen in the app so that I can quickly act on it.

**Acceptance Criteria:**
- [ ] Notification payload includes a `screen` field (e.g., `"HistoryDetail"`) and `params` (e.g., `{ logId }`)
- [ ] `src/services/notifications.ts` listens for notification responses and navigates via a navigation ref
- [ ] Deep link works when app is in foreground, background, and killed state
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 14: Settings

---

### US-055: Build Settings screen

**Description:** As a user, I want a settings screen where I can switch language, view my profile info, and sign out so that I can manage my account.

**Acceptance Criteria:**
- [ ] `src/screens/shared/SettingsScreen.tsx` shows display name, email, and role (read-only)
- [ ] Language toggle (Hebrew / English) updates i18n locale and persists to user document
- [ ] "Sign Out" button calls `useAuthStore.signOut` and returns to the auth screen
- [ ] RTL layout updates immediately when language changes
- [ ] All visible strings use i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### Phase 15: Polish & Hardening

---

### US-056: Enable Firestore offline persistence

**Description:** As a trainee, I want my workout logging to work offline so that I can log in the gym without cell service.

**Acceptance Criteria:**
- [ ] Firestore offline persistence is enabled in `firebase.ts` config
- [ ] Creating a log while offline queues the write and syncs when back online
- [ ] Reading data while offline returns cached documents
- [ ] Typecheck passes

---

### US-057: Add loading skeletons

**Description:** As a user, I want skeleton loading placeholders on list screens so that I see feedback while data loads.

**Acceptance Criteria:**
- [ ] `src/components/SkeletonCard.tsx` renders a pulsing placeholder card
- [ ] Programs list, clients list, history list, and dashboard screens show skeletons while `loading` is true
- [ ] Skeletons match the approximate layout of the real content
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-058: Add empty state illustrations

**Description:** As a user, I want friendly empty states on list screens so that I know what to do when there's no data yet.

**Acceptance Criteria:**
- [ ] `src/components/EmptyState.tsx` component accepts `title`, `message`, and optional `actionLabel` / `onAction`
- [ ] Used on programs list ("No programs yet"), clients list ("No clients yet"), history list ("No workouts logged yet")
- [ ] All text uses i18n keys
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

### US-059: Write Firestore security rules

**Description:** As a developer, I want Firestore security rules that enforce data isolation so that coaches only see their own clients' data and trainees only see their own.

**Acceptance Criteria:**
- [ ] `firestore.rules` file defines rules for `users`, `programs`, `workouts`, `logs`, `assignments`, `invites` collections
- [ ] Coaches can only read/write their own programs and their clients' data
- [ ] Trainees can only read their own assigned programs and read/write their own logs
- [ ] Unauthenticated users have no access
- [ ] Rules deploy successfully with `firebase deploy --only firestore:rules`
- [ ] Typecheck passes

---

### US-060: Run full i18n audit

**Description:** As a developer, I want every user-facing string to use i18n keys so that the app is fully translatable.

**Acceptance Criteria:**
- [ ] Search all `.tsx` files for hardcoded user-facing strings (not in `t()` calls)
- [ ] Replace any found hardcoded strings with i18n keys
- [ ] Add missing keys to both `en.json` and `he.json`
- [ ] Visually verify app in both English and Hebrew
- [ ] Typecheck passes
- [ ] Verify changes work in browser/device

---

## Non-Goals

- **Nutrition tracking** — not in v1; planned for future versions
- **Payments / Stripe integration** — deferred; focus on core app first
- **Wearable integrations** — no Apple Watch, Fitbit, etc. in MVP
- **Advanced AI features** — no AI-generated programs or auto-coaching in MVP
- **Social features** — no leaderboards, social feed, or community in MVP
- **Super Admin panel** — founder uses Firebase Console directly for now
- **Exercise image/video uploads** — storage support deferred to v2
- **Group coaching** — one-to-one coach–trainee only in MVP
- **Web app** — mobile only (iOS + Android); web via Expo is a bonus, not a requirement

## Technical Notes

- **Framework:** Expo (managed workflow) with TypeScript
- **Navigation:** React Navigation (native stack + bottom tabs)
- **State management:** Zustand (lightweight, no boilerplate)
- **Backend:** Firebase (Auth, Firestore, Cloud Functions, Cloud Messaging)
- **i18n:** i18n-js + expo-localization; RTL via `I18nManager`
- **Charts:** Victory Native or a lightweight React Native charting library
- **Offline:** Firestore built-in offline persistence (critical for gym use)
- **Data model:** Firestore collections — `users`, `programs`, `workouts`, `logs`, `assignments`, `invites`
- **Target platforms:** iOS + Android (web as bonus via Expo)
- **Every story must pass typecheck** — TypeScript strict mode enforced
- **i18n convention:** All UI strings must go through `t()` — no hardcoded visible text
- **Story size:** Each story is designed to be completable in a single AI iteration (~10 min)

## Phase Dependencies

Phase execution order with parallelization opportunities:

| Phase | Depends On | Can Parallel With |
|-------|-----------|-------------------|
| 1-7   | Previous phase | None (sequential) |
| 8     | 7 | 9, 14 |
| 9     | 7 | 8, 14 |
| 10    | 8, 9 | 13 |
| 11    | 10 | — |
| 12    | 11 | — |
| 13    | 8 | 10, 14 |
| 14    | 5 | 8, 9, 10, 13 |
| 15    | All | None (final) |
