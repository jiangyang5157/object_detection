import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';

import 'nav.dart';

setupGetIt() async {
  GetIt.I.registerLazySingleton<Nav>(() => Nav());

  GetIt.I.registerSingletonAsync<List<CameraDescription>>(
      () async => await availableCameras());
}
