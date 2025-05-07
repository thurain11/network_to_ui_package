// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
//
// import 'storage_interface.dart';
//
// /// Implementation of [StorageInterface] using Hive database.
// class HiveStorage implements StorageInterface {
//   final String boxName = 'app_storage';
//   late Future<Box> _box;
//
//   HiveStorage() {
//     _box = _initHive();
//   }
//
//   /// Initialize Hive database
//   Future<Box> _initHive() async {
//     final dir = await getApplicationDocumentsDirectory();
//     await Hive.initFlutter(dir.path);
//     return await Hive.openBox(boxName);
//   }
//
//   @override
//   Future<String?> getString(String key) async {
//     final box = await _box;
//     return box.get(key) as String?;
//   }
//
//   @override
//   Future<void> setString(String key, String value) async {
//     final box = await _box;
//     await box.put(key, value);
//   }
//
//   @override
//   Future<void> remove(String key) async {
//     final box = await _box;
//     await box.delete(key);
//   }
// }
