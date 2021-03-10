import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class CameraFeedView extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;

  // The cameraFeed Class takes the cameras list and the setRecognitions
  // function as argument
  CameraFeedView(this.cameras, this.setRecognitions);

  @override
  _CameraFeedViewState createState() => new _CameraFeedViewState();
}

class _CameraFeedViewState extends State<CameraFeedView> {
  CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    print(widget.cameras);
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No Cameras Found.');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;
            Tflite.detectObjectOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              model: "SSDMobileNet",
              imageHeight: img.height,
              imageWidth: img.width,
              imageMean: 127.5,
              imageStd: 127.5,
              numResultsPerClass: 1,
              threshold: 0.4,
            ).then((recognitions) {
              /*
              When setRecognitions is called here, the parameters are being passed on to the parent widget as callback. i.e. to the LiveFeed class
               */
              widget.setRecognitions(recognitions, img.height, img.width);
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
// import 'dart:io';
// import 'dart:isolate';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:object_detection/tflite/classifier.dart';
// import 'package:object_detection/tflite/recognition.dart';
// import 'package:object_detection/tflite/stats.dart';
// import 'package:object_detection/ui/camera_view_singleton.dart';
// import 'package:object_detection/utils/isolate_utils.dart';
//
// /// [CameraView] sends each frame for inference
// class CameraView extends StatefulWidget {
//   /// Callback to pass results after inference to [HomeView]
//   final Function(List<Recognition> recognitions) resultsCallback;
//
//   /// Callback to inference stats to [HomeView]
//   final Function(Stats stats) statsCallback;
//
//   /// Constructor
//   const CameraView(this.resultsCallback, this.statsCallback);
//
//   @override
//   _CameraViewState createState() => _CameraViewState();
// }
//
// class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
//   /// List of available cameras
//   List<CameraDescription> cameras;
//
//   /// Controller
//   CameraController cameraController;
//
//   /// true when inference is ongoing
//   bool predicting;
//
//   /// Instance of [Classifier]
//   Classifier classifier;
//
//   /// Instance of [IsolateUtils]
//   IsolateUtils isolateUtils;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     // Camera initialization
//     initializeCamera();
//
//     // Create an instance of classifier to load model and labels
//     classifier = Classifier();
//
//     // Initially predicting = false
//     predicting = false;
//
//     // Spawn a new isolate
//     isolateUtils = IsolateUtils();
//     isolateUtils.start();
//   }
//
//   /// Initializes the camera by setting [cameraController]
//   void initializeCamera() async {
//     cameras = await availableCameras();
//
//     // cameras[0] for rear-camera
//     cameraController =
//         CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);
//
//     cameraController.initialize().then((_) async {
//       if (!mounted) {
//         return;
//       }
//
//       // Stream of image passed to [onLatestImageAvailable] callback
//       await cameraController.startImageStream(onLatestImageAvailable);
//
//       /// previewSize is size of each image frame captured by controller
//       ///
//       /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
//       Size previewSize = cameraController.value.previewSize;
//
//       /// previewSize is size of raw input image to the model
//       CameraViewSingleton.inputImageSize = previewSize;
//
//       // the display width of image on screen is
//       // same as screenWidth while maintaining the aspectRatio
//       Size screenSize = MediaQuery.of(context).size;
//       CameraViewSingleton.screenSize = screenSize;
//
//       if (Platform.isAndroid) {
//         // On Android Platform image is initially rotated by 90 degrees
//         // due to the Flutter Camera plugin
//         CameraViewSingleton.ratio = screenSize.width / previewSize.height;
//       } else {
//         // For iOS
//         CameraViewSingleton.ratio = screenSize.width / previewSize.width;
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Return empty container while the camera is not initialized
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       return Container();
//     }
//
//     return AspectRatio(
//         aspectRatio: cameraController.value.aspectRatio,
//         child: CameraPreview(cameraController));
//   }
//
//   /// Callback to receive each frame [CameraImage] perform inference on it
//   onLatestImageAvailable(CameraImage cameraImage) async {
//     if (classifier.interpreter != null && classifier.labels != null) {
//       // If previous inference has not completed then return
//       if (predicting) {
//         return;
//       }
//
//       setState(() {
//         predicting = true;
//       });
//
//       var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;
//
//       // Data to be passed to inference isolate
//       var isolateData = IsolateData(
//           cameraImage, classifier.interpreter.address, classifier.labels);
//
//       // We could have simply used the compute method as well however
//       // it would be as in-efficient as we need to continuously passing data
//       // to another isolate.
//
//       /// perform inference in separate isolate
//       Map<String, dynamic> inferenceResults = await inference(isolateData);
//
//       var uiThreadInferenceElapsedTime =
//           DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;
//
//       // pass results to HomeView
//       widget.resultsCallback(inferenceResults["recognitions"]);
//
//       // pass stats to HomeView
//       widget.statsCallback((inferenceResults["stats"] as Stats)
//         ..totalElapsedTime = uiThreadInferenceElapsedTime);
//
//       // set predicting to false to allow new frames
//       setState(() {
//         predicting = false;
//       });
//     }
//   }
//
//   /// Runs inference in another isolate
//   Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
//     ReceivePort responsePort = ReceivePort();
//     isolateUtils.sendPort
//         .send(isolateData..responsePort = responsePort.sendPort);
//     var results = await responsePort.first;
//     return results;
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     switch (state) {
//       case AppLifecycleState.paused:
//         cameraController.stopImageStream();
//         break;
//       case AppLifecycleState.resumed:
//         await cameraController.startImageStream(onLatestImageAvailable);
//         break;
//       default:
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     cameraController.dispose();
//     super.dispose();
//   }
// }
