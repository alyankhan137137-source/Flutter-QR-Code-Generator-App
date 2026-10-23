# Professional QR Code Generator & Manager App - Implementation Plan

An enterprise-grade, feature-rich Flutter QR Code Generator App that goes far beyond basic requirements. It features a stunning Material 3 UI, advanced customization (colors, error correction, multiple data types like URL, Text, WiFi, vCard, Email, Phone), screenshot capture, gallery saving, sharing capabilities, and persistent generation history.

## User Review Required

> [!IMPORTANT]
> This app will add several high-grade packages to `pubspec.yaml`:
> - `qr_flutter`: QR rendering engine
> - `screenshot`: Capturing QR widgets into high-resolution images
> - `path_provider`: Temporary & local file management
> - `share_plus`: Native sharing of text and QR code images
> - `gal`: Seamless saving of images to device gallery
> - `shared_preferences`: Persistent history storage

## Open Questions

- None. The architecture follows clean separation of concerns (Models, Services, Screens, Widgets) to ensure maintainability and professional production quality.

## Proposed Changes

### Dependencies & Configuration

#### [MODIFY] [pubspec.yaml](file:///E:/flutter%20all%20project/pubspec.yaml)
- Add `qr_flutter`, `screenshot`, `path_provider`, `share_plus`, `gal`, `shared_preferences`, and `intl`.

---

### Core Models & Services

#### [NEW] [qr_item.dart](file:///E:/flutter%20all%20project/lib/models/qr_item.dart)
- Data model representing a generated QR code (data, title, type, timestamp, foregroundColor, backgroundColor, errorCorrectionLevel).

#### [NEW] [storage_service.dart](file:///E:/flutter%20all%20project/lib/services/storage_service.dart)
- Handles saving generated QR codes to history using `shared_preferences`, saving images to gallery using `gal` and `screenshot`, and exporting files.

---

### UI Components & Screens

#### [NEW] [main.dart](file:///E:/flutter%20all%20project/lib/main.dart)
- Enhanced entry point with Material 3 design system, custom light/dark color schemes, and navigation between Generator, History, and Templates.

#### [NEW] [home_screen.dart](file:///E:/flutter%20all%20project/lib/screens/home_screen.dart)
- Professional dashboard with bottom navigation or tab bar (`Generate QR`, `Templates`, `History`, `Settings`).

#### [NEW] [generator_screen.dart](file:///E:/flutter%20all%20project/lib/screens/generator_screen.dart)
- Interactive QR generator interface:
  - Input field with quick clear & paste.
  - Category selector tabs (Text/URL, WiFi, Email, Phone, vCard).
  - Advanced Customization drawer/section (QR color, background color, error correction level).
  - Live preview card wrapped in `Screenshot` controller.
  - Action buttons: Download/Save to Gallery, Share Image, Share Text, Copy.

#### [NEW] [templates_screen.dart](file:///E:/flutter%20all%20project/lib/screens/templates_screen.dart)
- Pre-built templates for WiFi connection, vCard business card, Email composer, and SMS.

#### [NEW] [history_screen.dart](file:///E:/flutter%20all%20project/lib/screens/history_screen.dart)
- List of previously generated QR codes with search, quick preview dialog, delete, and share actions.

## Verification Plan

### Automated Tests
- Build verification via `flutter build` or test compilation.

### Manual Verification
- Run the app on emulator/device.
- Test generating QR code from text/URL.
- Test generating QR code from WiFi template.
- Test customizing colors and error correction.
- Test saving to gallery and sharing via `share_plus`.
- Test history persistence across app restarts.
