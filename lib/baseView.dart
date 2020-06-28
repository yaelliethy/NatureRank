import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart' as color;
import 'package:equinox/equinox.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:NatureRank/views/events.dart';
import 'package:NatureRank/views/eventsBase.dart';
import 'package:NatureRank/views/jobs.dart';
import 'package:NatureRank/views/leaderboard.dart';
import 'package:NatureRank/views/settings.dart';

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
  Widget buttonLeading;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    checkIfNameExists().then((exists) {
      if(!exists)
        setName(() {
        });
      super.initState();

    });
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> setName(void then()) async {
    _handleSignIn().then((fireBaseUser) async {
      setState(() {
        buttonLeading = EqSpinner();
      });
      Future.delayed(const Duration(seconds: 3), () => "1");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Firestore.instance
          .collection('users')
          .where('id', isEqualTo: fireBaseUser.uid)
          .getDocuments()
          .then((value) {
        if (value.documents.length == 0) {
          Firestore.instance.collection('users').add({
            'name': fireBaseUser.displayName,
            'id': fireBaseUser.uid,
            'points': 0,
            'events_joined': [],
            'jobs': [],
          }).then((value) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('name', fireBaseUser.displayName);
              prefs.setString('document_path', value.path);
              then();
            });
          });
        } else {
          prefs.setString('name', fireBaseUser.displayName);
          prefs.setString('document_path', value.documents[0].reference.path);
          then();
        }
      });
    });
  }
  void logout(){
    
  }

  Future<bool> checkIfNameExists() async {
    return (await SharedPreferences.getInstance()).containsKey('name');
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
                return Text("Logout");
              },
              icon: (context) {
                return Icon(Icons.exit_to_app);
              },
            ),
          ]),
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _controller,
        children: <Widget>[EventsBase(), Jobs(), LeaderBoard(), LogOut()],
      ),
    );
  }
}
class LogOut extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((prefs){
      prefs.remove('name');
      prefs.remove('document_path');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => BaseView(),
        ),
      );
    });
    return Container();
  }
  
}
