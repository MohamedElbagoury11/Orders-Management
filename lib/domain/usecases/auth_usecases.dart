import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailAndPasswordUseCase {
  final AuthRepository _authRepository;

  SignInWithEmailAndPasswordUseCase(this._authRepository);

  Future<User?> call(String email, String password) async {
    return await _authRepository.signInWithEmailAndPassword(email, password);
  }
}

class SignUpWithEmailAndPasswordUseCase {
  final AuthRepository _authRepository;

  SignUpWithEmailAndPasswordUseCase(this._authRepository);

  Future<User?> call(String email, String password, String name) async {
    return await _authRepository.signUpWithEmailAndPassword(email, password, name);
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository _authRepository;

  SignInWithGoogleUseCase(this._authRepository);

  Future<User?> call() async {
    return await _authRepository.signInWithGoogle();
  }
}

class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<void> call() async {
    await _authRepository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<User?> call() async {
    return await _authRepository.getCurrentUser();
  }
}

class GetAuthStateChangesUseCase {
  final AuthRepository _authRepository;

  GetAuthStateChangesUseCase(this._authRepository);

  Stream<User?> call() {
    return _authRepository.authStateChanges;
  }
}

class SaveUserToFirestoreUseCase {
  final AuthRepository _authRepository;

  SaveUserToFirestoreUseCase(this._authRepository);

  Future<void> call(User user) async {
    await _authRepository.saveUserToFirestore(user);
  }
} 