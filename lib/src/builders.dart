

// TODO add support for hover text style change
import 'package:flutter/material.dart';
import 'package:x_table/x_table.dart';

Widget defaultColumnTextBuilder(String value, bool isHovered) => TextColumnBuilder(value);

class TextColumnBuilder extends StatelessWidget {

  final String value;
  const TextColumnBuilder(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    var theme = XTableTheme.of(context);
    return Text(value, style: theme.itemTextStyle);
  }
}

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

