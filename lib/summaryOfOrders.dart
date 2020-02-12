import 'package:fattarny/confirm_orders_page.dart';
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

class foodItemSummary {
  String name;
  int id, restaurantid, price;
  foodItemSummary.fromJson(Map json) {
    this.name = json['name'];
    this.id = json['id'];
    this.restaurantid = json['restaurant_id'];
    this.price = json['price'];
  }
}

class foodWithQuantity {
  foodItemSummary item;
  int count;
  foodWithQuantity.fromJson(Map json) {
    this.count = json['count'];
    this.item = foodItemSummary.fromJson(json['item']);
  }
}

Future<List<foodWithQuantity>> fetchFoodWithQuantity(http.Client client) async {
  final response = await client.get(
      'https://fattarny.herokuapp.com/orders/orders_summary/${globals.globalTodayDate}',
      headers: {"Accept": "application/json"});

  // var responseMap = json.decode(response.body).cast<Map<String, dynamic>>();
  // List<foodWithQuantity> summaryList = responseMap
  // .map<foodWithQuantity>((json) => foodWithQuantity.fromJson(json))
  // .toList();
  // Use the compute function to run parseOrders in a separate isolate.
  return compute(parseFoodWithQuantity, response.body);
}

// A function that converts a response body into a List<Order>.
List<foodWithQuantity> parseFoodWithQuantity(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<foodWithQuantity>((json) => foodWithQuantity.fromJson(json))
      .toList();
}

class SummaryOfOrders extends StatefulWidget {
  @override
  _SummaryOfOrdersState createState() => _SummaryOfOrdersState();
}

class _SummaryOfOrdersState extends State<SummaryOfOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        child: Scaffold(
          body: FutureBuilder<List<foodWithQuantity>>(
            future: fetchFoodWithQuantity(http.Client()),
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
                          '\nLoading Summary..',
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
  final List<foodWithQuantity> orders;
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
          title: Text('Summary of orders'),
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
                }),
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
                  userId_: widget.orders[index].item.name,
                  totalPrice_: widget.orders[index].count,
                ),
              );
            }),
      ),
    ));
  }
}
