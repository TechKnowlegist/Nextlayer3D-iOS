# Nextlayer3D iOS

Native SwiftUI companion app for [Nextlayer3D](https://nextlayer3d.app) — shares
the exact same AWS Amplify backend as the website (same Cognito user pool, same
AppSync GraphQL API, same S3 bucket), so an account created in one place works
in the other, and products/orders are the same data either way.

## Status: Phase 1 — Core Commerce

This is the first slice of a larger native rewrite, not the whole site. It
covers:

- Sign up / sign in / sign out (same Cognito user pool as the web app)
- Pre-Built product browsing + product detail
- Cart (local state) + Stripe checkout (PaymentSheet)
- Order confirmation + Track Order (by order number)
- Account page + saved addresses

Not yet ported (planned for later phases): the 3D Editor, Minecraft
voxelizer, AI (Layerai), AR viewer, Showroom, Build Plate, Hall of Fame,
Admin panel. See the web app's `CLAUDE.md` for the full feature list this
will eventually catch up to.

## Why this repo has no `.xcodeproj` checked in

The project file is generated from [`project.yml`](./project.yml) by
[XcodeGen](https://github.com/yonaskolb/XcodeGen) rather than hand-edited or
hand-written — this was built without access to a Mac/Xcode to verify a
committed `.xcodeproj` actually opens cleanly, so generating it from a plain
YAML spec (both locally and in CI) is the safer bet. See `SETUP.md`.

## CI

`.github/workflows/ios-ci.yml` builds the app against the iOS Simulator SDK
on every push, using GitHub's macOS runners — no Apple Developer account or
code signing required for this. It's the main way to know the Swift code
actually compiles, since no Mac was used to write it.

Getting a build you can install on a real iPhone (or submit to
TestFlight/App Store) needs an Apple Developer Program membership and a
signing certificate/provisioning profile — see `SETUP.md` for how to do that
without owning a Mac.
