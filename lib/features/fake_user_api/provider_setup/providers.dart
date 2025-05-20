import 'package:expand/features/fake_user_api/repository_layer/user_repository.dart';
import 'package:expand/features/fake_user_api/view_model_layer/user_viewModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(client: ref.read(httpClientProvider));
});

final userViewProvider = StateNotifierProvider<UserViewmodel, UserState>((ref) {
  return UserViewmodel(repository: ref.read(userRepositoryProvider));
});
