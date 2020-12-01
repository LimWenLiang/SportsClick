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
  SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registeration'),
      ),
      body: new Container(
        child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: SingleChildScrollView(
                child: Column(children: [
              Image.asset(
                'assets/images/sportsclick.png',
                scale: 5.5,
              ),
              TextField(
                  controller: _nmcontroller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Name', icon: Icon(Icons.person))),
              TextField(
                  controller: _emcontroller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', icon: Icon(Icons.email))),
              TextField(
                  controller: _phcontroller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Phone', icon: Icon(Icons.phone))),
              TextField(
                controller: _pscontroller,
                decoration: InputDecoration(
                    labelText: 'Password', icon: Icon(Icons.lock)),
                obscureText: true,
              ),
              TextField(
                controller: _ps2controller,
                decoration: InputDecoration(
                    labelText: 'Confirm Password', icon: Icon(Icons.lock)),
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
                child: Text('Register'),
                color: Colors.black,
                textColor: Colors.white,
                elevation: 15,
                onPressed: _onRegister,
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                  onTap: _onLogin,
                  child:
                      Text('Already Register', style: TextStyle(fontSize: 15))),
            ]))),
      ),
    );
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
            Toast.show(
              "Registration Success. An email has been sent to .$_email. Please check your email for OTP verification. Also check in your spam folder.",
              context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.CENTER,
            );
            _onLogin();
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
}
