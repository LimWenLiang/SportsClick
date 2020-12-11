import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'resetscreen.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final TextEditingController _emcontroller = TextEditingController();
  String _email = "";
  String _emailError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: new Container(
        child: Padding(
            padding: EdgeInsets.all(20),
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
                      labelText: 'Email',
                      errorText: _emailError,
                      icon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 20),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    minWidth: 200,
                    height: 40,
                    child: Text('Verify'),
                    color: Colors.black,
                    textColor: Colors.white,
                    elevation: 15,
                    onPressed: _onVerify,
                  ),
                ]))),
      ),
    );
  }

  Future<void> _onVerify() async {
    _email = _emcontroller.text;
    if (_email.isNotEmpty) {
      setState(() {
        _emailError = null;
      });
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Sending email...");
      await pr.show();
      http.post(
          "http://itprojectoverload.com/sportsclick/php/forgot_password.php",
          body: {
            "email": _email,
          }).then((res) {
        print(res.body);
        print(_email);
        if (res.body == "success") {
          _showDialog();
        } else {
          Toast.show(
            "Failed to send. Please check your email.",
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
        _emailError = "Please enter your email";
      });
    }
  }

  _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Email Sent",
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
                "Go to reset password",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              borderSide: BorderSide(color: Colors.black),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ResetScreen(email: _email)));
              },
            ),
          ],
        );
      },
    );
  }
}
