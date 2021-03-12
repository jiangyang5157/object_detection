import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:object_detection/helper/tflite_helper.dart';

class CameraHelper {
  CameraController cameraController;

  Future<void> initializeCameraControllerFuture;

  bool isReady = false;

  _getCameraDescription() async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.first,
    );
  }

  void initializeCamera() async {
    print("#### Initialize Camera..");

    cameraController = CameraController(
      await _getCameraDescription(),
      ResolutionPreset.low,
      enableAudio: false,
    );

    initializeCameraControllerFuture =
        cameraController.initialize().then((value) {
      print("#### Camera initialized, starting camera image stream..");
      cameraController.startImageStream((CameraImage image) {
        print("#### cameraController get an image.");
        if (!GetIt.I<TfLiteHelper>().isReady) return;
        if (!isReady) return;
        isReady = false;
        try {
          GetIt.I<TfLiteHelper>().runModelOnFrame(image);
        } catch (e) {
          print("#### runModelOnFrame ERROR: $e");
        }
      });
    });

    isReady = true;
  }

  void dispose() {
    cameraController?.dispose();
  }
}
