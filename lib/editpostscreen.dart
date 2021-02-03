import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'post.dart';
import 'user.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  final User user;
  const EditPostScreen({Key key, this.post, this.user}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  double screenHeight, screenWidth;
  File _image;
  List postList, userList;
  String _titleCenter = "Loading Post...";
  String pathAsset = 'assets/images/camera.png';
  TextEditingController _titlecontroller;
  TextEditingController _descriptioncontroller;
  String _title, _description, _currentImage = "";
  int titleCharLength = 50;
  int descCharLength = 100;

  @override
  void initState() {
    _titlecontroller = TextEditingController(text: widget.post.posttitle);
    _descriptioncontroller = TextEditingController(text: widget.post.postdesc);
    _onChangedTitle(_titlecontroller.text);
    _onChangedDesc(_descriptioncontroller.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.post.posttitle,
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
                                  "http://itprojectoverload.com/sportsclick/images/postimages/${widget.post.postimage}.jpg",
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
                                      "Old Title: " + widget.post.posttitle))
                            ]),
                            Row(children: [
                              Flexible(
                                  child: Text("Old Description: " +
                                      widget.post.postdesc))
                            ]),
                          ])),
                    ]),
                    SizedBox(height: 7.5),
                    Divider(height: 1, color: Colors.black),
                    SizedBox(height: 7.5),
                    GestureDetector(
                        onTap: () => {_onPictureSelection()},
                        child: Container(
                          height: screenHeight / 3.2,
                          width: screenWidth / 1.8,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: _image == null
                                  ? NetworkImage(
                                      "http://itprojectoverload.com/sportsclick/images/postimages/${widget.post.postimage}.jpg")
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
                    Text("Click camera to change new picture",
                        style: TextStyle(fontSize: 15.0, color: Colors.black)),
                    SizedBox(height: 5),
                    TextField(
                      controller: _titlecontroller,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'New Title',
                        icon: Icon(Icons.title),
                        hintText: 'Maximum of 50 characters',
                      ),
                      onChanged: _onChangedTitle,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text(
                        "$titleCharLength character remaining",
                        textAlign: TextAlign.right,
                        style:
                            TextStyle(fontSize: 10, color: Colors.deepPurple),
                      ),
                    ]),
                    TextField(
                      controller: _descriptioncontroller,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'New Description',
                        icon: Icon(Icons.description),
                        hintText: 'Maximum of 100 characters',
                      ),
                      onChanged: _onChangedDesc,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text(
                        "$descCharLength character remaining",
                        textAlign: TextAlign.right,
                        style:
                            TextStyle(fontSize: 10, color: Colors.deepPurple),
                      ),
                    ]),
                    SizedBox(height: 10),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      minWidth: 180,
                      height: 40,
                      child: Text('Edit Post'),
                      elevation: 15,
                      onPressed: _editPostDialog,
                    ),
                  ])))),
        ]));
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

  void _editPostDialog() {
    _title = _titlecontroller.text;
    _description = _descriptioncontroller.text;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text(
              "Edit " + widget.post.posttitle + " to " + _title + "?",
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
                  _onEditPost();
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

  void _onEditPost() {
    final dateTime = DateTime.now();
    _title = _titlecontroller.text;
    _description = _descriptioncontroller.text;

    print("Image" + _currentImage);

    String base64Image = "";
    try {
      if (base64Encode(_image.readAsBytesSync()) != null) {
        base64Image = base64Encode(_image.readAsBytesSync());
        _currentImage =
            widget.user.name + "-${dateTime.microsecondsSinceEpoch}";
      } else {
        _currentImage = widget.post.postimage;
      }
    } catch (Exception) {
      print(Exception);
    }

    print(base64Image);
    if (_validation(_title, _description)) {
      http.post("http://itprojectoverload.com/sportsclick/php/edit_post.php",
          body: {
            "postid": widget.post.postid,
            "posttitle": _title,
            "postdesc": _description,
            "useremail": widget.post.useremail,
            "postimage": _currentImage,
            "encoded_string": base64Image,
          }).then((res) {
        print(res.body);
        if (res.body == "success") {
          Toast.show(
            "Edit Post Success",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
          Navigator.pop(context);
        } else {
          Toast.show(
            "Edit Post Failed",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
          );
        }
      }).catchError((err) {
        print(err);
      });
    } else {
      if (_title.isEmpty || _description.isEmpty) {
        Toast.show(
          "Incomplete New Title/Description",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      } else {
        Toast.show(
          "Invalid New Title/Description",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      }
    }
  }
}
