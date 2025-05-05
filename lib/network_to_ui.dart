library network_to_ui;

export 'src/builder/single_ui_builder.dart';
export 'src/network/dio_base_network.dart';
export 'src/services/locator.dart';
export 'src/storage/hive_storage.dart';
export 'src/storage/storage_interface.dart';
export 'src/utils/dio_base_network_config.dart'; // DioBaseNetworkConfig export
export 'src/utils/factory_builder.dart';
export 'src/utils/object_factory.dart';

/// A Calculator.

//void registerFactory<T>(T Function(Map<String, dynamic>) factory) {
//   ObjectFactory.registerFactory<T>(factory);
// }
//
// void setupFactories() {
//   registerFactory<HomeSlideOb>((json) => HomeSlideOb.fromJson(json));
//   registerFactory<UserOb>((json) => UserOb.fromJson(json));
// }
