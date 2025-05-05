import 'package:get_it/get_it.dart';

import '../storage/hive_storage.dart';
import '../storage/shared_prefs_storage.dart';
import '../utils/dio_base_network_config.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<DioBaseNetworkConfig>(DioBaseNetworkConfig());
  getIt.registerSingleton(HiveStorage());
  getIt.registerSingleton(SharedPrefsStorage());
}
