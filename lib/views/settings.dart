import 'package:equinox/equinox.dart';
import 'package:flutter/material.dart';
import 'package:NatureRank/util.dart';

class Settings extends StatefulWidget {
  Settings({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String name="";
  final formKey = GlobalKey<FormState>();
  TextEditingController _controller=TextEditingController();
  @override
  void initState() {
    setState(() {
      getName().then((value) => name);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return EqLayout(
      appBar: EqAppBar(
        title: "Settings",
        actions: <Widget>[
          EqButton(
              label: Icon(Icons.save),
              onTap: (){
                if(formKey.currentState.validate()){
                  updateName(_controller.text);
                }
              },
              appearance: EqWidgetAppearance.ghost,
          )
        ],
      ),
      child: EqCard(
        header: Text('Name'),
        child: Form(
          key: formKey,
          child: EqTextFieldForm(
            hint: "Enter your name",
            controller: _controller,
            validator: (val){
              if(val.isEmpty){
                return 'Please enter your name';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

}