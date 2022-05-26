import 'package:candlesticks_plus/src/theme/theme_data.dart';
import 'package:candlesticks_plus/src/utils/helper_functions.dart';
import 'package:candlesticks_plus/src/widgets/toolbar_action.dart';
import 'package:flutter/material.dart';

class ToolBar extends StatelessWidget {
  final double currentZoom;

  const ToolBar({
    Key? key,
    required this.currentZoom,
    required this.onZoomInPressed,
    required this.onZoomOutPressed,
    required this.children,
  }) : super(key: key);

  final void Function() onZoomInPressed;
  final void Function() onZoomOutPressed;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            ToolBarAction(
              onPressed: onZoomOutPressed,
              child: Icon(
                Icons.remove,
                color: currentZoom == HelperFunctions.maxZoomOut ? Theme.of(context).grayColor : Theme.of(context).primaryColor,
              ),
            ),
            ToolBarAction(
              onPressed: onZoomInPressed,
              child: Icon(
                Icons.add,
                color: currentZoom == HelperFunctions.maxZoomIn ? Theme.of(context).grayColor : Theme.of(context).primaryColor,
              ),
            ),
            ...children
          ],
        ),
      ),
    );
  }
}
