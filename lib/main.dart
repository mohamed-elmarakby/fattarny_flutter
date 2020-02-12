import 'package:fattarny/vote_page.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:fattarny/widgets/splashFattarny.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:fattarny/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
      title: 'Fattarny',
      theme: basicTheme(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

Future<bool> getUserLoggedId() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool logged = sharedPreferences.getBool('logged');
  return logged;
}

bool loggedIn = false;

class _SplashState extends State<Splash> {
  initialize() async {
    await getUserLoggedId().then((onValue) {
      loggedIn = onValue;
    });
    dynamic destination =
        (loggedIn == null || loggedIn == false) ? LoginPage() : GetTimerTime();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return destination;
      }),
    );
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: FattarnySplash());
  }
}
