import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:object_detection/ui/home_view.dart';

class Routes {
  static String home = "/";

  static void setupRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("#### ERROR: Route was not found.");
      return;
    });

    router.define(home, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return HomeView();
    }));
  }
}

class Nav {
  FluroRouter _router;

  FluroRouter get router => _router;

  Nav() {
    _router = FluroRouter();
    Routes.setupRoutes(_router);
  }

  void exit() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
