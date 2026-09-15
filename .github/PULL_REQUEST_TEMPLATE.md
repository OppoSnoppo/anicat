<!-- Base branch must be `native-swift`, not `master`. See CONTRIBUTING.md. -->

## What this changes

<!-- What the change does and why. Link the issue it fixes, e.g. "Fixes #12". -->

## How it was tested

<!-- What you ran and what you saw. For UI changes, a screenshot or short recording helps. -->

## Checklist

- [ ] Base branch is `native-swift`
- [ ] `cargo test --lib` and `cargo clippy --lib --tests -- -D warnings` pass in `core/`
- [ ] `swift build --product Anicat` and `swift test` pass in `AnicatApple/`
- [ ] `scripts/build-xcframework.sh` rerun if `core/src/ffi.rs` changed
- [ ] Shared views still compile for the iOS Simulator
- [ ] Commit messages follow Conventional Commits; no emojis; English only
