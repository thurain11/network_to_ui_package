import 'package:rxdart/rxdart.dart';

import '../network/dio_base_network.dart';
import '../utils/object_factory.dart';
import '../utils/response_ob.dart';

class NetworkToUiBloc<T> extends DioBaseNetwork {
  String url;

  NetworkToUiBloc(this.url) : super();

  PublishSubject<ResponseOb> publishSubject = PublishSubject();
  Stream<ResponseOb> dataStream() => publishSubject.stream;

  void getData({
    Map<String, dynamic>? map,
    ReqType? requestType = ReqType.get,
    bool requestShowLoading = true,
    bool isCached = false,
  }) async {
    ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
    if (requestShowLoading) {
      publishSubject.sink.add(resp);
    }

    dioReq(
      requestType,
      url: url,
      params: map,
      isCached: isCached,
      callBack: (ResponseOb rv) {
        if (rv.message == MsgState.data) {
          if (rv.data != null && rv.data is Map) {
            // Check for "result" field
            if (rv.data.containsKey("result")) {
              if (rv.data["result"].toString() == "1") {
                T? ob;
                try {
                  ob = ObjectFactory.create<T>(rv.data);
                  if (ob == null) {
                    resp.message = MsgState.error;
                    resp.data =
                        "No factory registered for type ${T.toString()}";
                    resp.errState = ErrState.parseError;
                    publishSubject.sink.add(resp);
                    return;
                  }
                } catch (e) {
                  resp.message = MsgState.error;
                  resp.data = "Failed to parse data: $e";
                  resp.errState = ErrState.parseError;
                  publishSubject.sink.add(resp);
                  return;
                }
                resp.message = MsgState.data;
                resp.data = ob;
                publishSubject.sink.add(resp);
              } else if (rv.data["result"].toString() == "0") {
                resp.message = MsgState.more;
                resp.data = rv.data;
                publishSubject.sink.add(resp);
              } else {
                resp.message = MsgState.error;
                resp.data = "Invalid result value";
                resp.errState = ErrState.unknownError;
                publishSubject.sink.add(resp);
              }
            }
            // Handle responses with "message": "success"
            else if (rv.data.containsKey("message") &&
                rv.data["message"].toString().toLowerCase() == "success") {
              T? ob;
              try {
                var dataToParse =
                    rv.data.containsKey("data") ? rv.data["data"] : rv.data;
                ob = ObjectFactory.create<T>(dataToParse);
                if (ob == null) {
                  resp.message = MsgState.error;
                  resp.data = "No factory registered for type ${T.toString()}";
                  resp.errState = ErrState.parseError;
                  publishSubject.sink.add(resp);
                  return;
                }
              } catch (e) {
                resp.message = MsgState.error;
                resp.data = "Failed to parse data: $e";
                resp.errState = ErrState.parseError;
                publishSubject.sink.add(resp);
                return;
              }
              resp.message = MsgState.data;
              resp.data = ob;
              publishSubject.sink.add(resp);
            }
            // Handle plain JSON object without "result" or "message"
            else {
              T? ob;
              try {
                ob = ObjectFactory.create<T>(rv.data);
                if (ob == null) {
                  resp.message = MsgState.error;
                  resp.data = "No factory registered for type ${T.toString()}";
                  resp.errState = ErrState.parseError;
                  publishSubject.sink.add(resp);
                  return;
                }
              } catch (e) {
                resp.message = MsgState.error;
                resp.data = "Failed to parse data: $e";
                resp.errState = ErrState.parseError;
                publishSubject.sink.add(resp);
                return;
              }
              resp.message = MsgState.data;
              resp.data = ob;
              publishSubject.sink.add(resp);
            }
          } else {
            resp.message = MsgState.error;
            resp.data =
                "Invalid response format: Data is not a valid JSON object";
            resp.errState = ErrState.invalidResponse;
            publishSubject.sink.add(resp);
          }
        } else {
          // Pass through error responses from DioBaseNetwork
          resp.message = rv.message;
          resp.data = rv.data;
          resp.errState = rv.errState;
          publishSubject.sink.add(resp);
        }
      },
    );
  }

  void dispose() {
    publishSubject.close();
  }
}
