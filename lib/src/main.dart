import 'dart:math';
import 'package:candlesticks_plus/src/models/candle.dart';
import 'package:candlesticks_plus/src/models/candle_style.dart';
import 'package:candlesticks_plus/src/theme/theme_data.dart';
import 'package:candlesticks_plus/src/utils/helper_functions.dart';
import 'package:candlesticks_plus/src/widgets/toolbar_action.dart';
import 'package:candlesticks_plus/src/widgets/mobile_chart.dart';
import 'package:candlesticks_plus/src/widgets/desktop_chart.dart';
import 'package:candlesticks_plus/src/widgets/toolbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/candle.dart';
import 'dart:io' show Platform;

/// StatefulWidget that holds Chart's State (index of
/// current position and candles width).
class Candlesticks extends StatefulWidget {
  /// The arrangement of the array should be such that
  ///  the newest item is in position 0
  final List<Candle> candles;

  /// this callback calls when the last candle gets visible
  final Future<void> Function()? onLoadMoreCandles;

  /// list of buttons you what to add on top tool bar
  final List<ToolBarAction> actions;

  /// Candles color and styles
  final CandleStyle? candleStyle;

  final bool showToolbar;

  final bool ma7, ma25, ma99;

  final String? watermark;

  final double zoomFactor;

  Candlesticks({
    Key? key,
    required this.candles,
    this.onLoadMoreCandles,
    this.actions = const [],
    this.candleStyle,
    this.showToolbar = false,
    this.ma7 = true,
    this.ma25 = true,
    this.ma99 = true,
    this.watermark,
    this.zoomFactor = 6
  }) : super(key: key);

  @override
  _CandlesticksState createState() => _CandlesticksState();
}

class _CandlesticksState extends State<Candlesticks> {
  /// index of the newest candle to be displayed
  /// changes when user scrolls along the chart
  int index = -10;
  double lastX = 0;
  int lastIndex = -10;

  /// candleWidth controls the width of the single candles.
  ///  range: [2...10]
  double candleWidth = 6;

  /// true when widget.onLoadMoreCandles is fetching new candles.
  bool isCallingLoadMore = false;


  @override
  void initState() {
    candleWidth = widget.zoomFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showToolbar)
          ToolBar(
            currentZoom: candleWidth,
            onZoomInPressed: () {
              setState(() {
                candleWidth += 2;
                candleWidth = min(candleWidth, HelperFunctions.maxZoomIn);
              });
            },
            onZoomOutPressed: () {
              setState(() {
                candleWidth -= 2;
                candleWidth = max(candleWidth, HelperFunctions.maxZoomOut);
              });
            },
            children: widget.actions,
          ),
        if (widget.candles.length == 0)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).gold,
              ),
            ),
          )
        else
          Expanded(
            child: TweenAnimationBuilder(
              tween: Tween(begin: 6.toDouble(), end: candleWidth),
              duration: Duration(milliseconds: 120),
              builder: (_, double width, __) {
                if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
                  return DesktopChart(
                    watermark: widget.watermark,
                    ma7: widget.ma7,
                    ma25: widget.ma25,
                    ma99: widget.ma99,
                    candleStyle: widget.candleStyle,
                    onScaleUpdate: (double scale) {
                      scale = max(0.90, scale);
                      scale = min(1.1, scale);
                      setState(() {
                        candleWidth *= 1 / scale;
                        candleWidth = min(candleWidth, 16);
                        candleWidth = max(candleWidth, 4);
                      });
                    },
                    onPanEnd: () {
                      lastIndex = index;
                    },
                    onHorizontalDragUpdate: (double x) {
                      setState(() {
                        x = x - lastX;
                        index = lastIndex + x ~/ candleWidth;
                        index = max(index, -10);
                        index = min(index, widget.candles.length - 1);
                      });
                    },
                    onPanDown: (double value) {
                      lastX = value;
                      lastIndex = index;
                    },
                    onReachEnd: () {
                      if (isCallingLoadMore == false && widget.onLoadMoreCandles != null) {
                        isCallingLoadMore = true;
                        widget.onLoadMoreCandles!().then((_) {
                          isCallingLoadMore = false;
                        });
                      }
                    },
                    candleWidth: width,
                    candles: widget.candles,
                    index: index,
                  );
                } else {
                  return MobileChart(
                    candleStyle: widget.candleStyle,
                    onScaleUpdate: (double scale) {
                      scale = max(0.90, scale);
                      scale = min(1.1, scale);
                      setState(() {
                        candleWidth *= scale;
                        candleWidth = min(candleWidth, 16);
                        candleWidth = max(candleWidth, 4);
                      });
                    },
                    onPanEnd: () {
                      lastIndex = index;
                    },
                    onHorizontalDragUpdate: (double x) {
                      setState(() {
                        x = x - lastX;
                        index = lastIndex + x ~/ candleWidth;
                        index = max(index, -10);
                        index = min(index, widget.candles.length - 1);
                      });
                    },
                    onPanDown: (double value) {
                      lastX = value;
                      lastIndex = index;
                    },
                    onReachEnd: () {
                      if (isCallingLoadMore == false && widget.onLoadMoreCandles != null) {
                        isCallingLoadMore = true;
                        widget.onLoadMoreCandles!().then((_) {
                          isCallingLoadMore = false;
                        });
                      }
                    },
                    candleWidth: width,
                    candles: widget.candles,
                    index: index,
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}
