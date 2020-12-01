import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _pscontroller = TextEditingController();
  final TextEditingController _ps2controller = TextEditingController();

  String _password = "";
  String _password2 = "";

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

  void _onReset() {}
}
