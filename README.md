# Nebula Client

Flutter application for distributed encrypted cloud storage on Telegram.

## Stack

- **Framework**: Flutter 3.24+
- **State Management**: Riverpod 2.6+
- **Navigation**: GoRouter 14.0+
- **Platform**: Android, Linux, iOS (planned), Windows (planned)

## Architecture

```
lib/
├── main.dart                  # Application entry point
├── app/router.dart            # Route configuration
└── features/
    ├── auth/                  # Telegram authentication
    ├── vault_unlock/          # Password-based vault access
    ├── explorer/              # VFS file browser
    └── transfers/             # Upload/download progress
```

## Dependencies

### Private Core
```yaml
nebula_core:
  git:
    url: git@github.com:YOUR_ORG/nebula-core.git
    ref: main
```

Requires SSH key with deploy key access to private repository.

## Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### Linux
```bash
flutter build linux --release
```

### Development
```bash
flutter run -d linux
flutter run -d android
```

## CI/CD

GitHub Actions matrix builds for:
- Linux (x64)
- Windows (x64)
- Android (APK + AAB)

Requires `SSH_KEY_CORE` secret for private dependency access.

## Features

- Telegram phone/code authentication
- AES-256-GCM encrypted uploads
- 1.9GB automatic file chunking
- Virtual file system with hidden manifests
- Resume support for transfers
- Zero-knowledge encryption

## License

MIT License
