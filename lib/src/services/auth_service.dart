import '../storage/storage_interface.dart';
import 'locator.dart';

class AuthService {
  Future<String?> getUserToken() async {
    final storage = getIt<StorageInterface>();
    return await storage.getString("token");
  }

  Future<void> saveUserToken(String token) async {
    final storage = getIt<StorageInterface>();
    await storage.setString("token", token);
  }

  Future<void> logout() async {
    final storage = getIt<StorageInterface>();
    await storage.remove("token");
  }
}
