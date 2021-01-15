import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'court.dart';

class CourtDetail extends StatefulWidget {
  final Court court;
  const CourtDetail({Key key, this.court}) : super(key: key);

  @override
  _CourtDetailState createState() => _CourtDetailState();
}

class _CourtDetailState extends State<CourtDetail> {
  double screenHeight, screenWidth;
  List bookingList;
  String _status = "Available";
  String _titleCenter = "Loading Booking Details";
  bool _book = false;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.court.courttype,
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
          bookingList == null
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
                  children: List.generate(bookingList.length, (index) {
                    return Padding(
                      padding: EdgeInsets.all(1),
                      child: Card(
                          child: Column(
                        children: [
                          Text("Court Type: " +
                              bookingList[index]['bookingid']),
                        ],
                      )),
                    );
                  }),
                )),
          FittedBox(
              child: DataTable(columns: [
            DataColumn(
              label: Text("Start Time", style: TextStyle(fontSize: 17)),
            ),
            DataColumn(
              label: Text("End Time", style: TextStyle(fontSize: 17)),
            ),
            DataColumn(
              label: Text("Status", style: TextStyle(fontSize: 17)),
            ),
            DataColumn(
              label: Text("Select", style: TextStyle(fontSize: 17)),
            ),
          ], rows: [
            DataRow(
              cells: [
                DataCell(
                  Text("9.00am", style: TextStyle(fontSize: 16)),
                ),
                DataCell(
                  Text("10.00am", style: TextStyle(fontSize: 16)),
                ),
                DataCell(
                  Text(_status, style: TextStyle(fontSize: 16)),
                ),
                DataCell(
                  Checkbox(
                    value: _book,
                    onChanged: (bool value) {
                      _onChange(value);
                    },
                  ),
                )
              ],
            ),
          ]))
        ]),
      ]),
    );
  }

  void _loadBooking() {
    http.post("http://itprojectoverload.com/sportsclick/php/load_court.php",
        body: {
          "bookingid": widget.court.courtid,
        }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        bookingList = null;
        setState(() {
          _titleCenter = "No Booking Found";
        });
      } else {
        setState(() {
          var jsondata = json.decode(res.body);
          bookingList = jsondata["booking"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void _onChange(bool value) {}
}
