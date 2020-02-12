import 'dart:convert';

import 'package:fattarny/login_page.dart';
import 'package:fattarny/vote_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'theme.dart';
import 'widgets/textfieldFattarny.dart';

Future<bool> saveUserID(id) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('id', id);
  preferences.setBool('logged', true);
  return preferences.commit();
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  register(String id, String password, String email) async {
    Map data = {
      'user_id': id,
      'password': password,
      'email': email,
      'is_admin': '0'
    };
    print(data);
    var jsonData = null;
    //checking user's info
    var response = await http
        .post('https://fattarny.herokuapp.com/users/register', body: data);

    if (response.statusCode == 200) {
      saveUserID(id);
      jsonData = json.decode(response.body);
      print(response.statusCode);
      print('register done!');
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return LoginPage();
        }),
      );
    }
  }

  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  bool errorType;
  String errorMessage;
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
                errorFound: true,
                errorMsg: 'ID must be at least 5 characters long!',
                control: idController,
                obsecure: false,
                hint: 'Enter your Company\'s ID',
                label: 'Your ID',
                iconNeeded: Icons.person,
              ),
              SizedBox(
                height: 5,
              ),
              FattarnyTextField(
                type: TextInputType.visiblePassword,
                errorFound: true,
                errorMsg: 'Password must be at least 5 characters long!',
                control: passwordController,
                obsecure: true,
                hint: 'Enter your Password',
                label: 'Your Password',
                iconNeeded: Icons.lock,
              ),
              SizedBox(
                height: 5,
              ),
              FattarnyTextField(
                type: TextInputType.emailAddress,
                errorFound: true,
                errorMsg: 'Enter valid email address',
                control: emailController,
                hint: 'Enter your Email',
                label: 'Your Email Address',
                iconNeeded: Icons.email,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: RaisedButton(
                  splashColor: basicTheme().accentColor,
                  onPressed: () {
                    setState(() {
                      if (emailController.text.trim().isNotEmpty &&
                          passwordController.text.isNotEmpty &&
                          idController.text.trim().isNotEmpty) {
                        register(idController.text.trim(),
                            passwordController.text, emailController.text);
                      } else {
                        errorType = true;
                        Toast.show('Please fill in all fields', context,
                            duration: 1);
                      }
                    });
                  },
                  child: Text('Sign Up'),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              InkWell(
                child: Text('Already have an account? Click here!'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }),
                  );
                },
              )
            ],
          ),
        ),
      )),
      onWillPop: () => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Cancelation'),
          content: Text('Do you really want to cancel registration'),
          actions: [
            FlatButton(
              child: Text('Yes', style: basicTheme().textTheme.title),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }),
                );
              },
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
