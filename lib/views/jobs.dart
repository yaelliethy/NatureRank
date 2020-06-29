import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equinox/equinox.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:naturerank/util.dart';

class Jobs extends StatefulWidget {
  Jobs({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _JobsState createState() => _JobsState();
}

class _JobsState extends State<Jobs> {
  List<DocumentSnapshot> jobs = [];
  @override
  void initState() {
    super.initState();
    _getData(() {
    });
  }

  void _getData(void then()) {
    DateTime now = new DateTime.now();
    DateTime nowDate = new DateTime(now.year, now.month, now.day);
    getDocumentPath().then((name_path) {
      Firestore.instance.document(name_path).get().then((snapshot) {
        Map jobMap = snapshot['jobs'];
        List listToBeRemoved = [];
        jobMap.forEach((key, value) {
          DateTime date = new DateTime.fromMicrosecondsSinceEpoch(
              value.microsecondsSinceEpoch);
          if (nowDate.difference(date).inHours >= 24) listToBeRemoved.add(key);
        });
        jobMap.removeWhere((e, _) => listToBeRemoved.contains(e));
        Firestore.instance.document(name_path).updateData({
          "events_joined": snapshot['events_joined'],
          "jobs": jobMap,
          "name": snapshot['name'],
          "points": snapshot['points']
        });
        Firestore.instance
            .collection("jobs")
            .getDocuments()
            .asStream()
            .listen((querySnapshot) {
          List<DocumentSnapshot> docs = querySnapshot.documents;
          List<DocumentSnapshot> newDocs = [];
          for (int x = 0; x < docs.length; x++) {
            if (!jobMap.keys.contains(docs[x].reference.path)) {
              newDocs.add(docs[x]);
            }
          }
          setState(() {
            jobs = newDocs;
          });
          then();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return EqLayout(
      appBar: EqAppBar(
        title: "Jobs",
        subtitle: "Click on item to finish",
      ),
      child: Container(
          height: 500,
          child: ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (BuildContext context, int pos) {
                return GestureDetector(
                    onTap: () {
                      getDocumentPath().then((name_path) {
                        Firestore.instance
                            .document(name_path)
                            .get()
                            .then((snapshot) {
                          Map jobMap = snapshot['jobs'];
                          setState(() {
                            jobMap.addAll(
                                {jobs[pos].reference.path: Timestamp.now()});
                            Firestore.instance.document(name_path).updateData({
                              "events_joined": snapshot['events_joined'],
                              "jobs": jobMap,
                              "name": snapshot['name'],
                              "points": snapshot['points'] + jobs[pos]['points']
                            });
                            _getData(() {});
                          });
                        });
                      });
                    },
                    child: Container(
                      height: 30,
                        child: EqCard(
                      child: Text(jobs[pos]['job']),
                    )));
              })),
    );
  }
}
