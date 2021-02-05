import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sportsclick/postscreen.dart';
import 'addpostscreen.dart';
import 'addsportcenterscreen.dart';
import 'loginscreen.dart';
import 'searchscreen.dart';
import 'sportcenterscreen.dart';
import 'user.dart';
import 'userpostscreen.dart';
import 'usersportcenterscreen.dart';

class MainScreen extends StatefulWidget {
  final String email;
  const MainScreen({Key key, this.email}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double screenHeight, screenWidth;
  String _appBarName;
  int _selectedIndex = 0;
  List<Widget> _widgetOptions;
  String username = "Loading Username";
  List userList, postList;
  String posttitle;

  @override
  void initState() {
    _loadUser();
    _onItemTapped(_selectedIndex);
    _widgetOptions = [
      PostScreen(email: widget.email, posttitle: posttitle),
      SportCenterScreen(email: widget.email),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarName, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 25.0,
        actions: <Widget>[
          Flexible(
            child: IconButton(
              icon: Icon(Icons.add_circle_outline),
              iconSize: 24,
              onPressed: () {
                _onAddButton(_selectedIndex);
              },
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Sport Center',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      drawer: Container(
          width: 300,
          child: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Stack(
                    children: <Widget>[
                      // Stroked text as border.
                      Positioned(
                          bottom: 12.0,
                          right: 5.0,
                          child: Container(
                              child: Stack(children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 25,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = Colors.black,
                              ),
                            ),
                            // Solid text as fill.
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                          ])))
                    ],
                  ),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/background.png"),
                          fit: BoxFit.cover)),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 20),
                      Text('Search'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => SearchScreen()));
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.home),
                      SizedBox(width: 20),
                      Text('My Post'),
                    ],
                  ),
                  onTap: () {
                    //Navigator.pop(context);
                    _userPostScreen();
                    //_askLogin(widget.email);
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.sports_soccer),
                      SizedBox(width: 20),
                      Text('My Sport Center'),
                    ],
                  ),
                  onTap: () {
                    _userSportCenterScreen();
                    //Navigator.pop(context);
                    //_askLogin(widget.email);
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 20),
                      Text('Logout'),
                    ],
                  ),
                  onTap: () {
                    //Navigator.pop(context);
                    _onLogout();
                  },
                ),
              ],
            ),
          )),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _appBarName = "Discover";
          break;
        case 1:
          _appBarName = "Sport Center";
          break;
      }
    });
  }

  void _loadUser() {
    http.post("http://itprojectoverload.com/sportsclick/php/load_user.php",
        body: {
          "email": widget.email,
        }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        setState(() {
          username = "Guest";
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          userList = jsondata["user"];
          username = userList[0]['name'];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _onAddButton(int index) {
    switch (index) {
      case 0:
        _addPostScreen();
        break;
      case 1:
        _addCenterScreen();
        break;
    }
  }

  Future<void> _addPostScreen() async {
    User user = new User(
      name: userList[0]['name'],
      email: userList[0]['email'],
      phone: userList[0]['phone'],
    );
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AddPostScreen(user: user)));
  }

  Future<void> _addCenterScreen() async {
    User user = new User(
      name: userList[0]['name'],
      email: userList[0]['email'],
      phone: userList[0]['phone'],
    );
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                AddSportCenterScreen(user: user)));
  }

  Future<void> _userPostScreen() async {
    User user = new User(
      name: userList[0]['name'],
      email: userList[0]['email'],
      phone: userList[0]['phone'],
    );
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UserPostScreen(user: user)));
  }

  Future<void> _userSportCenterScreen() async {
    User user = new User(
      name: userList[0]['name'],
      email: userList[0]['email'],
      phone: userList[0]['phone'],
    );
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                UserSportCenterScreen(user: user)));
  }

  void _onLogout() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(
              "Are you sure you want to logout?",
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
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginScreen()));
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
            ],
          );
        });
  }
}
