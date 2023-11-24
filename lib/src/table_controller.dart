import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:x_table/src/builders.dart';
import 'package:x_table/src/utils.dart';
import 'package:x_table/src/filters.dart';
import 'package:collection/collection.dart';
import 'package:x_table/src/table.dart';


class XTableColumn<T extends Object> {

  final String key;
  final String? name;
  //final dynamic Function(T) value;
  final int Function(dynamic,dynamic)? compare;
  final int flex;
  final Alignment? alignment;
  final XTableCell<T> Function(T e) cell;
  //final List<Filter<dynamic>> filters;


  XTableColumn({
    required this.key,
    //required this.value,
    //required this.cellBuilder,
    required this.cell,
    this.name,
    this.compare,
    this.alignment,
    this.flex = 1,
    //List<Filter> filters = const [],
  }) ;

  
  XTableColumn.text({
    required this.key,
    required String Function(T) value,
    this.name,
    this.compare,
    this.alignment,
    this.flex = 1,
  }) : cell =  ((T e) => XTableCell<T>(
      cellBuilder: (e, isHovered) => defaultColumnTextBuilder(value(e), isHovered),
      value: value(e)
  ));


}

class XTableCell<T extends Object> {

  final Widget Function(T e, bool isHovered) cellBuilder;
  final dynamic value;

  const XTableCell({
    required this.value,
    required this.cellBuilder,
  });

}

class XTableRow<T extends Object> {

  final List<XTableCell<T>> cells;
  final int index;
  final T e;

  XTableRow({
    required this.cells,
    required this.index,
    required this.e
  });
}

typedef AttachmentCallback<T extends Object> = void Function(List<XTableColumn<T>> columns);

class XTableController<T extends Object> extends ChangeNotifier {


  /// The raw data of type [T] that will be mapped as _rows by the [columns] mapper
  late final List<T> source;

  /// The table column headers
  final List<XTableColumn<T>> columns = [];

  /// The list with the filtered and sorted items
  List<XTableRow<T>> filteredRows = [];

  /// The entire available data list
  List<XTableRow<T>> get effectiveRows => List<XTableRow<T>>.from(List<T>.from(source).mapIndexed((i,e) => XTableRow<T>(
    cells: columns.map((column) => column.cell(e)).toList(),
    index: i,
    e: e,
  )));

  bool isAttached = false;

  late String? sortingBy;
  bool sortingUp = true;
  int pageIndex = 0;
  late int paginateCount;
  int get activeFiltersCount => filters.values.expand((element) => element).where((element) => element.isActive).length;
  
  /// You do not need to have a column to apply a filter. Filters without columns will be stored as [_DEFAULT_FILTER_KEY]
  static const String _DEFAULT_FILTER_KEY = "any";
  final Map<String, List<Filter>> filters = {};

  XTableController({
    List<T>? source,
    int? paginateCount,
  }) {
    this.source = List.from(source ?? []);
    this.paginateCount = paginateCount ?? 10000;
  }


  void attach(List<XTableColumn<T>> columns) {
    if (isAttached) return;
    isAttached = true;
    this.columns.addAll(columns);

    for (var e in _attachmentCallbacks) {
      e.call(this.columns);
    }
    sortingBy = columns.firstWhereOrNull((element) => element.compare != null)?.key;
    _sortFilterPaginate();
  }

  final List<AttachmentCallback<T>> _attachmentCallbacks = [];
  void addPostAttachCallback(AttachmentCallback<T> callback) {
    _attachmentCallbacks.add(callback);
  }
  
  /// Clears and set the data notifying only once
  void set(List<T> data) {

    source.clear();
    filteredRows = [];
    source.addAll(List.from(data));
    _sortFilterPaginate();
  }

  /// Look for elements present in [source] using the optional [id] function if provided to run the equality comparison.
  /// If there was an item present in the source, it will be replaced, if there wasnt and [shouldAdd] is true, it will be added.
  /// At the end, current sorting and filters will be applied.
  /// Returns the list of candidates that were not added/replaced at the table
  List<T> replace(List<T> data, {dynamic Function(T)? id, bool shouldAdd = false}) {

    final List<T> rejected = [];
    for (final T update in data) {
      final int indexOf = source.indexWhere((e) => (id?.call(e) ?? e) == (id?.call(update) ?? update));
      if (indexOf != -1) {
        source[indexOf] = update;
      } else if(shouldAdd) {
        source.add(update);
      } else {
        rejected.add(update);
      }
    }
    _sortFilterPaginate(pageIndex);
    return rejected;
  }

