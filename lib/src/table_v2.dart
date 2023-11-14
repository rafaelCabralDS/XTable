import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:x_table/src/theme.dart';

import 'builders.dart';


class TableColumn<T> {

  final String name;
  final String key;
  final int flex;
  final Alignment alignment;
  final Widget Function(T e, bool isHovered) builder;
  final bool sortable;

  const TableColumn({
    required this.name,
    required this.key,
    required this.builder,
    this.flex = 1,
    this.alignment = Alignment.center,
    this.sortable = false,
  });


  TableColumn.text({
    required this.name,
    required this.key,
    required String Function(T e) value,
    this.flex = 1,
    this.alignment = Alignment.center,
    this.sortable = false,
  }) : builder = ((T e, bool isHovered) => defaultColumnTextBuilder(value(e), isHovered));

}




typedef RowActionsBuilder<T> = ({double width, Widget Function(BuildContext context,T e,bool isHovered) child});

class XTable2<T> extends StatefulWidget {

  final List<T> data;
  final List<TableColumn<T>> columns;
  final void Function(T e) onTap;
  final void Function(String, bool upwards)? onSort;

  /// Build actions/widgets without the need to have a header
  final RowActionsBuilder<T>? actions;


  /// Build a widget before the cells
  final Widget Function(T e, bool isHovered)? prefix;

  final Widget Function(String name, bool isHovered)? headerBuilder;

  final Widget Function(T e, bool isHovered, Widget child)? hoverWrapper;

  const XTable2({
    super.key,
    required this.data,
    required this.columns,
    required this.onTap,
    this.onSort,
    this.headerBuilder,
    this.hoverWrapper,
    this.actions,
    this.prefix,
  });

  @override
  State<XTable2<T>> createState() => _XTable2State<T>();

}

class _XTable2State<T> extends State<XTable2<T>> {

  String? sortingBy;
  bool sortingUp = true;


  void sort(String? value) {

    if (value == sortingBy) {
      sortingUp = !sortingUp;
    }

    if (value == null) {
      sortingBy = widget.columns.firstWhereOrNull((element) => element.sortable)?.name;
      if (sortingBy == null) return; // no sorting available
    } else {
      sortingBy = widget.columns.singleWhere((element) => element.name == value).name;
    }

    if (widget.onSort != null) {
      widget.onSort!(sortingBy!, sortingUp);
    }
    if (mounted) setState(() {});
  }


  @override
  void initState() {
    sortingBy = widget.columns.firstWhereOrNull((element) => element.sortable)?.name;
    //WidgetsBinding.instance.addPostFrameCallback((_){
    //  sort(null);
    //});
    super.initState();
  }

  @override
  void didUpdateWidget(covariant XTable2<T> oldWidget) {

    //if ({...oldWidget.data}.difference({...widget.data}).isNotEmpty) {
    //    setState(() {});
    //}

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var style = XTableTheme.of(context);

    return Column(
      children: [

        ///Header
        SizedBox(
            height: style.headerHeight,
            child: Row(
                children: [
                  ...widget.columns.map((e) => Builder(builder: (context) {
                          var isHeaderHovered = false;
                          return StatefulBuilder(builder: (context, setState) {
                            var headerTextStyle = (style.headerTextStyle ?? Theme.of(context).textTheme.titleSmall)?.copyWith(
                              color: isHeaderHovered ? style.headerHoverTextColor : style.headerTextColor,
                            );

                            return Expanded(
                              flex: e.flex,
                              child: IgnorePointer(
                                ignoring: widget.onSort == null || !e.sortable,
                                child: InkWell(
                                  onTap: () => sort(e.name),
                                  onHover: (h) => setState(() => isHeaderHovered = h),
                                  child: Align(
                                      alignment: e.alignment,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          widget.headerBuilder?.call(e.name, isHeaderHovered) ?? Text(e.name, style: headerTextStyle),

                                          if (e.name == sortingBy)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Icon((sortingUp ? style.sortUpIcon : style.sortDownIcon).icon,
                                                size: 18,
                                                color: isHeaderHovered ? style.headerHoverTextColor : style.headerTextColor),
                                          ),

                                      ],
                                    )),
                                ),
                              ),
                            );
                          });
                        })),
                  if (widget.actions != null) SizedBox(width: widget.actions!.width)
                ]
                    )
        ),

        if (widget.data.isNotEmpty)
          Expanded(
            child: ListView.separated(
              itemBuilder: (_, i) => Builder(builder: (context) {
                var isHovered = false;
                return StatefulBuilder(builder: (context, setState) {
                  final row = Row(
                    children: [
                      if (widget.prefix != null) widget.prefix!.call(widget.data[i], isHovered),
                      ...widget.columns.map((e) => Expanded(flex: e.flex, child: Align(alignment: e.alignment, child: e.builder(widget.data[i], isHovered)))),
                      if (widget.actions != null)
                        SizedBox(
                            width: widget.actions!.width,
                            child: widget.actions!.child.call(context, widget.data[i], isHovered),
                        )

                    ],
                  );

                  return InkWell(
                    onTap: () => widget.onTap(widget.data[i]),
                    onHover: (hovered) => setState(() => isHovered = hovered),
                    hoverColor: widget.hoverWrapper != null ? Colors.transparent : (style.hoverColor ?? Theme.of(context).hoverColor),
                    child: SizedBox(
                      height: style.rowHeight,
                      child: widget.hoverWrapper?.call(widget.data[i], isHovered, row) ?? row,
                    ),
                  );
                });
              }),
              separatorBuilder: (_, __) => style.divider,
              itemCount: widget.data.length,
            ),
          )
        else
          Expanded(child: style.emptyBuilder)
      ],
    );
  }
}
