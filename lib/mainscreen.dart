import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'addpostscreen.dart';
import 'editpostscreen.dart';
import 'user.dart';

class MainScreen extends StatefulWidget {
  final String email;
  const MainScreen({Key key, this.email}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List postList, userList;
  String _titleCenter = "Loading Post";
  double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Main Screen', style: TextStyle(color: Colors.black)),
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
            Flexible(
                child: IconButton(
              icon: Icon(Icons.chat),
              iconSize: 24,
              onPressed: () {
                print("onChat");
              },
            )),
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
                    childAspectRatio: (screenWidth / screenHeight) / 0.50,
                    children: List.generate(postList.length, (index) {
                      return Padding(
                          padding: EdgeInsets.all(1),
                          child: Card(
                            elevation: 0,
                            color: Colors.transparent,
                            child: InkWell(
                                onTap: () => _loadSportCenterDetail(
                                    index), //pass parameter need "() =>"
                                child: Column(
                                  children: [
                                    Container(
                                        height: screenHeight / 3.2,
                                        width: screenWidth / 1.1,
                                        child: CachedNetworkImage(
                                            imageUrl:
                                                "http://itprojectoverload.com/sportsclick/images/postimages/${postList[index]['postimage']}.jpg",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                new CircularProgressIndicator(),
                                            errorWidget: (context, url,
                                                    error) =>
                                                new Icon(Icons.broken_image,
                                                    size: screenWidth / 3))),
                                    Text("Title: " +
                                        postList[index]['posttitle']),
                                    Text("Description: " +
                                        postList[index]['postdesc']),
                                    Text(userList[0]['name'] +
                                        " (" +
                                        postList[index]['postdate'] +
                                        ")"),
                                  ],
                                )),
                          ));
                    }),
                  ))
          ]),
        ]));
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

  void _addPostScreen() {
    User user = new User(
      name: userList[0]['name'],
      email: userList[0]['email'],
      phone: userList[0]['phone'],
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AddPostScreen(user: user)));
  }

  void _editPostScreen() {
    User user = new User(
      name: userList[0]['name'],
      email: userList[0]['email'],
      phone: userList[0]['phone'],
    );
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => UserPostScreen(user: user)));
  }

  void _loadUser() {
    http.post("http://itprojectoverload.com/sportsclick/php/load_user.php",
        body: {
          "email": widget.email,
        }).then((res) {
      print(res.body);
      if (res.body != "nodata") {
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
