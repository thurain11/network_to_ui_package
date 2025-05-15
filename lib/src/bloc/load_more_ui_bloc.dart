import 'package:rxdart/rxdart.dart';

import '../network/dio_base_network.dart';
import '../utils/pin_ob.dart';
import '../utils/response_ob.dart';

class LoadMoreUiBloc<T extends Object?> extends DioBaseNetwork {
  PublishSubject<ResponseOb> publishSubject = PublishSubject();

  Stream<ResponseOb> shopStream() => publishSubject.stream;

  String nextPageUrl = "";

  void getData(
    String url, {
    Map<String, dynamic>? map,
    ReqType? requestType = ReqType.get,
    bool requestShowLoading = true,
    bool? isCached,
    bool isBaseUrl = true,
  }) async {
    ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
    if (requestShowLoading) {
      publishSubject.sink.add(resp);
    }

    dioReq(
      requestType,
      url: url, // Assuming baseUrl in DioBaseNetworkConfig
      params: map,
      isCached: isCached,
      callBack: (ResponseOb rv) {
        if (rv.message == MsgState.data) {
          if (rv.data is Map) {
            // Check for "result" field
            if (rv.data.containsKey("result")) {
              if (rv.data["result"].toString() == "1") {
                try {
                  PnObClass<T> flv = PnObClass.fromJson(rv.data);
                  nextPageUrl = flv.links?.next?.toString() ?? "";
                  resp.message = MsgState.data;
                  resp.pgState = PageState.first;
                  resp.meta = flv.meta;
                  resp.data = flv.data;
                  publishSubject.sink.add(resp);
                } catch (e) {
                  resp.message = MsgState.error;
                  resp.data = "Failed to parse data: $e";
                  resp.errState = ErrState.parse_error;
                  publishSubject.sink.add(resp);
                }
              } else if (rv.data["result"].toString() == "0") {
                resp.message = MsgState.more;
                resp.data = rv.data["message"] ?? "No more data";
                publishSubject.sink.add(resp);
              } else {
                resp.message = MsgState.error;
                resp.data = "Invalid result value";
                resp.errState = ErrState.unknown_err;
                publishSubject.sink.add(resp);
              }
            }
            // Check for "message": "success"
            else if (rv.data.containsKey("message") &&
                rv.data["message"].toString().toLowerCase() == "success") {
              try {
                PnObClass<T> flv = PnObClass.fromJson(rv.data);
                nextPageUrl = flv.links?.next?.toString() ?? "";
                resp.message = MsgState.data;
                resp.pgState = PageState.first;
                resp.meta = flv.meta;
                resp.data = flv.data;
                publishSubject.sink.add(resp);
              } catch (e) {
                resp.message = MsgState.error;
                resp.data = "Failed to parse data: $e";
                resp.errState = ErrState.parse_error;
                publishSubject.sink.add(resp);
              }
            }
            // Fallback for plain JSON
            else {
              try {
                PnObClass<T> flv = PnObClass.fromJson(rv.data);
                if (flv.data == null && flv.links == null && flv.meta == null) {
                  resp.message = MsgState.error;
                  resp.data = "Invalid plain JSON: No usable data";
                  resp.errState = ErrState.invalid_response;
                  publishSubject.sink.add(resp);
                } else {
                  nextPageUrl = flv.links?.next?.toString() ?? "";
                  resp.message = MsgState.data;
                  resp.pgState = PageState.first;
                  resp.meta = flv.meta;
                  resp.data = flv.data ?? [];
                  publishSubject.sink.add(resp);
                }
              } catch (e) {
                resp.message = MsgState.error;
                resp.data = "Failed to parse plain JSON: $e";
                resp.errState = ErrState.parse_error;
                publishSubject.sink.add(resp);
              }
            }
          } else {
            resp.message = MsgState.error;
            resp.data =
                "Invalid response format: Data is not a valid JSON object";
            resp.errState = ErrState.invalid_response;
            publishSubject.sink.add(resp);
          }
        } else {
          publishSubject.sink.add(rv);
        }
      },
    );
  }

