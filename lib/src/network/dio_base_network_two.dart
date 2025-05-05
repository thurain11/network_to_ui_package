import 'dart:io';

import 'package:dio/dio.dart';

import '../../network_to_ui.dart';
import '../utils/response_ob.dart';

class DioBaseNetwork {
  final DioBaseNetworkConfig config = getIt<DioBaseNetworkConfig>();
  DioBaseNetwork(); // Remove config parameter

  Future<Map<String, String?>> getHeader() async {
    String os = "";
    if (Platform.isIOS) {
      os = "ios";
    } else if (Platform.isAndroid) {
      os = "android";
    }

    String language = config.language ?? "en"; // Use singleton
    if (language == "mm") {
      language = 'mm_zg';
    } else if (language == "uni") {
      language = 'mm_uni';
    }

    return {
      "Authorization": config.authorizationToken,
      "Accept": "application/json",
      "version-ios": config.nowVersionIos,
      "version-android": config.nowVersionAndroid,
      "operating-system": os,
    };
  }

  void getReq(String url,
      {Map<String, dynamic>? params,
      required callBackFunction callBack}) async {
    dioReq(ReqType.Get, url: url, params: params, callBack: callBack);
  }

  // Post
  void postReq(String url,
      {Map<String, dynamic>? map,
      FormData? fd,
      required callBackFunction callBack}) async {
    dioReq(ReqType.Post, url: url, params: map, fd: fd, callBack: callBack);
  }

  Future<void> dioReq(ReqType? rt,
      {required String url,
      Map<String, dynamic>? params,
      FormData? fd,
      required callBackFunction callBack,
      bool? isCached = false}) async {
    BaseOptions options = BaseOptions();

    options.headers = await getHeader();

    Dio dio = Dio(options);

    dio.interceptors.add(LogInterceptor(
        responseBody: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true));

    if (isCached == true) {
      // dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: url)).interceptor);
    }

    try {
      Response response;
      if (rt == ReqType.Get) {
        if (params == null) {
          response = await dio.get(url);
        } else {
          response = await dio.get(
            url,
            queryParameters: params,
          );
        }
      } else if (rt == ReqType.Put) {
        if (params == null) {
          response = await dio.put(url);
        } else {
          response = await dio.put(url, queryParameters: params);
        }
      } else if (rt == ReqType.Delete) {
        if (params == null) {
          response = await dio.delete(url);
        } else {
          response = await dio.delete(url, queryParameters: params);
        }
      } else {
        if (params != null || fd != null) {
          response = await dio.post(url, data: fd ?? params);
        } else {
          response = await dio.post(url);
        }
      }

      int? statusCode = response.statusCode;
      ResponseOb respOb = ResponseOb(); //data,message,err

      if (statusCode == 200) {
        respOb.message = MsgState.data;
        respOb.data = response.data;
      } else {
        respOb.message = MsgState.error;
        respOb.data = "Unknown error";
        respOb.errState = ErrState.unknown_err;
      }
      callBack(respOb);
    } on DioError catch (e) {
      ResponseOb respOb = ResponseOb();

      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          respOb.message = MsgState.error;
          respOb.data = e.response.toString();
          respOb.errState = ErrState.validate_err;
        } else if (e.response!.statusCode == 500) {
          respOb.message = MsgState.error;
          respOb.data = "Internal Server Error";
          respOb.errState = ErrState.server_error;
        } else if (e.response!.statusCode == 503) {
          respOb.message = MsgState.error;
          respOb.data = "System Maintenance";
          respOb.errState = ErrState.server_maintain;
        } else if (e.response!.statusCode == 404) {
          respOb.message = MsgState.error;
          respOb.data = "Your requested data not found";
          respOb.errState = ErrState.not_found;
        } else if (e.response!.statusCode == 401) {
          respOb.message = MsgState.error;
          respOb.data = e.response!.data ?? "You need to Login";
          respOb.errState = ErrState.no_login;
        } else if (e.response!.statusCode == 429) {
          respOb.message = MsgState.error;
          respOb.data = "Too many request error";
          respOb.errState = ErrState.too_many_request;
        } else {
          if (e.toString().contains('SocketException')) {
            respOb.message = MsgState.error;
            respOb.data = "No internet connection";
            respOb.errState = ErrState.no_internet;
          } else {
            respOb.message = MsgState.error;
            respOb.data = "Unknown error";
            respOb.errState = ErrState.unknown_err;
          }
        }
      } else {
        if (e.toString().contains('SocketException')) {
          respOb.message = MsgState.error;
          respOb.data = "No internet connection";
          respOb.errState = ErrState.no_internet;
        } else {
          respOb.message = MsgState.error;
          respOb.data = "Unknown error";
          respOb.errState = ErrState.unknown_err;
        }
      }
      callBack(respOb);
    }
  }

  Future<void> dioProgressReq(
      {required String url,
      Map<String, dynamic>? params,
      FormData? fd,
      required callBackFunction callBack,
      ProgressCallbackFunction? progressCallback,
      CancelToken? cancelToken}) async {
    BaseOptions options = BaseOptions();

    options.headers = await getHeader();

    Dio dio = Dio(options);

    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    try {
      Response response;
      response = await dio.post(url, data: fd ?? params,
          onSendProgress: (int nowData, int totalData) {
        progressCallback!(nowData / totalData);
      }, cancelToken: cancelToken);

      int? statusCode = response.statusCode;

      ResponseOb respOb = ResponseOb(); //data,message,err

      if (statusCode == 200) {
        respOb.message = MsgState.data;
        respOb.data = response.data;
      } else {
        respOb.message = MsgState.error;
        respOb.data = "Unknown error";
        respOb.errState = ErrState.unknown_err;
      }
      callBack(respOb);
    } on DioError catch (e) {
      ResponseOb respOb = ResponseOb();

      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          respOb.message = MsgState.error;
          respOb.data = e.response.toString();
          respOb.errState = ErrState.validate_err;
        } else if (e.response!.statusCode == 500) {
          respOb.message = MsgState.error;
          respOb.data = "Internal Server Error";
          respOb.errState = ErrState.server_error;
        } else if (e.response!.statusCode == 404) {
          respOb.message = MsgState.error;
          respOb.data = "Your requested data not found";
          respOb.errState = ErrState.not_found;
        } else if (e.response!.statusCode == 401) {
          respOb.message = MsgState.error;
          respOb.data = "You need to login";
          respOb.errState = ErrState.no_login;
        } else if (e.response!.statusCode == 429) {
          respOb.message = MsgState.error;
          respOb.data = "Too many request error";
          respOb.errState = ErrState.too_many_request;
        } else {
          if (e.toString().contains('SocketException')) {
            respOb.message = MsgState.error;
            respOb.data = "No internet connection";
            respOb.errState = ErrState.no_internet;
          } else {
            respOb.message = MsgState.error;
            respOb.data = "Unknown error";
            respOb.errState = ErrState.unknown_err;
          }
        }
      } else {
        if (e.toString().contains('SocketException')) {
          respOb.message = MsgState.error;
          respOb.data = "No internet connection";
          respOb.errState = ErrState.no_internet;
        } else {
          respOb.message = MsgState.error;
          respOb.data = "Unknown error";
          respOb.errState = ErrState.unknown_err;
        }
      }
      callBack(respOb);
    }
  }
}

enum ReqType { Get, Post, Delete, Put }

typedef callBackFunction(ResponseOb ob);
typedef ProgressCallbackFunction(double i);
