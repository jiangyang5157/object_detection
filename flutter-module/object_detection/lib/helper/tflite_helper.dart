import 'dart:async';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

typedef void Callback(List<RunModelOnFrameResult> list);

class RunModelOnFrameResult {
  double confidence;
  int index;
  String label;

  RunModelOnFrameResult(this.confidence, this.index, this.label);

  @override
  String toString() =>
      "Result { confidence=$confidence , index=$index, label=$label }\n";
}

class TfLiteHelper {
  bool isReady = false;

  StreamController<List<RunModelOnFrameResult>>
      runModelOnFrameResultsController = new StreamController.broadcast();

  List<RunModelOnFrameResult> _runModelOnFrameResults = [];

  Future<String> loadModel() async {
    print("#### Loading model..");
    return Tflite.loadModel(
      labels: "assets/models/labels.txt",
      model: "assets/models/model_unquant.tflite",
    );
  }

  runModelOnFrame(CameraImage image) async {
    await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 5,
      rotation: 90,
      threshold: 0.1,
    ).then((value) {
      _runModelOnFrameResults.clear();

      if (value.isNotEmpty) {
        value.forEach((element) {
          var result = RunModelOnFrameResult(
              element['confidence'], element['index'], element['label']);
          _runModelOnFrameResults.add(result);
        });
      }

      _runModelOnFrameResults
          .sort((a, b) => b.confidence.compareTo(a.confidence));

      runModelOnFrameResultsController.add(_runModelOnFrameResults);
    });
  }

  void dispose() {
    Tflite.close();
    runModelOnFrameResultsController?.close();
  }
}
