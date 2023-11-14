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
  final Filter? filter;

  const XTableColumn({
    required this.key,
    required this.map,
    required this.cellBuilder,
    this.name,
    this.compare,
    this.alignment = Alignment.center,
    this.flex = 1,
    this.headerBuilder,
    this.filter,
  });

  XTableColumn.text({
    required this.key,
    required this.map,
    this.name,
    this.compare,
    this.alignment = Alignment.center,
    this.flex = 1,
    this.headerBuilder,
    this.filter,
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
  int? paginateCount;

  XTableController({
    required this.source,
    required this.columns,
    this.paginateCount,
  }) {
    assert (columns.isNotEmpty);

    rows = source.mapIndexed((i,e) => XTableRow(
        cells: columns.map((column) => column.map(e)).toList(),
        index: i
    )).toList();
    effectiveRows = rows;
    sortingBy = columns.first.key;
  }


  void applyFilters() {

    /*
    var filteredRows = effectiveRows;
    rows = effectiveRows;

    for (var row in rows) {
      var columnIndex = -1;
      for (var column in columns) {
        columnIndex+=1;
        if (column.filter == null) continue;
        var filteredVal = row.cells[columnIndex];
        if (column.filter!.getFiltered(filteredVal)) filteredRows.add(row);
      }
    }
    sort(sortingBy);
    sort(sortingBy);
    setPage(0);

     */

  }



  void clearFilters() {
    for (var column in columns) {
      if (column.filter == null) continue;
      column.filter!.clear();
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


  int get pagesCount => (effectiveRows.length / pageIndex).ceil();

  void setPage(int i) {
    assert(paginateCount != null);
    assert(i <= pagesCount);

    pageIndex = i;
    rows = effectiveRows.sublist(pageIndex*paginateCount!, min(effectiveRows.length, (pageIndex+1)*paginateCount!));
    notifyListeners();
  }

}
