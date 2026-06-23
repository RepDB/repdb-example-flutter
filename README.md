# RepDB Example — Flutter

A small Flutter (Material 3) starter that browses 21 fitness exercises from
the [RepDB](https://repdb.co) preview dataset.

## Features

- Responsive grid catalog with 2/3/4 columns based on viewport
- In-memory search (substring match across name, body part, equipment)
- Detail screen with start + peak frames, instructions, primary/secondary muscles
- Hero animation on the peak frame between catalog and detail
- EN / DE / ES locale switch (translates exercise data — UI strings are EN)
- Light + dark themes derived from a single seed color

## Run

```bash
flutter pub get
flutter run -d chrome    # or your iOS/Android simulator
```

## Build

```bash
flutter build web        # → build/web/
flutter build apk --debug
```

## What's vendored where

```
assets/exercises.json       # the preview bundle
assets/images/flat/*.webp   # 42 webp images (21 exercises × start/peak)
LICENSE-preview.md          # CC-BY-NC for the bundle data
LICENSE                     # MIT for the example code
```

`pubspec.yaml` registers `assets/exercises.json` and the entire
`assets/images/flat/` directory; Flutter handles per-platform asset bundling
for you.

## Data

This demo uses the RepDB **preview** bundle: 21 hand-picked exercises under
[CC-BY-NC 4.0](LICENSE-preview.md). For commercial use or the full dataset
(400+ exercises with two visual styles, transparent backgrounds, animations,
multilingual translations, alternative & progression relations), see
<https://repdb.co/pricing>.

> Exercise data & images: RepDB (https://repdb.co)

## Sister demos

- [repdb-example-nextjs](https://github.com/sergei-argutin/repdb-example-nextjs)
- [repdb-example-react-native](https://github.com/sergei-argutin/repdb-example-react-native)

## License

MIT for the example code (`LICENSE`). Bundle data under CC-BY-NC 4.0
(`LICENSE-preview.md`). PRs welcome — accessibility improvements especially.
