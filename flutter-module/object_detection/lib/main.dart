import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'core/di.dart';
import 'core/nav.dart';

void main() async {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Object Detection Module',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      onGenerateRoute: GetIt.I<Nav>().router.generator,
    );
  }
}
