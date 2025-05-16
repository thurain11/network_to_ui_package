import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_to_ui/src/utils/app_utils.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../bloc/load_more_ui_bloc.dart';
import '../network/dio_base_network.dart';
import '../utils/response_ob.dart';
import '../utils/type_def.dart';
import 'lit_widgets/err_widget.dart';
import 'lit_widgets/unknown_err_widget.dart';

typedef ChildWidget<T extends Object> = Widget Function(
    T data, RefreshLoad func, bool? isList);

typedef CustomMoreWidget = Widget Function(Map<String, dynamic> data);

class LoadMoreUiBuilder<T extends Object> extends StatefulWidget {
  final String? url; // Made final
  Map<String, dynamic> map; // Made final
  final bool? isList; // Made final
  final bool isSliver; // Made final
  final ReqType requestType; // Made final
  final Widget? loadingWidget; // Made final
  final int gridCount; // Made final
  final double gridChildRatio; // Made final
  final SuccessCallback? successCallback; // Made final
  final CustomMoreCallback? customMoreCallback; // Made final
  final CustomErrorCallback? customErrorCallback; // Made final
  final ChildWidget<T>? childWidget; // Made final
  final Widget? scrollHeaderWidget; // Made final
  final CustomMoreWidget? customMoreWidget; // Made final
  final Axis scrollDirection; // Made final
  bool isFirstLoad; // Made final
  final bool enablePullUp; // Made final
  final ScrollController? scrollController; // Made final
  final bool? isCached; // Made final
  final Widget? noDataWidget; // Made final
  final double? mainAxisExt; // Made final
  final bool isNotShowSnack; // Made final
  final double crossAxisSpacing; // Made final
  final double mainAxisSpacing; // Made final

  LoadMoreUiBuilder.init({
    required this.url,
    super.key,
    this.scrollController,
    this.childWidget,
    this.isFirstLoad = true,
    this.map = const {},
    this.scrollHeaderWidget,
    this.isList = true,
    this.requestType = ReqType.get,
    this.loadingWidget,
    this.gridCount = 2,
    this.successCallback,
    this.customMoreCallback,
    this.customErrorCallback,
    this.gridChildRatio = 100 / 130,
    this.mainAxisExt,
    this.customMoreWidget,
    this.enablePullUp = false,
    this.isCached = false,
    this.isNotShowSnack = false,
    this.noDataWidget,
    this.scrollDirection = Axis.vertical,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.isSliver = false,
  });

  LoadMoreUiBuilder({
    required this.url,
    super.key,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.childWidget,
    this.isFirstLoad = true,
    this.map = const {},
    this.scrollHeaderWidget,
    this.isList = true,
    this.requestType = ReqType.get,
    this.loadingWidget,
    this.gridCount = 2,
    this.successCallback,
    this.customMoreCallback,
    this.customErrorCallback,
    this.gridChildRatio = 100 / 130,
    this.customMoreWidget,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.enablePullUp = false,
    this.isCached = false,
    this.noDataWidget,
    this.isNotShowSnack = false,
    this.isSliver = false,
    this.mainAxisExt,
  });

  @override
  LoadMoreUiBuilderState<T> createState() {
    return LoadMoreUiBuilderState<T>();
  }
}

