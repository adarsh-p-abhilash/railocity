# 🚄 Railocity - Intelligent Railway Companion App

**Railocity** is a premium, cross-platform Flutter application (iOS & Android) designed as an all-in-one railway companion. It provides real-time arrival countdowns to boarding stations, next train tracking, route halts telemetry, and an integrated **Railo AI Agent** that can automate ticket bookings and convey crucial railway intelligence.

---

## ✨ Key Features

### 1. ⏱️ Live Boarding & Real-Time ETA Tracker
- **Real-Time Boarding Countdown**: Dynamically calculates and displays the exact countdown (`14m 28s until arrival`) until your train reaches your designated boarding station.
- **Boarding Station Selector**: Quickly switch between stations to recalculate live ETA, remaining stops, and platform numbers.
- **Speed & Telemetry**: Live train speed gauge (e.g., `112 km/h`), punctuality status (`On-Time` vs `+6m delay`), and distance remaining.
- **Coach Position Guide**: Visual train rake composition (Engine, EOG, 3A, 2A, 1A) highlighting your booked coach (e.g., Coach B3) and distance from the station's Foot-Over-Bridge (FOB) and escalators.
- **Interactive Route Halts Stepper**: Visual timeline showing passed halts, current train GPS position, and upcoming stations.

### 2. 📅 Train Schedules & Live Station Boards
- **Station-to-Station Search**: Query trains between any stations with departure date picker and class quota availability (1A, 2A, 3A, SL, CC, EC).
- **1-Tap AI Booking**: Instant action chips on seat cards to immediately invoke Railo AI for fast reservation.
- **Live Departure Boards**: View all upcoming train departures for any chosen station in the next 4 hours with live platform numbers.

### 3. 🤖 Railo AI Agent (Automated Bookings & Concierge)
- **Automated Ticket Reservation**: Natural language booking engine (e.g. *"Book ticket to Mumbai tomorrow"* or *"Reserve 3AC on Rajdhani"*). Railo AI analyzes the route, verifies IRCTC quota, selects preferred berths (Window/Lower), generates PNRs, and issues instant boarding passes.
- **Step-by-Step Autonomous Workflow**: Displays reasoning steps (Station Resolution ➔ Inventory Check ➔ Quota Verification ➔ PNR Generation).
- **Real-Time Intelligence Delivery**:
  - Answers *"How long until my train reaches?"* with live countdown & platform advice.
  - Guides passengers on *"Which platform is Coach B3 on?"*.
  - Delivers baggage allowance rules, onboard catering/pantry menus, and Tatkal booking guidance.

### 4. 🎫 Trips & Digital Boarding Passes
- **Digital Train Passes**: Perforated boarding pass aesthetic with QR code, PNR copy button, berth allocation, and passenger details.
- **1-Tap Track Live**: Jump directly from any ticket to the train's real-time boarding tracker.
- **Trip Cancellation**: Simulated cancellation and refund pipeline.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter 3.44+ (Dart 3.12+)
- **Target Platforms**: iOS, Android, macOS, Windows, Linux, Web
- **State Management**: Reactive ChangeNotifier & ValueNotifier architecture
- **Design System**: Material 3 + iOS modern dark aesthetic (`Outfit` Google Fonts, electric indigo & cyan accents, glassmorphic cards)
- **Packages**: `google_fonts`, `intl`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`>=3.12.0`)
- Android Studio / Xcode for mobile emulators, or Windows desktop build tools

### Installation & Run
```bash
# Clone the repository
cd railocity

# Get dependencies
flutter pub get

# Run on connected device or emulator (iOS/Android/Desktop)
flutter run

# Run tests
flutter test
```
