import 'dart:convert';
import 'package:fattarny/globals/global.dart' as globals;
import 'package:fattarny/register_page.dart';
import 'package:fattarny/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/textfieldFattarny.dart';
import 'package:http/http.dart' as http;
import 'vote_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

Future<bool> saveUserID(id) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('id', id);
  preferences.setBool('logged', true);
  return preferences.commit();
}

Future<bool> saveUserPassword(password) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('password', password);
  return preferences.commit();
}

class _LoginPageState extends State<LoginPage> {
  bool errorType = false;
  String errorMessage;
  signIn(String id, String password) async {
    Map data = {'user_id': id, 'password': password};
    print(data);
    var jsonData = null;
    //checking user's info
    var response = await http.post('https://fattarny.herokuapp.com/users/login',
        body: data);

    if (response.statusCode == 200) {
      await saveUserID(id).then((onValue) {
        print(onValue);
        saveUserPassword(password).then((onValue) {
          print(onValue);
          saveUserVoting(false).then((onValue) {
            print(onValue);
          });
        });
        jsonData = json.decode(response.body);
        globals.isAdmin = jsonData['is_admin'];
        print('user found');
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return GetTimerTime();
          }),
        );
      });
    }
    if (response.statusCode == 404) {
      setState(() {
        errorMessage = 'ID or Password may be incorrect!';
        errorType = true;
      });
      print(response.statusCode.toString());
    }
    if (response.statusCode == 401) {
      setState(() {
        errorMessage = 'ID or Password may be incorrect!';
        errorType = true;
      });
      print(response.statusCode.toString());
    }
  }

  final idController = TextEditingController();
  final passwordController = TextEditingController();
  void notCorrect() {
    errorMessage = 'ID or Password may be incorrect!';
    errorType = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
          child: Scaffold(
        backgroundColor: basicTheme().primaryColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset('assets/images/logo.png'),
              SizedBox(
                height: 5,
              ),
              FattarnyTextField(
                type: TextInputType.number,
                errorFound: errorType,
                errorMsg: errorMessage,
                obsecure: false,
                control: idController,
                hint: 'Enter your Company\'s ID',
                label: 'Your ID',
                iconNeeded: Icons.person,
              ),
              SizedBox(
                height: 5,
              ),
              FattarnyTextField(
                type: TextInputType.visiblePassword,
                errorFound: errorType,
                errorMsg: errorMessage,
                obsecure: true,
                control: passwordController,
                hint: 'Enter your Password',
                label: 'Your Password',
                iconNeeded: Icons.lock,
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: RaisedButton(
                  splashColor: basicTheme().accentColor,
                  onPressed: () {
                    idController.text.trim().isNotEmpty
                        ? signIn(idController.text.trim(),
                            passwordController.text.trim())
                        : notCorrect();
                  },
                  child: Text('Login'),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              InkWell(
                child: Text('Don\'t have an account? Click here!'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return RegisterPage();
                    }),
                  );
                },
              )
            ],
          ),
        ),
      )),
      //user going back warning
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Warning'),
          content: Text('Do you really want to close Fattarny?'),
          actions: [
            FlatButton(
              child: Text('Yes', style: basicTheme().textTheme.title),
              //when clicked the application closes by the method below
              onPressed: () =>
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            ),
            FlatButton(
              child: Text('No',
                  style:
                      basicTheme().textTheme.title.apply(color: Colors.green)),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ),
    );
  }
}
