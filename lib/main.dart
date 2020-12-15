import 'package:contact_tracing/screens/auth/phone_login.dart';
import 'package:contact_tracing/screens/auth/sign_in.dart';
import 'package:contact_tracing/screens/home/home.dart';
import 'package:firebase_core/firebase_core.dart'; // new requirement for all Firebase projects.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // new for Firebase Auth
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HaoC Study',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: (user == null)
          ? PhoneLogin()
          : Home(uid: user.uid),
    );
  }
}