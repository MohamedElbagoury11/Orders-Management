import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  );
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  Stream<User?> get authStateChanges;
  Future<void> saveUserToFirestore(User user);
  Future<void> incrementUserOrderCount(String userId);
}
