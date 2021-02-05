import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'user.dart';

class AddPostScreen extends StatefulWidget {
  final User user;
  const AddPostScreen({Key key, this.user}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  double screenHeight, screenWidth;
  File _image;
  String pathAsset = 'assets/images/camera.png';
  final TextEditingController _titlecontroller = TextEditingController();
  final TextEditingController _descriptioncontroller = TextEditingController();
  String _title, _description;
  int titleCharLength = 50;
  int descCharLength = 100;
  bool image = false;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Post', style: TextStyle(color: Colors.black)),
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
                        top: 80, left: 20, right: 20, bottom: 20),
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
                          controller: _titlecontroller,
                          keyboardType: TextInputType.name,
                          maxLength: 50,
                          decoration: InputDecoration(
                              labelText: 'Title',
                              icon: Icon(Icons.title),
                              hintText: 'Maximum of 50 characters'),
                        ),
                        TextField(
                          controller: _descriptioncontroller,
                          keyboardType: TextInputType.name,
                          maxLength: 100,
                          decoration: InputDecoration(
                              labelText: 'Description',
                              icon: Icon(Icons.description),
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
                          child: Text('Add Post'),
                          elevation: 15,
                          onPressed: _addNewPostDialog,
                        ),
                      ],
                    ))),
              ))
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

  void _addNewPostDialog() {
    _title = _titlecontroller.text;
    _description = _descriptioncontroller.text;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(
              "Add New Post? ",
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
                  _onAddPost();
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

  bool _validation(String title, String description) {
    if (title.isEmpty || description.isEmpty) {
      return false;
    } else {
      if (title.length > 50 || description.length > 100) {
        return false;
      } else {
        return true;
      }
    }
  }

  void _onAddPost() {
    _title = _titlecontroller.text;
    _description = _descriptioncontroller.text;

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

    if (_validation(_title, _description) && image) {
      http.post("http://itprojectoverload.com/sportsclick/php/add_post.php",
          body: {
            "posttitle": _title,
            "postdesc": _description,
            "postimage":
                widget.user.name + "-${dateTime.microsecondsSinceEpoch}",
            "useremail": widget.user.email,
            "encoded_string": base64Image,
          }).then((res) {
        print(res.body);
        if (res.body == "success") {
          Toast.show(
            "Add Post Success",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
          Navigator.pop(context);
        } else {
          Toast.show(
            "Add Post Failed",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
        }
      }).catchError((err) {
        print(err);
      });
    } else {
      if (_title.isEmpty || _description.isEmpty || image == false) {
        Toast.show(
          "Incomplete Title/Description",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      } else {
        Toast.show(
          "Invalid Title/Description",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      }
    }
  }
}
