import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tflite/tflite.dart';

import '../main.dart';
import 'camera_feed_view.dart';

class HomeView extends StatefulWidget {
  // final List<CameraDescription> _cameras;
  // GetIt.I<List<CameraDescription>>()
  HomeView();

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  StreamController<List<RunModelOnFrameResult>>
      _runModelOnFrameResultsController = new StreamController.broadcast();

  List<RunModelOnFrameResult> _runModelOnFrameResults = [];

  setResult(List list) {
    list.sort((a, b) => b.confidence.compareTo(a.confidence));
    _runModelOnFrameResultsController.add(list);
  }

  setupRunModelOnFrameResultsController() {
    _runModelOnFrameResultsController.stream.listen((value) {
      setState(() {
        _runModelOnFrameResults = value;
      });
    }, onDone: () {
      print("#### runModelOnFrameResultsController.stream.listen onDone");
    }, onError: (error) {
      print(
          "#### runModelOnFrameResultsController.stream.listen onError: $error");
    });
  }

  loadModel() async {
    print("#### Loading model..");
    return Tflite.loadModel(
      labels: "assets/models/labels.txt",
      model: "assets/models/model_unquant.tflite",
    );
  }

  @override
  void initState() {
    super.initState();
    setupRunModelOnFrameResultsController();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("HomeView"),
      ),
      body: Stack(
        children: <Widget>[
          CameraFeedView(camera, setResult),
          _buildRunModelOnFrameResultsWidget(
              screen.width, _runModelOnFrameResults)
        ],
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    _runModelOnFrameResultsController.close();
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
              : Center(
                  child: Text("Waiting for results..",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ))),
        ),
      ),
    );
  }
}
