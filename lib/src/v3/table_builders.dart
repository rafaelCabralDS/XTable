import 'package:flutter/material.dart';
import 'package:x_table/src/v3/table_controller.dart';
import 'package:x_table/x_table.dart';

class XTableV3<T> extends StatefulWidget {

  final XTableController<T> controller;

  const XTableV3({super.key, required this.controller});

  @override
  State<XTableV3<T>> createState() => _XTableV3State<T>();
}

class _XTableV3State<T> extends State<XTableV3<T>> {

  @override
  Widget build(BuildContext context) {
    var style = XTableTheme.of(context);

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Column(
          children: [

            ///Header
            SizedBox(
                height: style.headerHeight,
                child: Row(
                    children: [
                      ...widget.controller.columns.map((e) => Builder(builder: (context) {
                        var isHeaderHovered = false;
                        return StatefulBuilder(builder: (context, setState) {
                          var headerTextStyle = (style.headerTextStyle ?? Theme.of(context).textTheme.titleSmall)?.copyWith(
                            color: isHeaderHovered ? style.headerHoverTextColor : style.headerTextColor,
                          );

                          return Expanded(
                            flex: e.flex,
                            child: IgnorePointer(
                              ignoring: e.compare == null,
                              child: InkWell(
                                onTap: () => widget.controller.sort(e.key),
                                onHover: (h) => setState(() => isHeaderHovered = h),
                                child: Align(
                                  alignment: e.alignment,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(e.key, style: headerTextStyle),

                                      if (e.key == widget.controller.sortingBy)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Icon((widget.controller.sortingUp ? style.sortUpIcon : style.sortDownIcon).icon,
                                              size: 18,
                                              color: isHeaderHovered ? style.headerHoverTextColor : style.headerTextColor),
                                        ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      })),
                      //if (widget.actions != null) SizedBox(width: widget.actions!.width)
                    ]
                )
            ),

            if (widget.controller.rows.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemBuilder: (_, i) => Builder(builder: (context) {
                    var isHovered = false;
                    return StatefulBuilder(builder: (context, setState) {
                      var rowData = widget.controller.rows[i];
                      final row = Row(
                        children: [
                          //if (widget.prefix != null) widget.prefix!.call(widget.data[i], isHovered),
                          ...rowData.cells.map((cell) => Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(cell.toString()),
                              )
                          )),
                          //if (widget.actions != null)
                          //  SizedBox(
                          //    width: widget.actions!.width,
                          //   child: widget.actions!.child.call(context, widget.data[i], isHovered),
                          //  )

                        ],
                      );

                      return InkWell(
                        onTap: () => {},
                        onHover: (hovered) => setState(() => isHovered = hovered),
                        hoverColor: (style.hoverColor ?? Theme.of(context).hoverColor),
                        child: SizedBox(
                          height: style.rowHeight,
                          child: row,
                        ),
                      );
                    });
                  }),
                  separatorBuilder: (_, __) => style.divider,
                  itemCount: widget.controller.rows.length,
                ),
              )
            else
              Expanded(child: style.emptyBuilder)
          ],
        );
      }
    );
  }
}
