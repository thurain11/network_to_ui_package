/// Abstract interface for storage operations.
///
/// This interface defines the contract for storage operations such as
/// getting, setting, and removing key-value pairs.
/// Implementations can use different storage backends (e.g., SharedPreferences, Hive).
abstract class StorageInterface {
  /// Retrieves a string value for the given [key].
  Future<String?> getString(String key);

  /// Sets a string [value] for the given [key].
  Future<void> setString(String key, String value);

  /// Removes the value associated with the given [key].
  Future<void> remove(String key);
}
