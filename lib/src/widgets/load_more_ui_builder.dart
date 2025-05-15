import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_to_ui/src/utils/app_utils.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../bloc/load_more_ui_bloc.dart';
import '../network/dio_base_network.dart';
import '../utils/response_ob.dart';
import '../utils/type_def.dart';
import 'lit_widgets/err_widget.dart';
import 'lit_widgets/more_widget.dart';
import 'lit_widgets/unknown_err_widget.dart';

typedef ChildWidget<T extends Object> = Widget Function(
    T data, RefreshLoad func, bool? isList);

typedef CustomMoreWidget = Widget Function(Map<String, dynamic> data);

class LoadMoreUiBuilder<T extends Object> extends StatefulWidget {
  /// request link ရေးရန်
  String? url;

  /// request body ရေးရန်
  Map<String, dynamic>? map;

  /// listview  နဲ့ ဖော်ပြမယ်ဆိုရင် true, gridview နဲ့ ဖော်ပြမယ်ဆိုရင် false
  bool? isList;

  /// Listview ကို Sliver အနေနဲ့ သုံးချင််ရင် true
  bool isSliver;

  /// RequestType က Get ဒါမှမဟုတ် Post
  ReqType requestType;

  /// HeaderType က ယခု apex project အတွက် သီးသန့်ဖြစ်ပြီး customer, normal,agent ; default က normal

  /// ကိုယ်တိုင် loading widget ရေးချင်တဲ့အချိန်မှာ ထည့်ပေးရန် ; default က widget folder အောက်က LoadingWidget
  Widget? loadingWidget;

  /// girdView အသုံးပြုတဲ့အခါ ဖော်ပြမယ့် gridCount
  int gridCount;

  /// gridChildRatio က gridview ရဲ့ child တွေ size သတ်မှတ်ဖို့ အသုံးပြုပါတယ်
  double gridChildRatio;

  /// successResponse ကို စစ်ရန်
  SuccessCallback? successCallback;

  /// customMoreResponse
  CustomMoreCallback? customMoreCallback;

  /// errorMoreResponse
  CustomErrorCallback? customErrorCallback;

  /// listview or gridview အတွက် children widget ရေးရန်

  ChildWidget<T>? childWidget;

  Widget? scrollHeaderWidget;

  CustomMoreWidget? customMoreWidget;

  Axis scrollDirection = Axis.vertical;

  /// စာမျက်အစမှာ data ရယူချင်ရင် true, မယူချင်ရင် false,  default က true
  bool isFirstLoad;

  /// child widget ကို နှိပ်ရင် အလုပ်လုပ်မယ့် method
  // Function onChildPress;

  bool enablePullUp = false;

  ScrollController? scrollController;

  // Is Cached or not
  bool? isCached;

  //No Data Custom Widget
  Widget? noDataWidget;

  double? mainAxisExt;

  bool isNotShowSnack = false;

  double crossAxisSpacing;
  double mainAxisSpacing;

  LoadMoreUiBuilder.init(
      {required this.url,
      super.key,
      this.scrollController,
      this.childWidget,
      this.isFirstLoad = true,
      this.map,
      this.scrollHeaderWidget,
      this.isList = true,
      this.requestType = ReqType.get,
      this.loadingWidget,
      this.gridCount = 2,
      this.successCallback,
      this.customMoreCallback,
      this.customErrorCallback,
      this.gridChildRatio = 100 / 130,
      // this.onChildPress,
      this.mainAxisExt,
      this.customMoreWidget,
      this.enablePullUp = false,
      this.isCached = false,
      this.isNotShowSnack = false,
      this.noDataWidget,
      this.scrollDirection = Axis.vertical,
      this.crossAxisSpacing = 0,
      this.mainAxisSpacing = 0,
      this.isSliver = false});

  LoadMoreUiBuilder(
      {required this.url,
      super.key,
      this.scrollController,
      this.scrollDirection = Axis.vertical,
      this.childWidget,
      this.isFirstLoad = true,
      this.map,
      this.scrollHeaderWidget,
      this.isList = true,
      this.requestType = ReqType.get,
      this.loadingWidget,
      this.gridCount = 2,
      this.successCallback,
      this.customMoreCallback,
      this.customErrorCallback,
      this.gridChildRatio = 100 / 130,
      // this.onChildPress,
      this.customMoreWidget,
      this.crossAxisSpacing = 0,
      this.mainAxisSpacing = 0,
      this.enablePullUp = false,
      this.isCached = false,
      this.noDataWidget,
      this.isNotShowSnack = false,
      this.isSliver = false});

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
  var pskey = PageStorageKey('page1');

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    return shopWidget(size);
  }

  func(
      {Map<String, dynamic>? map,
      ReqType? requestType = ReqType.get,
      String? newUrl,
      bool? refreshShowLoading = true}) {
    widget.map = map;
    if (widget.isFirstLoad == false) {
      setState(() {
        widget.isFirstLoad = true;
      });
    }

    bloc.getData(newUrl ?? widget.url!,
        map: map,
        requestType: requestType,
        requestShowLoading: refreshShowLoading!,
        isCached: widget.isCached);
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
                            : Center(
                                child: CircularProgressIndicator(),
                              );
                      } else if (rv.message == MsgState.data) {
                        if (rv.pgState == PageState.first) {
                          ois = rv.data;
                        } else {
                          ois.addAll(rv.data);
                        }

                        return SmartRefresher(
                            // reverse: true,
                            physics: BouncingScrollPhysics(),
                            scrollController: widget.scrollController,
                            primary:
                                widget.scrollController == null ? true : false,
                            controller: _rController,
                            footer: CustomFooter(
                              builder: (context, loadStatus) {
                                if (loadStatus == LoadStatus.loading &&
                                    widget.scrollDirection == Axis.vertical) {
                                  return Center(
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
                            // enablePullUp: true,
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
                                          Text(
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
                                      )
                            // mainList(ois)
                            );
                      } else if (rv.message == MsgState.error) {
                        return SingleChildScrollView(
                          child: ErrWidget(
                            errState: rv.errState,
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
                            ? MoreWidget(rv.data)
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
                ? ClampingScrollPhysics()
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
                ? ClampingScrollPhysics()
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
