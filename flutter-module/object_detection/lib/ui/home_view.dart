import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:object_detection/helper/camera_helper.dart';
import 'package:object_detection/helper/tflite_helper.dart';

class HomeView extends StatefulWidget {
  HomeView();

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<RunModelOnFrameResult> _runModelOnFrameResults = [];

  @override
  void initState() {
    super.initState();

    GetIt.I<CameraHelper>().initializeCamera();

    GetIt.I<TfLiteHelper>().loadModel().then((value) {
      setState(() {
        GetIt.I<TfLiteHelper>().isReady = true;
      });
    });

    GetIt.I<TfLiteHelper>().runModelOnFrameResultsController.stream.listen(
        (value) {
      print("#### runModelOnFrameResultsController.stream.listen receive result size: ${value.length}");
      _runModelOnFrameResults = value;
      setState(() {
        GetIt.I<CameraHelper>().isReady = true;
      });
    }, onDone: () {
      print("#### runModelOnFrameResultsController.stream.listen onDone");
    }, onError: (error) {
      print(
          "#### runModelOnFrameResultsController.stream.listen onError: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("HomeView"),
      ),
      body: FutureBuilder<void>(
        future: GetIt.I<CameraHelper>().initializeCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget>[
                CameraPreview(GetIt.I<CameraHelper>().cameraController),
                _buildRunModelOnFrameResultsWidget(
                    screen.width, _runModelOnFrameResults)
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    GetIt.I<CameraHelper>().dispose();
    GetIt.I<TfLiteHelper>().dispose();
    super.dispose();
  }

  _buildRunModelOnFrameResultsWidget(
      double width, List<RunModelOnFrameResult> runModelOnFrameResults) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 100.0,
          width: width,
          color: Colors.white,
          child: _runModelOnFrameResults != null &&
                  _runModelOnFrameResults.isNotEmpty
              ? ListView.builder(
                  itemCount: _runModelOnFrameResults.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        Text(
                            "${_runModelOnFrameResults[index].label} ${(_runModelOnFrameResults[index].confidence * 100.0).toStringAsFixed(2)} %",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            )),
                      ],
                    );
                  })
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
