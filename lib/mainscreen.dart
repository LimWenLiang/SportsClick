import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Main Screen', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.transparent,
            elevation: 10.0),
        extendBodyBehindAppBar: true,
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover)),
          ),
          Center(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 400,
                  width: 300,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: <Color>[
                    Colors.white54,
                    Colors.white60,
                    Colors.white54
                  ])),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/sportsclick.png',
                          scale: 5,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Welcome",
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold)),
                            ])
                      ]))),
        ]));
  }
}
