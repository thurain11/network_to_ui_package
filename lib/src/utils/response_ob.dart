import 'pin_ob.dart';

class ResponseOb {
  dynamic data;
  Map<String, dynamic>? map;
  MsgState? message;
  ErrState? errState;
  PageState? pgState;
  String? pageName;
  RefreshUIMode mode;
  Meta? meta;
  int? success;

  ResponseOb(
      {this.data,
      this.message,
      this.pageName,
      this.pgState,
      this.errState,
      this.mode = RefreshUIMode.none,
      this.meta,
      this.map,
      this.success});
}

enum MsgState { error, loading, data, more, server }

enum ErrState {
  noInternet,
  connectionTimeout,
  notFound,
  serverError,
  tooManyRequest,
  unknownError,
  validateError,
  notSupported,
  noLogin, //401
  serverMaintain,
  parseError,
  invalidResponse,
  cancelled,
  unAuth,
  rateLimit
}

enum PageState { first, other, no_more }

enum RefreshUIMode {
  replace,
  edit,
  delete,
  none,
  status,
  add,
  addLocalStorage,
  replaceLocalStorage,
  replaceChatInfoData,
  editLocalStorage,
  replaceEditData,
  replaceFailedData
}
