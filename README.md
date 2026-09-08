# Swift Wheel of Fortune

A UIKit phrase-guessing coursework game with categories drawn from classic books, classic movies and television. Reveal letters, earn points using a changing multiplier, and save winning scores locally.

## Run locally

1. Open `Homework1.xcodeproj` in Xcode with an iOS 16.1 or newer simulator installed.
2. Select the **Homework1** scheme and an iPhone simulator, then run.
3. Start a game and enter one character at a time. Ten unmatched guesses end the round.

A physical device requires your own signing team and bundle identifier.

## Repository layout

- `Homework1/`: game controllers, storyboards and asset catalogue.
- `Homework1/JSONdatafiles/`: three bundled phrase lists; no network service is needed for these lists.
- `Homework1/letters/`: original A–Z letter images.
- `Homework1Tests/` and `Homework1UITests/`: original Xcode test scaffolding.
- `docs/Homework1Mohammed.docx`: original coursework document.

The Xcode project was restored from its ZIP archive and sources/resources were moved into their referenced directories. Letter-image lookups now include the bundled `letters/` directory, and the unit-test import matches the actual `Homework1` module. Author headers and coursework materials are retained.

## Status

This is an educational prototype. Test files are mostly generated scaffolding, not meaningful gameplay coverage. Input handling, punctuation display (including apostrophes in movie titles), repeated incorrect guesses and missing/corrupt phrase files still need further work. Scores are written to the app's Documents directory as `highscores.txt`.

All project file references resolve and property lists, JSON and XML resources were validated locally. No successful iOS build or simulator run is claimed: full Xcode is unavailable on the validation machine and its Swift compiler reports a duplicate `SwiftBridging` module. The reconstructed asset catalogue has an empty app-icon slot because icon artwork was absent from the original files.

## Credits

Created as coursework by Mohammed al-otaibi; original source headers and the accompanying document preserve attribution. No new licence is imposed on the original material.

## Automated checks

Run `python3 scripts/validate_resources.py` for portable resource checks. GitHub Actions runs this check and attempts unsigned iOS Simulator builds on macOS. These workflows have not yet been run remotely; successful local resource checks do not establish that an iOS build passes.
