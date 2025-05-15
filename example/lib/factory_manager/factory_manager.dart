import 'package:network_to_ui/network_to_ui.dart';

import '../models/user_ob.dart';
import '../models/yangon_townships_ob.dart';

class FactoryManager {
  static void setupFactories() {
    ObjectFactory.registerFactory<UserOb>((json) => UserOb.fromJson(json));
    //TownshipsData for LoadMore Ui Page
    ObjectFactory.registerFactory<TownshipsData>(
        (json) => TownshipsData.fromJson(json));
  }
}
