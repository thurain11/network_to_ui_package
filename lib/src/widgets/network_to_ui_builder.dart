import 'package:flutter/material.dart';

import '../../network_to_ui.dart';
import '../bloc/network_to_ui_bloc.dart';
import '../utils/type_def.dart';

/// A widget that builds UI based on network data from [NetworkToUiBloc].
/// Supports loading, data, error, and more states with customizable widgets and callbacks.
class NetWorkToUiBuilder<T extends Object> extends StatefulWidget {
  /// The API endpoint URL.
  final String url;

  /// An optional URL suffix to append to [url].
  final String urlId;

  /// Optional query parameters or body data for the network request.
  final Map<String, dynamic>? map;

  /// The type of network request (e.g., GET, POST).
  final ReqType requestType;

  /// The main widget builder for rendering data.
  final MainWidget widget;

  /// An optional widget to display in error state.
  final Widget? errorWidget;

  /// An optional widget to display in loading state.
  final Widget? customLoadingWidget;

  /// Whether to show loading state on initial request.
  final bool isInitLoading;

  /// An optional callback for successful data response.
  final SuccessCallback? successCallback;

  /// An optional callback for "more" state response.
  final CustomMoreCallback? customMoreCallback;

  /// An optional widget builder for "more" state.
  final More? moreWidget;

  /// An optional callback for error response.
  final CustomErrorCallback? customErrorCallback;

  /// Whether to cache the network request.
  final bool isCached;

  const NetWorkToUiBuilder({
    Key? key,
    required this.url,
    required this.widget,
    this.urlId = "",
    this.map,
    this.requestType = ReqType.get,
    this.customLoadingWidget,
    this.isInitLoading = true,
    this.successCallback,
    this.customMoreCallback,
    this.moreWidget,
    this.customErrorCallback,
    this.errorWidget,
    this.isCached = false,
  }) : super(key: key);

  @override
  NetWorkToUiBuilderState createState() => NetWorkToUiBuilderState<T>();
}

/// State class for [NetWorkToUiBuilder], managing the [NetworkToUiBloc] lifecycle and UI rendering.
class NetWorkToUiBuilderState<T> extends State<NetWorkToUiBuilder> {
  late NetworkToUiBloc<T> bloc;

  @override
  void initState() {
    super.initState();

    bloc = NetworkToUiBloc<T>(widget.url + widget.urlId);

    bloc.getData(
      map: widget.map,
      requestType: widget.requestType,
      isCached: widget.isCached,
    );

    bloc.dataStream().listen((rv) {
      if (rv.message == MsgState.data) {
        if (widget.successCallback != null) {
          widget.successCallback!(rv);
        }
      }
      if (rv.message == MsgState.error) {
        if (widget.customErrorCallback != null) {
          widget.customErrorCallback!(rv);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Error"),
              content: Text(rv.data?.toString() ?? "An error occurred"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        });
      }
      if (rv.message == MsgState.more) {
        if (widget.customMoreCallback != null) {
          widget.customMoreCallback!(rv);
        }
      }
    });
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  /// Triggers a data refresh with updated parameters.
  void blocFunc({
    Map<String, dynamic>? map,
    ReqType? requestType = ReqType.get,
    bool? refreshShowLoading = true,
  }) {
    bloc.getData(
      map: map ?? widget.map,
      requestType: requestType ?? widget.requestType,
      requestShowLoading: refreshShowLoading!,
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<ResponseOb>(
      stream: bloc.dataStream(),
      initialData: ResponseOb(data: null, message: MsgState.loading),
      builder: (context, AsyncSnapshot<ResponseOb> snap) {
        ResponseOb rv = snap.data!;
        if (rv.message == MsgState.loading) {
          return widget.customLoadingWidget ??
              const Center(child: CircularProgressIndicator());
        } else if (rv.message == MsgState.data) {
          T? data;
          if (rv.data is T) {
            data = rv.data as T?;
          } else {
            data = null;
          }
          return widget.widget(data, blocFunc);
        } else if (rv.message == MsgState.error) {
          return widget.errorWidget ?? Text("Error: ${rv.data}");
        } else if (rv.message == MsgState.more) {
          if (widget.moreWidget != null) {
            return widget.moreWidget!(rv.data, blocFunc);
          }
          return Text("More: ${rv.data}");
        }
        return const Text("Unknown state");
      },
    );
  }
}
