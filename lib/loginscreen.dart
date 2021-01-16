import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportsclick/forgotscreen.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'mainscreen.dart';
import 'registerscreen.dart';
import 'forgotscreen.dart';
import 'user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emcontroller = TextEditingController();
  final TextEditingController _pscontroller = TextEditingController();
  String _email = "";
  String _password = "";
  bool _rememberMe = false;
  SharedPreferences prefs;
  List userList;

  @override
  void initState() {
    loadpref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
          appBar: AppBar(
              title: Text('Login', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.transparent,
              elevation: 25.0),
          extendBodyBehindAppBar: true,
          body: Stack(children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover)),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                Colors.white54,
                Colors.white60,
                Colors.white54
              ])),
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 35, left: 20, right: 20, bottom: 20),
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/sportsclick.png',
                        scale: 5.5,
                      ),
                      TextField(
                          controller: _emcontroller,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: 'Email', icon: Icon(Icons.email))),
                      TextField(
                        controller: _pscontroller,
                        decoration: InputDecoration(
                            labelText: 'Password', icon: Icon(Icons.lock)),
                        obscureText: true,
                      ),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (bool value) {
                              _onChange(value);
                            },
                          ),
                          Text('Remember Me', style: TextStyle(fontSize: 15))
                        ],
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.5),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        minWidth: 180,
                        height: 40,
                        child: Text('Login'),
                        elevation: 15,
                        onPressed: _onLogin,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: _onRegister,
                          child: Text('Register New Account',
                              style: TextStyle(fontSize: 15))),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                          onTap: _onForgot,
                          child: Text('Forgot Password',
                              style: TextStyle(fontSize: 15))),
                    ],
                  ))),
            )
          ])),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }

  void _onChange(bool value) {
    setState(() {
      _rememberMe = value;
      savepref(value);
    });
  }

  Future<void> loadpref() async {
    prefs = await SharedPreferences.getInstance();
    _email = (prefs.getString('email')) ?? '';
    _password = (prefs.getString('password')) ?? '';
    _rememberMe = (prefs.getBool('rememberme')) ?? false;
    if (_email.isNotEmpty) {
      setState(() {
        _emcontroller.text = _email;
        _pscontroller.text = _password;
        _rememberMe = _rememberMe;
      });
    }
  }

  Future<void> savepref(bool value) async {
    prefs = await SharedPreferences.getInstance();
    _email = _emcontroller.text;
    _password = _pscontroller.text;

    if (value) {
      if (_email.length < 4 && _password.length < 8) {
        print("INVALID EMAIL/PASSWORD");
        _rememberMe = false;
        Toast.show(
          "Invalid Email/Password",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        return;
      } else {
        await prefs.setString('email', _email);
        await prefs.setString('password', _password);
        await prefs.setBool('rememberme', value);
        Toast.show(
          "Preferences Saved",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        print("SUCCESS");
      }
    } else {
      await prefs.setString('email', '');
      await prefs.setString('password', '');
      await prefs.setBool('rememberme', false);
      setState(() {
        _emcontroller.text = "";
        _pscontroller.text = "";
        _rememberMe = false;
      });
      Toast.show(
        "Preferences Removed",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    }
  }

  Future<void> _onLogin() async {
    _email = _emcontroller.text;
    _password = _pscontroller.text;
    if (_email.isNotEmpty && _password.isNotEmpty) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Login...");
      await pr.show();
      http.post("http://itprojectoverload.com/sportsclick/php/login_user.php",
          body: {
            "email": _email,
            "password": _password,
          }).then((res) {
        print(res.body);
        if (res.body == "success") {
          Toast.show(
            "Login Success",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MainScreen(email: _email)));
        } else if (res.body == "noverify") {
          _showDialog();
        } else {
          Toast.show(
            "Login Failed",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
        }
      }).catchError((err) {
        print(err);
      });
      await pr.hide();
    } else {
      Toast.show(
        "Incomplete Details",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    }
  }

  void _loadUser() {
    http.post("http://itprojectoverload.com/sportsclick/php/load_user.php",
        body: {
          "email": _email,
        }).then((res) {
      print(res.body);
      if (res.body != "nodata") {
        setState(() {
          var jsondata = json.decode(res.body);
          userList = jsondata["user"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _onRegister() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => RegisterScreen()));
  }

  void _onForgot() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ForgotScreen()));
  }

  _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Email Has Not Verify",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: new Text(
            "Please check your email from SportsClick. \n\nIf you cannot see the email from SportsClick in your inbox, make sure to check your SPAM folder.",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new OutlineButton(
              child: new Text(
                "OK",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30)),
              borderSide: BorderSide(color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }
}
