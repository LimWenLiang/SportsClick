import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'addpostscreen.dart';
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
        floatingActionButton:
            SpeedDial(animatedIcon: AnimatedIcons.menu_close, children: [
          SpeedDialChild(
              child: Icon(Icons.add),
              label: "Add Post",
              labelBackgroundColor: Colors.white,
              onTap: _addPostScreen),
          SpeedDialChild(
              child: Icon(Icons.edit),
              label: "Edit/Delete Post",
              labelBackgroundColor: Colors.white,
              onTap: _editPostScreen)
        ]),
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
        _titleCenter = "Loading User";
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          userList = jsondata["user"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }
}
