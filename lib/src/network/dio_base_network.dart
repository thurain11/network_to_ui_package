import 'dart:io';

import 'package:dio/dio.dart';

import '../../network_to_ui.dart';

enum ReqType { get, post, delete, put }

typedef CallBackFunction = void Function(ResponseOb);
typedef ProgressCallbackFunction = void Function(double);

class DioBaseNetwork {
  DioBaseNetworkConfig config = getIt<DioBaseNetworkConfig>();

  Future<Map<String, String?>> getHeader({
    Map<String, String?>? customHeaders,
  }) async {
    String os = "";
    if (Platform.isIOS) {
      os = "ios";
    } else if (Platform.isAndroid) {
      os = "android";
    }

    String language = config.language ?? "en";
    if (language == "mm") {
      language = 'mm_zg';
    } else if (language == "uni") {
      language = 'mm_uni';
    }

    final storage = getIt<StorageInterface>();
    final token = await storage.getString("token");

    final Map<String, String?> defaultHeaders = {
      "Authorization": token != null ? "Bearer $token" : null,
      "Accept": "application/json",
      "version-ios": config.nowVersionIos,
      "version-android": config.nowVersionAndroid,
      "operating-system": os,
    };

    // Merge additional headers from config
    if (config.additionalHeaders != null) {
      defaultHeaders.addAll(config.additionalHeaders!);
    }

    // Merge custom headers (highest priority)
    if (customHeaders != null) {
      defaultHeaders.addAll(customHeaders);
    }

    return defaultHeaders;
  }

  Future<void> getReq(
    String url, {
    Map<String, dynamic>? params,
    required CallBackFunction callBack,
    bool? isCached = false,
    CancelToken? cancelToken,
  }) async {
    await dioReq(
      ReqType.get,
      url: url,
      params: params,
      callBack: callBack,
      isCached: isCached,
      cancelToken: cancelToken,
    );
  }

  Future<void> postReq(
    String url, {
    Map<String, dynamic>? map,
    FormData? fd,
    required CallBackFunction callBack,
    bool? isCached = false,
    CancelToken? cancelToken,
  }) async {
    await dioReq(
      ReqType.post,
      url: url,
      params: map,
      fd: fd,
      callBack: callBack,
      isCached: isCached,
      cancelToken: cancelToken,
    );
  }

  Future<void> dioReq(
    ReqType? rt, {
    required String url,
    Map<String, dynamic>? params,
    FormData? fd,
    required CallBackFunction callBack,
    bool? isCached = false,
    CancelToken? cancelToken,
  }) async {
    ResponseOb respOb = ResponseOb();
    try {
      BaseOptions options = BaseOptions(headers: await getHeader());
      Dio dio = Dio(options);
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
        responseBody: true,
      ));

      // if (isCached == true) {
      //   dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: url)).interceptor);
      // }

      Response response;
      if (rt == ReqType.get) {
        response = params != null
            ? await dio.get(url,
                queryParameters: params, cancelToken: cancelToken)
            : await dio.get(url, cancelToken: cancelToken);
      } else if (rt == ReqType.put) {
        response = params != null
            ? await dio.put(url,
                queryParameters: params, cancelToken: cancelToken)
            : await dio.put(url, cancelToken: cancelToken);
      } else if (rt == ReqType.delete) {
        response = params != null
            ? await dio.delete(url,
                queryParameters: params, cancelToken: cancelToken)
            : await dio.delete(url, cancelToken: cancelToken);
      } else {
        response =
            await dio.post(url, data: fd ?? params, cancelToken: cancelToken);
      }

      if (response.statusCode == 200) {
        respOb.message = MsgState.data;
        respOb.data = response.data;
        callBack(respOb);
      } else {
        respOb.message = MsgState.error;
        respOb.errState = ErrState.unknown_err;
        callBack(respOb);
      }
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        respOb.message = MsgState.error;
        respOb.data = "Request cancelled";
        respOb.errState = ErrState.cancelled;
        callBack(respOb);
        return;
      }
      respOb.message = MsgState.error;
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          respOb.errState = ErrState.validate_err;
          respOb.data = e.response!.data;
        } else if (e.response!.statusCode == 500) {
          respOb.errState = ErrState.server_error;
        } else if (e.response!.statusCode == 503) {
          respOb.errState = ErrState.maintainance;
        } else if (e.response!.statusCode == 404) {
          respOb.errState = ErrState.not_found;
        } else if (e.response!.statusCode == 401) {
          respOb.errState = ErrState.unauth;
        } else if (e.response!.statusCode == 429) {
          respOb.errState = ErrState.rate_limit;
        } else {
          respOb.errState = ErrState.unknown_err;
        }
      } else {
        if (e.error is SocketException) {
          respOb.errState = ErrState.no_internet;
        } else {
          respOb.errState = ErrState.unknown_err;
        }
      }
      callBack(respOb);
    } catch (e) {
      respOb.message = MsgState.error;
      respOb.errState = ErrState.unknown_err;
      callBack(respOb);
    }
  }

  Future<void> dioProgressReq(
    String url, {
    Map<String, dynamic>? params,
    FormData? fd,
    required CallBackFunction callBack,
    ProgressCallbackFunction? progressCallback,
    CancelToken? cancelToken,
  }) async {
    ResponseOb respOb = ResponseOb();
    try {
      BaseOptions options = BaseOptions(headers: await getHeader());
      Dio dio = Dio(options);
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
        responseBody: true,
      ));

      Response response = await dio.post(
        url,
        data: fd ?? params,
        cancelToken: cancelToken,
        onSendProgress: (int sent, int total) {
          double per = (sent / total) * 100;
          if (progressCallback != null) {
            progressCallback(per);
          }
        },
      );

      if (response.statusCode == 200) {
        respOb.message = MsgState.data;
        respOb.data = response.data;
        callBack(respOb);
      } else {
        respOb.message = MsgState.error;
        respOb.errState = ErrState.unknown_err;
        callBack(respOb);
      }
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        respOb.message = MsgState.error;
        respOb.data = "Request cancelled";
        respOb.errState = ErrState.cancelled;
        callBack(respOb);
        return;
      }
      respOb.message = MsgState.error;
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          respOb.errState = ErrState.validate_err;
          respOb.data = e.response!.data;
        } else if (e.response!.statusCode == 500) {
          respOb.errState = ErrState.server_error;
        } else if (e.response!.statusCode == 503) {
          respOb.errState = ErrState.maintainance;
        } else if (e.response!.statusCode == 404) {
          respOb.errState = ErrState.not_found;
        } else if (e.response!.statusCode == 401) {
          respOb.errState = ErrState.unauth;
        } else if (e.response!.statusCode == 429) {
          respOb.errState = ErrState.rate_limit;
        } else {
          respOb.errState = ErrState.unknown_err;
        }
      } else {
        if (e.error is SocketException) {
          respOb.errState = ErrState.no_internet;
        } else {
          respOb.errState = ErrState.unknown_err;
        }
      }
      callBack(respOb);
    } catch (e) {
      respOb.message = MsgState.error;
      respOb.errState = ErrState.unknown_err;
      callBack(respOb);
    }
  }
}
