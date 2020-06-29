import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart' as color;
import 'package:equinox/equinox.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:naturerank/util.dart';
import 'package:naturerank/views/events.dart';
import 'package:naturerank/views/eventsBase.dart';
import 'package:naturerank/views/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewEvent extends StatefulWidget {
  DocumentSnapshot document;
  ViewEvent({Key key, this.title, this.document}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent>
    with SingleTickerProviderStateMixin {
  MapController _mapController;
  StatefulMapController statefulMapController;
  StreamSubscription<StatefulMapControllerStateChange> sub;
  LatLng eventPosition;
  StatefulMarker marker;
  LatLng userLocation;
  DocumentSnapshot document;
  bool buttonDisabled = false;
  @override
  void initState() {
    getDocumentPath().then((name_path) {
      Firestore.instance.document(name_path).get().then((snapshot) {
        buttonDisabled=snapshot['events_joined'].contains(widget.document.reference.path);
      });
    });

    document = widget.document;
    eventPosition =
        new LatLng(double.parse(document['location_lat'].toString()), double.parse(document['location_lng'].toString()));
    _mapController = MapController(); //Normal map controller
    statefulMapController =
        StatefulMapController(mapController: _mapController);
    statefulMapController.onReady.then((_) {
      print("The map controller is ready");
      statefulMapController.centerOnPoint(this.eventPosition);
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EqLayout(
        appBar: EqAppBar(
          title: widget.title,
        ),
        child: ListView(children: <Widget>[
          EqCard(
            header: Hero(
              child: CachedNetworkImage(
                imageUrl: document['image_url'],
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              tag: widget.title,
            ),
            child: Container(
              height: 500,
              child: Column(
                children: <Widget>[
                  EqText(document['event_name'] + " by " + document['name'],
                      eqStyle: EqTextStyle.heading4),
                  EqText(document['points'].toString() + " Points",
                      eqStyle: EqTextStyle.heading6),
                  Spacer(),
                  Text(document['description']),
                  Spacer(),
                  Container(
                      height: 300,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: new MapOptions(
                          zoom: 13.0,
                        ),
                        layers: [
                          new TileLayerOptions(
                            urlTemplate:
                                "https://www.google.com/maps/vt/pb=!1m4!1m3!1i{z}!2i{x}!3i{y}!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425",
                          ),
                          PolylineLayerOptions(
                              polylines: statefulMapController.lines),
                          PolygonLayerOptions(
                              polygons: statefulMapController.polygons),
                          new MarkerLayerOptions(
                            markers: [
                              new Marker(
                                width: 80.0,
                                height: 80.0,
                                point: eventPosition,
                                builder: (ctx) => new Container(
                                  child: new Icon(Icons.location_on),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  EqButton(
                    label: buttonDisabled ? Text("Joined") : Text("Join"),
                    onTap: buttonDisabled
                        ? null
                        : () {
                            getDocumentPath().then((name_path) {
                              getName().then((name) {
                                Firestore.instance
                                    .document(name_path)
                                    .get()
                                    .then((snapshot) {
                                  List events = document['events_joined'];
                                  if (events == null) {
                                    events = [];
                                  }
                                  events.add(document.reference.path);
                                  Firestore.instance
                                      .document(name_path)
                                      .updateData({
                                    "name": name,
                                    "points":
                                        snapshot['points'] + document['points'],
                                    "events_joined": events
                                  });
                                  setState(() {
                                    buttonDisabled = true;
                                  });
                                });
                              });
                            });
                          },
                  )
                ],
              ),
            ),
          ),
        ]));
  }
}
