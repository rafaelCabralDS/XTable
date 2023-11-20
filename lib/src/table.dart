import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:x_table/src/item.dart';
import 'package:x_table/src/theme.dart';
import 'header.dart';
import 'package:collection/collection.dart';

class _DataSource extends DataGridSource {

  final Map<TableHeader, List<TableItem>> data;

  _DataSource(this.data);

  Map<TableHeader, TableItem> getRow(int i) {
    var row = <TableHeader, TableItem>{};
    for (var column in data.entries) {
      row[column.key] = column.value[i];
    }
    return row;
  }

  TableHeader getHeaderByKey(String key) => data.keys.singleWhere((element) => element.key == key);
  TableHeader getHeaderByIndex(int i) =>  data.keys.toList()[i];
  MapEntry<TableHeader, List<TableItem>> getColumnByIndex(int i) => data.entries.toList()[i];
  MapEntry<TableHeader, List<TableItem>> getColumnByKey(String key) => data.entries.singleWhere((element) => element.key.key == key);

  @override
  List<DataGridRow> get rows {

    var len = data.values.first.length;
    var rows = <DataGridRow>[];
    for (int i = 0; i < len; i++) {
      var cells = <DataGridCell<TableItem>>[];
      for (var e in getRow(i).entries) {
        cells.add(DataGridCell<TableItem>(columnName: e.key.key, value: e.value));
      }
      rows.add(DataGridRow(cells: cells));
    }
    return rows;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    var rowIndex = effectiveRows.indexOf(row);
    return DataGridRowAdapter(
        cells: (row.getCells() as List<DataGridCell<TableItem>>)
            .mapIndexed<Widget>((i,e) => Builder(
              builder: (context) {

                var cellHeader = getHeaderByIndex(i);
                var theme = XTableTheme.of(context);

                return Column(
                  children: [
                    Expanded(
                      flex: cellHeader.flex,
                      child: Container(
                        color: rowIndex%2==0 ? theme.rowColor : (theme.rowAlternateColor ?? theme.rowColor),
                        child: Align(
                            alignment: cellHeader.alignment,
                            child: Padding(
                              padding: cellHeader.padding,
                              child: TableItemBuilder(e.value!),
                            )
                        ),
                      ),
                    ),
                    const Divider(height: 0)

                  ],
        );
              }
            ))
            .toList()
    );

  }

}

class XTableStatic extends StatelessWidget {

  final Map<TableHeader, List<TableItem>> data;
  final void Function(int i)? onRowTap;
  final Widget? emptyBuilder;

  static Map<TableHeader, List<TableItem>> _mapJson(List<Map<String,dynamic>> data) {
    final Map<String, List> foo = {};
    for (var row in data) {
      for (var column in row.entries) {
        if (foo.containsKey(column.key)) {
          foo[column.key]!.add(column.value);
        } else {
          foo[column.key] = [column.value];
        }
      }
    }
    return foo.map((key, value) => MapEntry(TableHeader(name: key), value.map((e) => TextTableItem(value: e)).toList()));
  }

  const XTableStatic({super.key, required this.data, this.onRowTap, this.emptyBuilder});
  XTableStatic.json({super.key,
    required List<Map<String,dynamic>> data,
    this.onRowTap,
    this.emptyBuilder,
  }): data = _mapJson(data);

  @override
  Widget build(BuildContext context) {
    var theme = XTableTheme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SfDataGridTheme(
          data: SfDataGridThemeData(
            headerColor: theme.headerColor,
            headerHoverColor: theme.hoverColor,
            rowHoverColor: theme.hoverColor,

          ),
          child: SfDataGrid(
              source: _DataSource(data),
              gridLinesVisibility: GridLinesVisibility.none,
              headerGridLinesVisibility: GridLinesVisibility.none,

              onCellTap: (details) {
                if (details.rowColumnIndex.rowIndex != 0 && onRowTap != null) {
                  int selectedRowIndex = details.rowColumnIndex.rowIndex - 1;
                  onRowTap!(selectedRowIndex);
                }
              },

              columnWidthMode: ColumnWidthMode.fill,
              shrinkWrapRows: true,
              headerRowHeight: theme.headerHeight ?? double.nan,
              rowHeight: theme.rowHeight ?? double.nan,
              columns: data.keys.map((e) => GridColumn(
                  columnName: e.key,
                  label: TableHeaderBuilder(e)
              )).toList()
          ),
        ),

        if (data.values.every((element) => element.isEmpty) && emptyBuilder != null)
          emptyBuilder!

      ],
    );
  }
}



