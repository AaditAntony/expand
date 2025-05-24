import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expand/lean_riverpod/data_model.dart';
import 'package:expand/lean_riverpod/data_service.dart';

// Provider to expose the DataService
final dataServiceProvider = Provider<DataService>((ref) => DataService());

// Notifier to manage loading state and data
class DataNotifier extends StateNotifier<AsyncValue<DataModel>> {
  final DataService dataService;

  DataNotifier({required this.dataService}) : super(const AsyncLoading()) {
    loadData();
  }

  // Fetch data from the API
  Future<void> loadData() async {
    try {
      final data = await dataService.fetchData();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Expose the notifier through a StateNotifierProvider
final dataNotifierProvider =
    StateNotifierProvider<DataNotifier, AsyncValue<DataModel>>(
      (ref) => DataNotifier(dataService: ref.watch(dataServiceProvider)),
    );
