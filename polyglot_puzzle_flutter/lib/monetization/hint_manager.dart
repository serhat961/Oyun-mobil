import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'purchase_manager.dart';

class HintManager {
  static final HintManager instance = HintManager._internal();
  final _storage = const FlutterSecureStorage();
  final ValueNotifier<int> hints = ValueNotifier(0);

  HintManager._internal();

  Future<void> initialize() async {
    final value = await _storage.read(key: 'hints');
    hints.value = int.tryParse(value ?? '') ?? 0;
  }

  Future<void> addHints(int amount) async {
    hints.value += amount;
    await _storage.write(key: 'hints', value: hints.value.toString());
  }

  Future<bool> consumeHint() async {
    if (PurchaseManager.instance.hasSubscription) return true;
    if (hints.value <= 0) return false;
    hints.value -= 1;
    await _storage.write(key: 'hints', value: hints.value.toString());
    return true;
  }
}