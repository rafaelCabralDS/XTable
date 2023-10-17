

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XTableThemeData with Diagnosticable {

  final Color? headerColor;
  final Color? headerHoverColor;
  final Color? rowHoverColor;
  final TextStyle? itemTextStyle;
  final TextStyle? headerTextStyle;

  const XTableThemeData({
    this.headerColor,
    this.headerHoverColor,
    this.rowHoverColor,
    this.itemTextStyle,
    this.headerTextStyle
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
      headerHoverColor: hoverColor ?? this.headerHoverColor,
      rowHoverColor: rowHoverColor ?? this.rowHoverColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle
  );

  XTableThemeData merge({XTableThemeData? themeData}) => XTableThemeData(
      headerColor: themeData?.headerColor ?? headerColor,
      headerHoverColor: themeData?.headerHoverColor ?? headerHoverColor,
      rowHoverColor: themeData?.rowHoverColor ?? rowHoverColor,
      itemTextStyle: themeData?.itemTextStyle ?? itemTextStyle,
      headerTextStyle: themeData?.headerTextStyle ?? headerTextStyle
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