
import 'package:flutter/cupertino.dart';
import 'package:x_table/src/theme.dart';

class TableHeader {

  final String key;
  final String name;
  final Alignment alignment;
  final int flex;
  final EdgeInsets padding;

  const TableHeader({
    required this.name,
    String? key,
    this.alignment = Alignment.centerLeft,
    this.flex = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0)
  }) : key = key ?? name;

}

class TableHeaderBuilder extends StatelessWidget {

  final TableHeader header;
  const TableHeaderBuilder(this.header, {super.key});

  @override
  Widget build(BuildContext context) {
    final XTableThemeData theme = XTableTheme.of(context);

    return Align(
        alignment: header.alignment,
        child: Padding(
          padding: header.padding,
          child: Text(header.name, style: theme.headerTextStyle),
        ));
  }
}
