import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sportsclick/sportcenter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'addsportcenterscreen.dart';
import 'sportcenterdetail.dart';
import 'user.dart';

class SportScreen extends StatefulWidget {
  final User user;
  const SportScreen({Key key, this.user}) : super(key: key);

  @override
  _SportScreenState createState() => _SportScreenState();
}

class _SportScreenState extends State<SportScreen> {
  List centerList;
  double screenHeight, screenWidth;
  String _titleCenter = "Loading Sport Center...";

  @override
  void initState() {
    super.initState();
    _loadSportCenter();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Sport Center', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          elevation: 20.0,
          actions: <Widget>[
            Flexible(
              child: IconButton(
                icon: Icon(Icons.add_circle_outline),
                iconSize: 24,
                onPressed: () {
                  _addCenterScreen();
                },
              ),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover)),
          ),
          Center(
              child: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[
              Colors.white54,
              Colors.white60,
              Colors.white54
            ])),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
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
                      childAspectRatio: (screenWidth / screenHeight) / 0.45,
                      children: List.generate(centerList.length, (index) {
                        return Padding(
                            padding: EdgeInsets.all(1),
                            child: Card(
                              elevation: 0,
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: () => _loadSportCenterDetail(index),
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
                                              errorWidget: (context, url,
                                                      error) =>
                                                  new Icon(Icons.broken_image,
                                                      size: screenWidth / 3))),
                                      Text("Name: " +
                                          centerList[index]['centername']),
                                      Text("Phone number: " +
                                          centerList[index]['centerphone']),
                                      Text("Location: " +
                                          centerList[index]['centerlocation']),
                                    ],
                                  )),
                            ));
                      }),
                    ))
            ]),
          )),
        ]));
  }

  void _loadSportCenter() {
    http.post(
        "http://itprojectoverload.com/sportsclick/php/load_sportcenter.php",
        body: {}).then((res) {
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

  _loadSportCenterDetail(int index) {
    print(centerList[index]['centername']);
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
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                SportCenterDetail(center: sportCenter)));
  }

  void _addCenterScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                AddSportCenterScreen(user: widget.user)));
  }
}
