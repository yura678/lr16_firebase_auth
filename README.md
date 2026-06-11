# Flutter + Firebase — серія лабораторних (Блок 5)

Наскрізний Flutter-застосунок, що розвивається протягом лабораторних робіт блоку **Firebase**.
Кожна ЛР додає окрему функціональність і описана у власній секції нижче — нові роботи
(LR17, LR18, …) дописуються як нові заголовки, не ламаючи попередні.

## Статус робіт

| ЛР   | Тема                          | Статус         |
|------|-------------------------------|----------------|
| LR16 | Firebase Authentication       | ✅ Готово       |
| LR17 | Cloud Firestore (Notes)       | ✅ Готово       |
| LR18 | Firebase Storage (фото)       | ✅ Готово       |

## Технології

Flutter · Dart · Material 3 · `firebase_core` · `firebase_auth` · `cloud_firestore` · `firebase_ui_firestore` · `firebase_storage` · `image_picker` · `intl`

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
>
> ⚠️ **LR18:** у **Firebase Console → Storage** має бути створено бакет та опубліковано
> Storage Rules (див. секцію LR18). Для запуску на **web** додатково потрібно налаштувати
> **CORS** на бакеті — інакше завантажене фото не відобразиться (`Image.network` блокується
> політикою CORS). На Android/iOS цей крок не потрібен.

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

## LR18 — Firebase Storage (фото в нотатках)

Розширення Notes App: до кожної нотатки можна прикріпити одне фото. Файл зберігається у
**Firebase Storage**, а його посилання (download URL) — у Firestore-документі нотатки.

### Реалізовано

- 📷 **Pick image** — вибір з галереї через `image_picker`; `maxWidth/Height` + `imageQuality:85` стискають фото перед завантаженням
- ⬆️ **Upload** — `StorageService.uploadNoteImage` через `putData` (байти — працює і на web, і на мобільних) у `users/{uid}/notes/{noteId}/`
- 📊 **Progress** — `UploadTask.snapshotEvents` → `LinearProgressIndicator` з відсотком
- 🔗 **Download URL** — `getDownloadURL()` після завантаження
- 💾 **Firestore integration** — URL пишеться в поле `imageUrl` нотатки одним записом (id генерується локально через `newNoteId()` ще до завантаження)
- 🖼️ **Display** — `Image.network` з loading/error builder: повне фото в редакторі + 48×48 мініатюра у списку
- 🗑️ **Delete** — `refFromURL().delete()`; старий файл прибирається при заміні/видаленні фото та при видаленні нотатки
- 📏 **Validation** — макс. **5 МБ**, перевірка перед завантаженням
- 🏷️ **Metadata** — `contentType` + `customMetadata` (`userId`, `noteId`)
- ⚠️ **Error handling** — коди Storage (`unauthorized`, `canceled`, `quota-exceeded`, `object-not-found`, `retry-limit-exceeded`) додано в `describeError()`
- 🧱 **Рефакторинг архітектури** — пошарова структура: `AuthService`, `NotesRepository` (координує Firestore + Storage), спільні віджети (`PrimaryButton`, `PasswordField`, `CenteredForm`) та `Validators` (деталі — у підрозділі «Архітектура» нижче)

### Структура `lib/` (додано / змінено до LR17)

```
lib/
├── services/
│   └── storage_service.dart          # upload (putData + progress + metadata) / delete
├── models/note.dart                  # + поле imageUrl
├── services/firestore_service.dart   # newNoteId(); createNote/updateNote несуть imageUrl
└── screens/
    ├── note_editor_screen.dart       # вибір / прев'ю / прогрес / видалення фото + оркестрація збереження
    └── notes_list_screen.dart        # мініатюра в картці; видалення файлу разом з ноткою
```
(`utils/errors.dart` — `describeError()` розширено на коди Firebase Storage.)

### Storage Security Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/notes/{noteId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### CORS (лише для запуску на web)

Flutter web (рендерер CanvasKit) читає байти зображення через `XMLHttpRequest`, тож бакет
має віддавати CORS-заголовки — інакше `Image.network` блокується політикою CORS. Налаштувати
один раз (наприклад, у **Google Cloud Shell**):

```bash
echo '[{"origin":["*"],"method":["GET"],"maxAgeSeconds":3600}]' > cors.json
gsutil cors set cors.json gs://<your-bucket>.firebasestorage.app
```

На Android/iOS CORS не діє — цей крок не потрібен.

### Архітектура (рефакторинг)

Частина LR18 — приведення коду до пошарової структури: екрани лишаються «тонкими», а вся
робота з Firebase і повторювані елементи UI винесені в окремі шари. (Дерева `lib/` у секціях
LR16–LR17 показують, що кожна ЛР додавала на той момент; нижче — підсумкова структура.)

- **`services/`** — уся взаємодія з Firebase; екрани не торкаються `FirebaseAuth.instance`
  чи `FirebaseFirestore.instance` напряму.
  - `auth_service.dart` — обгортка над `FirebaseAuth` (`signIn` / `signUp` / `signOut` /
    `sendPasswordReset`, `authStateChanges`, `currentUser`).
  - `firestore_service.dart` — CRUD + типізований `notesQuery()` на `users/{uid}/notes`.
  - `storage_service.dart` — upload / delete фото у Storage.
  - `notes_repository.dart` — координує Firestore + Storage: `saveNote()` / `deleteNote()`
    виконують весь сценарій із фото (upload, видалення старого файлу, запис) за один виклик.
- **`widgets/`** — спільні UI-елементи: `auth_wrapper`, `centered_form` (обмеження ширини на
  web), `primary_button` (кнопка зі станом завантаження), `password_field` (поле з toggle
  видимості), `image_attachment_section`, `note_card`.
- **`utils/`** — `errors.dart` (`describeError()` + `showSnackBar`),
  `validators.dart` (email / required / password / confirm).
- **`models/`** — `note.dart`. **`screens/`** — лише UI + виклики сервісів.

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   └── note.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── storage_service.dart
│   └── notes_repository.dart
├── screens/
│   ├── login_screen.dart
│   ├── sign_up_screen.dart
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── notes_list_screen.dart
│   └── note_editor_screen.dart
├── widgets/
│   ├── auth_wrapper.dart
│   ├── centered_form.dart
│   ├── primary_button.dart
│   ├── password_field.dart
│   ├── image_attachment_section.dart
│   └── note_card.dart
└── utils/
    ├── errors.dart
    └── validators.dart
```

### Перевірка

```bash
flutter analyze   # No issues found!
flutter test      # errors, Note, Validators
```
