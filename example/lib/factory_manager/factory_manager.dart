import 'package:network_to_ui/network_to_ui.dart';

import '../models/user_ob.dart';

class FactoryManager {
  static void setupFactories() {
    ObjectFactory.registerFactory<UserOb>((json) => UserOb.fromJson(json));
  }
}
