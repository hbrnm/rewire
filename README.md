# Rewire

Instrument de tip harm-reduction / impulse-control, offline-first, cu Spark (companion vizual non-punitiv).

## Ce contine acest arhivă

Doar codul sursă Dart (`lib/`), `pubspec.yaml`, `assets/` (goale, gata de populat) și un
`AndroidManifest.xml` de referință cu permisiunile de notificări adăugate. **Nu conține**
proiectul Flutter complet generat (folderele `android/`, `ios/`, `windows/` etc. cu tot
scheletul nativ) — acelea se generează local, la tine pe calculator, cu `flutter create`.

## Pași de instalare, pe scurt

1. **Dezarhivează** acest zip într-un folder temporar, de exemplu `D:\rewire_cod`.

2. **Creează proiectul Flutter real** (dacă nu-l ai deja):
   ```
   cd D:\projects
   flutter create rewire
   ```

3. **Copiază peste proiectul generat:**
   - tot conținutul folderului `lib/` din arhivă → suprascrie `D:\projects\rewire\lib\`
   - `pubspec.yaml` din arhivă → suprascrie `D:\projects\rewire\pubspec.yaml`
   - conținutul din `assets/` din arhivă → copiază în `D:\projects\rewire\assets\`
   - **AndroidManifest.xml**: nu suprascrie orbește fișierul generat de Flutter — deschide
     `D:\projects\rewire\android\app\src\main\AndroidManifest.xml` și adaugă manual cele
     3 linii `<uses-permission ...>` din fișierul inclus aici (`android/app/src/main/AndroidManifest.xml`),
     imediat sub tag-ul `<manifest ...>`.

4. **Instalează dependințele:**
   ```
   cd D:\projects\rewire
   flutter pub get
   ```

5. **Configurează Firebase** (obligatoriu — aplicația nu pornește fără asta):
   - creează un proiect gratuit pe https://console.firebase.google.com
   - activează **Authentication → Sign-in method → Anonymous**
   - activează **Firestore Database** (mod test, pentru început)
   - în terminal:
     ```
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
     Asta va **suprascrie automat** fișierul placeholder `lib/firebase_options.dart`
     inclus în arhivă, cu valorile reale ale proiectului tău Firebase.

6. **Rulează:**
   ```
   flutter run
   ```
   (cu un emulator Android pornit sau un device conectat)

## Firestore Security Rules

Incluse ca fișier separat: **`firestore.rules`** (în rădăcina arhivei). Le publici cu:
```
firebase deploy --only firestore:rules
```
sau le lipești direct în Firebase Console → Firestore Database → Rules.

## Structura codului

```
lib/
├── main.dart              # entry point, initializeaza Firebase + notificari
├── app.dart                # MaterialApp, routing
├── firebase_options.dart   # PLACEHOLDER - se regenereaza cu flutterfire configure
├── core/
│   ├── constants/          # culori, tema
│   ├── services/           # SQLite, sync, notificari, auth, progres, seed data
│   └── navigation/         # navigator key global (pt. deep links din notificari)
├── models/                 # UserModel, TriggerLogModel, DopamineItemModel
├── routes/                 # AppRouter
└── features/
    ├── onboarding/          # splash gate + ecran de start (auth anonima)
    ├── home/                # ecranul principal (Spark + buton SOS)
    ├── sos_flow/            # fluxul "Rewire Now" (30s/60s/60s + outcome)
    ├── trigger_log/         # jurnal rapid + follow-up dupa notificare
    ├── progress/            # Spark widget + constelatia de stele
    ├── dopamine_menu/       # alternative sanatoase, pe categorii de timp
    └── settings/            # mod incognito / notificari + sugestie check-in
```

`core/services/risk_pattern_analyzer.dart` deriva ora din zi cu cea mai mare frecventa
de impulsuri, din istoricul local. E folosit doar ca sugestie in ecranul de Setari —
userul trebuie sa apese explicit "Vreau un check-in blând atunci" ca sa se activeze o
notificare zilnica recurenta (consimtamant, nu supraveghere silentioasa).

## Status

Toate ecranele majore sunt implementate end-to-end: onboarding → home → SOS flow →
outcome → constelatie, plus jurnal rapid, meniu dopamină, notificări de follow-up cu
navigare directă din notificare, toate salvând local (SQLite, offline-first) și
sincronizând cu Firestore în fundal când există conexiune.

Rămas de făcut / de testat local:
- configurarea reală a Firebase (pas 5 de mai sus)
- testare end-to-end pe emulator/device
- eventual: Cloud Function care rulează `RiskPatternAnalyzer`-ul echivalent server-side
  (varianta curentă rulează 100% local, pe device)
- conținut real pentru `assets/` (animații Lottie/Rive pentru Spark, sunete de respirație) —
  folderele sunt incluse, dar goale
