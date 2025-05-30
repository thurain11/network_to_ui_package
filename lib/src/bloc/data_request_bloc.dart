import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import '../network/dio_base_network.dart';
import '../utils/response_ob.dart';

class DataRequestBloc extends DioBaseNetwork {
  PublishSubject<ResponseOb> requestButtonController = PublishSubject();
  Stream<ResponseOb> getRequestStream() => requestButtonController.stream;

  postData(
    url, {
    FormData? fd,
    Map<String, dynamic>? map,
    ReqType requestType = ReqType.post,
    bool requestShowLoading = true,
    bool? isBaseUrl,
    String? tempId = '',
  }) async {
    ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
    if (requestShowLoading) {
      requestButtonController.sink.add(resp);
    }
    dioReq(requestType, url: url, params: map, fd: fd,
        callBack: (ResponseOb rv) {
      if (rv.message == MsgState.data) {
        if (rv.data["result"].toString() == "1") {
          resp.message = MsgState.data;
          resp.data = rv.data;
          // resp.tempId=tempId;
          requestButtonController.sink.add(resp);
        } else if (rv.data['result'].toString() == "0") {
          resp.message = MsgState.more;
          resp.data = rv.data; //map['message'].toString();
          requestButtonController.sink.add(resp);
        } else {
          requestButtonController.sink.add(rv);
        }
      } else {
        requestButtonController.sink.add(rv);
      }
    }).catchError((e) {
      debugPrint("Java -> $e");
    });
  }

  void disponse() {
    requestButtonController.close();
  }
}