class LoadMoreUiBuilderState<T> extends State<LoadMoreUiBuilder>
    with AutomaticKeepAliveClientMixin {
  late LoadMoreUiBloc<T> bloc;
  List<T> ois = [];

  late RefreshController _rController;

  PageStorageBucket bucket = PageStorageBucket();
  var pskey = const PageStorageKey('page1');

  @override
  void initState() {
    super.initState();
    bloc = LoadMoreUiBloc<T>();
    _rController = RefreshController();

    if (widget.isFirstLoad) {
      bloc.getData(widget.url!,
          map: widget.map,
          requestType: widget.requestType,
          isCached: widget.isCached);
    }

    bloc.shopStream().listen((rv) {
      if (rv.pgState != null) {
        if (rv.pgState == PageState.first) {
          _rController.refreshCompleted();
          _rController.resetNoData();
          _rController.loadComplete();
        } else {
          if (rv.message == MsgState.data) {
            if (rv.pgState == PageState.no_more) {
              _rController.loadNoData();
            } else {
              _rController.loadComplete();
            }
          }
        }
      }
      if (rv.message == MsgState.data) {
        if (widget.successCallback != null) {
          widget.successCallback!(rv);
        }
      }
      if (rv.message == MsgState.error) {
        if (widget.customErrorCallback != null) {
          widget.customErrorCallback!(rv);
        }
      }
      if (rv.message == MsgState.more) {
        if (widget.isNotShowSnack) {
        } else {
          if (widget.customMoreCallback != null) {
            Map<String, dynamic> map = rv.data;

            //:TODO toast message ပြရန်
            AppUtils.showToast(message: map['message'].toString());
            // ToastHelper.showSuccessToast(
            //     title:  map['message'].toString(),
            //     context: context
            // );
          }
        }
      }
    });
  }

  final pullUpSty = TextStyle(fontSize: 15, color: Colors.grey.shade400);

  func({
    Map<String, dynamic>? map,
    ReqType? requestType = ReqType.get,
    String? newUrl,
    bool? refreshShowLoading = true,
  }) {
    if (map != null) {
      setState(() {
        widget.map = map; // Warning: Modifying widget state
      });
    }
    if (widget.isFirstLoad == false) {
      setState(() {
        widget.isFirstLoad = true; // Warning: Modifying widget state
      });
    }

    bloc.getData(newUrl ?? widget.url!,
        map: map ?? widget.map,
        requestType: requestType,
        requestShowLoading: refreshShowLoading!,
        isCached: widget.isCached);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    return shopWidget(size);
  }

  Widget shopWidget(Size size) {
    return Column(
      children: [
        !widget.isFirstLoad
            ? Container()
            : Expanded(
                child: StreamBuilder<ResponseOb>(
                    stream: bloc.shopStream(),
                    initialData:
                        ResponseOb(data: null, message: MsgState.loading),
                    builder: (context, AsyncSnapshot<ResponseOb> snap) {
                      ResponseOb rv = snap.data!;
                      if (rv.message == MsgState.loading) {
                        return widget.loadingWidget != null
                            ? widget.loadingWidget!
                            : const Center(
                                child: CircularProgressIndicator(),
                              );
                      } else if (rv.message == MsgState.data) {
                        if (rv.pgState == PageState.first) {
                          ois = rv.data;
                        } else {
                          ois.addAll(rv.data);
                        }

                        return SmartRefresher(
                            physics: const BouncingScrollPhysics(),
                            scrollController: widget.scrollController,
                            primary:
                                widget.scrollController == null ? true : false,
                            controller: _rController,
                            footer: CustomFooter(
                              builder: (context, loadStatus) {
                                if (loadStatus == LoadStatus.loading &&
                                    widget.scrollDirection == Axis.vertical) {
                                  return const Center(
                                      child: CupertinoActivityIndicator());
                                } else if (loadStatus == LoadStatus.failed) {
                                  return Center(
                                      child:
                                          Text("Load fail!", style: pullUpSty));
                                } else if (loadStatus ==
                                    LoadStatus.canLoading) {
                                  return Center(
                                      child: Text('Release to load more',
                                          style: pullUpSty));
                                } else if (loadStatus == LoadStatus.idle) {
                                  return Center(
                                      child: Text('Pull up to load',
                                          style: pullUpSty));
                                } else {
                                  if (widget.scrollDirection == Axis.vertical) {
                                    return Center(
                                        child: Text('No more data',
                                            style: pullUpSty));
                                  }
                                  return Container();
                                }
                              },
                            ),
                            enablePullUp: widget.enablePullUp
                                ? widget.enablePullUp
                                : ois.length > 9,
                            onRefresh: () {
                              bloc.getData(widget.url!,
                                  map: widget.map,
                                  requestType: widget.requestType,
                                  isCached: widget.isCached);
                            },
                            onLoading: () {
                              bloc.getLoad(widget.url, widget.map,
                                  requestType: widget.requestType,
                                  isCached: widget.isCached);
                            },
                            child: ois.isEmpty
                                ? widget.noDataWidget == null
                                    ? ListView(
                                        children: <Widget>[
                                          SizedBox(
                                            height: size.height * 0.20,
                                          ),
                                          const Text(
                                            "No Data",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(child: widget.noDataWidget)
                                : widget.scrollHeaderWidget == null
                                    ? widget.isSliver
                                        ? sliverWidget(ois)
                                        : mainList(ois)
                                    : SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            widget.scrollHeaderWidget!,
                                            mainList(ois)
                                          ],
                                        ),
                                      ));
                      } else if (rv.message == MsgState.error) {
                        return SingleChildScrollView(
                          child: ErrWidget(
                            errState: rv.errState ?? ErrState.unknownError,
                            func: () {
                              bloc.getData(
                                widget.url!,
                                map: widget.map,
                                requestType: widget.requestType,
                              );
                            },
                          ),
                        );
                      } else if (rv.message == MsgState.more) {
                        return widget.customMoreWidget == null
                            ? const SizedBox(
                                height: 40,
                                child: Text("No more data found"),
                              )
                            : widget.customMoreWidget!(rv.data);
                      } else {
                        return UnknownErrWidget(
                          fun: () {
                            bloc.getData(
                              widget.url!,
                              map: widget.map,
                              requestType: widget.requestType,
                            );
                          },
                        );
                      }
                    }),
              ),
      ],
    );
  }

  Widget mainList(List<T>? ois) {
    return widget.isList!
        ? ListView.builder(
            key: pskey,
            scrollDirection: widget.scrollDirection,
            shrinkWrap: widget.scrollHeaderWidget != null ? true : false,
            physics: widget.scrollHeaderWidget != null
                ? const ClampingScrollPhysics()
                : null,
            itemBuilder: (context, index) {
              T data = ois[index];

              return widget.childWidget!(data!, func, widget.isList);
            },
            itemCount: ois!.length,
          )
        : GridView.builder(
            shrinkWrap: widget.scrollHeaderWidget != null ? true : false,
            physics: widget.scrollHeaderWidget != null
                ? const ClampingScrollPhysics()
                : null,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: widget.crossAxisSpacing,
                mainAxisSpacing: widget.mainAxisSpacing,
                crossAxisCount: widget.gridCount,
                childAspectRatio: widget.gridChildRatio),
            itemBuilder: (context, index) {
              return widget.childWidget!(ois[index]!, func, widget.isList);
            },
            itemCount: ois!.length,
          );
  }

  Widget sliverWidget(List<T>? ois) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              T data = ois[index];
              return widget.childWidget!(data!, func, widget.isList);
            },
            childCount: ois!.length,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
