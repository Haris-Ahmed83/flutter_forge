# flutter_forge

> 60 Flutter projects — from **Beginner** to **Advanced** — auto-generated daily by Claude AI.

A hands-on collection of 60 Flutter projects, published **2 per day** (~30 days to complete the full series). Every project lives in its own folder and ships with `lib/main.dart`, `pubspec.yaml`, and a project-specific `README.md`.

---

## Structure

```
flutter_forge/
├── beginner/        # Projects  1 – 20
├── intermediate/    # Projects 21 – 40
└── advanced/        # Projects 41 – 60
```

Each project folder:

```
NN-project-slug/
├── lib/main.dart
├── pubspec.yaml
├── README.md
└── .gitignore
```

---

## Project List

### Beginner (1–20)
1. Hello World App — Widgets, MaterialApp
2. Counter App — setState, ElevatedButton
3. Profile Card UI — Column, Row, CircleAvatar
4. BMI Calculator — TextFields, Logic
5. Simple To-Do List — ListView, dynamic state
6. Color Picker — GestureDetector, Color
7. Quiz App — Conditional UI, Score
8. Temperature Converter — Input & conversion logic
9. Digital Clock — Timer, DateTime
10. Age Calculator — DatePicker, DateTime
11. Tip Calculator — Slider, math
12. Stopwatch App — Timer, StreamBuilder
13. Login UI Screen — Form, TextFormField
14. Onboarding Screens — PageView, Dots
15. Random Quote Generator — List, Random
16. Flashcard App — Card flip, animation
17. Unit Converter — DropdownButton
18. Number Guessing Game — Random, logic
19. Simple Calculator — Grid layout, logic
20. Dark / Light Mode Toggle — ThemeData, Provider

### Intermediate (21–40)
21. Weather App — REST API, http package
22. News Reader App — JSON parsing, ListView
23. Notes App — SQLite / Hive
24. Expense Tracker — CRUD, Charts
25. Recipe App — Navigation, Detail page
26. Movie Browser — TMDB API, FutureBuilder
27. Chat UI (Static) — Bubble UI, alignment
28. Habit Tracker — SharedPreferences, Calendar
29. Pomodoro Timer — Animation, Timer
30. Crypto Price Tracker — WebSocket / REST
31. Image Gallery App — GridView, cached images
32. QR Code Scanner — camera, qr_code_scanner
33. Maps & Location App — Google Maps, Geolocator
34. Music Player UI — Audio, Slider, Icons
35. Local Auth App — Biometrics, local_auth
36. PDF Viewer — flutter_pdfview
37. E-Commerce UI — Cart, Product Grid
38. Countdown Timer App — AnimatedContainer
39. Multi-Language App — Localization, intl
40. Push Notifications — Firebase Messaging

### Advanced (41–60)
41. Full Auth App — Firebase Auth (email + Google)
42. Real-Time Chat App — Firestore, streams
43. Blog App — Firebase CRUD, rich text
44. Social Media App — Follow, Feed, Like
45. Food Delivery App — Multi-screen, cart, orders
46. Fitness Tracker — Health API, Charts
47. Video Streaming UI — video_player, controls
48. Ride Booking App — Google Maps, real-time
49. AR Filter App — ARCore / ARKit basics
50. Flutter Web Portfolio — Responsive, animations
51. Job Board App — REST + Filter + Pagination
52. Stock Market App — Charts, live data
53. Language Learning App — Spaced repetition, audio
54. Meditation App — Animations, audio
55. Drawing / Paint App — CustomPainter, Canvas
56. Offline-First App — Hive + sync logic
57. Flutter + ML Kit — Text recognition, image labels
58. Admin Dashboard (Web) — Charts, tables, responsive
59. Multiplayer Game — WebSocket, game logic
60. Full-Stack Flutter App — Dart backend (shelf/frog) + Flutter

---

## How the automation works

- A GitHub Actions workflow (`.github/workflows/daily.yml`) runs once a day at **7 AM PKT**.
- `scripts/generate.py` reads `scripts/projects.json` and `progress.json`, generates the next **2 projects** via Claude, and commits them.
- `progress.json` tracks which projects have been generated so days can be skipped without duplicating work.
- Manually triggerable from the Actions tab (`workflow_dispatch`) — optional `count` input to override how many to generate.

## Run any project locally

```bash
cd beginner/01-hello-world-app
flutter pub get
flutter run
```

> Some advanced projects require external setup (Firebase, Google Maps API key, etc.). Check each project's README.

---

## Author

**HarisAhmed83** — https://github.com/Haris-Ahmed83
