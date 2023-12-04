import 'package:flutter/material.dart';
import 'package:x_table/src/theme.dart';
import 'package:x_table/src/table_controller.dart';
import 'package:collection/collection.dart';

typedef ElementWidgetBuilder<T extends Object> = Widget Function(BuildContext context,T e,bool isHovered);

class SizedBuilder<T extends Object> {

  final double width;
  final ElementWidgetBuilder<T> builder;

  const SizedBuilder({
    required this.width,
    required this.builder
  });

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

class BuildTable<T extends Object> extends StatelessWidget {

  final void Function(T)? onRowTap;
  final SizedBuilder<T>? actions;
  final Alignment columnsAlignment;
  final List<XTableColumn<T>> columns;
  final List<XTableRow<T>> rows;
  final String? sortingColumnKey;
  final bool sortingUp;
  final dynamic Function(XTableColumn<T> header)? onHeaderTap;

  /// Build a widget before the cells
  final SizedBuilder<T>? prefix;

  final Widget Function(XTableColumn<T> column, bool isHovered)? headerBuilder;

  final Widget Function(T e, bool isHovered, Widget child)? hoverWrapper;

  final bool shrinkWrap;
  final ScrollPhysics physics;
  final bool primary;

  const BuildTable({super.key,
    this.onRowTap,
    this.actions,
    this.columnsAlignment = Alignment.centerLeft,
    required this.columns,
    required this.rows,
    this.prefix,
    this.headerBuilder,
    this.hoverWrapper,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.shrinkWrap = false,
    this.onHeaderTap,
    this.sortingUp = true,
    this.sortingColumnKey,
    this.primary = true,
  });

  Widget _rowsBuilder() => Builder(
    builder: (context) {
      var style = XTableTheme.of(context);
      return ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: physics,
        primary: primary,
        itemBuilder: (_, i) => Builder(builder: (context) {
          var isHovered = false;
          return StatefulBuilder(builder: (context, setState) {
            var rowData = rows[i];

            final row = Row(
              children: [
                if (prefix != null) SizedBox(
                    width: prefix!.width,
                    child: Center(child: prefix!.builder(context, rowData.e, isHovered))
                ),

                ...rowData.cells.mapIndexed((i,cell) {
                  var column = columns[i];

                  return Expanded(
                      flex: column.flex,
                      child: Align(
                        alignment: column.alignment ?? columnsAlignment,
                        child: cell.cellBuilder(rowData.e, isHovered),
                      )
                  );

                }),
                if (actions != null)
                  SizedBox(
                    width: actions!.width,
                    child: Center(child: actions!.builder.call(context, rowData.e, isHovered)),
                  )

              ],
            );

            return InkWell(
              onTap: onRowTap != null ? () => onRowTap?.call(rowData.e) : null,
              onHover: (hovered) => setState(() => isHovered = hovered),
              hoverColor: (style.hoverColor ?? Theme.of(context).hoverColor),
              child: Container(
                height: style.rowHeight,
                color: i % 2 == 0 ? (style.rowAlternateColor ?? style.rowColor) : style.rowColor,
                padding: style.horizontalPadding,
                child: hoverWrapper?.call(rowData.e, isHovered, row) ?? row,
              ),
            );
          });
        }),
        separatorBuilder: (_, __) => style.divider,
        itemCount: rows.length,
      );
    }
  );

  @override
  Widget build(BuildContext context) {
    var style = XTableTheme.of(context);

    return Column(
      children: [

        ///Header
        Container(
            height: style.headerHeight,
            decoration: const BoxDecoration().copyWith(
                color: style.headerDecoration?.color ?? style.headerColor,
                shape: style.headerDecoration?.shape,
                borderRadius: style.headerDecoration?.borderRadius,
                boxShadow: style.headerDecoration?.boxShadow,
                gradient: style.headerDecoration?.gradient
            ),
            padding: style.horizontalPadding,
            child: Row(
                children: [
                  if (prefix != null) SizedBox(width: prefix!.width),

                  ...columns.map((e) => Builder(builder: (context) {
                    var isHeaderHovered = false;
                    return StatefulBuilder(builder: (context, setState) {
                      var headerTextStyle = (style.headerTextStyle ?? Theme.of(context).textTheme.titleSmall)?.copyWith(
                        color: isHeaderHovered ? style.headerHoverTextColor : style.headerTextColor,
                      );

                      return Expanded(
                        flex: e.flex,
                        child: IgnorePointer(
                          ignoring: e.compare == null,
                          child: InkWell(
                            onTap: () => onHeaderTap!.call(e),
                            onHover: (h) => setState(() => isHeaderHovered = h),
                            child: Align(
                              alignment: e.alignment ?? columnsAlignment,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  headerBuilder?.call(e, isHeaderHovered) ?? Text(e.name ?? e.key, style: headerTextStyle),

                                  if (e.key == sortingColumnKey)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                          sortingUp ? style.sortUpIcon?.icon : style.sortDownIcon?.icon,
                                          color: isHeaderHovered ? style.headerHoverTextColor : style.headerTextColor,
                                          size:  style.sortUpIcon?.size ?? style.sortDownIcon?.size ?? 18,
                                      )
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  })),
                  if (actions != null) SizedBox(width: actions!.width)
                ]
            )
        ),

        if (shrinkWrap)
          rows.isNotEmpty ? _rowsBuilder() : style.emptyBuilder
        else
          Expanded(child:  rows.isNotEmpty ? _rowsBuilder() : style.emptyBuilder)

      ],
    );
  }
}


