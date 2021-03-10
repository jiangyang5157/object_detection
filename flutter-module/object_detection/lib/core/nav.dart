import 'package:camera/camera.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:object_detection/ui/live_feed_view.dart';
import 'package:object_detection/ui/static_image_view.dart';
import 'package:object_detection/ui/home_view.dart';

class Routes {
  static String home = "/";
  static String staticImage = "/static_image";
  static String liveFeed = "/live_feed";

  static void setupRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ERROR: Route was not found.");
      return;
    });

    router.define(home, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return HomeView();
    }));
    router.define(staticImage, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return StaticImageView();
    }));
    router.define(liveFeed, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return LiveFeedView(GetIt.I<List<CameraDescription>>());
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