  /*
  void addAll(List<T> data) {
    source.addAll(data);
    if (isAttached) {
      _sortFilterPaginate();
    }
  }

  void insertAll(List<T> data) {
    source.insertAll(0,data);
    if (isAttached) {
      _sortFilterPaginate();
    }
  }

  void remove(T e) {
    source.remove(e);
    _sortFilterPaginate();
  }

  void clear() {
    source.clear();
    filteredRows.clear();
    setPage(0);
  }

   */


  void _sortFilterPaginate([int page = 0]) {
    if (!isAttached) return;
    filteredRows = _sort(effectiveRows);
    filteredRows = _filter(filteredRows);
    setPage(page);
  }

  /// Filtering

  F? getFilter<F extends Filter>(String? columnKey, [String filterKey = Filter.DEFAULT_KEY]) {
    columnKey ??= _DEFAULT_FILTER_KEY;
    for (Filter filter in (filters[columnKey] ?? [])) {
      if (filter.key == filterKey) return filter as F;
    }
    return null;
  }

  List<XTableRow<T>> _filter(List<XTableRow<T>> data) {
    var results = List<XTableRow<T>>.from(data);

    /// "And"
    for (final e in filters.entries) {
      for (final Filter filter in e.value) {
        if (filter.union != LogicOperator.and) continue;
        var columnIndex = columns.indexWhere((column) => column.key == e.key);
        results = results.where((element) => filter.isIn(columnIndex == -1
            ? element.e
            : element.cells[columnIndex].value)).toList();
      }
    }

    /// Or
    if (filters.values.expand((element) => element).any((element) => element.union == LogicOperator.or)) {
      final List<List<XTableRow<T>>> queries = [];
      for (final e in filters.entries) {
        for (final Filter filter in e.value) {
          if (filter.union != LogicOperator.or) continue;
          var columnIndex = columns.indexWhere((column) => column.key == e.key);

          queries.add(List<XTableRow<T>>.from(results.where((element) => filter.isIn(columnIndex == -1
              ? element.e
              : element.cells[columnIndex].value)))
          );
        }
      }
      return queries.expand((element) => element).toSet().toList(); // _sort(List<XTableRow<T>>.from(queries.expand((element) => element).toSet()));
    }  else {
      return results;
    }

  }

  void applyFilters() {
    filteredRows = _filter(effectiveRows);
    sort();
  }
  
  /// Add all [filters] to all given [columnKeys] if not present, otherwise will replace the old one
  /// This will not apply the new filters!
  void addFilter(String? columnKey, Filter filter) {
    assert(columnKey == null || columns.any((element) => element.key == columnKey));
    columnKey ??= _DEFAULT_FILTER_KEY;
    
    if (filter.sync && !filter.hasListeners) filter.addListener(applyFilters);
    
    // Replace the old filter
    if (filters[columnKey]?.containsBy(filter, (e) => e.key) ?? false) { 
      var indexOf = filters[columnKey]!.indexWhere((element) => element.key == filter.key);
      //filters[columnKey]![indexOf].dispose();
      filters[columnKey]![indexOf] = filter;
      return;
    } 
    
    /// Add if not present
    filters[columnKey] ??= <Filter>[]; // Create the entry if not present yet
    filters[columnKey]!.add(filter);
    
  }

  void clearFilters() {
    for (var filter in filters.values.expand((element) => element)) {
      filter.clear();
    }
    filteredRows = effectiveRows;
    setPage(0);
  }

  List<XTableRow<T>> _sort(List<XTableRow<T>> data) {
    if (sortingBy == null) return data;
    var sortedColumn = columns.firstWhere((element) => element.key == sortingBy);
    var sortedColumnIndex = columns.indexWhere((element) => element.key == sortingBy);
    if (sortedColumn.compare == null) return data;
    return data.sorted((rowA, rowB) => sortedColumn.compare!(
        (sortingUp ? rowA : rowB).cells[sortedColumnIndex].value,
        (!sortingUp ? rowA : rowB).cells[sortedColumnIndex].value));
  }

  void sort([String? columnKey]) {

    if (columnKey != null) {
      if (columnKey == sortingBy) sortingUp = !sortingUp;
      sortingBy = columnKey;
    }

    filteredRows = _sort(filteredRows);
    setPage(0);
  }

  /// -------------------- Paginate

  List<XTableRow<T>> get paginatedRows => filteredRows.sublist(pageIndex*paginateCount, min(filteredRows.length, (pageIndex+1)*paginateCount));
  int get pagesCount => (filteredRows.length / (paginateCount)).ceil();

  void setPage(int i) {
    int targetIndex = min(max(i,0), max(pagesCount-1,0));
    pageIndex = targetIndex;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var filter in filters.values.expand((element) => element)) {
      filter.dispose();
    }
    super.dispose();
  }

}


