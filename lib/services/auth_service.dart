
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> google() async {
    final google = GoogleSignIn.instance;

    await google.initialize(
      serverClientId:
          '295268278098-1n68him0b5jejv2b02o6aotfijnv056s.apps.googleusercontent.com',
    );

    if (!google.supportsAuthenticate()) {
      throw Exception(
        'Google authentication is unavailable.',
      );
    }

    final account = await google.authenticate();

    final idToken = account.authentication.idToken;

    if (idToken == null) {
      throw Exception(
        'Google did not return an ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    // Sign in to Firebase Authentication
    final userCredential = await _auth.signInWithCredential(credential);

    final User? user = userCredential.user;

    if (user == null) {
      throw Exception('Google login failed.');
    }

    // Save user information to Firestore
    await _saveUserToFirestore(user);
  }

Future<void> _saveUserToFirestore(User user) async {
  try {
    print('🔥 Saving user to Firestore...');
    print('UID: ${user.uid}');
    print('Email: ${user.email}');

    final userRef = _firestore.collection('users').doc(user.uid);

    await userRef.set({
      'uid': user.uid,
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'bio': 'Exploring beautiful things and saving what inspires me.',
      'isPremium': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('✅ USER SAVED TO FIRESTORE');
  } catch (e) {
    print('❌ FIRESTORE ERROR: $e');
    rethrow;
  }
}

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    await _auth.signOut();
  }
}
