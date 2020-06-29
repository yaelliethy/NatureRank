import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart' as color;
import 'package:equinox/equinox.dart';
import 'package:naturerank/views/events.dart';
import 'package:naturerank/views/eventsBase.dart';
import 'package:naturerank/views/jobs.dart';
import 'package:naturerank/views/leaderboard.dart';
import 'package:naturerank/views/settings.dart';
import 'package:naturerank/views/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseView extends StatefulWidget {
  BaseView({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _BaseViewState createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  int _currentIndex = 0;
  @override
  void initState() {
    _controller = TabController(
      length: 4,
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {
        _currentIndex = _controller.index;
      });
    });
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
      bottomTabBar: EqTabBar.bottom(
          defaultSelected: _currentIndex,
          onSelect: (pos) {
            setState(() {
              _currentIndex = pos;
            });
            _controller.animateTo(_currentIndex,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          },
          tabs: <EqTabData>[
            EqTabData(
              title: (context) {
                return Text("Events");
              },
              icon: (context) {
                return Icon(Icons.location_on);
              },
            ),
            EqTabData(
              title: (context) {
                return Text("Jobs");
              },
              icon: (context) {
                return Icon(EvaIcons.briefcaseOutline);
              },
            ),
            EqTabData(
              title: (context) {
                return Text("Leaderboard");
              },
              icon: (context) {
                return Icon(Icons.list);
              },
            ),
            EqTabData(
              title: (context) {
                return Text("Settings");
              },
              icon: (context) {
                return Icon(Icons.settings);
              },
            ),
          ]),
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _controller,
        children: <Widget>[
          EventsBase(),
          Jobs(),
          LeaderBoard(),
          Settings()
        ],
      ),
    );
  }
}
