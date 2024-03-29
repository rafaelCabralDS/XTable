import 'package:flutter/material.dart';
import 'package:x_table/src/theme.dart';
import 'package:x_table/src/builders.dart';
import 'package:x_table/src/table_controller.dart';
import 'package:collection/collection.dart';
import 'package:x_table/src/utils.dart';

class StaticXTable<T extends Object> extends StatefulWidget {
  final List<XTableColumn<T>> columns;
  final List<T> source;
  final void Function(T)? onRowTap;
  final SizedBuilder<T>? actions;
  final Alignment columnsAlignment;

  /// Build a widget before the cells
  final SizedBuilder<T>? prefix;

  final Widget Function(XTableColumn<T> column, bool isHovered)? headerBuilder;

  final Widget Function(T e, bool isHovered, Widget child)? hoverWrapper;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final bool primary;

  const StaticXTable({
    super.key,
    required this.source,
    required this.columns,
    this.onRowTap,
    this.actions,
    this.prefix,
    this.headerBuilder,
    this.hoverWrapper,
    this.columnsAlignment = Alignment.centerLeft,
    this.shrinkWrap = false,
    this.primary = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  @override
  State<StaticXTable<T>> createState() => _StaticXTableState<T>();
}

class _StaticXTableState<T extends Object> extends State<StaticXTable<T>> {
  late final XTableController<T> controller;

  @override
  void initState() {
    controller = XTableController<T>(source: widget.source);
    controller.attach(widget.columns);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StaticXTable<T> oldWidget) {
    if (!const DeepCollectionEquality.unordered().equals(widget.source, oldWidget.source)) {
      controller.set(widget.source);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BuildTable<T>(
      columns: widget.columns,
      rows: controller.paginatedRows,
      onRowTap: widget.onRowTap,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      prefix: widget.prefix,
      actions: widget.actions,
      onHeaderTap: (e) => e.compare != null ? controller.sort(e.key) : null,
      sortingColumnKey: controller.sortingBy,
      sortingUp: controller.sortingUp,
      hoverWrapper: widget.hoverWrapper,
      headerBuilder: widget.headerBuilder,
      columnsAlignment: widget.columnsAlignment,
      primary: widget.primary,
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

class JsonStaticXTable extends StatelessWidget {
  final List<Map<String, dynamic>> source;
  final void Function(Map<String, dynamic>)? onRowTap;
  final SizedBuilder<Map<String, dynamic>>? actions;
  final Alignment columnsAlignment;
  final SizedBuilder<Map<String, dynamic>>? prefix;

  final Widget Function(XTableColumn<Map<String, dynamic>> column, bool isHovered)? headerBuilder;

  final Widget Function(Map<String, dynamic> e, bool isHovered, Widget child)? hoverWrapper;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  const JsonStaticXTable({
      super.key,
      required this.source,
      this.onRowTap,
      this.actions,
      this.columnsAlignment = Alignment.centerLeft,
      this.prefix,
      this.headerBuilder,
      this.hoverWrapper,
      this.shrinkWrap = false,
      this.physics = const AlwaysScrollableScrollPhysics()
  });

  List<XTableColumn<Map<String, dynamic>>> parseColumns() {
    var template = source.firstOrNull?.entries;
    return template
            ?.map((column) => XTableColumn<Map<String, dynamic>>.text(
                  key: column.key.capitalize(),
                  value: (_) => column.value.toString(),
                ))
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    final columns = parseColumns();
    if (columns.isEmpty) return XTableTheme.of(context).emptyBuilder;

    return StaticXTable<Map<String, dynamic>>(
      source: source,
      columns: columns,
      shrinkWrap: shrinkWrap,
      physics: physics,
      onRowTap: onRowTap,
      headerBuilder: headerBuilder,
      hoverWrapper: hoverWrapper,
      prefix: prefix,
      actions: actions,
      columnsAlignment: columnsAlignment,
    );
  }
}
