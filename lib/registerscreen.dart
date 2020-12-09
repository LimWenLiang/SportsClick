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
  bool _validateName = false;
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
                          labelText: 'Name',
                          icon: Icon(Icons.person),
                          errorText: _validateName ? 'Required' : null)),
                  TextField(
                      controller: _emcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          icon: Icon(Icons.email),
                          errorText: _validateEmail ? 'Please enter valid email' : null)),
                  TextField(
                      controller: _phcontroller,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          labelText: 'Phone',
                          icon: Icon(Icons.phone),
                          errorText: _validatePhone ? 'Required' : null)),
                  TextField(
                    controller: _pscontroller,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        icon: Icon(Icons.lock),
                        errorText: _validatePassword
                            ? 'Password should consists upper case,\nlower case and number'
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
                    child: Text('Register'),
                    textColor: Colors.black,
                    elevation: 15,
                    onPressed: _onRegister,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                      onTap: _onLogin,
                      child: Text('Already Register',
                          style: TextStyle(fontSize: 15))),
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
      if (_password == _password2) {
        if (validateEmail(_email) && validatePassword(_password)) {
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
            if (res.body == "SUCCESS") {
              _showDialog();
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
          Toast.show(
            "Please check your email/password",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
          setState(() {
            _password.isEmpty
                ? _validatePassword = true
                : _validatePassword = false;
            _password2.isEmpty
                ? _validatePassword2 = true
                : _validatePassword2 = false;
          });
        }
      } else {
        Toast.show(
          "Password didn't match. Please try again.",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        setState(() {
          _rememberMe = false;
        });
      }
    } else {
      setState(() {
        _rememberMe = false;
      });
    }
    setState(() {
      _name.isEmpty ? _validateName = true : _validateName = false;
      _email.isEmpty ? _validateEmail = true : _validateEmail = false;
      _phone.isEmpty ? _validatePhone = true : _validatePhone = false;
      _password.isEmpty ? _validatePassword = true : _validatePassword = false;
      _password2.isEmpty
          ? _validatePassword2 = true
          : _validatePassword2 = false;
    });
  }

  void _onChange(bool value) {
    setState(() {
      _rememberMe = value;
      savepref(value);
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

  _showDialog() {
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
          content: new Text(
            "An email has been sent to $_email. \n\nIf you cannot see the email from SportsClick in your inbox, make sure to check your SPAM folder.",
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
