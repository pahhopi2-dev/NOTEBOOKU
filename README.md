# Notebooku

Notebooku adalah app catatan Flutter yang clean, responsive, offline-first, dan
siap disambungkan ke backend Firebase Functions untuk sync.

## Fitur Utama

- UI Material 3 baru dengan light/dark/system theme.
- Layout responsive untuk mobile, tablet, desktop, dan web.
- Hive local storage untuk catatan offline.
- Riverpod sebagai single source of truth untuk notes state.
- Filter kategori dengan count, pencarian real-time, sort, grid/list view.
- Bottom navigation aktif: Notes, Tugas, Pin, dan Setelan.
- Editor baru dengan checklist helper, timestamp helper, pin, kategori, warna,
  dan statistik kata/checklist.
- Slidable actions: pin, edit, duplicate, delete dengan undo.
- Animasi halus pada route transition, card, empty state, dan editor.
- Backend Node.js Firebase Functions untuk list/create/upsert/delete/summary.
- API client Flutter (`SyncService`) untuk integrasi sync HTTP.

## Struktur

```text
lib/
  main.dart
  models/
  providers/
  screens/
  services/
  theme/
  utils/
  widgets/
cloud_functions/
  index.js
  package.json
docs/
  API.md
```

## Menjalankan Flutter

```bash
flutter pub get
flutter run
```

## Quality Check

```bash
dart format .
flutter analyze
flutter test
```

## Backend Emulator

```bash
cd cloud_functions
npm install
npm run serve
```

Endpoint default Flutter:

```text
http://127.0.0.1:5001/notebooku/us-central1/api
```

Lihat dokumentasi endpoint di `docs/API.md`.
