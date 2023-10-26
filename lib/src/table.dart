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

    return DataGridRowAdapter(
        cells: (row.getCells() as List<DataGridCell<TableItem>>)
            .mapIndexed<Widget>((i,e) => Builder(
              builder: (context) {

                var cellHeader = getHeaderByIndex(i);

                return Column(
                  children: [
                    Expanded(
                      flex: cellHeader.flex,
                      child: Align(
                          alignment: cellHeader.alignment,
                          child: Padding(
                            padding: cellHeader.padding,
                            child: TableItemBuilder(e.value!),
                          )
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

class XTable extends StatefulWidget {

  final Map<TableHeader, List<TableItem>> data;
  final void Function(int i)? onRowTap;


  const XTable({super.key, required this.data, this.onRowTap});
  XTable.json({super.key,
    required List<Map<String,dynamic>> data,
    this.onRowTap,
  }): data = _mapJson(data);

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

  @override
  State<XTable> createState() => _XTableState();
}

class _XTableState extends State<XTable> {

  late final DataGridSource _source;

  @override
  void initState() {
    _source = _DataSource(widget.data);
    super.initState();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    var theme = XTableTheme.of(context);

    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: theme.headerColor,
        headerHoverColor: theme.headerHoverColor,
        rowHoverColor: theme.rowHoverColor
      ),
      child: SfDataGrid(
          source: _source,
          gridLinesVisibility: GridLinesVisibility.none,
          headerGridLinesVisibility: GridLinesVisibility.none,

          onCellTap: (details) {
            if (details.rowColumnIndex.rowIndex != 0 && widget.onRowTap != null) {
              int selectedRowIndex = details.rowColumnIndex.rowIndex - 1;
              widget.onRowTap!(selectedRowIndex);
            }
          },

          columnWidthMode: ColumnWidthMode.fill,
          shrinkWrapRows: true,
          columns: widget.data.keys.map((e) => GridColumn(
              columnName: e.key,
              label: TableHeaderBuilder(e)
          )).toList()
      ),
    );
  }
}


