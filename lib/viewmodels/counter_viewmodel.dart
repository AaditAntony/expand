import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/counter_repository.dart';

final counterRepositoryProvider = Provider<CounterRepository>((ref) {
  return CounterRepository();
});

final counterViewModelProvider = Provider<CounterViewModel>((ref) {
  return CounterViewModel(ref.read(counterRepositoryProvider));
});

class CounterViewModel {
  final CounterRepository _repository;

  CounterViewModel(this._repository);

  Future<int> getCounter() async {
    return await _repository.getCounter();
  }

  Future<void> setCounter(int value) async {
    await _repository.setCounter(value);
  }

  Future<void> incrementCounter() async {
    await _repository.incrementCounter();
  }
}
