# OSLife — AI-Powered Personal Life Operating System

> A Flutter-based personal productivity application that acts as your Life Operating System, bringing together tasks, goals, expenses, study planning, calendar events, notes, and an AI assistant into a single, beautifully designed mobile experience.

---

## Overview

OSLife is a production-ready Flutter application built as part of a final-year BTech project. It aims to solve the fragmentation problem in personal productivity — where people manage tasks in one app, expenses in another, study schedules elsewhere, and goals in yet another tool.

OSLife unifies all of these into one cohesive, AI-assisted Life Operating System. The application uses Firebase Authentication (with Email/Password and Google Sign-In), Hive for local-first offline data storage, and a local rule-based AI engine that can answer contextual questions about your tasks, goals, study progress, and expenses — all without sending your data to an external server.

---

## Features

### 🔐 Authentication
- **Firebase Authentication** — Secure Email/Password sign-in and registration
- **Google Sign-In** — One-tap Google account login
- **Password Reset** — Email-based password reset flow
- **Persistent Sessions** — Auth state persists across app restarts

### 🏠 Dashboard
- Personalised home screen showing the current user's name and daily overview
- Quick-access cards for tasks, calendar events, goals, and study progress

### ✅ Tasks
- Create, view, and manage personal tasks
- Tasks categorised by priority (High, Medium, Low) and category
- Due dates and completion tracking
- Per-user isolated task data (each user sees only their own tasks)

### 📅 Calendar & Events
- Monthly calendar view (powered by `table_calendar`)
- Add and track personal events with location, start/end times, and categories
- Per-user event data isolation

### 💰 Expense Tracker
- Log and track personal expenses by category and date
- View spending history
- Per-user expense data isolation

### 📓 Notes
- Create and manage personal notes with tags
- Pin important notes to the top
- Per-user note data

### 🎯 Goals
- Set and track long-term personal goals with progress percentages
- Category-based goal organisation (Career, Health, Finance, etc.)
- Target date tracking
- Per-user goals

### 📚 Study Planner
- Manage study subjects, timetable slots, assignments, and exams
- Track study sessions and time spent per subject
- Study analytics and progress overview
- Per-user study data

### 🤖 AI Assistant
- Built-in local rule-based AI engine (`LocalAIEngine`) that understands your personal data context
- Ask questions about your tasks, upcoming events, goals, expenses, study sessions, and notes
- Fully offline — no external AI API required; all reasoning happens on-device

### 🔍 Global Search
- Search across tasks, notes, goals, events, and expenses from a single search bar

### 📊 Analytics
- Visual charts and summaries (powered by `fl_chart`)
- Expense breakdowns, task completion rates, and study progress charts

### 🎨 Theme & Settings
- Dark theme with Deep Slate & AI Violet design system (glassmorphic UI)
- Custom Material 3 theme using Inter font (Google Fonts)
- Settings screen for user preferences

### 🔔 Local Notifications
- Scheduled local push notifications (powered by `flutter_local_notifications`)

---

## Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Firebase Authentication** | User authentication (Email + Google) |
| **Firebase Core** | Firebase SDK initialisation |
| **Google Sign-In** | OAuth 2.0 Google login |
| **Hive + Hive Flutter** | Local offline database (key-value store) |
| **Provider** | State management |
| **GoRouter** | Declarative navigation & routing |
| **Google Fonts** | Inter typography |
| **fl_chart** | Analytics charts |
| **table_calendar** | Calendar widget |
| **flutter_local_notifications** | Local push notifications |
| **timezone** | Timezone-aware notification scheduling |
| **shared_preferences** | Lightweight preferences storage |
| **flutter_spinkit** | Loading indicators |
| **http** | HTTP client for REST API calls |
| **flutter_svg** | SVG asset rendering |

---

## Screenshots

> Screenshots of the OSLife application will be added here.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Dart SDK `>=3.0.0 <4.0.0`)
- Android Studio or VS Code with Flutter extension
- An Android device or emulator
- A Firebase project (see [Firebase Configuration](#firebase-configuration) below)

### Clone & Run

```bash
# Clone the repository
git clone https://github.com/ksathwik-93/OSLife-Application.git
cd OSLife-Application

# Install dependencies
flutter pub get

# Run the application
flutter run
```

---

## Firebase Configuration

OSLife uses Firebase for user authentication. To run the project:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Email/Password** and **Google** sign-in providers under **Authentication → Sign-in method**.
3. Register your Android app and download the `google-services.json` file.
4. Place `google-services.json` inside `android/app/`.
5. Run `flutterfire configure` (FlutterFire CLI) to regenerate `lib/firebase_options.dart` for your project.

> **Note:** The `lib/firebase_options.dart` file in this repository contains the project's Firebase client configuration. Firebase client-side config (API keys, project IDs) are public identifiers and are safe to include in source code. Protect your Firebase project by configuring proper **Firebase Security Rules** and **Authorized Domains** in the Firebase Console.

---

## Building the APK

To build a release APK:

```bash
flutter build apk --release
```

> **Note:** The current project has a known Gradle compatibility issue that will be resolved in a future update. The release APK build is not yet confirmed as successful. This will be fixed separately.

---

## Project Structure

```
OSLife-Application/
├── android/                  # Android platform project
├── lib/
│   ├── main.dart             # Application entry point
│   ├── firebase_options.dart # Firebase client configuration
│   ├── models/               # Data models (Task, Event, Expense, Goal, etc.)
│   ├── providers/            # State management (Provider pattern)
│   ├── routes/               # GoRouter navigation configuration
│   ├── screens/              # UI screens (auth, dashboard, tasks, calendar…)
│   │   ├── ai/               # AI Assistant screen
│   │   ├── analytics/        # Analytics & charts screen
│   │   ├── auth/             # Login, Register, Forgot Password
│   │   ├── calendar/         # Calendar & events screen
│   │   ├── dashboard/        # Home dashboard screen
│   │   ├── expense/          # Expense tracker screen
│   │   ├── goals/            # Goals screen
│   │   ├── notes/            # Notes screen
│   │   ├── onboarding/       # Onboarding flow
│   │   ├── profile/          # User profile screen
│   │   ├── search/           # Global search screen
│   │   ├── settings/         # Settings screen
│   │   ├── splash/           # Splash screen
│   │   ├── study/            # Study planner screen
│   │   └── tasks/            # Tasks screen
│   ├── services/             # Service layer (Auth, Hive, Notifications, AI)
│   ├── theme/                # App theme and design tokens
│   ├── utils/                # Utility helpers
│   └── widgets/              # Reusable UI components
├── docs/                     # Project documentation
├── pubspec.yaml              # Flutter project dependencies
├── firebase.json             # Firebase project configuration
└── analysis_options.yaml     # Dart static analysis configuration
```

---

## Future Enhancements

The following features are planned for future development (not currently implemented):

- ☁️ **Cloud Firestore Sync** — Sync all user data across devices in real time
- 🌐 **External AI API Integration** — Connect to an LLM API (e.g., Gemini, GPT) for advanced natural language responses
- 📱 **iOS Support** — Full iOS platform configuration and release
- 🔄 **Recurring Tasks & Events** — Support for repeating tasks and calendar events
- 🏷️ **Custom Categories & Tags** — User-defined categories across all modules
- 📤 **Data Export** — Export tasks, expenses, and notes as CSV/PDF
- 🌍 **Localisation** — Multi-language support

---

## Contributors

| Name | Role |
|---|---|
| **K Sathwik Karanth** | Developer |

---

## License

A formal license has not been applied to this project yet. Licensing information will be added at a later stage.

---

*This project was developed as a final-year BTech project.*
