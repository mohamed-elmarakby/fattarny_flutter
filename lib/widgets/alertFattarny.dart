import 'package:fattarny/register_page.dart';
import 'package:flutter/material.dart';

class AlertFunc extends StatelessWidget {
  final String alertTitle;
  final String alertContent;
  final String responseOne;
  final String responseTwo;

  AlertFunc(
      {this.alertTitle, this.alertContent, this.responseOne, this.responseTwo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(alertTitle),
      content: Text(alertContent),
      actions: <Widget>[
        FlatButton(
          child: Text(responseOne),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return RegisterPage();
              }),
            );
          },
        ),
        FlatButton(
          child: Text(responseTwo),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
