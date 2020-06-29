import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart' as color;
import 'package:equinox/equinox.dart';
import 'package:naturerank/views/events.dart';
import 'package:naturerank/views/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'addEvent.dart';

class EventsBase extends StatefulWidget {
  EventsBase({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _EventsBaseState createState() => _EventsBaseState();
}

class _EventsBaseState extends State<EventsBase>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  int _currentIndex = 0;
  @override
  void initState() {
    _controller = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EqLayout(
        appBar:EqAppBar(
          title: "Events",
          actions: <Widget>[
            EqButton(
              label: Icon(Icons.add_circle_outline),
              appearance: EqWidgetAppearance.ghost,
              onTap: (){
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => AddEvent(),
                  ),
                );
              },
            )
          ],
        ),
        child: EqLayout(
          appBar:  EqTabBar.top(
              defaultSelected: _currentIndex,
              onSelect: (pos) {
                _controller.animateTo(pos,
                    duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                setState(() {
                  _currentIndex = pos;
                });
              },
              tabs: <EqTabData>[
                EqTabData(
                  title: (context) {
                    return Text("My Events");
                  },
                ),
                EqTabData(
                  title: (context) {
                    return Text("All Events");
                  },
                ),
              ]),
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _controller,
            children: <Widget>[
              Events(myOnly: true),
              Events(myOnly: false),
            ],
          )
        )
    );
  }
}
