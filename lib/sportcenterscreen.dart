import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sportsclick/sportcenter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'sportcenterdetail.dart';

class SportCenterScreen extends StatefulWidget {
  final String email;
  const SportCenterScreen({Key key, this.email}) : super(key: key);

  @override
  _SportCenterScreenState createState() => _SportCenterScreenState();
}

class _SportCenterScreenState extends State<SportCenterScreen> {
  List centerList;
  double screenHeight, screenWidth;
  String _titleCenter = "Loading Sport Center...";
  String username = "Loading Username";
  List userList;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadSportCenter();
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
                      childAspectRatio: (screenWidth / screenHeight) / 0.6,
                      children: List.generate(centerList.length, (index) {
                        return Padding(
                            padding: EdgeInsets.all(1),
                            child: Card(
                                elevation: 0,
                                color: Colors.transparent,
                                child: SingleChildScrollView(
                                  child: InkWell(
                                      onTap: () =>
                                          _loadSportCenterDetail(index),
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
                                                        text: centerList[index]
                                                            ['centername'])
                                                  ])),
                                          Container(
                                              height: screenHeight / 2.8,
                                              width: screenWidth / 1.0,
                                              child: CachedNetworkImage(
                                                  imageUrl:
                                                      "http://itprojectoverload.com/sportsclick/images/sportcenterimages/${centerList[index]['centerimage']}.jpg",
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      new CircularProgressIndicator(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      new Icon(
                                                          Icons.broken_image,
                                                          size: screenWidth /
                                                              3))),
                                          RichText(
                                              text: TextSpan(
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                  ),
                                                  children: [
                                                TextSpan(
                                                    text: "Phone number: "),
                                                TextSpan(
                                                    text: centerList[index]
                                                        ['centerphone'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ])),
                                          RichText(
                                              text: TextSpan(
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                  ),
                                                  children: [
                                                TextSpan(text: "Location: "),
                                                TextSpan(
                                                    text: centerList[index]
                                                        ['centerlocation'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ])),
                                        ],
                                      )),
                                )));
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

  Future<Null> refresh() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));
    _loadSportCenter();

    return null;
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
}
