# Publishing Welkin to the App Store

A step-by-step guide, tailored to this project. Budget ~1–2 hours for the first
submission, plus Apple's review time (usually 24–48h).

---

## 0. Prerequisites

- **A Mac with Xcode** (you have Xcode 26).
- **Apple Developer Program membership** — $99/year. Enroll at
  <https://developer.apple.com/programs/>. You cannot ship to the App Store
  without this (a free account only allows on-device testing).
- **A unique Bundle ID.** This project currently uses `com.welkin.weather.*`,
  which you almost certainly don't own. Pick a reverse-DNS prefix you control,
  e.g. `com.jeremylastname.welkin`. See step 1.

---

## 1. Rename the bundle identifiers to something you own

The IDs appear in **four** places — change all of them consistently:

1. `project.yml`
   - `options.bundleIdPrefix: com.YOURNAME`
   - app `PRODUCT_BUNDLE_IDENTIFIER: com.YOURNAME.welkin`
   - widget `PRODUCT_BUNDLE_IDENTIFIER: com.YOURNAME.welkin.WelkinWidget`
     (the widget ID **must** be prefixed by the app ID)
   - set `DEVELOPMENT_TEAM: ABCDE12345` (your 10-char Team ID from
     <https://developer.apple.com/account> → Membership)
2. `Resources/Welkin.entitlements` — the App Group string
3. `Widget/WelkinWidget.entitlements` — the same App Group string
4. `Sources/Shared/SharedStore.swift` — `static let appGroup = "group.com.YOURNAME.welkin"`

Use a matching App Group id, e.g. `group.com.YOURNAME.welkin`. Then regenerate:

```sh
xcodegen generate
```

---

## 2. Let Xcode register the identifiers & App Group

```sh
open Welkin.xcodeproj
```

For **each** target (Welkin and WelkinWidgetExtension):
- Select the target → **Signing & Capabilities**
- Check **Automatically manage signing**, choose your **Team**
- Xcode will register the App IDs and the App Group on the developer portal for
  you (the App Group capability is already declared via the entitlements files).

If you prefer to do it by hand, create the two App IDs and the App Group at
<https://developer.apple.com/account/resources/identifiers/list>.

---

## 3. Icon, version, and build number (mostly done)

- **App icon** — a 1024×1024 opaque PNG is already in
  `Resources/Assets.xcassets/AppIcon.appiconset` (alpha channel removed, which
  the App Store requires).
- **Version / build** — set in `project.yml`:
  `MARKETING_VERSION` (e.g. `1.0`) and `CURRENT_PROJECT_VERSION` (e.g. `1`).
  Bump the build number on every upload.

---

## 4. Create the app record in App Store Connect

Go to <https://appstoreconnect.apple.com> → **Apps** → **+** → **New App**:

- **Platform:** iOS
- **Name:** Welkin (must be globally unique — have a backup name ready)
- **Primary language**, **Bundle ID** (pick the app ID from step 2), **SKU** (any
  unique string, e.g. `welkin-001`)
- **Category:** Weather

Then fill in, under the version:
- **Description, keywords, subtitle, promotional text**
- **Support URL** and **Marketing URL** (a simple web page is fine)
- **Screenshots** — required for at least the 6.9"/6.7" iPhone. You can capture
  these from the simulator:
  ```sh
  xcrun simctl io booted screenshot shot.png
  ```
  Take 3–5 showing the landmark hero, hourly, 7-day + AQI, and the widget.

---

## 5. Privacy — required before you can submit

- **Location usage string** is already set (`NSLocationWhenInUseUsageDescription`
  in `Resources/Info.plist`). Good.
- **App Privacy "nutrition label"** (App Store Connect → your app → **App
  Privacy**): declare that you collect **Location (Precise or Coarse)** used for
  **App Functionality**, **not linked** to the user's identity, **not used for
  tracking**. Welkin sends coordinates to Open-Meteo only to fetch weather; it has
  no accounts, ads, or analytics, so everything else is "No".
- **Privacy Policy URL** is required. Host a short policy stating the app sends
  location to Open-Meteo to retrieve weather and stores nothing personal.

---

## 6. ⚠️ Weather data licensing (read this)

Welkin uses **Open-Meteo**. Two things matter for the store:

1. **Attribution.** Open-Meteo data is CC-BY 4.0 — the app already shows
   "Data from Open-Meteo". Keep it.
2. **Commercial use.** Open-Meteo's free API is intended for **non-commercial**
   use with fair-use limits (~10k calls/day). If you charge for the app, add
   ads/IAP, or expect heavy traffic, get an **Open-Meteo API key** (paid plan)
   and add it to the request URLs, or switch providers (Apple WeatherKit is a
   natural fit — 500k calls/mo included with the developer program). For a free,
   personal, low-volume app the current setup is fine.

---

## 7. Archive & upload

In Xcode:
1. Select the **Welkin** scheme and the **Any iOS Device (arm64)** destination
   (not a simulator).
2. **Product → Archive**.
3. When the Organizer opens: **Distribute App → App Store Connect → Upload**.
   Xcode handles signing, embeds the widget, and uploads.

Command-line alternative:
```sh
xcodebuild -project Welkin.xcodeproj -scheme Welkin \
  -destination 'generic/platform=iOS' -archivePath build/Welkin.xcarchive archive
xcodebuild -exportArchive -archivePath build/Welkin.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath build/export
# then upload build/export/*.ipa with `xcrun altool` or Transporter
```

---

## 8. TestFlight (optional but recommended)

Once the build finishes processing (~15–30 min) it appears in **TestFlight**.
Install it on your own device, add the widget to your Home Screen, and confirm
everything works against the real network and real GPS before shipping.

---

## 9. Submit for review

Back in App Store Connect → your version:
- Attach the uploaded **Build**.
- Set **age rating** (Weather with no objectionable content → 4+).
- **Export compliance:** the app uses only standard HTTPS, so answer that it uses
  exempt encryption.
- Click **Add for Review → Submit**.

Apple reviews it (usually a day or two). If rejected, they cite the guideline;
fix and resubmit. Common first-timer issues: missing privacy policy, screenshots
that don't match the app, or an unclear location-permission reason.

---

## 10. Release

After approval you can release immediately or schedule it. Updates repeat steps
3, 7, and 9 with a bumped version/build number.

### Quick checklist
- [ ] Developer Program active
- [ ] Bundle IDs + App Group renamed to a domain you own (4 files)
- [ ] Team set, automatic signing on for both targets
- [ ] App record created in App Store Connect
- [ ] Screenshots + description + privacy policy URL
- [ ] App Privacy label filled (Location → App Functionality)
- [ ] Open-Meteo attribution kept / commercial plan if monetized
- [ ] Archive uploaded, build attached, submitted
