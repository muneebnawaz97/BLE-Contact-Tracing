import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../main.dart';


class Home extends StatefulWidget {
  Home({this.uid});
  final String uid;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String title = "Home";
  var uniqueId = '';

  @override
  void initState() {
    super.initState();
    User user = FirebaseAuth.instance.currentUser;
    uniqueId = user.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.logout, color: Colors.white,),
              label: Text('Logout', style:TextStyle(color: Colors.white)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
          ],
        ),
        body: Center(child: Text('UID: ' + uniqueId))
    );
  }
}
