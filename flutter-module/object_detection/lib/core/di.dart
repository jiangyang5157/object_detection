import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';

import 'nav.dart';

setupGetIt() async {
  // GetIt.I.registerSingletonAsync<List<CameraDescription>>(
  //         () async => await availableCameras());

  GetIt.I.registerLazySingleton<Nav>(() => Nav());
}
