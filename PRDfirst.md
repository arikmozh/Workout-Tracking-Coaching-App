Product Requirements Document (PRD) – Workout Tracking & Coaching App1. Product OverviewProduct DescriptionA simple, flexible mobile app that allows personal trainers (coaches) to create and assign workout programs to their clients (trainees), and enables trainees to log workouts in a flexible, non-rigid way (not tied to specific days of the week).
The focus is exclusively on workouts — no nutrition tracking in v1.
Trainees follow a checklist-style interface, log sets/reps/weights/time/distance, add notes per set/exercise/workout, and see history & progress. Coaches get full visibility, can comment, correct, and track progress across clients.Business GoalsSolve the founder’s personal pain point: flexible delivery & tracking of personalized workout plans.
Start as a private tool for the founder (admin access), then open to all coaches with a subscription model.
Launch MVP quickly (2–4 months), validate with existing clients, then scale.

Target AudienceCoaches: Personal trainers, mostly in Israel at first, managing 5–200+ clients.
Trainees: Active individuals (ages ~18–50) doing strength training, running, jump rope, cardio, etc.
Primary language: Hebrew (RTL support required), with English support.

MVP ScopeCore loop only: coach creates program → assigns to trainee → trainee logs freely → coach views & comments.
No nutrition, no advanced AI, no wearables integration in MVP (planned for v2).2. Functional RequirementsUser RolesCoach (Admin for own clients): Creates programs, manages clients, views logs & adds feedback.
Trainee (Client): Views assigned programs, logs workouts flexibly, sees personal history.
Super Admin (founder): Full access to all data (for initial phase & support).

Key FeaturesCoach FeaturesCreate & Manage Workout ProgramsProgram: name, description, list of workouts (e.g. A = Pull, B = Push, C = Legs).
Each workout contains:List of exercises (required + optional/alternative choices).
For each exercise: sets × reps/weight/time/distance (flexible fields), rest time suggestion.
Choice exercises: 2–4 alternatives with coach notes (“Why choose X? Best for beginners / shoulder issues / etc.”).

Support multiple types: strength (sets/reps/weight), cardio (time/distance/pace), jump rope, running intervals, etc.
Save as reusable template / bank of programs.

Client ManagementInvite clients (share link / code / email).
Assign one or more programs to a client.
Dashboard: list of clients, quick overview of recent activity.

Monitoring & FeedbackView full history per client per program (logs with dates, sets, weights, notes).
Add coach comments/notes visible to the client on next login / next similar workout.
Simple progress graphs (e.g. average weight on Bench Press over time).

Trainee FeaturesAccess Assigned ProgramsSee list of active programs assigned by coach.
Freely choose which workout to do today (not forced by day of week).

Workout LoggingVisual checklist interface: mark sets/exercises as completed.
Input fields: reps, weight (kg/lbs), time, distance, RPE (optional), notes.
Per-set, per-exercise, or per-workout notes — notes from previous sessions shown when relevant.
When choice exercises exist: show alternatives + coach explanations → trainee picks one.

Personal TrackingHistory list: filter by date / program / exercise.
Simple charts: progress on specific exercises (weight/reps over time).

Shared / General FeaturesPush notifications: “Time for today’s workout?”, “Coach left you a note”, “Well done – 5 workouts this week!”.
Search/filter in exercise / workout bank.

Example User StoriesAs a coach, I want to create Workout A (Back + Biceps) with 3 pulling exercise options + explanations, so clients can choose what suits them.
As a trainee, I want to log today’s workout by selecting “Push A”, completing 4 sets of Bench Press at 80 kg, and adding a note “left shoulder felt tight”.
As a coach, I want to see a graph of my client’s Squat progress and leave a comment: “Great job – try +5 kg next time”.

3. User Flows (High-Level)Coach flow
Login → Dashboard → Create new program → Add workouts & exercises → Save → Invite/assign to client → Later: open client profile → view logs → add comment.Trainee flow
Login → See my programs → Pick a workout → Log sets (checklist style) → Add notes → Save → View my history.4. Technical RequirementsTechnology StackFrontend: React Native (bare or Expo — Expo recommended for faster MVP).Navigation: React Navigation
State management: Zustand or Redux Toolkit
UI components: NativeBase, Tamagui, or Tailwind + shadcn-mobile style
Charts: Victory Native or Recharts

Backend & Services: FirebaseAuthentication: Firebase Auth (email/password + Google/Apple)
Database: Firestore (collections: users, programs, workouts, logs, comments)
Storage: Firebase Storage (if adding exercise images/videos later)
Cloud Messaging: FCM for push notifications
Functions: Cloud Functions (for subscription webhooks, admin tasks)

Payments: Stripe (integrated via Firebase or React Native SDK)

Data Model (Firestore – high level)users → { uid, role: "coach"|"trainee", name, email, coachId (for trainees) }
programs → { id, coachId, name, description, workouts: array of workout refs }
workouts → { id, name, exercises: array of {name, sets, alternatives: […], notes} }
logs → { id, traineeId, programId, workoutId, date, completedSets: array, notes, coachComment? }
subscriptions → linked to Stripe (for coaches)

Non-Functional RequirementsOffline support: Firestore offline persistence (crucial for logging workouts without internet).
RTL support: full Hebrew UI (react-native-localize + i18n-js).
Performance: <2s screen loads, realtime updates on logs/comments.
Security: Firestore security rules — coach sees only their clients’ data.
App platforms: iOS + Android.

5. Monetization (Phase 1 & 2)Freemium: free for coaches with up to 5 clients.
Paid plans (via Stripe):Monthly: ~49 ILS
3 months: ~120 ILS
6 months: ~200 ILS
Yearly: ~350 ILS (discount)

Future upsell: analytics, templates marketplace, group coaching features.

6. MVP Milestones (Rough Timeline)Week 1–2: Project setup, auth, basic screens (login, dashboard).
Week 3–5: Program & workout creation (coach side).
Week 6–8: Logging + history (trainee side) + realtime sync.
Week 9–10: Notifications, comments, basic charts, RTL Hebrew.
Week 11–12: Testing, bug fixes, Stripe skeleton, App Store / Play Store prep.

7. Assumptions, Dependencies & RisksAssumptions: users have modern smartphones; initial users are Hebrew-speaking.
Dependencies: Firebase project, Stripe account, Expo/EAS build system.
Risks: low user retention → mitigate with good onboarding & notifications.

This PRD is concise, structured, and ready to be handed to Claude (or Cursor, Devin, etc.) with a prompt like:
“Build a React Native + Firebase MVP according to this PRD. Start with folder structure, auth flow, and main screens.”Let me know which part you want to zoom in on next (e.g. data model details, screen list, security rules examples, or initial folder structure).

