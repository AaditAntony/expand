import 'package:shared_preferences/shared_preferences.dart';

class CounterRepository {
  static const _keyCounter = 'counter';

  Future<int> getCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCounter) ?? 0;
  }

  Future<void> setCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCounter, value);
  }

  Future<void> incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyCounter) ?? 0;
    await prefs.setInt(_keyCounter, current + 1);
  }
}
