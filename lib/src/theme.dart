

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class XTableThemeData with Diagnosticable {

  final Color? headerColor;
  final Color? hoverColor;
  final Color? rowColor;
  final Color? rowAlternateColor;
  final TextStyle? itemTextStyle;
  final Color? itemHoverTextColor;
  final TextStyle? headerTextStyle;
  final double? rowHeight;
  final double? headerHeight;
  final Widget divider;
  final Icon sortDownIcon;
  final Icon sortUpIcon;
  final Widget loadingBuilder;
  final Widget emptyBuilder;

  /// If not null, it will override the sort icons color as well as the default header text color
  final Color? headerTextColor;
  final Color? headerHoverTextColor;

  const XTableThemeData({
    this.headerColor,
    this.hoverColor,
    this.itemTextStyle,
    this.headerTextStyle,
    this.headerHeight,
    this.rowHeight,
    this.divider = const Divider(height: 0, thickness: 2),
    this.sortDownIcon = const Icon(CupertinoIcons.sort_down),
    this.sortUpIcon = const Icon(CupertinoIcons.sort_up),
    this.headerTextColor,
    this.headerHoverTextColor,
    this.loadingBuilder = const CircularProgressIndicator(),
    this.emptyBuilder = const SizedBox.shrink(),
    this.rowColor,
    this.rowAlternateColor,
    this.itemHoverTextColor,
  });

  static const XTableThemeData factory = XTableThemeData();

  XTableThemeData copyWith({
    Color? headerColor,
    Color? hoverColor,
    Color? rowColor,
    Color? rowAlternateColor,
    TextStyle? itemTextStyle,
    TextStyle? headerTextStyle,
    Widget? divider,
    Icon? sortDownIcon,
    Icon? sortUpIcon,
    Color? headerTextColor,
    double? headerHeight,
    double? rowHeight,
    Color? headerHoverTextColor,
    Widget? loadingBuilder,
    Widget? emptyBuilder,
    Color? itemHoverTextColor,
  }) => XTableThemeData(
      rowColor: rowColor ?? this.rowColor,
      rowAlternateColor: rowAlternateColor ?? this.rowAlternateColor,
      headerColor: headerColor ?? this.headerColor,
      hoverColor: hoverColor ?? this.hoverColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      divider: divider ?? this.divider,
      sortDownIcon: sortDownIcon ?? this.sortDownIcon,
      sortUpIcon: sortUpIcon ?? this.sortUpIcon,
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      headerHoverTextColor: headerHoverTextColor ?? this.headerHoverTextColor,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
      itemHoverTextColor: itemHoverTextColor ?? this.itemHoverTextColor
  );

  XTableThemeData merge({XTableThemeData? themeData}) => XTableThemeData(
      rowAlternateColor: themeData?.rowAlternateColor ?? rowAlternateColor,
      rowColor: themeData?.rowColor ?? rowColor,
      headerColor: themeData?.headerColor ?? headerColor,
      hoverColor: themeData?.hoverColor ?? hoverColor,
      itemTextStyle: themeData?.itemTextStyle ?? itemTextStyle,
      headerTextStyle: themeData?.headerTextStyle ?? headerTextStyle,
      headerHeight: themeData?.headerHeight ?? headerHeight,
      rowHeight: themeData?.rowHeight ?? rowHeight,
      divider: themeData?.divider ?? divider,
      sortUpIcon: themeData?.sortUpIcon ?? sortUpIcon,
      sortDownIcon: themeData?.sortDownIcon ?? sortDownIcon,
      headerTextColor: themeData?.headerTextColor ?? headerTextColor,
      headerHoverTextColor: themeData?.headerHoverTextColor ?? headerHoverTextColor,
      loadingBuilder: themeData?.loadingBuilder ?? loadingBuilder,
      emptyBuilder: themeData?.emptyBuilder ?? emptyBuilder,
      itemHoverTextColor: themeData?.itemHoverTextColor ?? itemHoverTextColor
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