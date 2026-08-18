# Rewire

Instrument de tip harm-reduction / impulse-control, offline-first, cu Spark
(companion vizual non-punitiv).

Aplicația pornește și **fără Firebase configurat** — totul se salvează local
(SQLite pe mobil/desktop, memorie pe web). Când Firebase e setat, datele se
sincronizează în fundal.

## Ce conține proiectul

Proiect Flutter complet (`android/`, `ios/`, `web/`, `linux/`, `windows/`, `macos/`)
plus tot codul din `lib/`:

```
lib/
├── main.dart              # Firebase (opțional) + notificări + SQLite
├── app.dart               # MaterialApp, routing
├── firebase_options.dart  # PLACEHOLDER — regenerează cu flutterfire configure
├── core/
│   ├── constants/         # paletă, temă
│   ├── services/          # SQLite, sync, notificări, auth, progres, seed, analyzer
│   └── navigation/        # navigator key (deep links din notificări)
├── models/                # User, TriggerLog, DopamineItem, Star
├── routes/                # AppRouter
└── features/
    ├── onboarding/        # splash + ecran de start (auth anonimă)
    ├── home/              # Spark + buton SOS
    ├── sos_flow/          # Rewire Now (30s / 60s / 60s + outcome)
    ├── trigger_log/       # jurnal rapid + follow-up
    ├── progress/          # constelația de stele
    ├── dopamine_menu/     # Aperitiv / Fel principal / Desert
    └── settings/          # incognito, notificări, check-in cu consimțământ
```

## Rulare

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

(cu un emulator Android, un device, Chrome, sau desktop Linux)

## Firebase (opțional, pentru sync)

1. Creează / deschide proiectul pe https://console.firebase.google.com
2. Activează **Authentication → Anonymous**
3. Activează **Firestore Database**
4. Rulează:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Asta înlocuiește `lib/firebase_options.dart` cu cheile reale. Până atunci,
aplicația rămâne 100% locală.

Regulile Firestore sunt în `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

## Notificări Android

`AndroidManifest.xml` include deja:

- `POST_NOTIFICATIONS`
- `RECEIVE_BOOT_COMPLETED`
- `VIBRATE`
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`

Check-in-ul zilnic **nu** se activează singur. `RiskPatternAnalyzer` doar
sugerează o oră din istoricul local; userul trebuie să apese
„Vreau un check-in blând atunci”.

## Assets

`assets/animations/`, `assets/sounds/`, `assets/images/` există, goale, gata
de populat (Lottie/Rive pentru Spark, sunete de respirație).
