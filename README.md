# Pinspire Public Full App

## Included
- Modern Google login with Firebase Auth
- Firebase/Firestore synced favorites
- Anime, Cars, Bikes, Sports
- Search
- Pinterest masonry grid
- Image details
- Gallery download
- Share
- Cached images
- Firebase Cloud Function Pexels proxy
- Firestore security rules
- Profile/sign out

## Setup
1. Install Flutter and Firebase CLI.
2. Run `flutterfire configure` in the project root. This replaces `lib/firebase_options.dart`.
3. In Firebase Console enable Authentication -> Google.
4. Add Android SHA-1/SHA-256 fingerprints for debug and release.
5. Run `flutter pub get`.
6. In `functions`, run `npm install`.
7. Run `firebase functions:secrets:set PEXELS_API_KEY`.
8. Run `firebase deploy --only functions,firestore`.
9. Put the deployed `searchPhotos` HTTPS URL into `lib/services/pexels_service.dart`.
10. Run `flutter run`.

## Public Play Store checklist
- Use release signing.
- Add production Firebase configuration.
- Add privacy policy and account/data deletion flow.
- Add AdMob after testing.
- Verify Pexels/API/image licensing and attribution requirements.
- Test Android gallery permissions/download behavior.
- Build `flutter build appbundle --release`.

The Pexels secret stays in the Cloud Function rather than inside the APK.
