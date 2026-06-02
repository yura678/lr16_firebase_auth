# Flutter + Firebase — серія лабораторних (Блок 5)

Наскрізний Flutter-застосунок, що розвивається протягом лабораторних робіт блоку **Firebase**.
Кожна ЛР додає окрему функціональність і описана у власній секції нижче — нові роботи
(LR17, LR18, …) дописуються як нові заголовки, не ламаючи попередні.

## Статус робіт

| ЛР   | Тема                          | Статус         |
|------|-------------------------------|----------------|
| LR16 | Firebase Authentication       | ✅ Готово       |
| LR17 | Firebase (продовження)        | 🔜 Заплановано  |
| LR18 | Firebase (продовження)        | 🔜 Заплановано  |

## Технології

Flutter · Dart · Material 3 · `firebase_core` · `firebase_auth`

## Запуск

```bash
flutter pub get
flutterfire configure        # генерує lib/firebase_options.dart і налаштовує платформи
flutter run -d chrome        # або -d windows / Android-емулятор
```

> ⚠️ У **Firebase Console → Authentication → Sign-in method** має бути увімкнено
> провайдер **Email/Password**, інакше реєстрація/вхід повертатимуть `operation-not-allowed`.

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
- ⚠️ **Error handling** — централізований мапінг кодів помилок Firebase (`AuthErrors`)

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
    └── auth_errors.dart               # FirebaseAuthException.code → зрозуміле повідомлення
```

### Перевірка

```bash
flutter analyze   # No issues found!
flutter test      # юніт-тести AuthErrors
```

---

## LR17 — Firebase (продовження) · 🔜 заплановано

> Буде додано в наступній лабораторній. Опис функціональності та змін у `lib/` з'явиться тут.

---

## LR18 — Firebase (продовження) · 🔜 заплановано

> Буде додано в наступній лабораторній. Опис функціональності та змін у `lib/` з'явиться тут.
