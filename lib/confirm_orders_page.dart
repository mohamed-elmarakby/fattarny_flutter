import 'package:fattarny/globals/global.dart' as globals;
import 'dart:convert';
import 'package:fattarny/theme.dart';
import 'package:fattarny/vote_page.dart';
import 'package:fattarny/widgets/confirmTileFattarny.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

Future<List<Order>> fetchOrders(http.Client client) async {
  final response = await client.get(
      'https://fattarny.herokuapp.com/orders/get_all_paid/${globals.globalTodayDate}/false',
      headers: {"Accept": "application/json"});

  // Use the compute function to run parseOrders in a separate isolate.
  return compute(parseOrders, response.body);
}

// A function that converts a response body into a List<Order>.
List<Order> parseOrders(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Order>((json) => Order.fromJson(json)).toList();
}

class Order {
  final int totalPrice;
  final String userid;
  final String generatedId;
  final bool isConfirmPay;

  Order(
      {this.generatedId,
      this.userid,
      this.totalPrice,
      this.isConfirmPay = false});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      generatedId: json['_id'] as String,
      userid: json['user_id'] as String,
      totalPrice: json['total_price'] as int,
      isConfirmPay: json['is_paid'] as bool,
    );
  }
}

class ConfirmOrdersPage extends StatefulWidget {
  @override
  _ConfirmOrdersPageState createState() => _ConfirmOrdersPageState();
}

class _ConfirmOrdersPageState extends State<ConfirmOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        child: Scaffold(
          body: FutureBuilder<List<Order>>(
            future: fetchOrders(http.Client()),
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? OrdersList(orders: snapshot.data)
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SpinKitPouringHourglass(
                          size: 120.0,
                          color: basicTheme().primaryColor,
                        ),
                        Text(
                          '\nLoading Orders..',
                          style: TextStyle(
                              color: basicTheme().primaryColor,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        )
                      ],
                    ));
            },
          ),
        ),
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
                    style: basicTheme()
                        .textTheme
                        .title
                        .apply(color: Colors.green)),
                onPressed: () => Navigator.pop(c, false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrdersList extends StatefulWidget {
  final List<Order> orders;
  OrdersList({Key key, this.orders}) : super(key: key);

  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: null,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Orders Confirmation'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.restore),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ConfirmOrdersPage();
                    }),
                  );
                })
          ],
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return GetTimerTime();
                }),
              );
            },
          ),
        ),
        body: ListView.builder(
            itemCount: widget.orders.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return Padding(
                padding: const EdgeInsets.only(right: 2, left: 2, bottom: 5),
                child: ConfirmingUserTile(
                  generatedID: widget.orders[index].generatedId,
                  isPaid_: widget.orders[index].isConfirmPay,
                  totalPrice_: widget.orders[index].totalPrice,
                  userId_: widget.orders[index].userid,
                ),
              );
            }),
      ),
    ));
  }
}
