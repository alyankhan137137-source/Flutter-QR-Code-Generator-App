# 5 New Professional Features - Implementation Plan

An enterprise-grade feature expansion for the QR Code Studio app, introducing 5 powerful new capabilities:
1. **Batch QR Code Generator**: Generate and export multiple QR codes simultaneously from a list of texts or URLs.
2. **QR Code Scanner / Reader**: Scan QR codes directly using device camera or gallery image picker.
3. **Logo & Center Branding**: Embed custom center icons / emojis / badges inside the QR code.
4. **Favorites & Starred History**: Pin and favorite important QR codes for quick access.
5. **Custom QR Frame / Banner Designer**: Add professional promotional frames (e.g., "SCAN ME", custom title/footer) around the QR code.

## User Review Required

> [!IMPORTANT]
> This plan adds `mobile_scanner` and `image_picker` packages to `pubspec.yaml` to support the new QR code scanning feature.

## Open Questions

- None. All features integrate smoothly into the existing Material 3 and Glassmorphism design system.

## Proposed Changes

### Dependencies

#### [MODIFY] [pubspec.yaml](file:///E:/flutter%20all%20project/pubspec.yaml)
- Add `mobile_scanner: ^5.2.3` and `image_picker: ^1.1.2`.

---

### Data Models & Services

#### [MODIFY] [qr_item.dart](file:///E:/flutter%20all%20project/lib/models/qr_item.dart)
- Add `isFavorite` (bool) property with JSON serialization support.

---

### New Feature Screens & Widgets

#### [NEW] [scanner_screen.dart](file:///E:/flutter%20all%20project/lib/screens/scanner_screen.dart)
- Camera scanner and gallery image scanner for reading QR codes.

#### [NEW] [batch_generator_screen.dart](file:///E:/flutter%20all%20project/lib/screens/batch_generator_screen.dart)
- Multi-line text input to batch generate multiple QR codes at once.

#### [NEW] [frame_designer_screen.dart](file:///E:/flutter%20all%20project/lib/screens/frame_designer_screen.dart)
- Custom frame designer with banner text ("SCAN ME", header/footer) and styling.

#### [MODIFY] [generator_screen.dart](file:///E:/flutter%20all%20project/lib/screens/generator_screen.dart)
- Integrate center logo/icon branding toggle and quick access to frame designer.

#### [MODIFY] [history_screen.dart](file:///E:/flutter%20all%20project/lib/screens/history_screen.dart)
- Add favorite/star filtering and pinning logic.

#### [MODIFY] [home_screen.dart](file:///E:/flutter%20all%20project/lib/screens/home_screen.dart)
- Update bottom navigation or tab bar to include Scanner, Batch, Generator, Templates, and History.

## Verification Plan

### Automated Tests
- Run `flutter analyze` and `flutter test`.

### Manual Verification
- Test scanning a QR code with the camera/image picker.
- Test batch generating QR codes.
- Test adding center logo branding.
- Test favoriting history items.
- Test designing a QR frame banner.
