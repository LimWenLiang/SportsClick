import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'editpostscreen.dart';
import 'post.dart';
import 'user.dart';

class UserPostScreen extends StatefulWidget {
  final User user;
  const UserPostScreen({Key key, this.user}) : super(key: key);

  @override
  _UserPostScreenState createState() => _UserPostScreenState();
}

class _UserPostScreenState extends State<UserPostScreen> {
  double screenHeight, screenWidth;
  List postList;
  String _titleCenter = "Loading Post...";

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            title: Text('My Post', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.transparent,
            elevation: 25.0,
            actions: <Widget>[]),
        extendBodyBehindAppBar: true,
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover)),
          ),
          Container(
            alignment: Alignment.topCenter,
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
                    childAspectRatio: (screenWidth / screenHeight) / 0.60,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                        textAlign: TextAlign.left,
                                        text: TextSpan(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
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
                                              text: postList[index]['postdesc'])
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
                                                    size: screenWidth / 3))),
                                    Text(
                                        "Date/Time Posted: " + _dateTime(index),
                                        style: TextStyle(fontSize: 10)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MaterialButton(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          minWidth: 130,
                                          height: 40,
                                          child: Text('Edit'),
                                          elevation: 15,
                                          onPressed: () =>
                                              _editPostScreen(index),
                                        ),
                                        SizedBox(width: 10),
                                        MaterialButton(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          minWidth: 130,
                                          height: 40,
                                          child: Text('Delete'),
                                          elevation: 15,
                                          onPressed: () =>
                                              _deletePostDialog(index),
                                        ),
                                      ],
                                    )
                                  ],
                                )),
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
    http.post("http://itprojectoverload.com/sportsclick/php/load_user_post.php",
        body: {
          "useremail": widget.user.email,
        }).then((res) {
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

  Future<void> _editPostScreen(int index) async {
    Post post = new Post(
      postid: postList[index]['postid'],
      posttitle: postList[index]['posttitle'],
      postdesc: postList[index]['postdesc'],
      postimage: postList[index]['postimage'],
      useremail: widget.user.email,
    );
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                EditPostScreen(post: post, user: widget.user)));
    _loadPost();
  }

  void _deletePostDialog(int index) {
    print("Delete " + postList[index]['posttitle']);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text(
                "Delete post " + postList[index]['posttitle'] + "?",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              content: new Text(
                "Are your sure? ",
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
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _deletePost(index);
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
              ]);
        });
  }

  void _deletePost(int index) {
    http.post("https://itprojectoverload.com/sportsclick/php/delete_post.php",
        body: {
          "useremail": widget.user.email,
          "postid": postList[index]['postid'],
        }).then((res) {
      print(res.body);
      if (res.body == "success") {
        _loadPost();
        Toast.show(
          "Delete Success",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      } else {
        Toast.show(
          "Delete Failed",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      }
    }).catchError((err) {
      print(err);
    });
  }
}
