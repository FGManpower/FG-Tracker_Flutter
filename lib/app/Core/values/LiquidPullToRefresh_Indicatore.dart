import 'dart:async';
import 'dart:ui';


import 'package:fgtracker/app/config/themes_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class LiquidPullToRefresh_Indicatore {
  static int millisecond = 700;

  static Future<void> handleRefresh(
      {Function()? onTapCallback, Function()? onTap2Callback}) {
    onTapCallback?.call();
    onTap2Callback?.call();
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(milliseconds: 500), () {
      completer.complete();
    });
    return completer.future.then<void>((_) {});
  }
}

class MyCustomPullToRefresh extends StatelessWidget {
  Color? color = Colors.transparent;
  Color? backgroundColor = Colors.transparent;
  final GlobalKey<LiquidPullToRefreshState> Indicatorekey;
  final Widget child;
  Function()? onTapCallback;
  Function()? onTap2Callback;


  MyCustomPullToRefresh({
    Key? key,
    this.color,
    this.backgroundColor,
    required this.Indicatorekey,
    required this.child,
    this.onTapCallback,
    this.onTap2Callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      key: Indicatorekey,
      color: context.isDarkMode
          ? ToggleThemeData.darkThemeBackground
          : ToggleThemeData.Appcolor,
      backgroundColor: Colors.white,
      child: child,
      onRefresh: () {
        if (onTapCallback != null) onTapCallback!();
        if (onTap2Callback != null) onTap2Callback!();
        return Future<void>.value();
      },
      springAnimationDurationInMilliseconds:
          LiquidPullToRefresh_Indicatore.millisecond,
      showChildOpacityTransition: false,
    );
  }
}
