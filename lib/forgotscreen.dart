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
            title:
                Text('Verify Account', style: TextStyle(color: Colors.black)),
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
                          labelText: 'Email',
                          errorText: _emailError,
                          icon: Icon(Icons.email),
                        ),
                      ),
                      SizedBox(height: 20),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1.5),
                            borderRadius: BorderRadius.circular(20.0)),
                        minWidth: 180,
                        height: 40,
                        child: Text('Verify Account'),
                        elevation: 15,
                        onPressed: _onVerify,
                      ),
                    ]))),
          ),
        ]));
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
            "Failed to verify. Please check your email.",
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
