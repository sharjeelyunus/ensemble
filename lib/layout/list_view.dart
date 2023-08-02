import 'package:ensemble/framework/action.dart';
import 'package:ensemble/framework/event.dart';
import 'package:ensemble/framework/widget/widget.dart';
import 'package:ensemble/layout/box/base_box_layout.dart';
import 'package:ensemble/layout/box/box_layout.dart';
import 'package:ensemble/layout/templated.dart';
import 'package:ensemble/page_model.dart';
import 'package:ensemble/util/utils.dart';
import 'package:ensemble/framework/theme/theme_manager.dart';
import 'package:ensemble/widget/helpers/widgets.dart';
import 'package:ensemble_ts_interpreter/invokables/invokable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:ensemble/screen_controller.dart';

class ListView extends StatefulWidget
    with
        UpdatableContainer,
        Invokable,
        HasController<ListViewController, BoxLayoutState> {
  static const type = 'ListView';
  ListView({Key? key}) : super(key: key);

  final ListViewController _controller = ListViewController();
  @override
  ListViewController get controller => _controller;

  @override
  Map<String, Function> getters() {
    return {
      'selectedItemIndex': () => _controller.selectedItemIndex,
    };
  }

  @override
  Map<String, Function> setters() {
    return {
      'onSwipeToRefresh': (funcDefinition) => _controller.onSwipeToRefresh =
          EnsembleAction.fromYaml(funcDefinition, initiator: this),
      'onItemTap': (funcDefinition) => _controller.onItemTap =
          EnsembleAction.fromYaml(funcDefinition, initiator: this),
      'showSeparator': (value) =>
          _controller.showSeparator = Utils.optionalBool(value),
      'separatorColor': (value) =>
          _controller.separatorColor = Utils.getColor(value),
      'separatorWidth': (value) =>
          _controller.separatorWidth = Utils.optionalDouble(value),
      'separatorPadding': (value) =>
          _controller.separatorPadding = Utils.optionalInsets(value),
    };
  }

  @override
  Map<String, Function> methods() {
    return {};
  }

  @override
  void initChildren({List<Widget>? children, ItemTemplate? itemTemplate}) {
    _controller.children = children;
    _controller.itemTemplate = itemTemplate;
  }

  @override
  State<StatefulWidget> createState() => ListViewState();
}

class ListViewController extends BoxLayoutController {
  EnsembleAction? onItemTap;
  EnsembleAction? onSwipeToRefresh;
  int selectedItemIndex = -1;

  bool? showSeparator;
  Color? separatorColor;
  double? separatorWidth;
  EdgeInsets? separatorPadding;
}

class ListViewState extends WidgetState<ListView> with TemplatedWidgetState {
  // template item is created on scroll. this will store the template's data list
  List<dynamic>? templatedDataList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget._controller.itemTemplate != null) {
      // initial value maybe set before the screen rendered
      templatedDataList = widget._controller.itemTemplate!.initialValue;

      registerItemTemplate(context, widget._controller.itemTemplate!,
          evaluateInitialValue: true, onDataChanged: (List dataList) {
        setState(() {
          templatedDataList = dataList;
        });
      });
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    // children displayed first, followed by item template
    int itemCount = (widget._controller.children?.length ?? 0) +
        (templatedDataList?.length ?? 0);
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    Widget listView = flutter.ListView.separated(
        padding: widget._controller.padding ?? const EdgeInsets.all(0),
        scrollDirection: Axis.vertical,
        physics: const ScrollPhysics(),
        itemCount: itemCount,
        shrinkWrap: false,
        itemBuilder: (BuildContext context, int index) {
          // show children
          Widget? itemWidget;
          if (widget._controller.children != null &&
              index < widget._controller.children!.length) {
            itemWidget = widget._controller.children![index];
          }
          // create widget from item template
          else if (templatedDataList != null &&
              widget._controller.itemTemplate != null) {
            itemWidget = buildWidgetForIndex(
                context,
                templatedDataList!,
                widget._controller.itemTemplate!,
                // templated widget should start at 0, need to offset chidlren length
                index - (widget._controller.children?.length ?? 0));
          }
          if (itemWidget != null) {
            return widget._controller.onItemTap == null
                ? itemWidget
                : flutter.InkWell(
                    onTap: () => _onItemTapped(index), child: itemWidget);
          }
          return const SizedBox.shrink();
        },
        separatorBuilder: (context, index) =>
            widget._controller.showSeparator == false
                ? const SizedBox.shrink()
                : flutter.Padding(
                    padding: widget._controller.separatorPadding ??
                        const EdgeInsets.all(0),
                    child: flutter.Divider(
                        color: widget._controller.separatorColor,
                        thickness:
                            widget._controller.separatorWidth?.toDouble())));

    if (widget._controller.onSwipeToRefresh != null) {
      final tempList = listView;
      listView = flutter.RefreshIndicator(
        onRefresh: _swipeToRefresh,
        child: tempList,
      );
    }

    return BoxWrapper(
        boxController: widget._controller,
        widget: DefaultTextStyle.merge(
            style: TextStyle(
                fontFamily: widget._controller.fontFamily,
                fontSize: widget._controller.fontSize?.toDouble()),
            child: listView));
  }

  Future<void> _swipeToRefresh() async {
    if (widget._controller.onSwipeToRefresh != null) {
      ScreenController()
          .executeAction(context, widget._controller.onSwipeToRefresh!);
    }
  }

  void _onItemTapped(int index) {
    if (index != widget._controller.selectedItemIndex &&
        widget._controller.onItemTap != null) {
      widget._controller.selectedItemIndex = index;
      //log("Changed to index $index");
      ScreenController().executeAction(context, widget._controller.onItemTap!);
      print(
          "The Selected index in data array of ListView is ${widget._controller.selectedItemIndex}");
    }
  }
}
