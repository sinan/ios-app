# Developer Setup Guide

Get HA Dashboard building and running from scratch on a new Mac.

## Prerequisites

### macOS

Apple Silicon Mac required (arm64). Intel Macs won't run the arm64 simulators.

### Xcode

| Xcode | Install Path | Required? | Purpose |
|-------|-------------|-----------|---------|
| **26** (latest) | `/Applications/Xcode.app` | Yes | Builds all targets: simulator, device arm64, Mac Catalyst |
| **13.2.1** | `/Applications/Xcode-13.2.1.app` | Only for iPad 2 | Provides armv7 SDK stubs for the universal device build |

After installing Xcode 26, open it once and install the iOS simulator runtime when prompted.

If you don't need to target iPad 2 (armv7), you can skip Xcode 13.2.1 entirely — the `sim` and `mac` build targets only use Xcode 26.

### Homebrew Dependencies

```bash
brew install xcodegen
```

That's the only required Homebrew dependency. XcodeGen generates the `.xcodeproj` from `project.yml`.

### Optional Tools (for physical device deploy)

These are only needed if deploying to physical devices, not for simulator development:

| Tool | Install | Used By |
|------|---------|---------|
| `pymobiledevice3` | `pip install pymobiledevice3` | iPad Mini 4 deploy |
| `sshpass` | `brew install hudochenkov/sshpass/sshpass` | iPad 2 WiFi SSH deploy |

## Quick Start (Simulator)

```bash
# 1. Clone the repo
git clone https://github.com/ha-dashboard/ios-app.git
cd ios-app

# 2. Create your .env file
cp .env.example .env
```

Edit `.env` with at minimum:
```bash
BUNDLE_ID=com.yourname.hadashboard    # Your bundle identifier
# Apple Team ID is optional for simulator-only builds
```

If you have a Home Assistant server, also set:
```bash
HA_SERVER=http://192.168.1.100:8123   # Your HA server
HA_TOKEN=eyJ...                        # Long-lived access token from HA
HA_DASHBOARD=living-room               # Dashboard path
```

If you don't have a HA server, you can use demo mode (see below).

```bash
# 3. Generate the Xcode project
scripts/regen.sh

# 4. Build and run in the iPad simulator
scripts/deploy.sh sim
```

This builds the app and launches it in an iPad simulator. The first build takes a couple of minutes; subsequent builds are incremental.

For an iPhone simulator instead:
```bash
scripts/deploy.sh sim iphone
```

### Demo Mode (No Server Needed)

If you don't have a Home Assistant server available:

```bash
scripts/deploy.sh sim --demo
```

This launches with 3 built-in dashboards (Home, Monitoring, Media) using simulated entities and history data. No network connection required.

## What the Scripts Do

| Script | Purpose |
|--------|---------|
| `scripts/regen.sh` | Runs XcodeGen to generate `.xcodeproj` from `project.yml`. Run after changing project.yml or adding/removing source files. |
| `scripts/build.sh sim` | Builds arm64 simulator binary |
| `scripts/build.sh device` | Builds universal armv7+arm64 device binary (requires Xcode 13.2.1) |
| `scripts/build.sh mac` | Builds Mac Catalyst binary |
| `scripts/deploy.sh <target>` | Builds + installs + launches on a target |
| `scripts/test-snapshots.sh` | Runs snapshot regression tests |
| `scripts/clean.sh` | Cleans build artifacts |

`deploy.sh` calls `build.sh` automatically — you don't normally need to call `build.sh` directly.

## Opening in Xcode

If you prefer building from Xcode's UI rather than the command line:

1. Run `scripts/regen.sh` to generate the project
2. Open `HADashboard.xcodeproj`
3. Select the **HADashboard** scheme
4. Choose a simulator destination
5. Build and run (Cmd+R)

Note: the build scripts inject the version number from git tags. Building directly from Xcode uses the `0.0.0` fallback, which is fine for development.

## Running Tests

```bash
scripts/test-snapshots.sh
```

This runs pixel-perfect snapshot regression tests against reference images in `HADashboardTests/ReferenceImages_64/`. The tests use an iPad 10th gen simulator on iOS 17.4.

To re-record reference images after intentional visual changes:
```bash
scripts/test-snapshots.sh record
```

## Versioning

Version numbers come from git tags — never hardcode them:

```bash
git tag v1.2.3
git push --tags
```

The build scripts read the latest `v*` tag for `MARKETING_VERSION` and use the commit count for `CURRENT_PROJECT_VERSION`.

## Project Overview

- **Language**: Pure Objective-C — no Swift, no storyboards, no XIBs
- **UI**: All programmatic, using `NSLayoutConstraint` anchors (iOS 9+ compatible)
- **Networking**: SocketRocket (WebSocket), NSURLSession (REST)
- **Project config**: XcodeGen (`project.yml`) — the `.xcodeproj` is generated and committed, but should be regenerated via `scripts/regen.sh` after changing `project.yml`

### Key Directories

```
HADashboard/         App source code
├── Auth/            Authentication (OAuth, tokens, keychain)
├── Controllers/     View controllers (dashboard, settings)
├── Models/          Data models, Lovelace JSON parser
├── Networking/      WebSocket, REST, mDNS discovery
├── Theme/           Themes, icon mapping, haptics
└── Views/           All UI — cells, layouts, helpers
Vendor/              Third-party: SocketRocket, MDI icons, snapshot test framework
HADashboardTests/    Snapshot regression tests + reference images
scripts/             Build, deploy, test automation
```

## Troubleshooting

**`xcodegen: command not found`** — Run `brew install xcodegen`

**Simulator not found** — Open Xcode, go to Settings > Platforms, and install the iOS simulator runtime. The deploy script looks for "iPad Pro 11 M4" by default; set `SIM_IPAD_NAME` in `.env` to match an available simulator.

**Build fails with signing errors** — For simulator builds, signing is disabled automatically. For device builds, you need `APPLE_TEAM_ID` set in `.env`.

**Snapshot tests fail immediately** — Make sure you have the iPad (10th generation) + iOS 17.4 simulator runtime installed. Snapshot tests are pixel-exact and depend on a specific device/OS combination.
