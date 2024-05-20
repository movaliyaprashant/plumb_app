import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:plumbata/utils/colors.dart';

// ignore: must_be_immutable
class AppBottomNavigationBar extends StatefulWidget {
  final bool? reverse;
  final Curve curve;
  final Color? activeColor;
  final Color inactiveColor;
  final Color? inactiveStripColor;
  final Color? backgroundColor;
  final bool enableShadow;
  final bool? showIndicator;
  int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationBarItem> items;
  final bool showGap;
  final double height;

  AppBottomNavigationBar(
      {Key? key,
        this.showIndicator = false,
        this.reverse = false,
        this.curve = Curves.linear,
        required this.onTap,
        required this.items,
        this.activeColor,
        this.inactiveColor = Colors.grey,
        this.inactiveStripColor,
        this.backgroundColor,
        this.enableShadow = false,
        this.currentIndex = 0,
        this.showGap = false,
        this.height = 60})
      : assert(items.length >= 2 && items.length <= 5), super(key: key);

  @override
  State createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  static const double INDICATOR_HEIGHT = 2;

  double get _barHeight => widget.height;

  bool? get reverse => widget.reverse;

  Curve get curve => widget.curve;

  List<NavigationBarItem> get items => widget.items;

  int get itemsCount => widget.showGap ? items.length + 1 : items.length;

  int get gapPosition => items.length ~/ 2;

  double width = 0;
  late Color activeColor;
  Duration duration = const Duration(milliseconds: 270);

  double _getIndicatorPosition(int index) {
    var realIndex =
    widget.showGap ? (index < gapPosition ? index : index + 1) : index;
    var isLtr = Directionality.of(context) == TextDirection.ltr;
    if (isLtr) {
      return lerpDouble(-1.0, 1.0, realIndex / (itemsCount - 1))??0.0;
    } else {
      return lerpDouble(1.0, -1.0, realIndex / (itemsCount - 1))??0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    activeColor = widget.activeColor ?? Theme.of(context).indicatorColor;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        boxShadow: widget.enableShadow
            ? [
          BoxShadow(
            offset: const Offset(0, -16),
            color: const Color(0xffEAEAEA).withOpacity(0.73),
            blurRadius: 33,
          ),
        ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          height: _barHeight,
          width: width,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: INDICATOR_HEIGHT,
                left: 0,
                right: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildItems(),
                ),
              ),
              if (widget.showIndicator != null)
                Positioned(
                  top: 0,
                  width: width,
                  child: AnimatedAlign(
                    alignment: Alignment(
                        _getIndicatorPosition(widget.currentIndex), 0),
                    curve: curve,
                    duration: duration,
                    child: Container(
                      color: AppColors.selectedItemBarColor ?? activeColor,
                      width: width / itemsCount,
                      height: INDICATOR_HEIGHT,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _select(int index) {
    widget.currentIndex = index;
    widget.onTap(widget.currentIndex);

    setState(() {});
  }

  Widget _buildIcon(NavigationBarItem item, bool isSelected) {
    return isSelected ? item.selectedIcon : item.unSelectedIcon;
  }


  Widget _buildItemWidget(NavigationBarItem? item, bool isSelected) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: _barHeight,
      child: item == null
          ? null
          : Center(
        child: Container(

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: _buildIcon(item, isSelected)),
            ],
          ),
        ),
      ),
    );
  }

  _buildItems() {
    List<Widget> item = items.map((item) {
      var index = items.indexOf(item);
      return Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: () => _select(index),
          child: _buildItemWidget(item, index == widget.currentIndex),
        ),
      );
    }).toList();
    if (widget.showGap) {
      item.insert(
          items.length ~/ 2,
          Expanded(
            child: GestureDetector(
              child: _buildItemWidget(null, false),
            ),
          ));
    }
    return item;
  }
}

class NavigationBarItem {
  final Widget? title;
  final Widget selectedIcon;
  final Widget unSelectedIcon;
  final Color backgroundColor;

  NavigationBarItem({
    required this.selectedIcon,
    required this.unSelectedIcon,
    this.title,
    this.backgroundColor = Colors.white,
  });
}
