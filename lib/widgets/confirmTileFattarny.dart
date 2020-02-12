import 'package:fattarny/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class ConfirmingUserTile extends StatefulWidget {
  final String generatedID;
  final String userId_;
  final int totalPrice_;
  final bool isPaid_;
  ConfirmingUserTile(
      {this.generatedID, this.totalPrice_, this.userId_, this.isPaid_});

  @override
  _ConfirmingUserTileState createState() => _ConfirmingUserTileState();
}

class _ConfirmingUserTileState extends State<ConfirmingUserTile> {
  paying(String genId) async {
    var response = await http
        .put('https://fattarny.herokuapp.com/orders/set_is_paid/$genId/true');

    if (response.statusCode == 200) {
      Toast.show('Click on restart icon to refresh orders', context,
          duration: 3);
    } else {
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        child: ListTile(
            title: Text(
              widget.userId_,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              widget.totalPrice_.toString() + ' L.E.',
              style: basicTheme().textTheme.title.apply(color: Colors.green),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.check),
                onPressed: () {
                  paying(widget.generatedID);
                },
              ),
            )));
  }
}
