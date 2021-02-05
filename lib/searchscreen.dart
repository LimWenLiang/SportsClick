import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  double screenHeight, screenWidth;
  final TextEditingController _searchcontroller = TextEditingController();

  List postList, centerList;
  String _titleCenter = "Loading...";
  TabController _controller;
  int _selectedIndex = 0;

  List<Widget> list = [
    Tab(text: "Post"),
    Tab(text: "Sport Center"),
  ];

  @override
  void initState() {
    _loadSearchPost("");
    _loadSearchSportCenter("");
    super.initState();

    _controller = TabController(length: list.length, vsync: this);

    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
      print("Selected Index: " + _controller.index.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                //title: Text('Search', style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.transparent,
                elevation: 25.0,
                bottom: TabBar(
                  onTap: (index) {},
                  controller: _controller,
                  tabs: list,
                ),
                actions: <Widget>[
                  Container(
                      width: screenWidth / 1.9,
                      padding: EdgeInsets.fromLTRB(3, 10, 1, 10),
                      child: TextField(
                        autofocus: false,
                        controller: _searchcontroller,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(5.0),
                            ),
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      )),
                  SizedBox(width: 5),
                  Flexible(
                    child: IconButton(
                      icon: Icon(Icons.search),
                      iconSize: 24,
                      onPressed: () {
                        _onItemTapped(_selectedIndex);
                      },
                    ),
                  ),
                  Flexible(
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      iconSize: 24,
                      onPressed: () {
                        _onRefresh();
                      },
                    ),
                  ),
                ]),
            extendBodyBehindAppBar: true,
            body: TabBarView(controller: _controller, children: [
              Stack(children: <Widget>[
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
                                          onTap: () => {
                                                _loadSportCenterDetail(index),
                                              }, //pass parameter need "() =>"
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
                                                            text: postList[
                                                                    index]
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
                                                      placeholder: (context,
                                                              url) =>
                                                          new CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          new Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size:
                                                                  screenWidth /
                                                                      3))),
                                              RichText(
                                                  textAlign: TextAlign.left,
                                                  text: TextSpan(
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                            text:
                                                                "Posted by: "),
                                                        TextSpan(
                                                            text:
                                                                postList[index]
                                                                    ['name'],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ])),
                                              Text(
                                                  "Date/Time Posted: " +
                                                      _dateTime(index),
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                            ],
                                          ))),
                                ));
                          }),
                        ))
                ]),
              ]),
              Stack(children: <Widget>[
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
                                                            text: centerList[
                                                                    index]
                                                                ['centername'])
                                                      ])),
                                              Container(
                                                  height: screenHeight / 2.8,
                                                  width: screenWidth / 1.0,
                                                  child: CachedNetworkImage(
                                                      imageUrl:
                                                          "http://itprojectoverload.com/sportsclick/images/sportcenterimages/${centerList[index]['centerimage']}.jpg",
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          new CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          new Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size:
                                                                  screenWidth /
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
                                                                FontWeight
                                                                    .bold))
                                                  ])),
                                              RichText(
                                                  text: TextSpan(
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                      ),
                                                      children: [
                                                    TextSpan(
                                                        text: "Location: "),
                                                    TextSpan(
                                                        text: centerList[index]
                                                            ['centerlocation'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ])),
                                            ],
                                          )),
                                    )));
                          }),
                        ))
                ]),
              ])
            ])));
  }

  void _onItemTapped(int index) {
    if (_searchcontroller.text.isEmpty) {
      Toast.show(
        "Please enter post title or sport center name",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    } else {
      FocusScope.of(context)
          .requestFocus(FocusNode()); //hide keyboard after press
      setState(() {
        _selectedIndex = index;
        switch (index) {
          case 0:
            _loadSearchPost(_searchcontroller.text);
            break;
          case 1:
            _loadSearchSportCenter(_searchcontroller.text);
            break;
        }
      });
    }
  }

  Future<void> _onRefresh() async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading...");
    await pr.show();
    FocusScope.of(context).requestFocus(FocusNode());
    _searchcontroller.clear();
    _loadSearchPost("");
    _loadSearchSportCenter("");
    await pr.hide();
  }

  Future<void> _loadSearchPost(String posttitle) async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading...");
    await pr.show();
    http.post("https://itprojectoverload.com/sportsclick/php/load_post.php",
        body: {"posttitle": posttitle}).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        postList = null;
        setState(() {
          _titleCenter = "No Post Found";
        });

        Toast.show(
          "No Result",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          postList = jsondata["post"];
          if (posttitle.isNotEmpty) {
            Toast.show(
              "Search Found",
              context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.CENTER,
            );
          }
        });
      }
    }).catchError((err) {
      print(err);
    });
    await pr.hide();
  }

  Future<void> _loadSearchSportCenter(String centername) async {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading...");
    await pr.show();
    http.post(
        "https://itprojectoverload.com/sportsclick/php/load_sportcenter.php",
        body: {"centername": centername}).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        centerList = null;
        setState(() {
          _titleCenter = "No Sport Center Found";
        });
        Toast.show(
          "No Result",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          centerList = jsondata["center"];
          if (centername.isNotEmpty) {
            Toast.show(
              "Search Found",
              context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.CENTER,
            );
          }
        });
      }
    }).catchError((err) {
      print(err);
    });
    await pr.hide();
  }

  _loadSportCenterDetail(int index) {}
  String _dateTime(int index) {
    String s = postList[index]['postdate'];
    String result = s.substring(0, s.indexOf('.'));
    return result;
  }
}
