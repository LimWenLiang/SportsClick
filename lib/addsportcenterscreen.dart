import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'user.dart';
import 'package:http/http.dart' as http;

class AddSportCenterScreen extends StatefulWidget {
  final User user;
  const AddSportCenterScreen({Key key, this.user}) : super(key: key);

  @override
  _AddSportCenterScreenState createState() => _AddSportCenterScreenState();
}

class _AddSportCenterScreenState extends State<AddSportCenterScreen> {
  double screenHeight, screenWidth, latitude, longitude;
  String _titleCenter = "Loading Sport Center...";
  String _mapTitle = "Press to choose your location";
  File _image;
  String pathAsset = 'assets/images/camera.png';
  bool image = false, location = false;

  String _name, _phone, _location, _remarks;
  final TextEditingController _nmcontroller = TextEditingController();
  final TextEditingController _hpcontroller = TextEditingController();
  final TextEditingController _loccontroller = TextEditingController();
  final TextEditingController _rmcontroller = TextEditingController();

  TimeOfDay _selectedOpenTime = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay _selectedCloseTime = TimeOfDay(hour: 00, minute: 00);

  String _selectedPrice = "RM4.00";
  String _selectedOffDay = "No Off Day";
  String _openTime, _closeTime;

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
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title:
              Text('Add Sport Center', style: TextStyle(color: Colors.black)),
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
                      EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      GestureDetector(
                          onTap: () => {_onPictureSelection()},
                          child: Container(
                            height: screenHeight / 3.2,
                            width: screenWidth / 1.8,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: _image == null
                                    ? AssetImage(pathAsset)
                                    : FileImage(_image),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                width: 3.0,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                      5.0) //         <--- border radius here
                                  ),
                            ),
                          )),
                      SizedBox(height: 5),
                      Text("Click image to take picture",
                          style:
                              TextStyle(fontSize: 10.0, color: Colors.black)),
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
                      SizedBox(height: 20),
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
                          Text("Close Time: ", style: TextStyle(fontSize: 17)),
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
                                        style: TextStyle(color: Colors.black)),
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
                                        style: TextStyle(color: Colors.black)),
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
                        child: Text('Add Sport Center'),
                        elevation: 15,
                        onPressed: _addNewCenterDialog,
                      ),
                    ],
                  )))),
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

  void _addNewCenterDialog() {
    print(_latitude);
    print(_longitude);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(
              "Add New Sport Center? ",
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
                  _onAddSportCenter();
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

  void _selectOpenTime() async {
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

  void _selectCloseTime() async {
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

  bool _validation(String name, String phone, String remarks) {
    if (name.isEmpty || phone.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void _onAddSportCenter() {
    _name = _nmcontroller.text;
    _phone = _hpcontroller.text;
    _location = _loccontroller.text;
    _remarks = _rmcontroller.text;
    _openTime = _selectedOpenTime.format(context);
    _closeTime = _selectedCloseTime.format(context);

    final dateTime = DateTime.now();
    String base64Image = "";
    try {
      if (base64Encode(_image.readAsBytesSync()) != null) {
        base64Image = base64Encode(_image.readAsBytesSync());
        image = true;
      } else {
        image = false;
      }
    } catch (Exception) {
      print(Exception);
    }
    print(base64Image);

    if (_remarks.isEmpty) {
      _remarks = "No Remarks";
    }

    if (_validation(_name, _phone, _remarks) && image && location) {
      http.post(
          "http://itprojectoverload.com/sportsclick/php/add_sportcenter.php",
          body: {
            "centername": _name,
            "centerphone": _phone,
            "centerlocation": _mapTitle,
            "centerlatitude": _latitude,
            "centerlongitude": _longitude,
            "centeropentime": _openTime,
            "centerclosetime": _closeTime,
            "centerprice": _selectedPrice,
            "centeroffday": _selectedOffDay,
            "centerremarks": _remarks,
            "centerimage":
                widget.user.name + "-${dateTime.microsecondsSinceEpoch}",
            "useremail": widget.user.email,
            "encoded_string": base64Image,
          }).then((res) {
        print(res.body);
        if (res.body == "success") {
          Toast.show(
            "Add Success",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
          Navigator.pop(context);
        } else {
          Toast.show(
            "Add Failed",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
        }
      }).catchError((err) {
        print(err);
      });
    } else {
      if (_name.isEmpty ||
          _phone.isEmpty ||
          image == false ||
          location == false) {
        Toast.show(
          "Incomplete Sport Center Details",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      } else {
        Toast.show(
          "Invalid Sport Center Details",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      }
    }
  }
}
