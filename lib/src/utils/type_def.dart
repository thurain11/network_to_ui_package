import 'package:flutter/material.dart';

import '../network/dio_base_network.dart';
import 'response_ob.dart';

typedef MainWidget = Widget Function(dynamic data, RefreshLoad reload);
typedef More = Widget Function(dynamic data, RefreshLoad reload);
typedef HeaderWidget = Widget Function();
typedef FooterWidget = Widget Function(RefreshLoad reload);
typedef SuccessCallback = void Function(ResponseOb resp);
typedef CustomMoreCallback = void Function(ResponseOb resp);
typedef CustomErrorCallback = void Function(ResponseOb resp);

typedef RefreshLoad = void Function(
    {Map<String, dynamic>? map,
    ReqType? requestType,
    bool? refreshShowLoading});
