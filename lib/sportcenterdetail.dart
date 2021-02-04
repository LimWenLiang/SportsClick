import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sportsclick/sportcenter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

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
      extendBodyBehindAppBar: true,
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
        Padding(
          padding: EdgeInsets.only(top: 80, left: 10, right: 10, bottom: 20),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Container(
                    height: screenHeight / 2.8,
                    width: screenWidth / 1.0,
                    child: CachedNetworkImage(
                        imageUrl:
                            "http://itprojectoverload.com/sportsclick/images/sportcenterimages/${widget.center.centerimage}.jpg",
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            new CircularProgressIndicator(),
                        errorWidget: (context, url, error) => new Icon(
                            Icons.broken_image,
                            size: screenWidth / 3))),
                SizedBox(height: 20),
                RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        children: [
                          TextSpan(text: "Phone Number: "),
                          TextSpan(
                              text: widget.center.centerphone,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])),
                Row(children: [
                  Text("Location: ", style: TextStyle(fontSize: 17)),
                ]),
                Text(widget.center.centerlocation,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        children: [
                          TextSpan(text: "Open Time : "),
                          TextSpan(
                              text: widget.center.centeropentime,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])),
                RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        children: [
                          TextSpan(text: "Close Time : "),
                          TextSpan(
                              text: widget.center.centerclosetime,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])),
                RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        children: [
                          TextSpan(text: "Book Price (hour): "),
                          TextSpan(
                              text: widget.center.centerprice,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])),
                RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                        children: [
                          TextSpan(text: "Off Day: "),
                          TextSpan(
                              text: widget.center.centeroffday,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])),
                Text("Remarks: ", style: TextStyle(fontSize: 17)),
                Text(widget.center.centerremarks,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ])),
        )
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
}