  void getLoad(
    String? url,
    Map<String, dynamic>? map, {
    ReqType requestType = ReqType.get,
    bool? isCached,
  }) async {
    ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
    if (nextPageUrl != "null" && nextPageUrl != "") {
      dioReq(
        requestType,
        url: nextPageUrl,
        params: map,
        isCached: isCached,
        callBack: (ResponseOb rv) {
          if (rv.message == MsgState.data) {
            if (rv.data is Map) {
              // Check for "result" field
              if (rv.data.containsKey("result")) {
                if (rv.data["result"].toString() == "1") {
                  try {
                    PnObClass<T> flv = PnObClass.fromJson(rv.data);
                    nextPageUrl = flv.links?.next?.toString() ?? "";
                    resp.message = MsgState.data;
                    resp.pgState = PageState.other;
                    resp.data = flv.data;
                    resp.meta = flv.meta;
                    publishSubject.sink.add(resp);
                  } catch (e) {
                    resp.message = MsgState.error;
                    resp.data = "Failed to parse data: $e";
                    resp.errState = ErrState.parse_error;
                    publishSubject.sink.add(resp);
                  }
                } else if (rv.data["result"].toString() == "0") {
                  resp.message = MsgState.more;
                  resp.data = rv.data["message"] ?? "No more data";
                  publishSubject.sink.add(resp);
                } else {
                  resp.message = MsgState.error;
                  resp.data = "Invalid result value";
                  resp.errState = ErrState.unknown_err;
                  publishSubject.sink.add(resp);
                }
              }
              // Check for "message": "success"
              else if (rv.data.containsKey("message") &&
                  rv.data["message"].toString().toLowerCase() == "success") {
                try {
                  PnObClass<T> flv = PnObClass.fromJson(rv.data);
                  nextPageUrl = flv.links?.next?.toString() ?? "";
                  resp.message = MsgState.data;
                  resp.pgState = PageState.other;
                  resp.data = flv.data;
                  resp.meta = flv.meta;
                  publishSubject.sink.add(resp);
                } catch (e) {
                  resp.message = MsgState.error;
                  resp.data = "Failed to parse data: $e";
                  resp.errState = ErrState.parse_error;
                  publishSubject.sink.add(resp);
                }
              }
              // Fallback for plain JSON
              else {
                try {
                  PnObClass<T> flv = PnObClass.fromJson(rv.data);
                  if (flv.data == null &&
                      flv.links == null &&
                      flv.meta == null) {
                    resp.message = MsgState.error;
                    resp.data = "Invalid plain JSON: No usable data";
                    resp.errState = ErrState.invalid_response;
                    publishSubject.sink.add(resp);
                  } else {
                    nextPageUrl = flv.links?.next?.toString() ?? "";
                    resp.message = MsgState.data;
                    resp.pgState = PageState.other;
                    resp.data = flv.data ?? [];
                    resp.meta = flv.meta;
                    publishSubject.sink.add(resp);
                  }
                } catch (e) {
                  resp.message = MsgState.error;
                  resp.data = "Failed to parse plain JSON: $e";
                  resp.errState = ErrState.parse_error;
                  publishSubject.sink.add(resp);
                }
              }
            } else {
              resp.message = MsgState.error;
              resp.data =
                  "Invalid response format: Data is not a valid JSON object";
              resp.errState = ErrState.invalid_response;
              publishSubject.sink.add(resp);
            }
          } else {
            publishSubject.sink.add(rv);
          }
        },
      );
    } else {
      List<T> l = [];
      resp.message = MsgState.data;
      resp.data = l;
      resp.pgState = PageState.no_more;
      publishSubject.sink.add(resp);
    }
  }

  void dispose() {
    publishSubject.close();
  }

  void replaceChatInfoData({required String id}) {
    ResponseOb resp = ResponseOb(
        data: {"id": id},
        mode: RefreshUIMode.replaceChatInfoData,
        message: MsgState.data);
    publishSubject.sink.add(resp);
  }
}
