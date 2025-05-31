import 'package:expand/features/Product/pro_model.dart';
import 'package:expand/features/Product/pro_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// provider to expose the data from api
final proRepositoryProvider = Provider<ProRepository>((ref) => ProRepository());

// notifier state to manage the loading state and the data

class ProNotifier extends StateNotifier<AsyncValue<ProModel>> {
  final ProRepository repository;
  ProNotifier(this.repository) : super(AsyncLoading()) {
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await repository.fetchApi();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// exposes the notifer that  connect with the value to the screen

final dataNotiferProvider =
    StateNotifierProvider<ProNotifier, AsyncValue<ProModel>>(
      (ref) => ProNotifier(ref.watch(proRepositoryProvider)),
    );
