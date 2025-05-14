import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bloc/data_request_bloc.dart';
import '../network/dio_base_network.dart';
import '../utils/app_utils.dart';
import '../utils/response_ob.dart';

typedef OnPressed = dynamic Function();
typedef onAsyncPressed = Future<Map<String, dynamic>?>? Function();
typedef SuccessFuncMethod = void Function(ResponseOb ob);
typedef ValidFuncMethod = void Function(ResponseOb ob);
typedef MoreFuncMethod = void Function(ResponseOb ob);
typedef StateFuncMethod = void Function(ResponseOb ob);

class DataRequestWidget extends StatefulWidget {
  final String? url;
  final String? text;
  final ScaffoldState? scaffoldState;
  final bool changeFormData;
  final bool isShowDialog;
  final Color textColor;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final SuccessFuncMethod successFunc;
  final StateFuncMethod? stateFunc;
  final MoreFuncMethod? moreFunc;
  final OnPressed? onPress;
  final onAsyncPressed? onAsyncPress;
  final Function? errorFunc;
  final ValidFuncMethod? validFunc;
  final ReqType requestType;
  final bool isDisable;
  final double borderRadius;
  final BorderRadius? bRadius;
  final bool showErrSnack;
  final Widget? icon;
  final Widget? loadingWidget;
  final bool showLoading;
  final Color borderColor;
  final double borderWidth;
  final bool isAlreadyFormData;
  final TextAlign? align;
  final String? tempId;

  const DataRequestWidget({
    super.key,
    required this.url,
    required this.text,
    this.scaffoldState,
    required this.successFunc,
    this.stateFunc,
    this.moreFunc,
    this.errorFunc,
    this.isAlreadyFormData = false,
    this.showLoading = true,
    this.onPress,
    this.onAsyncPress,
    this.changeFormData = false,
    this.textColor = Colors.white,
    this.color = Colors.blueAccent,
    this.padding = const EdgeInsets.all(10),
    this.isShowDialog = false,
    this.textStyle,
    this.align,
    this.validFunc,
    this.requestType = ReqType.post,
    this.isDisable = false,
    this.borderRadius = 5,
    this.bRadius,
    this.showErrSnack = true,
    this.icon,
    this.loadingWidget,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0.0,
    this.tempId = '',
  });

  @override
  _DataRequestWidgetState createState() => _DataRequestWidgetState();
}

class _DataRequestWidgetState extends State<DataRequestWidget> {
  final _bloc = DataRequestBloc();
  bool isShowingDialog = false;

  @override
  void initState() {
    super.initState();
    _bloc.getRequestStream().listen((ResponseOb resp) {
      if (widget.stateFunc != null) {
        widget.stateFunc!(resp);
      }

      if (resp.message == MsgState.data) {
        if (widget.isShowDialog) {
          if (isShowingDialog && mounted) {
            Navigator.of(context).pop();
          }
        }
        widget.successFunc(resp);
      }

      if (resp.message == MsgState.more) {
        if (widget.isShowDialog) {
          if (isShowingDialog && mounted) {
            Navigator.of(context).pop();
          }
        }
        if (widget.errorFunc == null) {
          if (widget.showErrSnack && mounted) {
            AppUtils.moreResponse(resp, context);
          }
          if (widget.moreFunc != null) {
            widget.moreFunc!(resp);
          } else if (widget.moreFunc == null) {}
        } else {
          widget.errorFunc!();
        }
      }

      if (resp.message == MsgState.error) {
        if (resp.errState == ErrState.no_login) {
          // Handle no_login case if needed
        }

        if (widget.isShowDialog) {
          if (isShowingDialog && mounted) {
            Navigator.of(context).pop();
          }
        }

        if (widget.errorFunc == null) {
          if (widget.scaffoldState != null && mounted) {
            AppUtils.checkError(context: context, responseOb: resp);
          } else {
            if (widget.showErrSnack && mounted) {
              AppUtils.checkError(context: context, responseOb: resp);
            } else {
              if (resp.errState == ErrState.server_error) {
                AppUtils.showToast(
                  message: "Internal Server Error",
                  isError: true,
                );
              }
              if (resp.errState == ErrState.no_internet) {
                AppUtils.showToast(
                  message: "No Internet connection!",
                  isError: true,
                );
              }
              if (resp.errState == ErrState.not_found) {
                AppUtils.showToast(
                  message: "Your requested data not found!",
                  isError: true,
                );
              }
              if (resp.errState == ErrState.connection_timeout) {
                AppUtils.showToast(
                  message: "Connection Timeout! Try Again",
                  isError: true,
                );
              }
            }
          }
        } else {
          widget.errorFunc!();
          if (widget.showErrSnack && mounted) {
            AppUtils.checkError(context: context, responseOb: resp);
          }
        }

        if (resp.errState == ErrState.validate_err) {
          if (widget.validFunc != null) {
            widget.validFunc!(resp);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResponseOb>(
      initialData: ResponseOb(),
      stream: _bloc.getRequestStream(),
      builder: (context, snapshot) {
        ResponseOb? resp = snapshot.data;
        return mainWidget();
      },
    );
  }

  Widget mainWidget() {
    return TextButton(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: widget.bRadius == null
              ? BorderRadius.circular(widget.borderRadius)
              : widget.bRadius!,
          side: BorderSide(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
        ),
        padding: widget.padding,
        backgroundColor: widget.color,
      ),
      onPressed: widget.isDisable
          ? null
          : () async {
              if (widget.onPress != null) {
                checkDialog();
                if (widget.isAlreadyFormData) {
                  _bloc.postData(
                    widget.url,
                    fd: widget.onPress!(),
                    requestType: widget.requestType,
                    tempId: widget.tempId,
                  );
                } else {
                  if (!widget.changeFormData) {
                    _bloc.postData(
                      widget.url,
                      map: await widget.onPress!(),
                      requestType: widget.requestType,
                      tempId: widget.tempId,
                    );
                  } else {
                    FormData fd = FormData.fromMap(widget.onPress!());
                    _bloc.postData(
                      widget.url,
                      fd: fd,
                      requestType: widget.requestType,
                      tempId: widget.tempId,
                    );
                  }
                }
              } else if (widget.onAsyncPress != null) {
                final a = await widget.onAsyncPress!();
                if (!mounted) return; // Check if widget is still mounted
                if (a != null) {
                  checkDialog();
                  if (widget.requestType == ReqType.get) {
                    _bloc.postData(
                      widget.url,
                      map: a,
                      requestType: widget.requestType,
                      tempId: widget.tempId,
                    );
                  } else {
                    FormData fd = FormData.fromMap(a);
                    _bloc.postData(
                      widget.url,
                      fd: fd,
                      requestType: widget.requestType,
                      tempId: widget.tempId,
                    );
                  }
                }
              }
            },
      child: widget.icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.icon!,
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.text!,
                    style: widget.textStyle ??
                        const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                widget.text!,
                style: widget.textStyle ?? const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  void checkDialog() {
    if (widget.isShowDialog) {
      isShowingDialog = true;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: const CupertinoActivityIndicator(),
              ),
            ],
          );
        },
      ).then((v) {
        isShowingDialog = false;
      });
    }
  }

  @override
  void dispose() {
    _bloc.disponse();
    super.dispose();
  }
}
