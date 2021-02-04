import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sportsclick/sportcenter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';

class SportCenterDetail extends StatefulWidget {
  final SportCenter center;
  const SportCenterDetail({Key key, this.center}) : super(key: key);

  @override
  _SportCenterDetailState createState() => _SportCenterDetailState();
}

class _SportCenterDetailState extends State<SportCenterDetail> {
  double screenHeight, screenWidth, latitude, longitude;
  List courtList;
  String _titleCenter = "Loading Court...";
  String _mapTitleCenter = "Loading Map...";
  String _homeloc = "";
  String _latitude = "";
  String _longitude = "";
  Position _currentPosition;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
    _loadCourt();
    _getLocation();
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
                  RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                          children: [
                            TextSpan(text: "Venue: "),
                            TextSpan(
                                text: widget.center.centerlocation,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ])),
                  GestureDetector(
                    onTap: _loadMapDialog,
                    child: Row(children: [
                      Icon(Icons.location_on_outlined),
                    ]),
                  ),
                ]),
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

  void _loadMapDialog() {
    _controller = null;
    try {
      if (_currentPosition.latitude == null) {
        Toast.show("Current location not available. Please wait...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _getLocation(); //_getCurrentLocation();
        return;
      }
      _controller = Completer();
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              var alheight = MediaQuery.of(context).size.height;
              var alwidth = MediaQuery.of(context).size.width;
              return AlertDialog(
                  //scrollable: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  title: Center(
                    child: Text("Select New Delivery Location",
                        style: TextStyle(color: Colors.black, fontSize: 14)),
                  ),
                  //titlePadding: EdgeInsets.all(5),
                  //content: Text(_homeloc),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          _homeloc,
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        Container(
                          height: alheight - 250,
                          width: alwidth - 10,
                          child: GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(latitude, longitude),
                                  zoom: 17),
                              markers: markers.toSet(),
                              onMapCreated: (controller) {
                                _controller.complete(controller);
                              },
                              onTap: (newLatLng) {
                                _loadLoc(newLatLng, newSetState);
                              }),
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          //minWidth: 200,
                          height: 30,
                          child: Text('Close'),
                          color: Colors.deepPurple,
                          textColor: Colors.white,
                          elevation: 10,
                          onPressed: () => {
                            markers.clear(),
                            Navigator.of(context).pop(false),
                          },
                        ),
                      ],
                    ),
                  ));
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }

  Future<void> _getLocation() async {
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
              markers.add(Marker(
                markerId: markerId1,
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(
                  title: 'Location',
                  snippet: 'Your Location',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet),
              ));
              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }

  void _loadLoc(LatLng loc, newSetState) {
    newSetState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, newSetState);
      _home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      markers.add(Marker(
        markerId: markerId1,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: 'New Location',
          snippet: 'New Selected  Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ));
    });
    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng, setState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      _latitude = lat.toStringAsFixed(7);
      _longitude = lng.toStringAsFixed(7);
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;
        return;
      }
    });
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }
}
