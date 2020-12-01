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
            title: Text('Login'),
          ),
          body: new Container(
            child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
                          borderRadius: BorderRadius.circular(20.0)),
                      minWidth: 200,
                      height: 40,
                      child: Text('Login'),
                      color: Colors.black,
                      textColor: Colors.white,
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
                        child: Text('Forgot Account',
                            style: TextStyle(fontSize: 15))),
                  ],
                ))),
          )),
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
      if (_email.length < 4 && _password.length < 4) {
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
      if (res.body == "SUCCESS") {
        Toast.show(
          "Login Success",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
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
  }

  void _onRegister() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => RegisterScreen()));
  }

  void _onForgot() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => ForgotScreen()));
  }
}
