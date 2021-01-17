import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'loginscreen.dart';

class ResetScreen extends StatefulWidget {
  final String email;
  ResetScreen({Key key, this.email}) : super(key: key);
  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final TextEditingController _pscontroller = TextEditingController();
  final TextEditingController _ps2controller = TextEditingController();
  String _password = "";
  String _password2 = "";
  SharedPreferences prefs;
  bool _validatePassword = false;
  bool _validatePassword2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Reset Password', style: TextStyle(color: Colors.black)),
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
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: <Color>[
            Colors.white54,
            Colors.white60,
            Colors.white54
          ])),
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
                      controller: _pscontroller,
                      decoration: InputDecoration(
                          labelText: 'New Password',
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
                    SizedBox(height: 20),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.5),
                          borderRadius: BorderRadius.circular(20.0)),
                      minWidth: 180,
                      height: 40,
                      child: Text('Reset'),
                      elevation: 15,
                      onPressed: _onReset,
                    ),
                  ]))),
        )
      ]),
    );
  }

  Future<void> _onReset() async {
    _password = _pscontroller.text;
    _password2 = _ps2controller.text;

    if (_password.isNotEmpty && _password2.isNotEmpty) {
      if (validatePassword(_password)) {
        setState(() {
          _validatePassword = false;
        });
        if (_password == _password2) {
          setState(() {
            _validatePassword2 = false;
          });
          ProgressDialog pr = new ProgressDialog(context,
              type: ProgressDialogType.Normal, isDismissible: false);
          pr.style(message: "Reseting...");
          await pr.show();
          http.post(
              "http://itprojectoverload.com/sportsclick/php/reset_password.php",
              body: {
                "email": widget.email,
                "password": _password,
              }).then((res) {
            print(res.body);
            if (res.body == "success") {
              Toast.show(
                "Reset Success",
                context,
                duration: Toast.LENGTH_LONG,
                gravity: Toast.CENTER,
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen()));
            } else if (res.body == "noverify") {
              _showDialog();
              Toast.show(
                "Reset Failed",
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
          setState(() {
            _validatePassword2 = true;
          });
        }
      } else {
        setState(() {
          print("invalid password2");
          _validatePassword = true;
        });
      }
    } else {
      Toast.show(
        "Incomplete Details",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    }
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
