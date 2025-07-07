import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CoinManager {
  static final CoinManager instance = CoinManager._internal();
  final _storage = const FlutterSecureStorage();
  final ValueNotifier<int> coins = ValueNotifier(0);

  static const _key = 'coins';

  CoinManager._internal();

  Future<void> initialize() async {
    final value = await _storage.read(key: _key);
    coins.value = int.tryParse(value ?? '') ?? 0;
  }

  Future<void> addCoins(int amount) async {
    coins.value += amount;
    await _storage.write(key: _key, value: coins.value.toString());
  }

  Future<bool> spendCoins(int amount) async {
    if (coins.value < amount) return false;
    coins.value -= amount;
    await _storage.write(key: _key, value: coins.value.toString());
    return true;
  }
}