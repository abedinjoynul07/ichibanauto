Here's the updated README content with the package name and full instructions included:

---

## Car Workshop Management System

This is a **Car Workshop Management System** built with Flutter and integrated with Firebase. The application allows admins to manage car service bookings and mechanics to view their assigned jobs. The system includes a calendar view, role-based authentication, and booking management functionalities.

### Features
- Admin dashboard to manage bookings and assign mechanics.
- Mechanic dashboard to view assigned jobs.
- Calendar view to manage and filter bookings.
- Firebase Authentication with role-based access (Admin/Mechanic).
- Firestore for real-time data syncing.
- Flutter cross-platform support (Android, iOS).

### Prerequisites
Before you begin, ensure you have the following installed on your local development environment:
- **Flutter SDK**: Download and install Flutter from flutter.dev.
- **Dart SDK**: Ensure that Dart is installed (comes bundled with Flutter).
- **Xcode** (for iOS development): Make sure Xcode is installed and up to date.
- **Android Studio** (for Android development): Make sure Android Studio is installed and configured.
- **Firebase Account**: Create a Firebase project for authentication and database setup.

### Tools
- Flutter 3.0.0 or later
- Firebase CLI (Optional, but helpful)
- Xcode (for iOS deployment)
- Android Studio (for Android deployment)
- Git

### Installation

#### 1. Clone the Repository
```bash
git clone https://github.com/your-username/car-workshop-app.git
cd car-workshop-app
```

#### 2. Install Dependencies
After cloning the repository, run the following command to install the necessary dependencies:
```bash
flutter pub get
```

#### 3. Setup Firebase

This app uses Firebase Authentication and Firestore. To get Firebase up and running, follow these steps:

#### Step 1: Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com).
2. Click on **Add Project** and follow the instructions to create a new project.

#### Step 2: Add Android/iOS apps to Firebase
- For Android:
    - Click on the Android icon in the Firebase console.
    - Register the app with the package name `com.mdjoynulabedinshokal.ichibanauto`.
    - Download the `google-services.json` file and place it in your Flutter project's `android/app` directory.

- For iOS:
    - Click on the iOS icon in the Firebase console.
    - Register the app with the package name `com.mdjoynulabedinshokal.ichibanauto`.
    - Download the `GoogleService-Info.plist` file and place it in your Flutter project's `ios/Runner` directory.
    - Open `ios/Runner.xcworkspace` in Xcode, and configure the app according to Firebase setup instructions.

#### Step 3: Enable Firebase Authentication
1. In the Firebase console, navigate to **Authentication**.
2. Enable **Email/Password** sign-in method.

#### Step 4: Set up Firestore Database
1. Navigate to **Firestore Database** in Firebase Console.
2. Create collections such as:
    - `users`: Stores user roles (admin/mechanic).
    - `bookings`: Stores service booking details.

### Running the Application

#### 1. Android
To run the app on an Android device or emulator, follow these steps:
1. Run the command to get all the dependencies:
   ```bash
   flutter pub get
   ```
2. Then, run the app on the connected Android device or emulator:
   ```bash
   flutter run
   ```

Make sure your Android emulator or physical device is connected, and debugging mode is enabled.

#### 2. iOS
To run the app on an iOS device or simulator:
1. Run the command to get all the dependencies:
   ```bash
   flutter pub get
   ```
2. Open `ios/Runner.xcworkspace` in Xcode.
3. Select your device/simulator and hit the Run button in Xcode, or use the command:
   ```bash
   flutter run
   ```

Ensure that you have all required provisioning profiles for iOS development.

#### 3. Web (Optional)
To run the application on the web:
```bash
flutter run -d chrome
```
Ensure that Firebase services are configured for web if you plan to use it.

### License
This project is licensed under the MIT License. See the LICENSE file for details.