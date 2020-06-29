import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart' as color;
import 'package:equinox/equinox.dart';
import 'package:naturerank/baseView.dart';
import 'package:naturerank/views/events.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatefulWidget {
  Welcome({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  TextEditingController _controller;
  Widget buttonLeading;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _controller = TextEditingController();
    checkIfNameExists().then((exists) {
      if (exists) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => BaseView(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      } else
        super.initState();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> setName() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        buttonLeading = EqSpinner();
      });
      Future.delayed(const Duration(seconds: 3), () => "1");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _controller.text);
      Firestore.instance.collection('users').add({
        'name': _controller.text,
        'points': 0,
        'events_joined': [],
        'jobs': {},
      }).then((value) {
        SharedPreferences.getInstance().then((prefs){
          prefs.setString('document_path', value.path);
        });
      });
      setState(() {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => BaseView(),
          ),
        );
      });
    }
  }

  Future<bool> checkIfNameExists() async {
    return (await SharedPreferences.getInstance()).containsKey('name');
  }

  @override
  Widget build(BuildContext context) {
    return EqLayout(
      appBar: EqAppBar(
        // Here we take the value from the Welcome object that was created by
        // the App.build method, and use it to set our appbar title.
        title: "Welcome",
      ),
      child: Form(
          key: _formKey,
          child: Center(
            child: EqCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: EqTextFieldForm(
                    hint: "Enter your name (can be changed in settings later)",
                    controller: _controller,
                    validator: (value) {
                      if (value.isEmpty) return "Please Enter Your Name";
                      return null;
                    },
                  ),
                ),
              ),
              header: Text("Please Enter Your Name"),
              footer: EqButton(
                backgroundColor: color.Colors.blue,
                label: Text(
                  "Set Name",
                  style: TextStyle(color: color.Colors.white),
                ),
                onTap: setName,
                leading: buttonLeading,
              ),
            ),
          )),
    );
  }
}
