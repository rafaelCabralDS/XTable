import 'package:flutter/material.dart';
import 'package:x_table/src/theme.dart';
import 'package:x_table/src/builders.dart';
import 'package:x_table/src/table_controller.dart';
import 'package:collection/collection.dart';


class XTableV3<T extends Object> extends StatefulWidget {

  final XTableController<T> controller;
  final List<XTableColumn<T>> columns;
  final void Function(T)? onRowTap;
  final SizedBuilder<T>? actions;
  final Alignment columnsAlignment;

  /// Build a widget before the cells
  final SizedBuilder<T>? prefix;

  final Widget Function(XTableColumn<T> column, bool isHovered)? headerBuilder;

  final Widget Function(T e, bool isHovered, Widget child)? hoverWrapper;
  final bool shrinkWrap;
  final ScrollPhysics physics;

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
    this.shrinkWrap = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
  }) : assert(columns.length > 0);

  @override
  State<XTableV3<T>> createState() => _XTableV3State<T>();
}

class _XTableV3State<T extends Object> extends State<XTableV3<T>> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.attach(widget.columns);
    });
    super.initState();
  }

  List<XTableRow<T>> get rows => widget.controller.paginatedRows;

  @override
  Widget build(BuildContext context) {


    return LayoutBuilder(
      builder: (context, dimens) {

        /// This is meant to solve the row overflow problem
        //var maxWidth = dimens.maxWidth;
        //if (widget.prefix != null) maxWidth -= widget.prefix!.width;
        //if (widget.actions != null) maxWidth -= widget.actions!.width;

        //final flexSum = widget.columns.map((e) => e.flex).reduce((a, b) => a+b);

        return AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {

            if (!widget.controller.isAttached) return XTableTheme.of(context).loadingBuilder;

            return BuildTable<T>(
                columns: widget.columns,
                rows: rows,
                onRowTap: widget.onRowTap,
                onHeaderTap: (e) => widget.controller.sort(e.key),
                shrinkWrap: widget.shrinkWrap,
                physics: widget.physics,
                headerBuilder: widget.headerBuilder,
                hoverWrapper: widget.hoverWrapper,
                prefix: widget.prefix,
                actions: widget.actions,
                columnsAlignment: widget.columnsAlignment,
                sortingUp: widget.controller.sortingUp,
                sortingColumnKey: widget.controller.sortingBy,
            );

          }
        );
      }
    );
  }
}


