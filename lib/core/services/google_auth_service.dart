import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      print('=== Google Sign-In Started ===');
      
      // Step 1: Initialize Google Sign-In
      print('Step 1: Initializing Google Sign-In...');
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // Step 2: Sign out to clear cached account (forces account picker to show)
      print('Step 2: Signing out to clear cached account...');
      await googleSignIn.signOut();
      
      // Step 3: Trigger sign-in flow
      print('Step 3: Triggering sign-in flow...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Sign-In Cancelled: User closed the popup');
        return null; // User cancelled
      }
      
      print('✅ Google Account Selected: ${googleUser.email}');
      print('   Display Name: ${googleUser.displayName}');
      print('   ID: ${googleUser.id}');
      
      // Step 4: Get authentication tokens
      print('Step 4: Getting authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      
      print('✅ Tokens received');
      print('   Access Token: ${googleAuth.accessToken != null ? "Present (${googleAuth.accessToken!.length} chars)" : "NULL"}');
      print('   ID Token: ${googleAuth.idToken != null ? "Present (${googleAuth.idToken!.length} chars)" : "NULL"}');
      
      // Step 5: Create Firebase credential
      print('Step 5: Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      print('✅ Firebase credential created');
      
      // Step 6: Sign in to Firebase
      print('Step 6: Signing in to Firebase...');
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      
      print('✅ Firebase Sign-In Successful!');
      print('   User UID: ${userCredential.user?.uid}');
      print('   User Email: ${userCredential.user?.email}');
      print('   Display Name: ${userCredential.user?.displayName}');
      print('=== Google Sign-In Complete ===');
      
      return userCredential;
    } catch (e, stackTrace) {
      print('❌ Google Sign-In Error: $e');
      print('   Error Type: ${e.runtimeType}');
      print('   Stack Trace: $stackTrace');
      
      // Provide specific error messages
      String errorMessage = 'Google Sign-In failed';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('canceled')) {
        errorMessage = 'Sign-in was cancelled.';
      } else if (e.toString().contains('account')) {
        errorMessage = 'No Google account found on device.';
      } else if (e.toString().contains('Firebase')) {
        errorMessage = 'Firebase authentication failed. Check Firebase Console configuration.';
      }
      
      print('   User-friendly message: $errorMessage');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      print('=== Google Sign-Out Started ===');
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      print('✅ Google Sign-Out Complete ===');
    } catch (e) {
      print('❌ Google Sign-Out Error: $e');
      rethrow;
    }
  }
}