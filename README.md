# 🚶‍♂️ Walkie - Real-Time Voice Communication App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![WebRTC](https://img.shields.io/badge/WebRTC-333333?style=for-the-badge&logo=webrtc&logoColor=white)](https://webrtc.org/)

A modern, cross-platform walkie-talkie application built with Flutter, featuring real-time voice communication using WebRTC technology. The app demonstrates advanced software architecture patterns, state management, and real-time communication protocols.

## ✨ Features

- 🎙️ **Real-time Voice Communication** - Instant walkie-talkie style voice calls
- 🔐 **User Authentication** - Secure login and registration with Firebase
- 👥 **Friend Management** - Add and manage friends for communication
- 📱 **Cross-platform** - Runs on Android, iOS, Web, Windows, macOS, and Linux
- 🎯 **Clean Architecture** - Well-structured codebase following SOLID principles
- 🔄 **Real-time Sync** - Live updates using Firebase Realtime Database
- 🎨 **Modern UI** - Beautiful Material Design 3 interface
- ⚡ **Optimized Performance** - Efficient state management and resource handling

## 🏗️ Architecture & Technical Highlights

### Clean Architecture Implementation
This project showcases a robust implementation of Clean Architecture with clear separation of concerns:

```
lib/
├── core/           # Core utilities, DI, routing, constants
├── data/           # Data layer (repositories, datasources, services)
├── domain/         # Business logic (entities, use cases, repositories)
└── presentation/   # UI layer (screens, providers, widgets)
```

### Key Technical Features

#### 🎯 **State Management with Riverpod**
- **Flutter Riverpod 2.4.9** for reactive state management
- **Code generation** with `riverpod_generator` for type-safe providers
- **Freezed** for immutable data classes and union types
- **Provider pattern** for dependency injection and state sharing

#### 🔧 **Dependency Injection**
- **GetIt** for service locator pattern
- **Injectable** for automatic dependency registration
- **Code generation** for compile-time dependency resolution

#### 🌐 **Real-time Communication**
- **WebRTC** implementation for peer-to-peer voice communication
- **Firebase Realtime Database** for signaling and user presence
- **Custom signaling service** for offer/answer exchange
- **ICE candidate handling** for NAT traversal

#### 🗄️ **Data Management**
- **Repository pattern** for data abstraction
- **Firebase integration** for backend services
- **Local storage** with SharedPreferences
- **Error handling** with Either pattern using Dartz

#### 🧭 **Navigation & Routing**
- **GoRouter** for declarative routing
- **Type-safe navigation** with route definitions
- **Deep linking** support

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.5.1+** - Cross-platform UI framework
- **Dart** - Programming language
- **Material Design 3** - Modern UI components

### State Management & Architecture
- **Riverpod** - Reactive state management
- **Freezed** - Code generation for data classes
- **Dartz** - Functional programming utilities
- **GetIt** - Dependency injection
- **Injectable** - Code generation for DI

### Backend & Real-time
- **Firebase Core** - Backend services
- **Firebase Realtime Database** - Real-time data sync
- **WebRTC** - Peer-to-peer communication
- **HTTP** - API communication

### Development Tools
- **Build Runner** - Code generation
- **JSON Serializable** - JSON serialization
- **Flutter Lints** - Code quality
- **Permission Handler** - Runtime permissions

## 📱 Screenshots

| Login Screen | Home Screen | Call Screen |
|--------------|-------------|-------------|
| ![Login](https://via.placeholder.com/300x600/6366F1/FFFFFF?text=Login+Screen) | ![Home](https://via.placeholder.com/300x600/8B5CF6/FFFFFF?text=Home+Screen) | ![Call](https://via.placeholder.com/300x600/EC4899/FFFFFF?text=Call+Screen) |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.5.1 or higher
- Dart SDK 3.5.1 or higher
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/walkie.git
   cd walkie
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure Firebase**
   - Create a Firebase project
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Enable Firebase Realtime Database

5. **Run the app**
   ```bash
   flutter run
   ```

## 🏛️ Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── di/                # Dependency injection setup
│   ├── errors/            # Custom error classes
│   ├── router/            # Navigation configuration
│   └── utils/             # Utility functions
├── data/
│   ├── datasources/       # Data sources (Firebase, local)
│   ├── repositories/      # Repository implementations
│   └── services/          # External services (WebRTC, Firebase)
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business logic use cases
└── presentation/
    ├── features/          # Feature-based UI organization
    │   ├── auth/          # Authentication feature
    │   ├── home/          # Home screen feature
    │   ├── call/          # Voice call feature
    │   └── splash/        # Splash screen feature
    └── widgets/           # Reusable UI components
```

## 🔧 Key Components

### WebRTC Service
- **Peer-to-peer connection** management
- **Media stream handling** for audio
- **ICE candidate exchange** for NAT traversal
- **Session description** (offer/answer) handling
- **Connection state management**

### Authentication System
- **Email/password authentication** with Firebase
- **Session management** with local storage
- **User presence tracking** in real-time
- **Form validation** with custom validators

### Real-time Features
- **Live user list** updates
- **Call state synchronization** across devices
- **Signal message handling** for WebRTC negotiation
- **Connection status monitoring**

## 🎯 Design Patterns Used

- **Clean Architecture** - Separation of concerns
- **Repository Pattern** - Data access abstraction
- **Provider Pattern** - State management
- **Singleton Pattern** - Service management
- **Observer Pattern** - Reactive programming
- **Factory Pattern** - Object creation
- **Strategy Pattern** - Algorithm selection

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 📦 Build & Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- WebRTC community for real-time communication protocols
- Riverpod team for state management solution

---

⭐ **Star this repository** if you found it helpful!

🔗 **Connect with me** for collaboration opportunities or technical discussions.