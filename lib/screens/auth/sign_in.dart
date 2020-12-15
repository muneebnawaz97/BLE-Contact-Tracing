import 'package:contact_tracing/screens/auth/phone_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignIn extends StatelessWidget {
  final String title = "Sign In";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.title),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SignInButtonBuilder(
                      icon: Icons.phone_outlined,
                      text: "Sign in with phone number",
                      backgroundColor: Colors.lightBlueAccent[700],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhoneLogin()),
                        );
                      },
                    )),

              ]),
        ));
  }

}