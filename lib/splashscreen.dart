import 'package:flutter/material.dart';
import 'loginscreen.dart';

void main() => runApp(SplashScreen());

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: <Color>[
                  Colors.white54,
                  Colors.white60,
                  Colors.white54
                ])),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/sportsclick.png',
                      scale: 3.5,
                    ),
                    new ProgressIndicator(),
                  ],
                ))),
      ])),
    );
  }
}

class ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          if (animation.value > 0.99) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen()));
          }
        });
      });
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: new Container(
      child: CircularProgressIndicator(
        value: animation.value,
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepPurple),
      ),
    ));
  }
}
