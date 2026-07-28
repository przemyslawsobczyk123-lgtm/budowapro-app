# Google Play assets

`google-play-icon-512.png` is generated from the production launcher artwork:

```bash
dart run tool/prepare_play_store_assets.dart
```

The tool enforces a 512 x 512 PNG and the Google Play 1 MB file limit.
Feature graphics and screenshots must be captured from the signed release build
and reviewed before upload; placeholder or mock data must not be published.
