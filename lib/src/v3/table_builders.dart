import 'package:flutter/material.dart';
import 'package:x_table/src/theme.dart';
import 'package:x_table/src/v3/table_controller.dart';
import 'package:collection/collection.dart';

typedef ElementWidgetBuilder<T> = Widget Function(BuildContext context,T e,bool isHovered);
typedef RowActionsBuilder<T> = ({double width, ElementWidgetBuilder builder});
typedef PrefixBuilder<T> = ({double width, ElementWidgetBuilder builder});

class XTableV3<T> extends StatefulWidget {

  final XTableController<T> controller;
  final List<XTableColumn<T>> columns;
  final void Function(T)? onRowTap;
  final RowActionsBuilder<T>? actions;
  final Alignment columnsAlignment;

  /// Build a widget before the cells
  final PrefixBuilder? prefix;

  final Widget Function(XTableColumn column, bool isHovered)? headerBuilder;

  final Widget Function(T e, bool isHovered, Widget child)? hoverWrapper;

  const XTableV3({
    super.key,
    required this.controller,
    required this.columns,
    this.onRowTap,
    this.actions,
    this.prefix,
    this.headerBuilder,
    this.hoverWrapper,
    this.columnsAlignment = Alignment.centerLeft,
  }) : assert(columns.length > 0);

  @override
  State<XTableV3<T>> createState() => _XTableV3State<T>();
}

class _XTableV3State<T> extends State<XTableV3<T>> {

  @override
  void initState() {
    widget.controller.attach(widget.columns);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var style = XTableTheme.of(context);

    return LayoutBuilder(
      builder: (context, dimens) {

        /// This is meant to solve the row overflow problem
        var maxWidth = dimens.maxWidth;
        if (widget.prefix != null) maxWidth -= widget.prefix!.width;
        if (widget.actions != null) maxWidth -= widget.actions!.width;

        final flexSum = widget.columns.map((e) => e.flex).reduce((a, b) => a+b);

        return AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {
            return Column(
              children: [

                ///Header
                SizedBox(
                    height: style.headerHeight,
                    child: Row(
                        children: [
                          if (widget.prefix != null) SizedBox(width: widget.prefix!.width),

                          ...widget.columns.map((e) => Builder(builder: (context) {
                            var isHeaderHovered = false;
                            return StatefulBuilder(builder: (context, setState) {
                              var headerTextStyle = (style.headerTextStyle ?? Theme.of(context).textTheme.titleSmall)?.copyWith(
                                color: isHeaderHovered ? style.headerHoverTextColor : style.headerTextColor,
                              );

                              return SizedBox(
                                width: maxWidth* (e.flex/flexSum),
                                child: IgnorePointer(
                                  ignoring: e.compare == null,
                                  child: InkWell(
                                    onTap: () => widget.controller.sort(e.key),
                                    onHover: (h) => setState(() => isHeaderHovered = h),
                                    child: Align(
                                      alignment: e.alignment ?? widget.columnsAlignment,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          widget.headerBuilder?.call(e, isHeaderHovered) ?? Text(e.name ?? e.key, style: headerTextStyle),

                                          if (e.key == widget.controller.sortingBy)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Icon((widget.controller.sortingUp ? style.sortUpIcon : style.sortDownIcon).icon,
                                                  size: 18,
                                                  color: isHeaderHovered ? style.headerHoverTextColor : style.headerTextColor),
                                            ),

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          })),
                          if (widget.actions != null) SizedBox(width: widget.actions!.width)
                        ]
                    )
                ),

                if (widget.controller.paginatedRows.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (_, i) => Builder(builder: (context) {
                        var isHovered = false;
                        return StatefulBuilder(builder: (context, setState) {
                          var rowData = widget.controller.paginatedRows[i];

                          final row = Row(
                            children: [
                              if (widget.prefix != null) SizedBox(
                                  width: widget.prefix!.width,
                                  child: Center(child: widget.prefix!.builder(context, rowData.e, isHovered))
                              ),

                              ...rowData.cells.mapIndexed((i,cell) {
                                var column = widget.controller.columns[i];
                                return SizedBox(
                                    width: maxWidth*column.flex/flexSum,
                                    child: Align(
                                      alignment: column.alignment ?? widget.columnsAlignment,
                                      child: cell.cellBuilder(rowData.e, isHovered),
                                    )
                                );

                              }),
                              if (widget.actions != null)
                                SizedBox(
                                  width: widget.actions!.width,
                                 child: Center(child: widget.actions!.builder.call(context, rowData.e, isHovered)),
                                )

                            ],
                          );

                          return InkWell(
                            onTap: () => widget.onRowTap?.call(rowData.e),
                            onHover: (hovered) => setState(() => isHovered = hovered),
                            hoverColor: (style.hoverColor ?? Theme.of(context).hoverColor),
                            child: SizedBox(
                              height: style.rowHeight,
                              child: widget.hoverWrapper?.call(rowData.e, isHovered, row) ?? row,
                            ),
                          );
                        });
                      }),
                      separatorBuilder: (_, __) => style.divider,
                      itemCount: widget.controller.paginatedRows.length,
                    ),
                  )
                else
                  Expanded(child: style.emptyBuilder)
              ],
            );
          }
        );
      }
    );
  }
}


Widget defaultColumnTextBuilder(String value, bool isHovered) => Builder(
  builder: (context) {
    var theme = XTableTheme.of(context);
    return  Text(value, style: theme.itemTextStyle?.copyWith(color: isHovered ? theme.itemHoverTextColor : null));
  }
);

class ElevatedHoverWrapperBuilder extends StatelessWidget {

  final bool isHovered;
  final Widget child;
  final Color backgroundColor;
  final Color shadowColor;
  final BorderRadius borderRadius;

  const ElevatedHoverWrapperBuilder({
    super.key,
    required this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    Color? shadowColor,
    required this.isHovered,
    required this.child,
  }) : shadowColor = shadowColor ?? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: isHovered ? backgroundColor : null,
          boxShadow: isHovered ? [BoxShadow(color: shadowColor.withOpacity(0.3), blurRadius: 25, spreadRadius: 0, offset: const Offset(0, 8))] : null),
      child: child,
    );
  }
}

