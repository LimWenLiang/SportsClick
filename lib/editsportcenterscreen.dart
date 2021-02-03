import 'package:flutter/material.dart';
import 'sportcenter.dart';
import 'user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditSportCenterScreen extends StatefulWidget {
  final SportCenter sportCenter;
  final User user;
  const EditSportCenterScreen({Key key, this.sportCenter, this.user})
      : super(key: key);

  @override
  _EditSportCenterScreenState createState() => _EditSportCenterScreenState();
}

class _EditSportCenterScreenState extends State<EditSportCenterScreen> {
  double screenHeight, screenWidth;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.sportCenter.centername,
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          elevation: 25.0,
        ),
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
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 80, left: 10, right: 10, bottom: 20),
                  child: SingleChildScrollView(
                      child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                          height: screenHeight / 3.7,
                          width: screenWidth / 2.4,
                          child: CachedNetworkImage(
                              imageUrl:
                                  "http://itprojectoverload.com/sportsclick/images/sportcenterimages/${widget.sportCenter.centerimage}.jpg",
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  new CircularProgressIndicator(),
                              errorWidget: (context, url, error) => new Icon(
                                  Icons.broken_image,
                                  size: screenWidth / 3))),
                      SizedBox(width: 5),
                      Container(
                          width: screenWidth / 2.4,
                          child: Column(children: [
                            Row(children: [
                              Flexible(
                                  child: Text(
                                      "Name: " + widget.sportCenter.centername))
                            ]),
                            Row(children: [
                              Flexible(
                                  child: Text("Phone Number: " +
                                      widget.sportCenter.centerphone))
                            ]),
                            Row(children: [
                              Flexible(
                                  child: Text("Location: " +
                                      widget.sportCenter.centerlocation))
                            ]),
                            Row(children: [
                              Flexible(
                                  child: Text("Open Time : " +
                                      widget.sportCenter.centeropentime))
                            ]),
                            Row(children: [
                              Flexible(
                                  child: Text("Close Time : " +
                                      widget.sportCenter.centerclosetime))
                            ]),
                            Row(children: [
                              Flexible(
                                  child: Text("Book Price (hour): " +
                                      widget.sportCenter.centerprice))
                            ]),
                            Row(children: [
                              Flexible(
                                  child: Text("Remarks: " +
                                      widget.sportCenter.centerremarks))
                            ]),
                          ])),
                    ]),
                  ]))))
        ]));
  }
}
