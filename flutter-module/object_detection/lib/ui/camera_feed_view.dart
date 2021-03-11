import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

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

class CameraFeedView extends StatefulWidget {
  final List<CameraDescription> _cameras;
  final Callback _setResults;

  CameraFeedView(this._cameras, this._setResults);

  @override
  _CameraFeedViewState createState() => new _CameraFeedViewState();
}

class _CameraFeedViewState extends State<CameraFeedView> {
  CameraController _controller;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    print(widget._cameras);
    if (widget._cameras == null || widget._cameras.length < 1) {
      print('ERROR: No Cameras Found.');
    } else {
      _controller = new CameraController(
        widget._cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      _controller.initialize().then((_) {
        print("#### Camera initialized, starting camera image stream..");
        setState(() {});
        _controller.startImageStream((CameraImage image) {
          if (_isDetecting) return;
          _isDetecting = true;
          try {
            Tflite.runModelOnFrame(
                    bytesList: image.planes.map((plane) {
                      return plane.bytes;
                    }).toList(),
                    numResults: 5)
                .then((value) {
              List<RunModelOnFrameResult> list = [];
              if (value.isNotEmpty) {
                value.forEach((element) {
                  var result = RunModelOnFrameResult(element['confidence'],
                      element['index'], element['label']);
                  list.add(result);
                  print("#### runModelOnFrame load result: $result");
                });
              }
              widget._setResults(list);
              _isDetecting = false;
            });
          } catch (e) {
            print("#### Tflite.runModelOnFrame ERROR: $e");
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = _controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(_controller),
    );
  }
}
