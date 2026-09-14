/// Prepared interface for Local Storage (SharedPreferences / Hive / SecureStorage).
abstract class StorageService {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
}

class MockStorageService implements StorageService {
  final Map<String, dynamic> _memoryStore = {};

  @override
  Future<void> setString(String key, String value) async {
    _memoryStore[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _memoryStore[key] as String?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _memoryStore[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    return _memoryStore[key] as bool?;
  }
}
