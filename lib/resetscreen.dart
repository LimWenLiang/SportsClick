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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
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
                    controller: _pscontroller,
                    decoration: InputDecoration(
                        labelText: 'New Password', icon: Icon(Icons.lock)),
                    obscureText: true,
                  ),
                  TextField(
                    controller: _ps2controller,
                    decoration: InputDecoration(
                        labelText: 'Confirm Password', icon: Icon(Icons.lock)),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    minWidth: 200,
                    height: 40,
                    child: Text('Reset'),
                    color: Colors.black,
                    textColor: Colors.white,
                    elevation: 15,
                    onPressed: _onReset,
                  ),
                ]))),
      ),
    );
  }

  Future<void> _onReset() async {
    _password = _pscontroller.text;
    _password2 = _ps2controller.text;

    if (_password.isNotEmpty && _password2.isNotEmpty) {
      if (_password == _password2) {
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
          } else {
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
        Toast.show(
          "Password didn't match. Please try again.",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
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
}
