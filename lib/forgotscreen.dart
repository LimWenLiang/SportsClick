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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification'),
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
                      labelText: 'Email',
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
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Verifying...");
    await pr.show();
    http.post("http://itprojectoverload.com/sportsclick/php/forgot_password.php",
        body: {
          "email": _email,
        }).then((res) {
      print(res.body);
      print(_email);
      if (res.body == "SUCCESS") {
        Toast.show(
          "Verify Success",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ResetScreen(email:_email)));
      } else {
        Toast.show(
          "Verify Failed, Please check your email.",
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
}
