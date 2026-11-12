# 🌾 Smart Farm Sheba

### Smart Farming, Better Future.

**Smart Farm Sheba** is a Flutter-based agricultural management application designed to make everyday farming easier and smarter. It brings essential farm management tools and practical agricultural guidance together in one simple platform.

Farmers can manage their expenses, track irrigation activities, save personal notes, explore seasonal crop suggestions, and access useful farming information.

The application uses **Firebase Authentication and Cloud Firestore** to provide secure accounts and private cloud storage. Each farmer can access only their own records.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Cloud%20Firestore-FF6F00?logo=firebase&logoColor=white" alt="Firestore">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web-3DDC84?logo=android&logoColor=white" alt="Platform">
</p>

---

## 📖 About the Project

Many farmers face difficulties managing farming costs, keeping records, planning irrigation, and finding reliable agricultural guidance.

**Smart Farm Sheba** aims to solve these problems through a user-friendly mobile and web application.

The main goal is to help farmers manage their agricultural activities more efficiently using modern technology.

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Secure Authentication** | Register and log in using Email/Password, Google, or Phone Number. Includes password reset functionality. |
| 📧 **Email Notifications** | Receive a welcome email after registration and a new login notification on every login. |
| 🏠 **Smart Dashboard** | An interactive dashboard with an auto-scrolling carousel, quick-access tools, and farm summaries. |
| 📊 **Farm Summary** | View total expenses, total profit, net balance, and personal notes count. |
| 💰 **Expense Tracking** | Add and manage farming expenses and profit records. |
| 💧 **Irrigation Management** | Record irrigation activities by crop, date, and cost. Includes crop filters and expense summaries. |
| 📝 **Personal Notes** | Create, search, pin, color-label, and delete personal farming notes. |
| 🌱 **Crop Suggestions** | Explore seasonal crop recommendations to support better farming decisions. |
| 🐛 **Pesticide Guide** | Get pesticide dosage information and important safety guidelines. |
| 💡 **Farming Tips** | Learn practical tips and modern agricultural techniques. |
| 🌦️ **Weather Updates** | Access weather information to help plan farming activities. |
| 👤 **User Profile** | View and manage personal account information. |

## 🔒 Data Privacy & Security

User privacy is an important part of Smart Farm Sheba.

- Every personal record is associated with the owner's unique Firebase UID.
- Firestore queries filter records using the authenticated user's UID.
- Users can only access their own expenses, notes, and irrigation records.
- Firebase Firestore Security Rules enforce access permissions on the server.

This ensures that each farmer's personal farming information remains separate and protected.

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform application development |
| **Dart** | Programming language |
| **Firebase Authentication** | User registration and login |
| **Cloud Firestore** | Cloud database and user-specific data storage |
| **EmailJS** | Welcome and login notification emails |
| **Material Design** | User interface design |

**Supported Platforms:** Android and Web.

## 📂 Project Structure

```text
Smart-Farm-Sheba/
│
├── android/                 # Android platform code
├── ios/                     # iOS platform code
├── web/                     # Web platform code
│
├── lib/
│   ├── features/
│   │   ├── dashboard/       # Dashboard and carousel
│   │   ├── home/             # Home screen and farm summary
│   │   ├── expense/          # Expense tracking
│   │   ├── irrigation/       # Irrigation management
│   │   ├── notes/            # Personal notes
│   │   ├── crop_suggestion/  # Seasonal crop suggestions
│   │   ├── pesticide/        # Pesticide guide
│   │   ├── tips/             # Farming tips
│   │   ├── weather/          # Weather updates
│   │   └── profile/          # User profile
│   │
│   ├── screens/
│   │   ├── auth/             # Login, registration, phone login
│   │   ├── onboarding/       # Onboarding screens
│   │   └── splash_screen.dart
│   │
│   ├── services/             # Authentication and email services
│   ├── providers/            # State management
│   ├── utils/                # Helper functions and utilities
│   ├── firebase_options.dart
│   ├── theme.dart
│   └── main.dart
│
├── test/                     # Application tests
├── firebase.json             # Firebase configuration
├── pubspec.yaml              # Dependencies and assets
└── README.md
```

## 🚀 Getting Started

Follow these steps to set up and run Smart Farm Sheba locally.

### Prerequisites

Before getting started, make sure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable Channel)
- [Android Studio](https://developer.android.com/studio) or VS Code
- Flutter and Dart extensions
- An Android device, emulator, or Google Chrome
- A Firebase project
- A free [EmailJS](https://www.emailjs.com/) account

### 1. Clone the Repository

```bash
git clone https://github.com/alaminsarder/Smart-Farm-Sheba.git

cd Smart-Farm-Sheba
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable Firebase Authentication.
3. Enable the Email/Password, Google, and Phone sign-in providers.
4. Create a Cloud Firestore database.
5. Add your Android application to the Firebase project.
6. Place your `google-services.json` file inside `android/app/`.
7. Install and configure FlutterFire CLI.
8. Generate the Firebase configuration:

```bash
flutterfire configure
```

For Google Sign-In on Android, add your signing key's SHA-1 fingerprint in Firebase Project Settings.

### 4. Configure EmailJS

Create an EmailJS account and configure the required email service, templates, and public key according to the application's email service configuration.

### 5. Run the Application

```bash
flutter run
```

To run the application in Chrome:

```bash
flutter run -d chrome
```

## 🗄️ Database Structure

Smart Farm Sheba uses Cloud Firestore to store user information and farming records.

| Collection | Main Fields |
|---|---|
| `users` | `uid`, `name`, `firstName`, `lastName`, `phone`, `email`, `zila`, `role`, `createdAt`, `updatedAt` |
| `expenses` | `uid`, `title`, `cost`, `profit`, `date`, `createdAt`, `updatedAt` |
| `notes` | `uid`, `title`, `description`, `date`, `tone`, `pinned`, `createdAt`, `updatedAt` |
| `irrigation` | `uid`, `crop`, `dateTime`, `costTaka`, `createdAt`, `updatedAt` |

## 📱 Build APK

To generate a release APK, run the following commands:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

After a successful build, the APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

To generate smaller APK files for different CPU architectures:

```bash
flutter build apk --split-per-abi
```

## 🗺️ Future Improvements

The project will continue to grow with more useful agricultural features.

- [x] Email/Password Authentication
- [x] Google Sign-In
- [x] Phone Authentication
- [x] User-specific cloud data storage
- [x] Expense and profit tracking
- [x] Personal notes management
- [x] Irrigation management
- [x] Farm summary dashboard
- [x] Welcome and login email notifications
- [ ] Bangla language support
- [ ] Offline functionality
- [ ] AI-based crop disease detection
- [ ] Push notifications for weather alerts
- [ ] Secure backend email integration using Firebase Cloud Functions




<p align="center">
  <b>🌾 Smart Farm Sheba — Smart Farming, Better Future.</b>
  <br>
  Built with ❤️ to support smarter agriculture.
  <br><br>
  ⭐ If you find this project useful, don't forget to give it a star!
</p>


## License

This project is licensed under the MIT License.
See the [LICENSE](LICENSE) file for details.
