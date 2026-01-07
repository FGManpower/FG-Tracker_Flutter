import 'package:flutter/widgets.dart';

class AppLifecycleTracker {
  static AppLifecycleState state = AppLifecycleState.resumed;
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState newState) {
    AppLifecycleTracker.state = newState;
  }
}
