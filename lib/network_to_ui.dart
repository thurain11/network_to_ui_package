library network_to_ui;

import 'package:get_it/get_it.dart';
import 'package:network_to_ui/network_to_ui.dart';

export 'src/bloc/data_request_bloc.dart';
export 'src/network/dio_base_network.dart';
export 'src/services/auth_service.dart';
export 'src/services/locator.dart';
export 'src/storage/hive_storage.dart';
export 'src/storage/shared_prefs_storage.dart';
export 'src/storage/storage_interface.dart';
export 'src/utils/dio_base_network_config.dart'; // DioBaseNetworkConfig export
export 'src/utils/factory_builder.dart';
export 'src/utils/object_factory.dart';
export 'src/utils/response_ob.dart';
export 'src/widgets/data_request_widget.dart';
export 'src/widgets/network_to_ui_builder.dart';

final getIt = GetIt.instance;

/// Initializes the network_to_ui package by setting up dependencies and storage.
/// Returns the [StorageInterface] instance for accessing stored data.
Future<StorageInterface> initializeNetwork() async {
  // Setup dependency injection
  setupLocator();

  // Setup factories
  // Return the registered StorageInterface instance
  return getIt<StorageInterface>();
}
