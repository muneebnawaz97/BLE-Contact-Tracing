import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contact_tracing/stores/login_store.dart';

import '../theme.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginStore>(
        builder: (_, loginStore, __) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: MyColors.primaryColor,
              title: Text('Contact Tracing'),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.logout, color: Colors.white,),
                  onPressed: () {
                    loginStore.signOut(context);
                  },
                ),
              ],
            ),
          );
        }
    );
  }
}
