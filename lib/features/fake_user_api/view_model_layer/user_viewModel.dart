import 'package:expand/features/fake_user_api/model_layer/user_model.dart';
import 'package:expand/features/fake_user_api/repository_layer/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserState {
  final List<User> user;
  final bool isLoading;
  final String? error;
  UserState({this.user = const [], this.isLoading = false, this.error});

  UserState copywith({List<User>? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserViewmodel extends StateNotifier<UserState> {
  final UserRepository repository;
  UserViewmodel({required this.repository}) : super(UserState()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = state.copywith(isLoading: true, error: null);
    try {
      final user = await repository.fetchUser();
      state = state.copywith(user: user, isLoading: false);
    } catch (e) {
      state = state.copywith(error: e.toString(), isLoading: false);
    }
  }
}
