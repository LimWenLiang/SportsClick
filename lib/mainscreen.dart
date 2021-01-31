import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'addpostscreen.dart';
import 'loginscreen.dart';
import 'userpostscreen.dart';
import 'user.dart';

class MainScreen extends StatefulWidget {
  final String email;
  const MainScreen({Key key, this.email}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List postList, userList, postUserList;
  String _titleCenter = "Loading Post...";
  String username = "Loading Username";
  double screenHeight, screenWidth;
  DateTime date;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPost();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('SportsClick', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          elevation: 25.0,
          actions: <Widget>[
            Flexible(
              child: IconButton(
                icon: Icon(Icons.refresh),
                iconSize: 24,
                onPressed: () {
                  _loadPost();
                },
              ),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        drawer: Container(
            width: 220,
            child: Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Stack(
                      children: <Widget>[
                        // Stroked text as border.
                        Positioned(
                            bottom: 12.0,
                            right: 5.0,
                            child: Container(
                                child: Stack(children: [
                              Text(
                                username,
                                style: TextStyle(
                                  fontSize: 25,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 6
                                    ..color = Colors.black,
                                ),
                              ),
                              // Solid text as fill.
                              Text(
                                username,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ])))
                      ],
                    ),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/background.png"),
                            fit: BoxFit.cover)),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 20),
                        Text('My Post'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _editPostScreen();
                      //_askLogin(widget.email);
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 20),
                        Text('Profile'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      //_askLogin(widget.email);
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.sports_soccer),
                        SizedBox(width: 20),
                        Text('Sport Center'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      //_askLogin(widget.email);
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 20),
                        Text('Logout'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _onLogout();
                    },
                  ),
                ],
              ),
            )),
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
          ),
          Container(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  _addPostScreen();
                },
                child: Icon(Icons.add),
              )),
          Column(children: [
            postList == null
                ? Flexible(
                    child: Container(
                    child: Center(
                      child: Text(_titleCenter,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ))
                : Flexible(
                    child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: (screenWidth / screenHeight) / 0.6,
                    children: List.generate(postList.length, (index) {
                      return Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Card(
                            elevation: 0,
                            color: Colors.transparent,
                            child: SingleChildScrollView(
                                child: InkWell(
                                    onTap: () => _loadSportCenterDetail(
                                        index), //pass parameter need "() =>"
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                            textAlign: TextAlign.left,
                                            text: TextSpan(
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                      text: postList[index]
                                                          ['posttitle'])
                                                ])),
                                        RichText(
                                            text: TextSpan(
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                                children: [
                                              TextSpan(
                                                  text: postList[index]
                                                      ['postdesc'])
                                            ])),
                                        Container(
                                            height: screenHeight / 2.8,
                                            width: screenWidth / 1.0,
                                            child: CachedNetworkImage(
                                                imageUrl:
                                                    "http://itprojectoverload.com/sportsclick/images/postimages/${postList[index]['postimage']}.jpg",
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    new CircularProgressIndicator(),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    new Icon(Icons.broken_image,
                                                        size:
                                                            screenWidth / 3))),
                                        RichText(
                                            textAlign: TextAlign.left,
                                            text: TextSpan(
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                ),
                                                children: [
                                                  TextSpan(text: "Posted by: "),
                                                  TextSpan(
                                                      text: postList[index]
                                                          ['name'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ])),
                                        Text(
                                            "Date/Time Posted: " +
                                                _dateTime(index),
                                            style: TextStyle(fontSize: 10)),
                                      ],
                                    ))),
                          ));
                    }),
                  ))
          ]),
        ]));
  }

  String _dateTime(int index) {
    String s = postList[index]['postdate'];
    String result = s.substring(0, s.indexOf('.'));
    return result;
  }

  void _loadPost() {
    print("Load Post");
    http.post("http://itprojectoverload.com/sportsclick/php/load_post.php",
        body: {}).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        postList = null;
        setState(() {
          _titleCenter = "No Post Found";
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          postList = jsondata["post"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  _loadSportCenterDetail(int index) {}

  Future<void> _addPostScreen() async {
    User user = new User(
      name: userList[0]['name'],
      email: userList[0]['email'],
      phone: userList[0]['phone'],
    );
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AddPostScreen(user: user)));
    _loadPost();
  }

  Future<void> _editPostScreen() async {
    User user = new User(
      name: userList[0]['name'],
      email: userList[0]['email'],
      phone: userList[0]['phone'],
    );
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UserPostScreen(user: user)));
    _loadPost();
  }

  void _loadUser() {
    http.post("http://itprojectoverload.com/sportsclick/php/load_user.php",
        body: {
          "email": widget.email,
        }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        setState(() {
          username = "Guest";
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          userList = jsondata["user"];
          username = userList[0]['name'];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _onLogout() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(
              "Are you sure you want to logout?",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginScreen()));
                },
              ),
              new FlatButton(
                child: new Text(
                  "No",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _askLogin(String email) {
    if (email.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text(
                "Please Login Account to continue.",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text(
                    "Login Account",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => LoginScreen()));
                  },
                ),
              ],
            );
          });
    }
  }
}
