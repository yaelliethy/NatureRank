import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart' as color;
import 'package:equinox/equinox.dart';
import 'package:naturerank/util.dart';
import 'package:naturerank/views/viewEvent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Events extends StatefulWidget {
  bool myOnly;
  Events({Key key, this.title, this.myOnly}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _EventsState createState() => _EventsState(myOnly);
}

class _EventsState extends State<Events> {
  TextEditingController _controller = TextEditingController();
  Widget buttonLeading;
  bool myOnly;
  String name;
  String name_path;
  _EventsState(this.myOnly);
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      name = value.getString("name");
    });
    getDocumentPath().then((value) => name_path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: EqLayout(child: getListView()),
      key: new PageStorageKey(1),
    );
  }

  Widget getListView() {
    if (myOnly) {
      return FutureBuilder<QuerySnapshot>(
        future: Firestore.instance
            .collection('events')
            .where("name_path", isEqualTo: name_path)
            .getDocuments(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return EqSpinner();
            case ConnectionState.active:
            default:
              List list =
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return Padding(
                    padding: EdgeInsets.all(10),

                        child: EqCard(
                            footer: EqIconButton(
                                icon: Icons.delete,
                                color: color.Colors.red,
                                onTap: () {
                                  setState(() {
                                    Firestore.instance
                                        .document(document.reference.path)
                                        .delete();
                                  });
                                }),
                            child: Text(document['description']),
                            header: Stack(children: <Widget>[
                              Hero(
                                child: CachedNetworkImage(
                                  imageUrl: document['image_url'],
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                tag: document['event_name'],
                              ),
                              Positioned(
                                child: Text(document['event_name']),
                                bottom: 16,
                                left: 10,
                              ),
                              Positioned(
                                child: Text(
                                    document['points'].toString() + " Points"),
                                bottom: 16,
                                right: 10,
                              )])));
              }).toList();
              return new ListView(
                children: list,
              );
          }
        },
      );
    } else {
      return FutureBuilder<QuerySnapshot>(
        future: Firestore.instance.collection('events').getDocuments(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return EqSpinner();
            case ConnectionState.active:
            default:
              List list =
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => ViewEvent(title:document['event_name'],document:document),
                        ),
                      );
                    },
                    child:EqCard(
                      child: Text(document['description']),
                      footer: Text("By " + document['name']),
                      header: Stack(children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: document['image_url'],
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                        Positioned(
                          child: Text(document['event_name']),
                          bottom: 16,
                          left: 10,
                        ),
                        Positioned(
                          child:
                              Text(document['points'].toString() + " Points"),
                          bottom: 16,
                          right: 10,
                        )
                      ])),
                ));
              }).toList();
              return new ListView(
                children: list,
              );
          }
        },
      );
    }
  }
}
