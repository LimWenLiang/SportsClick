import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'sportcenter.dart';
import 'user.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class EditSportCenterScreen extends StatefulWidget {
  final SportCenter sportCenter;
  final User user;
  const EditSportCenterScreen({Key key, this.sportCenter, this.user})
      : super(key: key);

  @override
  _EditSportCenterScreenState createState() => _EditSportCenterScreenState();
}

class _EditSportCenterScreenState extends State<EditSportCenterScreen> {
  double screenHeight, screenWidth, latitude, longitude;
  File _image;
  bool image = false, location = false;
  TextEditingController _nmcontroller;
  TextEditingController _hpcontroller;
  TextEditingController _loccontroller;
  TextEditingController _rmcontroller;

  TimeOfDay _selectedOpenTime;
  TimeOfDay _selectedCloseTime;

  String _selectedPrice = "RM4.00";
  String _selectedOffDay = "No Off Day";
  String _openTime, _closeTime;

  String _name, _phone, _location, _remarks, _currentImage = "", _mapTitle;

  var priceList = {
    "RM4.00",
    "RM4.50",
    "RM5.00",
    "RM5.50",
    "RM6.00",
    "RM6.50",
    "RM7.00",
    "RM7.50",
    "RM8.00"
  };
  var offDayList = {"No Off Day", "Public Holiday"};

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
    _nmcontroller = TextEditingController(text: widget.sportCenter.centername);
    _hpcontroller = TextEditingController(text: widget.sportCenter.centerphone);
    _mapTitle = widget.sportCenter.centerlocation;
    _selectedOpenTime = TimeOfDay(
        hour: _hour(widget.sportCenter.centeropentime),
        minute: _minute(widget.sportCenter.centeropentime));
    _selectedCloseTime = TimeOfDay(
        hour: _hour(widget.sportCenter.centerclosetime),
        minute: _minute(widget.sportCenter.centerclosetime));
    print(widget.sportCenter.centerclosetime);
    _selectedPrice = widget.sportCenter.centerprice;
    _selectedOffDay = widget.sportCenter.centeroffday;
    _rmcontroller =
        TextEditingController(text: widget.sportCenter.centerremarks);
    _getLocation();
    super.initState();
  }

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
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: 80, left: 10, right: 10, bottom: 20),
                      child: SingleChildScrollView(
                          child: Column(children: [
                        Column(
                          children: [
                            GestureDetector(
                                onTap: () => {_onPictureSelection()},
                                child: Container(
                                  height: screenHeight / 2.8,
                                  width: screenWidth / 1.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: _image == null
                                          ? NetworkImage(
                                              "http://itprojectoverload.com/sportsclick/images/sportcenterimages/${widget.sportCenter.centerimage}.jpg")
                                          : FileImage(_image),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                        width: 2.0, color: Colors.deepPurple),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            5.0) //         <--- border radius here
                                        ),
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text("Click camera to change new picture",
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.black)),
                        SizedBox(height: 5),
                        TextField(
                          controller: _nmcontroller,
                          keyboardType: TextInputType.name,
                          maxLength: 50,
                          decoration: InputDecoration(
                              labelText: 'Name',
                              icon: Icon(Icons.location_city),
                              hintText: 'Maximum of 50 characters'),
                        ),
                        TextField(
                          controller: _hpcontroller,
                          keyboardType: TextInputType.phone,
                          maxLength: 15,
                          decoration: InputDecoration(
                              labelText: 'Phone Number',
                              icon: Icon(Icons.phone),
                              hintText: 'Maximum of 15 characters'),
                        ),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_outlined),
                              SizedBox(width: 16),
                              Flexible(
                                child: GestureDetector(
                                    onTap: _loadMapDialog,
                                    child: Text(_mapTitle,
                                        style: TextStyle(fontSize: 16))),
                              )
                            ]),
                        SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Open Time: ", style: TextStyle(fontSize: 17)),
                            SizedBox(width: 18),
                            GestureDetector(
                                onTap: _selectOpenTime,
                                child: Text(
                                    '${_selectedOpenTime.format(context)}',
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Close Time: ",
                                style: TextStyle(fontSize: 17)),
                            SizedBox(width: 18),
                            GestureDetector(
                                onTap: _selectCloseTime,
                                child: Text(
                                    '${_selectedCloseTime.format(context)}',
                                    style: TextStyle(fontSize: 16))),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Booking Price (hour): ",
                                style: TextStyle(fontSize: 17)),
                            SizedBox(width: 18),
                            Container(
                                height: 50,
                                child: DropdownButton(
                                  value: _selectedPrice,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedPrice = newValue;
                                      print("Booking Price: " + _selectedPrice);
                                    });
                                  },
                                  items: priceList.map((selectedPrice) {
                                    return DropdownMenuItem(
                                      child: new Text(selectedPrice.toString(),
                                          style:
                                              TextStyle(color: Colors.black)),
                                      value: selectedPrice,
                                    );
                                  }).toList(),
                                )),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Off Day: ", style: TextStyle(fontSize: 17)),
                            SizedBox(width: 18),
                            Container(
                                height: 50,
                                child: DropdownButton(
                                  value: _selectedOffDay,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedOffDay = newValue;
                                      print("Off Day: " + _selectedOffDay);
                                    });
                                  },
                                  items: offDayList.map((selectedOffDay) {
                                    return DropdownMenuItem(
                                      child: new Text(selectedOffDay.toString(),
                                          style:
                                              TextStyle(color: Colors.black)),
                                      value: selectedOffDay,
                                    );
                                  }).toList(),
                                )),
                          ],
                        ),
                        TextField(
                          maxLines: 5,
                          controller: _rmcontroller,
                          keyboardType: TextInputType.name,
                          maxLength: 100,
                          decoration: InputDecoration(
                              labelText: 'Remarks',
                              icon: Icon(Icons.notes),
                              hintText: 'Maximum of 100 characters'),
                        ),
                        SizedBox(height: 10),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1.5),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          minWidth: 180,
                          height: 40,
                          child: Text('Edit Sport Center'),
                          elevation: 15,
                          onPressed: _editSportCenterDialog,
                        ),
                      ])))))
        ]));
  }

  _onPictureSelection() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: new Container(
                  //color: Colors.white,
                  height: screenHeight / 4,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Take picture from:",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            )),
                        SizedBox(height: 5),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                minWidth: 100,
                                height: 100,
                                child: Text('Camera',
                                    style: TextStyle(
                                      color: Colors.black,
                                    )),
                                color: Colors.grey,
                                textColor: Colors.black,
                                elevation: 10,
                                onPressed: () =>
                                    {Navigator.pop(context), _chooseCamera()},
                              )),
                              SizedBox(width: 10),
                              Flexible(
                                  child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                                minWidth: 100,
                                height: 100,
                                child: Text('Gallery',
                                    style: TextStyle(
                                      color: Colors.black,
                                    )),
                                color: Colors.grey,
                                textColor: Colors.black,
                                elevation: 10,
                                onPressed: () => {
                                  Navigator.pop(context),
                                  _chooseGallery(),
                                },
                              ))
                            ])
                      ])));
        });
  }

  void _chooseCamera() async {
    // ignore: deprecated_member_use
    _image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 800, maxWidth: 800);
    _cropImage();
    setState(() {});
  }

  void _chooseGallery() async {
    // ignore: deprecated_member_use
    _image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 800, maxWidth: 800);
    _cropImage();
    setState(() {});
  }

  Future<void> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Resize',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {});
    }
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
                    child: Text("Select Your Location",
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
                          child: Text('OK'),
                          color: Colors.deepPurple,
                          textColor: Colors.white,
                          elevation: 10,
                          onPressed: () => {
                            markers.clear(),
                            setState(() {
                              _mapTitle = _homeloc;
                            }),
                            location = true,
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
            _latitude = _currentPosition.latitude.toStringAsFixed(7);
            _longitude = _currentPosition.longitude.toStringAsFixed(7);
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

  Future<void> _selectOpenTime() async {
    final TimeOfDay pickOpenTime = await showTimePicker(
      context: context,
      initialTime: _selectedOpenTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (pickOpenTime != null) {
      setState(() {
        _selectedOpenTime = pickOpenTime;
      });
    }
  }

  Future<void> _selectCloseTime() async {
    final TimeOfDay pickCloseTime = await showTimePicker(
      context: context,
      initialTime: _selectedCloseTime,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (pickCloseTime != null) {
      setState(() {
        _selectedCloseTime = pickCloseTime;
      });
    }
  }

  void _editSportCenterDialog() {
    _name = _nmcontroller.text;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(
              "Edit " + widget.sportCenter.centername + " to " + _name + "?",
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
                  Navigator.of(context).pop();
                  _onEditSportCenter();
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

  int _hour(String time) {
    String hour;

    if (time.length == 7) {
      hour = "0" + time[0];
    } else {
      hour = time[0] + time[1];
      print(time[7]);
      if (hour == "12" && time[6] == "A") {
        hour = (int.parse(hour) - 12).toString();
      }
    }
    return int.parse(hour);
  }

  int _minute(String time) {
    String minute;

    if (time.length == 7) {
      minute = time[2] + time[3];
    } else {
      minute = time[3] + time[4];
    }
    return int.parse(minute);
  }

  void _onEditSportCenter() {
    final dateTime = DateTime.now();
    String base64Image = "";

    _name = _nmcontroller.text;
    _phone = _hpcontroller.text;
    _location = _mapTitle;
    _remarks = _rmcontroller.text;
    _openTime = _selectedOpenTime.format(context);
    _closeTime = _selectedCloseTime.format(context);

    try {
      if (base64Encode(_image.readAsBytesSync()) != null) {
        base64Image = base64Encode(_image.readAsBytesSync());
        _currentImage =
            widget.user.name + "-${dateTime.microsecondsSinceEpoch}";
      } else {
        _currentImage = widget.sportCenter.centerimage;
      }
    } catch (Exception) {
      print(Exception);
    }

    http.post(
        "http://itprojectoverload.com/sportsclick/php/edit_sportcenter.php",
        body: {
          "centerid": widget.sportCenter.centerid,
          "centername": _name,
          "centerphone": _phone,
          "centerlocation": _location,
          "centeropentime": _openTime,
          "centerclosetime": _closeTime,
          "centerprice": _selectedPrice,
          "centeroffday": _selectedOffDay,
          "centerremarks": _remarks,
          "centerimage": _currentImage,
          "useremail": widget.sportCenter.useremail,
          "encoded_string": base64Image,
        }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show(
          "Edit Success",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        Navigator.pop(context);
      } else {
        Toast.show(
          "Edit Failed",
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
