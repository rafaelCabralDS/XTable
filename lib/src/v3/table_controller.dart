import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:x_table/src/builders.dart';
import 'package:x_table/src/v3/filters.dart';
import 'package:collection/collection.dart';

class XTableColumn<T> {

  final String key;
  final String? name;
  final dynamic Function(T) map;
  final int Function(dynamic,dynamic)? compare;
  final int flex;
  final Alignment alignment;
  final Widget Function(T e, bool isHovered) cellBuilder;
  final Widget Function(T e, bool isHovered)? headerBuilder;
  final List<Filter<dynamic>> filters;

  const XTableColumn({
    required this.key,
    required this.map,
    required this.cellBuilder,
    this.name,
    this.compare,
    this.alignment = Alignment.center,
    this.flex = 1,
    this.headerBuilder,
    this.filters = const [],
  });

  XTableColumn.text({
    required this.key,
    required this.map,
    this.name,
    this.compare,
    this.alignment = Alignment.center,
    this.flex = 1,
    this.headerBuilder,
    this.filters = const [],
  }) : cellBuilder =  ((T e, bool isHovered) => defaultColumnTextBuilder(map(e).toString(), isHovered));

}



class XTableRow {

  final List cells;
  final int index;

  XTableRow({required this.cells, required this.index});
}


class XTableController<T> extends ChangeNotifier {

  final List<T> source;
  final List<XTableColumn<T>> columns;
  late List<XTableRow> rows;
  late List<XTableRow> effectiveRows;
  late String sortingBy;
  bool sortingUp = true;
  int pageIndex = 0;
  late int paginateCount;

  XTableController({
    required this.source,
    required this.columns,
    int? paginateCount,
  }) {
    assert (columns.isNotEmpty);

    effectiveRows = source.mapIndexed((i,e) => XTableRow(
        cells: columns.map((column) => column.map(e)).toList(),
        index: i
    )).toList();
    rows = effectiveRows;
    this.paginateCount = paginateCount ?? effectiveRows.length;
    sortingBy = columns.first.key;
    setPage(0);
    _setFilters();
  }

  List<E> getEffectiveColumn<E>(String key) {
    var columnIndex = columns.indexWhere((element) => element.key == key);
    return effectiveRows.map((e) => e.cells[columnIndex]).toList() as List<E>;
  }

  void _setFilters() {
    // Look for sync filters;
    for (var filter in columns.expand((e) => e.filters)) {
      if (filter.sync) {
        filter.addListener(() {
          applyFilters();
        });
      }
    }
  }

  void applyFilters() {

    // And filters first
    var results = List<XTableRow>.from(effectiveRows);
    for (var e in columns) {
      var columnIndex = columns.indexOf(e);
      for (var filter in e.filters) {
        if (filter.union != FilterUnion.and) continue;
        results = results.where((element) => filter.isIn(element.cells[columnIndex])).toList();
      }
    }


    final List<List<XTableRow>> queries = [];
    for (var e in columns) {
      var columnIndex = columns.indexOf(e);
      for (var filter in e.filters) {
        if (filter.union != FilterUnion.or) continue;
        queries.add(List<XTableRow>.from(results.where((element) => filter.isIn(element.cells[columnIndex]))));
      }
    }
    rows = List<XTableRow>.from(queries.expand((element) => element).toSet());
    notifyListeners();
  }

  void clearFilters() {
    for (var filter in columns.expand((element) => element.filters)) {
      filter.clear();
    }
    rows = effectiveRows;
    notifyListeners();
  }

  void sort(String columnKey) {

    var sortedColumn = columns.singleWhere((element) => element.key == columnKey);
    var sortedColumnIndex = columns.indexWhere((element) => element.key == columnKey);

    if (columnKey == sortingBy) sortingUp = !sortingUp;
    sortingBy = columnKey;
    rows.sort((rowA, rowB) => sortedColumn.compare!(
        (sortingUp ? rowA : rowB).cells[sortedColumnIndex],
        (!sortingUp ? rowA : rowB).cells[sortedColumnIndex]));
    notifyListeners();
  }

  /// Paginate

  int get pagesCount => (effectiveRows.length / (paginateCount)).ceil();

  void setPage(int i) {
    assert(i <= pagesCount);

    pageIndex = i;
    rows = effectiveRows.sublist(pageIndex*paginateCount, min(effectiveRows.length, (pageIndex+1)*paginateCount!));
    notifyListeners();
  }

  @override
  void dispose() {
    for (var filter in columns.expand((e) => e.filters)) {
      filter.dispose();
    }
    super.dispose();
  }

}
