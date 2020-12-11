import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nmcontroller = TextEditingController();
  final TextEditingController _emcontroller = TextEditingController();
  final TextEditingController _phcontroller = TextEditingController();
  final TextEditingController _pscontroller = TextEditingController();
  final TextEditingController _ps2controller = TextEditingController();

  String _name = "";
  String _email = "";
  String _phone = "";
  String _password = "";
  String _password2 = "";
  bool _rememberMe = false;
  bool _acceptance = false;
  bool _validateEmail = false;
  bool _validatePhone = false;
  bool _validatePassword = false;
  bool _validatePassword2 = false;
  SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Registeration', style: TextStyle(color: Colors.black)),
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
                    child: Column(children: [
                  Image.asset(
                    'assets/images/sportsclick.png',
                    scale: 5.5,
                  ),
                  TextField(
                      controller: _nmcontroller,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          labelText: 'Name', icon: Icon(Icons.person))),
                  TextField(
                      controller: _emcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          icon: Icon(Icons.email),
                          errorText: _validateEmail ? 'Invalid email' : null)),
                  TextField(
                      controller: _phcontroller,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          labelText: 'Phone',
                          icon: Icon(Icons.phone),
                          errorText:
                              _validatePhone ? 'Invalid phone number' : null)),
                  TextField(
                    controller: _pscontroller,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        icon: Icon(Icons.lock),
                        errorText: _validatePassword
                            ? 'At least 8 characters consists of upper case,\nlower case and number'
                            : null),
                    obscureText: true,
                  ),
                  TextField(
                    controller: _ps2controller,
                    decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        icon: Icon(Icons.lock),
                        errorText: _validatePassword2
                            ? 'Password didn\'t match'
                            : null),
                    obscureText: true,
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool value) {
                          _onChangeRememberMe(value);
                        },
                      ),
                      Text('Remember Me', style: TextStyle(fontSize: 15))
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _acceptance,
                        onChanged: (bool value) {
                          _onChangeAcceptance(value);
                        },
                      ),
                      Text('Accept Terms of Service and\nPrivacy Policy',
                          style: TextStyle(fontSize: 15))
                    ],
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1.5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minWidth: 180,
                    height: 40,
                    child: Text('Register'),
                    textColor: Colors.black,
                    elevation: 15,
                    onPressed: _onRegister,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Already have an account? '),
                      GestureDetector(
                          onTap: _onLogin,
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.deepPurple, fontSize: 15, fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                TextSpan(
                                  text: 'Login',
                                )
                              ]))),
                    ],
                  ),
                ]))),
          ),
        ]));
  }

  Future<void> _onRegister() async {
    _name = _nmcontroller.text;
    _email = _emcontroller.text;
    _phone = _phcontroller.text;
    _password = _pscontroller.text;
    _password2 = _ps2controller.text;

    if (_name.isNotEmpty &&
        _email.isNotEmpty &&
        _phone.isNotEmpty &&
        _password.isNotEmpty &&
        _password2.isNotEmpty) {
      if (validateEmail(_email)) {
        setState(() {
          _validateEmail = false;
        });
        if (_phone.length > 7 && _phone.length < 13) {
          setState(() {
            _validatePhone = false;
          });
          if (validatePassword(_password)) {
            setState(() {
              _validatePassword = false;
            });
            if (_password == _password2) {
              setState(() {
                _validatePassword2 = false;
              });
              if (_acceptance) {
                ProgressDialog pr = new ProgressDialog(context,
                    type: ProgressDialogType.Normal, isDismissible: false);
                pr.style(message: "Registration...");
                await pr.show();
                http.post(
                    "http://itprojectoverload.com/sportsclick/php/register_user.php",
                    body: {
                      "name": _name,
                      "email": _email,
                      "phone": _phone,
                      "password": _password,
                      "password2": _password2,
                    }).then((res) {
                  print(res.body);
                  if (res.body == "success") {
                    _showRegisterDialog();
                  } else {
                    Toast.show(
                      "Registration Failed",
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
                _showAcceptDialog();
              }
            } else {
              print("invalid password");
              setState(() {
                _rememberMe = false;
                _validatePassword2 = true;
              });
            }
          } else {
            setState(() {
              print("invalid password2");
              _rememberMe = false;
              _validatePassword = true;
            });
          }
        } else {
          print("invalid phone");
          setState(() {
            _rememberMe = false;
            _validatePhone = true;
          });
        }
      } else {
        print("invalid email & password");
        setState(() {
          _rememberMe = false;
          _validateEmail = true;
        });
      }
    } else {
      Toast.show(
        "Incomplete Details",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
      setState(() {
        _rememberMe = false;
      });
    }
  }

  void _onChangeRememberMe(bool value) {
    setState(() {
      _rememberMe = value;
      savepref(value);
    });
  }

  void _onChangeAcceptance(bool value) {
    setState(() {
      _acceptance = value;
    });
  }

  Future<void> savepref(bool value) async {
    if (value) {
      prefs = await SharedPreferences.getInstance();
      _email = _emcontroller.text;
      _password = _pscontroller.text;
      await prefs.setString('email', _email);
      await prefs.setString('password', _password);
      await prefs.setBool('rememberme', true);
    }
  }

  void _onLogin() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  bool validatePassword(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Registration Success",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: new RichText(
              text: new TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: <TextSpan>[
                new TextSpan(text: 'An email has been sent to '),
                new TextSpan(
                    text: '$_email',
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                new TextSpan(
                    text:
                        '\n\nIf you cannot see the email from SportsClick in your inbox, make sure to check your SPAM folder.')
              ])),
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
                _onLogin();
              },
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "SportsClick's Term of Service",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: new RichText(
              text: new TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: <TextSpan>[
                new TextSpan(
                    text:
                        'I accept SportsClick\'s Terms and Conditions and Privacy Policy.')
              ])),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new OutlineButton(
              child: new Text(
                "Accept",
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30)),
              borderSide: BorderSide(color: Colors.green),
              onPressed: () {
                setState(() {
                  _acceptance = true;
                });
                Navigator.of(context).pop();
              },
            ),
            SizedBox(width: 5),
            GestureDetector(
              child: Text('Decline', style: TextStyle(fontSize: 15)),
              onTap: () {
                Navigator.of(context).pop();
                _showCancelDialog();
              },
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Cancel register for SportsClick?",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: new RichText(
              text: new TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: <TextSpan>[
                new TextSpan(
                    text:
                        'Declining SportsClick terms means you wont have account.')
              ])),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            GestureDetector(
              child: Text('Go Back',
                  style: TextStyle(color: Colors.green, fontSize: 15)),
              onTap: () {
                Navigator.of(context).pop();
                _showAcceptDialog();
              },
            ),
            SizedBox(width: 5),
            GestureDetector(
              child: Text('Cancel Register',
                  style: TextStyle(color: Colors.red, fontSize: 15)),
              onTap: () {
                Navigator.of(context).pop();
                _onLogin();
              },
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }
}
