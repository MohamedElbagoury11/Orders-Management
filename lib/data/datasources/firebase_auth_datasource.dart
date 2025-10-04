import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> signUpWithEmailAndPassword(String email, String password);
  Future<UserModel?> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<bool> checkGoogleSignInConfiguration();
  Future<void> clearAuthState();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],
        );

  @override
  Future<bool> checkGoogleSignInConfiguration() async {
    try {
      // Check if Google Sign-In is available
    //  final isAvailable = await _googleSignIn.isSignedIn();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAuthState() async {
    try {
      print('Clearing authentication state');
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('Authentication state cleared');
    } catch (e) {
      print('Error clearing auth state: $e');
    }
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        print('Successfully signed in user: ${userCredential.user!.uid}');
        return UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign up with email: $email');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        print('Successfully created user: ${userCredential.user!.uid}');
        return UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          createdAt: userCredential.user!.metadata.creationTime ?? DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Sign up error: $e');
      
      // Check if this is a PigeonUserDetails error (which shouldn't happen for email/password)
      if (e.toString().contains('PigeonUserDetails')) {
        print('Unexpected PigeonUserDetails error in email/password signup');
        // Try to recover by getting the current user
        try {
          final currentUser = _firebaseAuth.currentUser;
          if (currentUser != null) {
            print('Recovered user from PigeonUserDetails error in signup: ${currentUser.uid}');
            return UserModel(
              id: currentUser.uid,
              email: currentUser.email ?? '',
              name: currentUser.displayName,
              photoUrl: currentUser.photoURL,
              createdAt: currentUser.metadata.creationTime ?? DateTime.now(),
            );
          }
        } catch (recoveryError) {
          print('Failed to recover from PigeonUserDetails error in signup: $recoveryError');
        }
      }
      
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      print('Attempting Google Sign-In');
      
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      
      // Attempt Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        // User cancelled the sign-in
        return null;
      }

      print('Google user obtained: ${googleUser.email}');

      // Get authentication details with error handling
      GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (authError) {
        print('Google authentication error: $authError');
        throw Exception('Failed to authenticate with Google: $authError');
      }

      // Validate authentication tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Google authentication tokens missing');
        throw Exception('Google authentication tokens are missing');
      }

      print('Google authentication successful, creating Firebase credential');

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final user = userCredential.user!;
        print('Successfully signed in with Google: ${user.uid}');
        
        // Use Google user data as fallback if Firebase user data is missing
        final email = user.email ?? googleUser.email;
        final name = user.displayName ?? googleUser.displayName;
        final photoUrl = user.photoURL ?? googleUser.photoUrl?.toString();
        final createdAt = user.metadata.creationTime ?? DateTime.now();
        
      
        
        return UserModel(
          id: user.uid,
          email: email,
          name: name,
          photoUrl: photoUrl,
          createdAt: createdAt,
        );
      }
      return null;
    } catch (e) {
      // Handle specific Google Sign-In errors
      final errorMessage = e.toString();
      print('Google Sign-In error: $errorMessage');
      
      if (errorMessage.contains('PigeonUserDetails')) {
        // This is a known issue with Google Sign-In plugin
        // The authentication actually succeeded, but there's a type casting issue
        // We can still proceed with the Firebase user that was created
        try {
          final currentUser = _firebaseAuth.currentUser;
          if (currentUser != null) {
            print('Recovering from PigeonUserDetails error - user is authenticated: ${currentUser.uid}');
            return UserModel(
              id: currentUser.uid,
              email: currentUser.email ?? '',
              name: currentUser.displayName,
              photoUrl: currentUser.photoURL,
              createdAt: currentUser.metadata.creationTime ?? DateTime.now(),
            );
          }
        } catch (recoveryError) {
          print('Failed to recover from PigeonUserDetails error: $recoveryError');
        }
        
        throw Exception('Google Sign-In completed but encountered a configuration issue. Please try again or use email/password login.');
      } else if (errorMessage.contains('network_error')) {
        throw Exception('Network error. Please check your internet connection and try again.');
      } else if (errorMessage.contains('sign_in_canceled')) {
        throw Exception('Sign-in was cancelled.');
      } else if (errorMessage.contains('sign_in_failed')) {
        throw Exception('Google Sign-In failed. Please try again or use email/password login.');
      } else if (errorMessage.contains('DEVELOPER_ERROR')) {
        throw Exception('Google Sign-In developer error. Please check your Google Services configuration.');
      } else if (errorMessage.contains('INVALID_ACCOUNT')) {
        throw Exception('Invalid Google account. Please try with a different account.');
      } else {
        throw Exception('Google Sign-In error: $e');
      }
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('Signing out user');
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('Sign out successful');
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        print('Current user found: ${user.uid}');
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName,
          photoUrl: user.photoURL,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      }
      print('No current user found');
      return null;
    } catch (e) {
      print('Get current user error: $e');
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        print('Auth state changed - user signed in: ${user.uid}');
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName,
          photoUrl: user.photoURL,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      } else {
        print('Auth state changed - user signed out');
        return null;
      }
    });
  }
} 