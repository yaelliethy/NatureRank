import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equinox/equinox.dart';
import 'package:flutter/material.dart';
import 'package:NatureRank/util.dart';

class LeaderBoard extends StatefulWidget {
  LeaderBoard({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  List<DocumentSnapshot> data = [];
  List<String> paths = [];
  String name = "";
  int rank = 0;
  int points = 0;
  @override
  void initState() {
    Firestore.instance
        .collection("users")
        .orderBy("points", descending: true)
        .getDocuments()
        .then((value) {
      data = value.documents;
      data.forEach((element) {
        paths.add(element.reference.path);
      });
      getDocumentPath().then((path) {
        Firestore.instance.document(path).get().then((value) {
          setState(() {
            name = value['name'];
            rank = paths.indexOf(path);
            points = value['points'];
          });
          super.initState();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return EqLayout(
      appBar: EqAppBar(
        title: "Leader Board",
      ),
      child: ListView(
        children: <Widget>[
          Container(
            height: 80,
            child: Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 10),
                child: EqCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text((rank+1).toString()),
                      Text(name),
                      Text(points.toString()),
                    ],
                  ),
                )),
          ),
          Container(
              height: double.parse((data.length * 80).toString()),
              child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int pos) {
                    return Container(
                        height: 80,
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, bottom: 10, top: 10),
                            child: Container(
                                height: 50,
                                child: EqCard(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text((pos+1).toString()),
                                      Text(data[pos]['name']),
                                      Text(data[pos]['points'].toString()),
                                    ],
                                  ),
                                ))));
                  })),
        ],
      ),
    );
  }
}
