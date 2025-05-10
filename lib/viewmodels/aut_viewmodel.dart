import 'package:expand/repositories/auth_repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Provider for AuthViewModel
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<User?>>((ref) {
      return AuthViewModel(ref.read(authRepositoryProvider));
    });

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AsyncValue.loading()) {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
