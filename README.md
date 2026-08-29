# RepDB Example — Flutter

A small Flutter (Material 3) starter that browses the current fully
illustrated [RepDB free-tier dataset](https://exercise-dataset.com/).

## Features

- Responsive grid catalog with 2/3/4 columns based on viewport
- In-memory search (substring match across name, body part, equipment)
- Detail screen with flat start/peak frames (or a single-pose "main" frame),
  instructions, primary/secondary muscles, MET, and muscle / equipment icons
  with localized labels
- Standard-tier teaser: a "Standard tier preview" strip on the catalog screen
  shows a **looping animation** — the exact clip shown on repdb.co, auto-played
  natively by `Image.asset` — with a link to pricing
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
assets/exercises.json         # the public flat-edition bundle
assets/images/flat/*.webp     # flat WebP (start/peak pairs + single-pose "main")
assets/images/muscles/*.webp  # 27 muscle icons
assets/images/equipment/*.webp# 46 equipment icons
assets/images/samples/*.webp  # 1 paid-tier looping animation (Standard-tier preview)
LICENSE-free.md               # RepDB Free Tier License for the bundle data & images
LICENSE                       # MIT for the example code
```

`pubspec.yaml` registers each of those directories; Flutter handles per-platform
asset bundling for you. The sample animation(s) are derived at load time from
the `.webp` files present in `assets/images/samples/` (see `Bundle` in
`lib/data/bundle.dart`) — there's no hardcoded list.

## Data & license

This demo uses the RepDB **free tier**: every fully illustrated exercise in
the current catalog with flat-style images, under the
[RepDB Free Tier License](LICENSE-free.md).

**Attribution required.** Keep a visible link — "Exercise data by RepDB
(repdb.co)" — in your app's credits, README, or footer.

**No generative-AI derivation.** The images may not be used as input, reference,
or conditioning material for generative models (image-to-image, style transfer,
fine-tuning, or similar). See term 5 of [LICENSE-free.md](LICENSE-free.md).

**No redistribution as a dataset** — in-app use only.

For classic images, transparent backgrounds, animations, 1024px assets, and a
commercial license without attribution, see
<https://repdb.co/pricing?utm_source=github-flutter>.

> Exercise data & images: RepDB (https://repdb.co)

## Sister demos

- [**exercise-dataset**](https://github.com/RepDB/exercise-dataset) — the raw dataset (JSON + WebP), browsable [live viewer](https://exercise-dataset.com/)
- [repdb-example-nextjs](https://github.com/RepDB/repdb-example-nextjs)
- [repdb-example-react-native](https://github.com/RepDB/repdb-example-react-native)

## License

MIT for the example code (`LICENSE`). Bundle data & images under the
[RepDB Free Tier License](LICENSE-free.md). PRs welcome — accessibility
improvements especially.
