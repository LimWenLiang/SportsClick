import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'listitem.dart';
import 'user.dart';

class AddSportCenterScreen extends StatefulWidget {
  final User user;
  const AddSportCenterScreen({Key key, this.user}) : super(key: key);

  @override
  _AddSportCenterScreenState createState() => _AddSportCenterScreenState();
}

class _AddSportCenterScreenState extends State<AddSportCenterScreen> {
  double screenHeight, screenWidth;
  String _titleCenter = "Loading Sport Center...";
  File _image;
  String pathAsset = 'assets/images/camera.png';
  String _title, _description;
  int titleCharLength = 50;
  int descCharLength = 100;

  final TextEditingController _nmcontroller = TextEditingController();
  final TextEditingController _hpcontroller = TextEditingController();
  final TextEditingController _loccontroller = TextEditingController();
  final TextEditingController _rmcontroller = TextEditingController();

  TimeOfDay _openTime = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay _closeTime = TimeOfDay(hour: 00, minute: 00);

  String selectedPrice = "RM4.00";
  String selectedOffDay = "No Off Day";

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
                        decoration: InputDecoration(
                          labelText: 'Name',
                          icon: Icon(Icons.location_city),
                        ),
                        onChanged: _onChangedTitle,
                      ),
                      TextField(
                        controller: _hpcontroller,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          icon: Icon(Icons.phone),
                        ),
                        onChanged: _onChangedDesc,
                      ),
                      TextField(
                        controller: _loccontroller,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Venue',
                          icon: Icon(Icons.location_on_outlined),
                        ),
                        onChanged: _onChangedDesc,
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Open Time: ", style: TextStyle(fontSize: 17)),
                          SizedBox(width: 18),
                          GestureDetector(
                              onTap: _selectOpenTime,
                              child: Text('${_openTime.format(context)}',
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
                              child: Text('${_closeTime.format(context)}',
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
                                value: selectedPrice,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedPrice = newValue;
                                    print("Booking Price: " + selectedPrice);
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
                                value: selectedOffDay,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedOffDay = newValue;
                                    print("Off Day: " + selectedOffDay);
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
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          icon: Icon(Icons.notes),
                        ),
                        onChanged: _onChangedDesc,
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

  _onChangedTitle(String value) {
    setState(() {
      titleCharLength = 50 - value.length;
    });
  }

  _onChangedDesc(String value) {
    setState(() {
      descCharLength = 100 - value.length;
    });
  }

  void _addNewCenterDialog() {}

  void _selectOpenTime() async {
    final TimeOfDay newOpenTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 00, minute: 00),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (newOpenTime != null) {
      setState(() {
        _openTime = newOpenTime;
      });
    }
  }

  void _selectCloseTime() async {
    final TimeOfDay newCloseTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 00, minute: 00),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (newCloseTime != null) {
      setState(() {
        _closeTime = newCloseTime;
      });
    }
  }
}
