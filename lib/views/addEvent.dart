import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart' as color;
import 'package:equinox/equinox.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:latlong/latlong.dart';
import 'package:naturerank/baseView.dart';
import 'package:naturerank/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_controller/map_controller.dart';
import 'package:uuid/uuid.dart';

class AddEvent extends StatefulWidget {
  AddEvent({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController _nameController=TextEditingController();
  TextEditingController _descriptionController=TextEditingController();
  TextEditingController _pointsController=TextEditingController();
  Widget buttonLeading;
  final _formKey = GlobalKey<FormState>();
  MapController _mapController;
  StatefulMapController statefulMapController;
  StreamSubscription<StatefulMapControllerStateChange> sub;
  LatLng selectedPosition;
  StatefulMarker marker;
  LatLng userLocation;
  Widget icon = Icon(Icons.save);
  File _image;
  FirebaseStorage _storage = FirebaseStorage.instance;
  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  Future<String> uploadPic() async {
    //Get the file from the image picker and store it
    //Create a reference to the location you want to upload to in firebase
    StorageReference reference = _storage.ref().child("event_images").child(getRandomString(15));

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putFile(_image);

    // Waits till the file is uploaded then stores the download url
    Uri location = (await uploadTask.onComplete).uploadSessionUri;

    //returns the download url
    return await reference.getDownloadURL();
  }

  void getImage() {
    ImagePickerGC.pickImage(
      context: context,
      source: ImgSource.Both,
      cameraIcon: Icon(
        Icons.camera,
      ),
      galleryIcon: Icon(
        Icons.image,
      ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
    ).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  @override
  void initState() {
    _mapController = MapController(); //Normal map controller
    statefulMapController =
        StatefulMapController(mapController: _mapController);
    statefulMapController.onReady
        .then((_) => print("The map controller is ready"));
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      if (value != null) {
        this.userLocation = new LatLng(value.latitude, value.longitude);
        this.selectedPosition = this.userLocation;
        _addMarker(); //Add marker
        statefulMapController.centerOnPoint(this.userLocation);
      }
    });
    super.initState();
  }

  void _addMarker() {
    setState(() {
      statefulMapController.addMarker(
          marker: Marker(
              point: selectedPosition,
              builder: (BuildContext context) {
                return Icon(Icons.location_on);
              }),
          name: "pos");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EqLayout(
      appBar: EqAppBar(
        // Here we take the value from the AddEvent object that was created by
        // the App.build method, and use it to set our appbar title.
        title: "Add Event",
        actions: <Widget>[
          EqButton(
            label: icon,
            appearance: EqWidgetAppearance.ghost,
            onTap: () {
              if (_formKey.currentState.validate()) {
                uploadPic().then((url) {
                  getDocumentPath().then((name_path){
                    getName().then((name){
                      Firestore.instance.collection('events').add({
                        'event_name': _nameController.text,
                        'description': _descriptionController.text,
                        'image_url': url,
                        'location_lat': selectedPosition.latitude,
                        'location_lng': selectedPosition.longitude,
                        'points': int.parse(_pointsController.text),
                        'name_path': name_path,
                        'name':name
                      });
                    });
                  });
                });
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
      child: Form(
          key: _formKey,
          child: Center(
            child: EqCard(
              child: Container(
                  height: 500,
                  child: Center(
                    child: ListView(
                      children: <Widget>[
                        Container(
                            height: 100,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: EqTextFieldForm(
                                hint: "Event Name",
                                controller: _nameController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please Enter an Event Name';
                                  }
                                  return null;
                                },
                              ),
                            )),
                        Container(
                            height: 100,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: EqTextFieldForm(
                                hint: "Event Description",
                                controller: _descriptionController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please Enter an Event Description';
                                  }
                                  return null;
                                },
                              ),
                            )),
                        Container(
                            height: 100,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: EqTextFieldForm(
                                hint: "Event Points",
                                keyboardType: TextInputType.number,
                                controller: _pointsController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please Enter Event Points';
                                  }
                                  if (int.parse(value) > 100)
                                    return "This number of points is too high";
                                  return null;
                                },
                              ),
                            )),
                        _image != null
                            ? Image.file(_image)
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                        Padding(
                          padding: EdgeInsets.all(10),
                            child: EqButton(
                          label: Text("Choose Image"),
                          onTap: getImage,
                        )),
                        Container(
                            height: 300,
                            child: FlutterMap(
                              mapController: _mapController,
                              options: new MapOptions(
                                  zoom: 13.0,
                                  onTap: (LatLng pos) {
                                    statefulMapController.removeMarker(
                                        name: "pos");
                                    this.selectedPosition = pos;
                                    _addMarker();
                                  }),
                              layers: [
                                new TileLayerOptions(
                                  urlTemplate:
                                      "https://www.google.com/maps/vt/pb=!1m4!1m3!1i{z}!2i{x}!3i{y}!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425",
                                ),
                                MarkerLayerOptions(
                                    markers: statefulMapController.markers),
                                PolylineLayerOptions(
                                    polylines: statefulMapController.lines),
                                PolygonLayerOptions(
                                    polygons: statefulMapController.polygons)
                              ],
                            ))
                      ],
                    ),
                  )),
              header: Text("Please Enter Your Event Data"),
            ),
          )),
    );
  }
}
