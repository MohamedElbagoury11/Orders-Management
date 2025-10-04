import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreDataSource _firestoreDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required FirestoreDataSource firestoreDataSource,
  })  : _authDataSource = authDataSource,
        _firestoreDataSource = firestoreDataSource;

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _authDataSource.signInWithEmailAndPassword(email, password);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      // Create user with Firebase Auth
      final user = await _authDataSource.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        // Create a new user with the provided name
        final newUser = User(
          id: user.id,
          email: user.email,
          name: name, // Use the provided name instead of Firebase display name
          photoUrl: user.photoUrl,
          createdAt: user.createdAt,
        );
        return newUser;
      }
      return null;
    } catch (e) {
      // Handle specific Firebase Auth errors
      final errorMessage = e.toString();
      
      if (errorMessage.contains('PigeonUserDetails')) {
        // This is an unexpected error in email/password signup
        // Try to recover by getting the current user
        try {
          final currentUser = await _authDataSource.getCurrentUser();
          if (currentUser != null) {
            print('Successfully recovered user from PigeonUserDetails error in email/password signup');
            // Create a new user with the provided name
            final newUser = User(
              id: currentUser.id,
              email: currentUser.email,
              name: name, // Use the provided name
              photoUrl: currentUser.photoUrl,
              createdAt: currentUser.createdAt,
            );
            return newUser;
          }
        } catch (recoveryError) {
          print('Failed to recover from PigeonUserDetails error in email/password signup: $recoveryError');
        }
        
        throw Exception('Account creation completed but encountered a configuration issue. Please try signing in with your email and password.');
      } else if (errorMessage.contains('email-already-in-use')) {
        throw Exception('An account with this email already exists. Please sign in instead.');
      } else if (errorMessage.contains('weak-password')) {
        throw Exception('Password is too weak. Please choose a stronger password.');
      } else if (errorMessage.contains('invalid-email')) {
        throw Exception('Please enter a valid email address.');
      } else if (errorMessage.contains('operation-not-allowed')) {
        throw Exception('Email/password sign up is not enabled. Please contact support.');
      } else {
        throw Exception('Failed to create account: $e');
      }
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      return await _authDataSource.signInWithGoogle();
    } catch (e) {
      // Handle specific Google Sign-In errors
      final errorMessage = e.toString();
      
      if (errorMessage.contains('PigeonUserDetails')) {
        // This is a known issue - the authentication actually succeeded
        // Try to get the current user from Firebase Auth
        try {
          final currentUser = await _authDataSource.getCurrentUser();
          if (currentUser != null) {
            print('Successfully recovered user from PigeonUserDetails error');
            return currentUser;
          }
        } catch (recoveryError) {
          print('Failed to recover user from PigeonUserDetails error: $recoveryError');
        }
        
        throw Exception('Google Sign-In encountered a configuration issue. Please try again or use email/password login.');
      } else if (errorMessage.contains('network_error')) {
        throw Exception('Network error. Please check your internet connection and try again.');
      } else if (errorMessage.contains('sign_in_canceled')) {
        throw Exception('Sign-in was cancelled.');
      } else if (errorMessage.contains('sign_in_failed')) {
        throw Exception('Google Sign-In failed. Please try again or use email/password login.');
      } else if (errorMessage.contains('DEVELOPER_ERROR')) {
        throw Exception('Google Sign-In developer error. Please use email/password login.');
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
      await _authDataSource.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await _authDataSource.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges => _authDataSource.authStateChanges;

  @override
  Future<void> saveUserToFirestore(User user) async {
    try {
      await _firestoreDataSource.createUser(user);
    } catch (e) {
      // Don't throw error here as it might prevent login
      // Just log the error for debugging
      print('Failed to save user to Firestore: $e');
    }
  }
} 