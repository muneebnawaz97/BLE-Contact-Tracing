import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash_page.dart';
import 'stores/login_store.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controller/requirement_state_controller.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // new for Firebase Auth
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    Get.put(RequirementStateController());

    final themeData = Theme.of(context);
    final primary = Colors.blue;

    return MultiProvider(
        providers: [
          Provider<LoginStore>(
            create: (_) => LoginStore(),
          )
        ],
        child: GetMaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: primary,
            appBarTheme: themeData.appBarTheme.copyWith(
              brightness: Brightness.light,
              elevation: 0.5,
              color: Colors.white,
              actionsIconTheme: themeData.primaryIconTheme.copyWith(
                color: primary,
              ),
              iconTheme: themeData.primaryIconTheme.copyWith(
                color: primary,
              ),
              textTheme: themeData.primaryTextTheme.copyWith(
                headline6: themeData.textTheme.headline6.copyWith(
                  color: primary,
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: primary,
          ),
          home: SplashPage(),
        ),
    );
  }
}