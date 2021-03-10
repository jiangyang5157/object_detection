import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:object_detection/core/nav.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomeView"),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                child: ElevatedButton(
                  child: Text("Static Image"),
                  onPressed: () {
                    GetIt.I<Nav>()
                        .router
                        .navigateTo(context, Routes.staticImage);
                  },
                ),
              ),
              ButtonTheme(
                child: ElevatedButton(
                  child: Text("Live Feed"),
                  onPressed: () {
                    GetIt.I<Nav>().router.navigateTo(context, Routes.liveFeed);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
