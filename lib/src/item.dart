import 'package:flutter/material.dart';
import 'package:x_table/src/theme.dart';

sealed class TableItem {

  const TableItem();
}

class TextTableItem extends TableItem {
  final String? value;

  const TextTableItem({
    required this.value
  });
}

class WidgetTableItem extends TableItem {
  final Widget child;
  const WidgetTableItem({required this.child});
}

class EmptyTableItem extends TableItem {
  const EmptyTableItem();
}


class TableItemBuilder extends StatelessWidget {

  final TableItem item;

  const TableItemBuilder(this.item, {super.key});

  @override
  Widget build(BuildContext context) {

    final XTableThemeData theme = XTableTheme.of(context);

    switch (item) {

      case TextTableItem():
        return Text((item as TextTableItem).value ?? "-", style: theme.itemTextStyle);
      case WidgetTableItem():
        return (item as WidgetTableItem).child;
      case EmptyTableItem():
        return const SizedBox.shrink();
    }

  }
}
