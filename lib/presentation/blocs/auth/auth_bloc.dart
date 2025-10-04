import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth_usecases.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInWithEmailAndPasswordEvent extends AuthEvent {
  final String email;
  final String password;

  SignInWithEmailAndPasswordEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailAndPasswordEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  SignUpWithEmailAndPasswordEvent({
    required this.email, 
    required this.password, 
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class SignInWithGoogleEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}

class CheckAuthStateEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPasswordUseCase _signInWithEmailAndPassword;
  final SignUpWithEmailAndPasswordUseCase _signUpWithEmailAndPassword;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final GetCurrentUserUseCase _getCurrentUser;
  final GetAuthStateChangesUseCase _getAuthStateChanges;
  final SaveUserToFirestoreUseCase _saveUserToFirestore;

  AuthBloc({
    required SignInWithEmailAndPasswordUseCase signInWithEmailAndPassword,
    required SignUpWithEmailAndPasswordUseCase signUpWithEmailAndPassword,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignOutUseCase signOut,
    required GetCurrentUserUseCase getCurrentUser,
    required GetAuthStateChangesUseCase getAuthStateChanges,
    required SaveUserToFirestoreUseCase saveUserToFirestore,
  })  : _signInWithEmailAndPassword = signInWithEmailAndPassword,
        _signUpWithEmailAndPassword = signUpWithEmailAndPassword,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        _getAuthStateChanges = getAuthStateChanges,
        _saveUserToFirestore = saveUserToFirestore,
        super(AuthInitial()) {
    on<SignInWithEmailAndPasswordEvent>(_onSignInWithEmailAndPassword);
    on<SignUpWithEmailAndPasswordEvent>(_onSignUpWithEmailAndPassword);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStateEvent>(_onCheckAuthState);
  }

  Future<void> _onSignInWithEmailAndPassword(
    SignInWithEmailAndPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _signInWithEmailAndPassword(event.email, event.password);
      if (user != null) {
        // Try to save user to Firestore (don't fail if it doesn't work)
        try {
          await _saveUserToFirestore(user);
        } catch (e) {
          // Log error but don't fail the sign-in
          print('Failed to save user to Firestore during sign-in: $e');
        }
        emit(Authenticated(user));
      } else {
        emit(AuthError('Sign in failed'));
      }
    } catch (e) {
      // Handle PigeonUserDetails error in sign-in
      final errorMessage = e.toString();
      if (errorMessage.contains('PigeonUserDetails')) {
        try {
          final currentUser = await _getCurrentUser();
          if (currentUser != null) {
            print('Successfully recovered from PigeonUserDetails error in sign-in');
            try {
              await _saveUserToFirestore(currentUser);
            } catch (firestoreError) {
              print('Failed to save user to Firestore after PigeonUserDetails recovery in sign-in: $firestoreError');
            }
            emit(Authenticated(currentUser));
            return;
          }
        } catch (recoveryError) {
          print('Failed to recover from PigeonUserDetails error in sign-in: $recoveryError');
        }
      }
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _signUpWithEmailAndPassword(event.email, event.password, event.name);
      if (user != null) {
        // Save user to Firestore
        try {
          await _saveUserToFirestore(user);
        } catch (e) {
          // Log error but don't fail the sign-up
          print('Failed to save user to Firestore during sign-up: $e');
        }
        emit(Authenticated(user));
      } else {
        emit(AuthError('Sign up failed'));
      }
    } catch (e) {
      // Handle PigeonUserDetails error in sign-up
      final errorMessage = e.toString();
      if (errorMessage.contains('PigeonUserDetails')) {
        try {
          final currentUser = await _getCurrentUser();
          if (currentUser != null) {
            print('Successfully recovered from PigeonUserDetails error in sign-up');
            // Create a new user with the provided name
            final newUser = User(
              id: currentUser.id,
              email: currentUser.email,
              name: event.name, // Use the provided name
              photoUrl: currentUser.photoUrl,
              createdAt: currentUser.createdAt,
            );
            try {
              await _saveUserToFirestore(newUser);
            } catch (firestoreError) {
              print('Failed to save user to Firestore after PigeonUserDetails recovery in sign-up: $firestoreError');
            }
            emit(Authenticated(newUser));
            return;
          }
        } catch (recoveryError) {
          print('Failed to recover from PigeonUserDetails error in sign-up: $recoveryError');
        }
      }
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _signInWithGoogle();
      if (user != null) {
        // Save user to Firestore
        try {
          await _saveUserToFirestore(user);
        } catch (e) {
          // Log error but don't fail the sign-in
          print('Failed to save user to Firestore during Google sign-in: $e');
        }
        emit(Authenticated(user));
      } else {
        emit(AuthError('Google sign in failed'));
      }
    } catch (e) {
      // Handle PigeonUserDetails error specially
      final errorMessage = e.toString();
      if (errorMessage.contains('PigeonUserDetails')) {
        // Try to get the current user from Firebase Auth
        try {
          final currentUser = await _getCurrentUser();
          if (currentUser != null) {
            print('Successfully recovered from PigeonUserDetails error');
            // Save user to Firestore
            try {
              await _saveUserToFirestore(currentUser);
            } catch (firestoreError) {
              print('Failed to save user to Firestore after PigeonUserDetails recovery: $firestoreError');
            }
            emit(Authenticated(currentUser));
            return;
          }
        } catch (recoveryError) {
          print('Failed to recover from PigeonUserDetails error: $recoveryError');
        }
      }
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthState(
    CheckAuthStateEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Stream<AuthState> get authStateChanges {
    return _getAuthStateChanges().map((user) {
      if (user != null) {
        return Authenticated(user);
      } else {
        return Unauthenticated();
      }
    });
  }
} 