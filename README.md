# Flutter + Firebase — серія лабораторних (Блок 5)

Наскрізний Flutter-застосунок, що розвивається протягом лабораторних робіт блоку **Firebase**.
Кожна ЛР додає окрему функціональність і описана у власній секції нижче — нові роботи
(LR17, LR18, …) дописуються як нові заголовки, не ламаючи попередні.

## Статус робіт

| ЛР   | Тема                          | Статус         |
|------|-------------------------------|----------------|
| LR16 | Firebase Authentication       | ✅ Готово       |
| LR17 | Cloud Firestore (Notes)       | ✅ Готово       |
| LR18 | Firebase Storage              | 🔜 Заплановано  |

## Технології

Flutter · Dart · Material 3 · `firebase_core` · `firebase_auth` · `cloud_firestore` · `firebase_ui_firestore` · `intl`

## Запуск

```bash
flutter pub get
flutterfire configure        # генерує lib/firebase_options.dart і налаштовує платформи
flutter run -d chrome        # або -d windows / Android-емулятор
```

> ⚠️ **LR16:** у **Firebase Console → Authentication → Sign-in method** має бути увімкнено
> провайдер **Email/Password**, інакше реєстрація/вхід повертатимуть `operation-not-allowed`.
>
> ⚠️ **LR17:** у **Firebase Console → Firestore Database** має бути створено базу та
> опубліковано Security Rules (див. секцію LR17), інакше операції з нотатками дадуть `permission-denied`.

---

## LR16 — Firebase Authentication

Повноцінна автентифікація через email/пароль.

### Реалізовано

- 📝 **Sign Up** — реєстрація з валідацією (ім'я, email, пароль, підтвердження) + `updateDisplayName`
- 🔑 **Login** — вхід через email/пароль
- 🚪 **Logout** — вихід із діалогом підтвердження
- 🔄 **Password Reset** — скидання паролю листом на email
- 🛡️ **Protected routes** — доступ до екранів лише для авторизованих (`ProfileScreen`, in-screen guard)
- 💾 **Auth state persistence** — сесія зберігається автоматично; `AuthWrapper` слухає `authStateChanges()`
- ⚠️ **Error handling** — `describeError()` (`utils/errors.dart`) перетворює помилки Firebase (auth + Firestore) у дружні повідомлення; показ через `context.showSnackBar()`

### Структура `lib/`

```
lib/
├── main.dart                          # ініціалізація Firebase + MaterialApp(home: AuthWrapper)
├── firebase_options.dart              # згенеровано flutterfire configure
├── widgets/
│   └── auth_wrapper.dart              # StreamBuilder(authStateChanges) → Home / Login
├── screens/
│   ├── login_screen.dart              # вхід + посилання на Sign Up / Forgot Password
│   ├── sign_up_screen.dart            # реєстрація
│   ├── forgot_password_screen.dart    # скидання паролю
│   ├── home_screen.dart               # захищений головний екран + logout
│   └── profile_screen.dart            # захищений екран профілю (protected route)
└── utils/
    └── errors.dart                    # describeError() + context.showSnackBar() (auth + Firestore)
```

### Перевірка

```bash
flutter analyze   # No issues found!
flutter test      # юніт-тести (errors, Note)
```

---

## LR17 — Cloud Firestore (Notes App)

Нотатки користувача в хмарній NoSQL-базі **Firestore**, поверх автентифікації LR16 —
кожен бачить лише свої нотатки.

### Реалізовано

- ✍️ **Create / ✏️ Update / 🗑️ Delete** — CRUD через `FirestoreService`
- 📖 **Read (real-time)** — `FirestoreListView` (`firebase_ui_firestore`) поверх `snapshots()`; UI оновлюється миттєво
- 👤 **User-specific data** — шлях `users/{uid}/notes`; Security Rules за `request.auth.uid`
- 🕓 **serverTimestamp** — `createdAt` / `updatedAt` проставляє сервер
- 📄 **Pagination** — курсорна, вбудована у `FirestoreListView`: наступна сторінка підвантажується при прокрутці, читаються лише показані документи
- 📴 **Offline persistence** — локальний кеш Firestore (працює офлайн, синхронізується онлайн)

### Структура `lib/` (додано до LR16)

```
lib/
├── models/
│   └── note.dart                      # Note model (fromJson/toJson/copyWith)
├── services/
│   └── firestore_service.dart         # CRUD + typed notesQuery() на users/{uid}/notes
└── screens/
    ├── notes_list_screen.dart         # список нотаток (FirestoreListView) + delete
    └── note_editor_screen.dart        # створення / редагування нотатки
```
(`main.dart` — offline persistence; `home_screen.dart` — кнопка **My Notes**; `utils/errors.dart` — обробку помилок розширено на Firestore.)

### Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## LR18 — Firebase Storage · 🔜 заплановано

> Буде додано в наступній лабораторній. Опис функціональності та змін у `lib/` з'явиться тут.
