# DebtZero AI — Flutter source (build this into your APK)

## Fastest path: build it in the cloud, no install on your computer

This zip includes `.github/workflows/build-apk.yml`, a GitHub Actions
workflow that builds the APK for you on GitHub's servers — you don't need
Flutter, Android Studio, or any SDK on your own machine. You just need a
free GitHub account.

1. Create a new repo on GitHub (public or private, doesn't matter).
2. Push this unzipped folder to it:
   ```
   git init
   git add .
   git commit -m "DebtZero AI initial source"
   git branch -M main
   git remote add origin https://github.com/<you>/<repo>.git
   git push -u origin main
   ```
3. Go to the **Actions** tab on your repo. A "Build Android APK" run will
   already be in progress (it triggers on push). Wait for it to finish
   (a few minutes).
4. Open the finished run, scroll to **Artifacts**, and download
   `debtzero-ai-debug-apk` — that's a `.zip` containing `app-debug.apk`.
5. Transfer that `.apk` to your phone (email it to yourself, upload to
   Google Drive, or use `adb push`) and tap it to install. You'll need to
   allow "install from unknown sources" the first time.
6. Open the app, grant the SMS permission when asked, and it'll scan your
   real inbox for bank/UPI alerts.

This builds a **debug** APK (fine for personal use/testing). If you want a
smaller, optimized **release** APK instead, change `flutter build apk --debug`
to `flutter build apk --release` in `.github/workflows/build-apk.yml` —
note a release build needs a signing key for the Play Store, but an
unsigned/debug-signed release APK still installs and runs fine via sideload.

---

## Alternative: build locally instead

This is a real Flutter project: local JSON file storage, a working SMS/UPI
scraper, the corrected cash/safe-to-spend math, an offline rule-based AI
coach, and all the screens from the earlier web prototype. It was written
in a sandbox **without Flutter/Android SDK or internet access**, so it has
**not been compiled or run yet** — you'll do that build step on your own
machine, where the toolchain actually exists. Budget 20–30 minutes for
first-time setup if you don't already have Flutter installed.

## What's already done for you
- `lib/` — every screen, model, and service (storage, SMS parsing,
  categorization, calculations, AI coach) fully written.
- `pubspec.yaml` — all required dependencies already listed.
- `android/app/src/main/AndroidManifest.xml` — SMS/notification permissions
  already added, with a comment explaining the Play Store caveat.

## What you need to add (standard Flutter scaffolding only)
This sandbox can't run the `flutter create` command, so the boilerplate
platform files Flutter normally generates (Gradle wrapper, `MainActivity`,
launcher icons, `build.gradle` files, iOS folder, etc.) aren't here yet.
You'll generate those in one command — it will NOT overwrite the files
already provided above, because `flutter create` skips files that already
exist in the target folder.

## Step-by-step

1. **Install Flutter** (if you haven't): https://docs.flutter.dev/get-started/install
   Then run `flutter doctor` and resolve anything it flags (Android SDK,
   accepted licenses, etc.).

2. **Unzip this project**, `cd` into the folder, and generate the missing
   platform scaffolding:
   ```
   flutter create .
   ```
   You'll see it report a handful of "created" files (Gradle wrapper,
   `MainActivity.kt`, icons, etc.) and skip the ones we already wrote.

3. **Install dependencies:**
   ```
   flutter pub get
   ```
   If `another_telephony` has been renamed/updated since this was written,
   `pub get` will tell you — check https://pub.dev/packages/another_telephony
   for the current API and adjust `lib/services/sms_service.dart` if any
   method names changed slightly. Everything else in the app is independent
   of that package and won't need touching.

4. **Connect a real Android device** (USB debugging on) — an emulator
   won't have real SMS to scrape, so test the SMS scraper on a physical
   phone. For everything else (UI, storage, calculations, AI coach) an
   emulator is fine.

5. **Run it in debug mode first** to catch anything that needs a fix:
   ```
   flutter run
   ```

6. **Build the release APK:**
   ```
   flutter build apk --release
   ```
   Output lands at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

7. **Install it on your phone:**
   ```
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```
   or just copy the `.apk` file to the phone and tap it (enable "install
   from unknown sources" for sideloading).

## Important: SMS permission & Play Store
Google Play restricts `READ_SMS`/`RECEIVE_SMS` to apps that are the user's
default SMS/dialer app, with very few approved exceptions — a debt app
won't qualify. **That restriction only applies to apps distributed through
the Play Store.** A sideloaded APK (installed directly, not via Play) is
not subject to it, so this works as-is for personal use. If you later want
to publish to Play, swap the ingestion approach to:
- the **Account Aggregator (AA)** framework (e.g. via Setu, Finvu, OneMoney) — the compliant, durable path, or
- a `NotificationListenerService` reading GPay/PhonePe/Paytm notification text instead of raw SMS.

Either way, only `lib/services/sms_service.dart` needs to change — nothing
else in the app depends on *how* transactions arrive.

## Where things are stored right now (and how to move to a DB later)
Everything lives in one JSON file in the app's private documents directory
(`lib/services/storage_service.dart`, `LocalFileStorageService`). To move
to SQLite or a remote API later:
1. Write a new class implementing the same `StorageService` interface
   (`load()` / `save(AppData)`).
2. Swap `LocalFileStorageService()` for your new class in `lib/main.dart`.
Nothing in `AppState` or any screen needs to change.

## What's intentionally simplified for this first build
- **OTP login is mocked** (any 4 digits work) — there's no backend yet to
  send/verify a real OTP. Swap-in point is `OtpScreen._verify()`.
- **AI Coach is offline/rule-based** (keyword matching against your real
  numbers), not OpenAI-backed yet — swap-in point is `lib/services/ai_coach.dart`.
- **SMS parsing regexes are a starting point.** Indian bank SMS formats
  vary a lot bank-to-bank; expect to add a few bank-specific patterns in
  `SmsService.parseBankSms()` once you see real messages it misses.

## Design tokens
Matches the original brief exactly: white background (#FFFFFF), text
#111827, success #16A34A, warning #F59E0B, danger #DC2626, brand navy
#1E3A5F, gold accent #B8860B (`lib/theme/app_theme.dart`).
