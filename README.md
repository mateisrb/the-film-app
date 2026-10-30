# The Film App 📷 (Flutter Native Mobile)

Native iOS and Android mobile companion application for analog and hybrid photographers, built with **Flutter & Dart**.

---

## 📱 App Modules Included

1. **Meter Transposer (`transposer_screen.dart`):**
   - Transpose in-camera SLR meter readings (`ISO 1600, f/5.6, 1/125s`) $\rightarrow$ real film speed (`ISO 400`) & desired aperture (`f/2.8` or `f/1.8`).
   - Vintage mechanical dial snapping (`1/1000, 1/500, 1/250, 1/125...`) with dial deviation indicator.
   - Scene meter compensation presets: Snow (+2 EV), Backlit (+1.5 EV), High-Key (+1.7 EV), Sunset (-1.0 EV), Concert (-1.5 EV).
   - Reciprocity failure warning banner when exposure $\ge 1\text{s}$.

2. **Reciprocity Timer (`timer_screen.dart`):**
   - Schwarzschild curves for Fuji Acros II, Kodak Portra, Tri-X, T-Max, Ilford HP5/FP4/Delta, CineStill, and Fomapan.
   - Large digital countdown digits with start/pause/reset.
   - **Night Vision (Darkroom Red Light) Mode** to preserve dark-adapted vision during long exposure sessions.
   - Device haptic feedback on completion.

3. **Field Roll Logger (`roll_logger_screen.dart`):**
   - Track active rolls on the street (Frame #1 through #36).
   - Record aperture, shutter speed, lens, notes, and timestamp.
   - One-tap copy/export JSON to drop into CamUtils Desktop EXIF injector.

4. **Format & FOV Equivalence Matrix (`fov_screen.dart`):**
   - Cross-format equivalence between 35mm, 6x4.5, 6x6, 6x7, 6x9, and 4x5 Large Format.
   - Calculates 35mm equivalent focal length, DoF equivalent aperture, and field of view angles.

5. **Gear Closet (`gear_screen.dart`):**
   - Saved camera bodies, vintage lenses, and custom film emulsions with local device persistence (`shared_preferences`).

---

## 🚀 How to Run

### Prerequisites
* Flutter SDK (3.x+)
* Xcode (for iOS simulator / iPhone) or Android Studio (for Android emulator / APK)

### Launching on Device / Emulator
```bash
cd the_film_app

# Install Dart/Flutter dependencies
flutter pub get

# Run on connected phone or emulator
flutter run
```

### Building Release Binaries
```bash
# Android APK
flutter build apk --release

# Android App Bundle for Google Play
flutter build appbundle --release

# iOS Bundle
flutter build ipa --release
```
