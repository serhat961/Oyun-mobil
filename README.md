# Polyglot Puzzle – Mobile Game Plan

Polyglot Puzzle is a hybrid block-puzzle + language-learning mobile game implemented in Flutter.

This repository contains a Clean-Architecture skeleton ready for further development, including:

1. Core game mechanics (8×8 grid, Tetromino pieces, line clearing, scoring)
2. Language-learning integration hooks (SM-2 spaced repetition, SQLite + Supabase sync)
3. Monetisation stubs (Google AdMob, in-app purchases)

## Structure

```
polyglot_puzzle_flutter/
├── lib/
│   ├── domain/         # Pure business logic
│   ├── data/           # Persistence & external APIs
│   └── presentation/   # UI widgets & view-models
├── test/               # Unit & widget tests
└── pubspec.yaml        # Dependencies
```

## Quick Start

```bash
# Install Flutter SDK ≥ 3.19 first
flutter pub get
flutter run     # Run on connected device / emulator
```

## Next Steps

– Complete gesture input for drag-and-drop piece placement with haptics.<br>
– Implement piece preview + queue.<br>
– Wire up language service to fetch / assign vocabulary.<br>
– Integrate Google Mobile Ads + in_app_purchase flows.

Happy hacking 👾