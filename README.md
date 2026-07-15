# Tiny Tap Kids

A playful, toddler-friendly interactive Flutter application that works on both Mobile (Android) and Desktop (Windows/Linux).

## Features

- **Language Selection**: Choose between English and Hindi
- **Interactive Characters**: Tap or press keys to interact with floating letters and emojis
- **Animations**: Smooth floating animations, zoom effects, and particle bursts
- **Responsive Design**: Adapts to both mobile and desktop screen sizes
- **Offline**: No internet connection required

## Project Structure

```
lib/
├── main.dart                              # App entry point
├── screens/
│   ├── language_screen.dart              # Language selection screen
│   └── main_screen.dart                   # Main interaction screen
└── widgets/
    ├── floating_character_widget.dart     # Animated character widget
    └── background_bubbles.dart            # Background animation
```

## How to Run

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- For Desktop: Windows, Linux, or macOS development environment

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run on mobile:
```bash
flutter run
```

3. Run on desktop:
```bash
flutter run -d windows
# or
flutter run -d linux
# or
flutter run -d macos
```

## How to Play

### Mobile
- Tap on floating characters to see them enlarge with burst effects
- Tap anywhere on the screen to return to normal

### Desktop
- Press keyboard keys that match visible characters
- Click with mouse to interact like mobile
- Press ESC or click back button to return to language selection

## Characters

### English Mode
- Letters: A-Z
- Numbers: 0-9
- Emojis: e.g., 😊, ⭐, ❤️, 🌟

### Hindi Mode
- Letters: All Hindi vowels and consonants
- Numbers: 0-9
- Emojis: e.g., 😊, ⭐, ❤️, 🌟
