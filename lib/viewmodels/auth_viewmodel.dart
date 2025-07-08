import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authViewModelProvider = Provider<AuthViewModel>((ref) {
  return AuthViewModel(ref.read(authRepositoryProvider));
});

class AuthViewModel {
  final AuthRepository _repository;

  AuthViewModel(this._repository);

  Future<User?> signInWithGoogle() async {
    return await _repository.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  User? getCurrentUser() {
    return _repository.getCurrentUser();
  }
}
