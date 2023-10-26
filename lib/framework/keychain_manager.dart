import 'package:ensemble/framework/error_handling.dart';
import 'package:ensemble/framework/storage_manager.dart';

class KeychainManager {
  static final KeychainManager _instance = KeychainManager._internal();

  KeychainManager._internal();

  factory KeychainManager() {
    return _instance;
  }

  Future<void> saveToKeychain(dynamic inputs) async {
    try {
      final key = inputs?['key'] as String;
      final value = inputs?['value'];
      await StorageManager().writeSecurely(key: key, value: value.toString());
    } catch (e) {
      throw LanguageError('Failed to store value. Reason: ${e.toString()}');
    }
  }

  Future<void> clearKeychain(dynamic inputs) async {
    try {
      final key = inputs?['key'] as String;
      await StorageManager().remove(key);
    } catch (e) {
      throw LanguageError(
          'Failed to remove value with the key - ${inputs['key']}. Reason: ${e.toString()}');
    }
  }
}
