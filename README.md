# 🌾 Smart Farm Sheba

**Smart Farm Sheba** is a Flutter app that gives farmers everyday farm-management tools and practical agricultural guidance in one place. Every user signs in to a personal account, and all records (expenses, notes, irrigation) are stored in the cloud and are private to that user.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Cloud%20Firestore-FF6F00?logo=firebase&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-3DDC84?logo=android&logoColor=white)

---

## 📖 About

Many farmers do not have a simple way to track their costs, keep farm notes, log irrigation, or get quick guidance on crops and pesticides. Smart Farm Sheba brings all of this together in one clean, easy-to-use app, with data saved safely to each farmer's own account.

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Secure Accounts** | Register and log in with email/password, Google, or phone number. Password reset is supported |
| 📧 **Email Notifications** | A welcome email on registration and a "new login detected" email on every login |
| 🏠 **Smart Dashboard** | Auto-scrolling highlight carousel, quick-access tool cards, and a live farm summary |
| 📊 **Farm Summary** | Total cost, total profit, net balance, and notes count calculated from your own data |
| 💰 **Expense Tracking** | Record cost and profit entries, saved per user in the cloud |
| 💧 **Irrigation Log** | Log irrigation by crop, date, and cost, with crop filters and totals |
| 📝 **Personal Notes** | Create, search, pin, color-label, and delete farm notes |
| 🌱 **Crop Suggestions** | Recommendations on which crops suit the season |
| 🐛 **Pesticide Guide** | Dosage and safety tips for pesticides |
| 💡 **Farming Tips** | Practical advice on modern farming techniques |
| 🌦️ **Weather Updates** | Weather information to plan farm work |
| 👤 **Profile** | View and manage your account details |

## 🔒 Data Privacy

- Every record stores the owner's `uid`.
- Screens query only `where('uid', isEqualTo: currentUser.uid)`, so a user only sees their own data.
- Firestore Security Rules enforce this on the server (see [Firestore Rules](#firestore-rules)).

## 📱 Screenshots

> Add your app screenshots to a `screenshots/` folder and update the paths below.

| Login | Dashboard | Expense |
|:---:|:---:|:---:|
| ![Login](screenshots/login.png) | ![Dashboard](screenshots/dashboard.png) | ![Expense](screenshots/expense.png) |

| Irrigation | Notes | Profile |
|:---:|:---:|:---:|
| ![Irrigation](screenshots/irrigation.png) | ![Notes](screenshots/notes.png) | ![Profile](screenshots/profile.png) |

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Language:** [Dart](https://dart.dev/)
- **Authentication:** Firebase Authentication (email/password, Google, phone)
- **Database:** Cloud Firestore
- **Email:** [EmailJS](https://www.emailjs.com/) (welcome and login notifications, no backend needed)
- **Target Platforms:** Android, Web

## 📂 Project Structure

```
Smart-Farm-Sheba/
├── android/                 # Android platform code
├── ios/                     # iOS platform code
├── web/                     # Web platform code
├── lib/
│   ├── features/
│   │   ├── dashboard/       # Dashboard and carousel
│   │   ├── home/            # Home screen and farm summary card
│   │   ├── expense/         # Expense tracking
│   │   ├── irrigation/      # Irrigation log
│   │   ├── notes/           # Personal notes
│   │   ├── crop_suggestion/ # Crop suggestions
│   │   ├── pesticide/       # Pesticide guide
│   │   ├── tips/            # Farming tips
│   │   ├── weather/         # Weather
│   │   └── profile/         # Profile
│   ├── screens/
│   │   ├── auth/            # Login, register, phone login, forgot password
│   │   ├── onboarding/      # Onboarding
│   │   └── splash_screen.dart
│   ├── services/            # Google auth and email services
│   ├── providers/           # State management
│   ├── utils/
│   ├── firebase_options.dart
│   ├── theme.dart
│   └── main.dart
├── test/                    # Tests
├── firebase.json            # Firebase configuration
├── pubspec.yaml             # Dependencies and assets
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio or VS Code with the Flutter extension
- An Android device, emulator, or Chrome
- A Firebase project
- A free [EmailJS](https://www.emailjs.com/) account (for email notifications)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/alaminsarder/Smart-Farm-Sheba.git
   cd Smart-Farm-Sheba
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a project in the [Firebase Console](https://console.firebase.google.com/)
   - Enable **Authentication** (Email/Password, Google, Phone)
   - Create a **Cloud Firestore** database
   - Add an Android app and place `google-services.json` in `android/app/`
   - Generate `lib/firebase_options.dart` with FlutterFire CLI:
     ```bash
     flutterfire configure
     ```
   - For Google Sign-In on Android, add your signing key's **SHA-1** in Firebase Project Settings

4. **Set up EmailJS**
   - Create an Email Service (Gmail) and an Email Template
   - Set the template fields:

     | Field | Value |
     |---|---|
     | To Email | `{{to_email}}` |
     | From Name | `Smart Farm Sheba` |
     | Subject | `{{subject}}` |

   - The template body can use these variables: `{{heading}}`, `{{to_name}}`, `{{message}}`, `{{box_title}}`, `{{box_text}}`, `{{footer_note}}`
   - Put your IDs in `lib/services/email_service.dart`:
     ```dart
     static const String _serviceId = 'YOUR_SERVICE_ID';
     static const String _templateId = 'YOUR_TEMPLATE_ID';
     static const String _publicKey = 'YOUR_PUBLIC_KEY';
     ```
   - For the Android app, enable **Allow EmailJS API for non-browser applications** in EmailJS → Account → Security
   - Restrict allowed domains in EmailJS Security to protect your monthly quota

5. **Run the app**
   ```bash
   flutter run
   ```

### Firestore Rules

Use these rules so each user can read and write only their own data:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /expenses/{docId} {
      allow read, update, delete: if request.auth != null
        && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
    }

    match /notes/{docId} {
      allow read, update, delete: if request.auth != null
        && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
    }

    match /irrigation/{docId} {
      allow read, update, delete: if request.auth != null
        && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
    }
  }
}
```

### Data Model

| Collection | Fields |
|---|---|
| `users` | `uid`, `name`, `firstName`, `lastName`, `phone`, `email`, `zila`, `role`, `createdAt`, `updatedAt` |
| `expenses` | `uid`, `title`, `cost`, `profit`, `date`, `createdAt`, `updatedAt` |
| `notes` | `uid`, `title`, `description`, `date`, `tone`, `pinned`, `createdAt`, `updatedAt` |
| `irrigation` | `uid`, `crop`, `dateTime`, `costTaka`, `createdAt`, `updatedAt` |

### Build a release APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

For smaller per-architecture files:

```bash
flutter build apk --split-per-abi
```

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

## 🗺️ Roadmap

- [x] Email/password, Google, and phone authentication
- [x] Per-user cloud data (expenses, notes, irrigation)
- [x] Farm summary on the dashboard
- [x] Welcome and login email notifications
- [ ] Bangla language support
- [ ] Offline mode
- [ ] Crop disease detection
- [ ] Push notifications for weather alerts
- [ ] Move email sending to a secure backend (Cloud Functions)

## 📄 License

This project is licensed under the [MIT License](LICENSE). *(Add a `LICENSE` file, or change this section to match your chosen license.)*

## 👤 Author

**Al-Amin Sarder**
GitHub: [@alaminsarder](https://github.com/alaminsarder)

---

⭐ If you find this project useful, please give it a star!
