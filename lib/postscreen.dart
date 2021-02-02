import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'loginscreen.dart';

class PostScreen extends StatefulWidget {
  final String email;
  const PostScreen({Key key, this.email}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List postList, userList, postUserList;
  String _titleCenter = "Loading Post...";
  double screenHeight, screenWidth;
  DateTime date;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
        key: refreshKey,
        onRefresh: refresh,
        child: Stack(children: <Widget>[
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

  Future<Null> refresh() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));
    _loadPost();

    return null;
  }

  _loadSportCenterDetail(int index) {}

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
