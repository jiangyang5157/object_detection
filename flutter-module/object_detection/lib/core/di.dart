import 'package:get_it/get_it.dart';
import 'package:object_detection/helper/camera_helper.dart';
import 'package:object_detection/helper/tflite_helper.dart';

import 'nav.dart';

setupGetIt() async {
  GetIt.I.registerLazySingleton<Nav>(() => Nav());
  GetIt.I.registerLazySingleton<CameraHelper>(() => CameraHelper());
  GetIt.I.registerLazySingleton<TfLiteHelper>(() => TfLiteHelper());
}
