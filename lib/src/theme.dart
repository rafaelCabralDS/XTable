

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XTableThemeData with Diagnosticable {

  final Color? headerColor;
  final Color? hoverColor;
  final TextStyle? itemTextStyle;
  final TextStyle? headerTextStyle;
  final double? rowHeight;
  final double? headerHeight;

  const XTableThemeData({
    this.headerColor,
    this.hoverColor,
    this.itemTextStyle,
    this.headerTextStyle,
    this.headerHeight,
    this.rowHeight,
  });

  static const XTableThemeData factory = XTableThemeData();

  XTableThemeData copyWith({
    Color? headerColor,
    Color? hoverColor,
    Color? rowHoverColor,
    TextStyle? itemTextStyle,
    TextStyle? headerTextStyle
  }) => XTableThemeData(
      headerColor: headerColor ?? this.headerColor,
      hoverColor: hoverColor ?? this.hoverColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle
  );

  XTableThemeData merge({XTableThemeData? themeData}) => XTableThemeData(
      headerColor: themeData?.headerColor ?? headerColor,
      hoverColor: themeData?.hoverColor ?? hoverColor,
      itemTextStyle: themeData?.itemTextStyle ?? itemTextStyle,
      headerTextStyle: themeData?.headerTextStyle ?? headerTextStyle,
      headerHeight: themeData?.headerHeight ?? headerHeight,
      rowHeight: themeData?.rowHeight ?? rowHeight
  );

}


class XTableTheme extends InheritedTheme {


  /// Applies the given theme [data] to [child].
  const XTableTheme({Key? key, required this.data, required super.child})
      : super(key: key);

  final XTableThemeData data;


  static XTableThemeData of(BuildContext context) {
    final XTableTheme? inheritedTheme = context.dependOnInheritedWidgetOfExactType<XTableTheme>();
    return inheritedTheme?.data ?? XTableThemeData.factory;

  }

  @override
  bool updateShouldNotify(XTableTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    final XTableTheme? ancestorTheme =
    context.findAncestorWidgetOfExactType<XTableTheme>();
    return identical(this, ancestorTheme)
        ? child
        : XTableTheme(data: data.merge(themeData: ancestorTheme?.data), child: child);
  }
}