import 'dart:convert';
import 'package:flutter/material.dart';
import 'editsportcenterscreen.dart';
import 'sportcenter.dart';
import 'user.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toast/toast.dart';

class UserSportCenterScreen extends StatefulWidget {
  final User user;
  const UserSportCenterScreen({Key key, this.user}) : super(key: key);

  @override
  _UserSportCenterScreenState createState() => _UserSportCenterScreenState();
}

class _UserSportCenterScreenState extends State<UserSportCenterScreen> {
  List centerList;
  double screenHeight, screenWidth;
  String _titleCenter = "Loading Sport Center...";

  @override
  void initState() {
    _loadSportCenter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Text('My Sport Center', style: TextStyle(color: Colors.black)),
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
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            centerList == null
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
                    children: List.generate(centerList.length, (index) {
                      return Padding(
                        padding: EdgeInsets.all(1),
                        child: Card(
                            elevation: 0,
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                Container(
                                    height: screenHeight / 3.2,
                                    width: screenWidth / 1.1,
                                    child: CachedNetworkImage(
                                        imageUrl:
                                            "http://itprojectoverload.com/sportsclick/images/sportcenterimages/${centerList[index]['centerimage']}.jpg",
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            new CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            new Icon(Icons.broken_image,
                                                size: screenWidth / 3))),
                                Text(
                                    "Name: " + centerList[index]['centername']),
                                Text("Phone number: " +
                                    centerList[index]['centerphone']),
                                Text("Location: " +
                                    centerList[index]['centerlocation']),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          _editSportCenterScreen(index),
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
                                          _deleteSportCenterDialog(index),
                                    ),
                                  ],
                                )
                              ],
                            )),
                      );
                    }),
                  ))
          ]),
        ),
      ]),
    );
  }

  void _loadSportCenter() {
    http.post(
        "http://itprojectoverload.com/sportsclick/php/load_user_sportcenter.php",
        body: {
          "useremail": widget.user.email,
        }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        centerList = null;
        setState(() {
          _titleCenter = "No Sport Center Found";
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          centerList = jsondata["center"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _editSportCenterScreen(int index) {
    SportCenter sportCenter = new SportCenter(
      centerid: centerList[index]['centerid'],
      centername: centerList[index]['centername'],
      centerphone: centerList[index]['centerphone'],
      centerlocation: centerList[index]['centerlocation'],
      centeropentime: centerList[index]['centeropentime'],
      centerclosetime: centerList[index]['centerclosetime'],
      centerprice: centerList[index]['centerprice'],
      centeroffday: centerList[index]['centeroffday'],
      centerremarks: centerList[index]['centerremarks'],
      centerimage: centerList[index]['centerimage'],
      useremail: widget.user.email,
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                EditSportCenterScreen(sportCenter: sportCenter, user: widget.user)));
  }

  void _deleteSportCenterDialog(int index) {
    print("Delete " + centerList[index]['centername']);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text(
                "Delete " + centerList[index]['centername'] + "?",
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
                    _deleteSportCenter(index);
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

  void _deleteSportCenter(int index) {
    http.post("https://itprojectoverload.com/sportsclick/php/delete_sportcenter.php",
        body: {
          "useremail": widget.user.email,
          "centerid": centerList[index]['centerid'],
        }).then((res) {
      print(res.body);
      if (res.body == "success") {
        _loadSportCenter();
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
