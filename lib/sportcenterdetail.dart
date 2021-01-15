import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sportsclick/sportcenter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'court.dart';
import 'courtdetail.dart';

class SportCenterDetail extends StatefulWidget {
  final SportCenter center;
  const SportCenterDetail({Key key, this.center}) : super(key: key);

  @override
  _SportCenterDetailState createState() => _SportCenterDetailState();
}

class _SportCenterDetailState extends State<SportCenterDetail> {
  double screenHeight, screenWidth;
  List courtList;
  String _titleCenter = "Loading Court...";

  @override
  void initState() {
    super.initState();
    _loadCourt();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.center.centername,
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          elevation: 20.0),
      extendBodyBehindAppBar: false,
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover)),
        ),
        Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[
          Colors.white54,
          Colors.white60,
          Colors.white54
        ]))),
        Column(children: <Widget>[
          Container(
              height: screenHeight / 1.6,
              width: screenWidth / 1.1,
              child: CachedNetworkImage(
                  imageUrl:
                      "http://itprojectoverload.com/sportsclick/images/${widget.center.centerimage}.jpg",
                  fit: BoxFit.scaleDown,
                  placeholder: (context, url) =>
                      new CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      new Icon(Icons.broken_image, size: screenWidth / 3))),
          courtList == null
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
                  crossAxisCount: 2,
                  childAspectRatio: (screenWidth / screenHeight) / 0.25,
                  children: List.generate(courtList.length, (index) {
                    return Padding(
                        padding: EdgeInsets.all(1),
                        child: Card(
                          child: InkWell(
                              onTap: () => _loadCourtDetail(
                                  index), //pass parameter need "() =>"
                              child: Column(
                                children: [
                                  Text("Court Type: " +
                                      courtList[index]['courttype']),
                                  Text("Price per Hour: RM" +
                                      courtList[index]['courtprice']),
                                  Text("Quantity: " +
                                      courtList[index]['courtqty']),
                                ],
                              )),
                        ));
                  }),
                )),
        ]),
      ]),
    );
  }

  void _loadCourt() {
    http.post("http://itprojectoverload.com/sportsclick/php/load_court.php",
        body: {
          "centerid": widget.center.centerid,
        }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        courtList = null;
        setState(() {
          _titleCenter = "No Court Found";
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          courtList = jsondata["court"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  _loadCourtDetail(int index) {
    print(courtList[index]['courttype']);
    Court court = new Court(
      courtid: courtList[index]['courtid'],
      courttype: courtList[index]['courttype'],
      courtprice: courtList[index]['courtprice'],
      courtqty: courtList[index]['courtqty'],
      centerid: widget.center.centerid
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => CourtDetail(court: court)));
  }
}
