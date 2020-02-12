import 'dart:collection';
import 'package:fattarny/globals/global.dart' as globals;
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:fattarny/confirm_orders_page.dart';
import 'package:fattarny/theme.dart';
import 'package:fattarny/vote_page.dart';
import 'package:fattarny/widgets/menuListFattarny.dart';
import 'package:fattarny/widgets/splashFattarny.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LoadMenu extends StatefulWidget {
  @override
  _LoadMenuState createState() => _LoadMenuState();
}

final String url = 'http://worldtimeapi.org/api/timezone/Africa/Cairo';

String timeGlobal, todayDate = '';
double differenceInHours;
int differenceHours,
    difference,
    differenceMinutes,
    serverHours,
    globalHours,
    globalMinutes,
    totalServerMinutes,
    totalGlobalMinutes;

int timeNow = 0;
bool isButtonDisabled = false;
String winner = '';
String userId = '';
Future<String> getUserId() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String userId = sharedPreferences.getString('id');
  return userId;
}

class _LoadMenuState extends State<LoadMenu> {
  Future<int> minutesNow() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var convertDatatoJSON = jsonDecode(response.body);
    todayDate = convertDatatoJSON['datetime'].toString().substring(0, 10);
    globals.globalTodayDate = todayDate;
    timeGlobal = convertDatatoJSON['datetime'].toString().substring(11, 16);
    globalHours = int.parse(timeGlobal.toString().substring(0, 2));
    globalMinutes = int.parse(timeGlobal.toString().substring(3));
    String timeServer = globals.timeServer;
    serverHours = int.parse(timeServer.toString().substring(0, 2));
    serverMinutes = int.parse(timeServer.toString().substring(3));
    totalServerMinutes = (serverHours * 60) + serverMinutes;
    timeNow = globalMinutes;
    if (timeNow - serverMinutes < 0) {
      timeNow = globalMinutes + 60;
    }
    if (timeNow - serverMinutes >= 0) {
      timeNow = -timeNow;
    }
    return timeNow;
  }
  // getWinnerID() async {
  //   var Response = await http.get(
  //     "https://fattarny.herokuapp.com/menuItems/$todayDate",
  //     headers: {"Accept": "application/json"},
  //   );
  //   if (Response.statusCode == 200) {
  //     String responseBody = Response.body;
  //     var responseJSON = json.decode(responseBody);
  //     winner = responseJSON['id'];
  //     setState(() {});
  //   } else {
  //     print('Something went wrong. \nResponse Code : ${Response.statusCode}');
  //   }
  // }

  sendDate() async {
    Map data = {'date': todayDate};
    print(data);
    var jsonData = null;
    //checking user's info
    var response1 = await http.post(
        'https://fattarny.herokuapp.com/menuItems/$todayDate',
        body: data);

    if (response1.statusCode == 200) {
      jsonData = json.decode(response1.body);
      winner = jsonData['id'];
      print(winner);
      print(data);
      print('date sent!');
      // getWinnerID();
    }
  }

  initiate() async {
    await getJsonData();
    await minutesNow();
    await getUserId().then((onValue) {
      userId = onValue;
    });
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MenuPage();
      }),
    );
  }

  Future<String> getJsonData() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var convertDatatoJSON = jsonDecode(response.body);
    todayDate = convertDatatoJSON['datetime'].toString().substring(0, 10);
    todayDate = convertDatatoJSON['datetime'].toString().substring(0, 10);
    todayDate = convertDatatoJSON['datetime'].toString().substring(0, 10);
    timeGlobal = convertDatatoJSON['datetime'].toString().substring(11, 16);
    globalHours = int.parse(timeGlobal.toString().substring(0, 2));
    globalMinutes = int.parse(timeGlobal.toString().substring(3));
    totalGlobalMinutes = (globalHours * 60) + globalMinutes;
    //server time in 24 hours time
    String timeServer = globals.timeServer;
    serverHours = int.parse(timeServer.toString().substring(0, 2));
    serverMinutes = int.parse(timeServer.toString().substring(3));
    totalServerMinutes = (serverHours * 60) + serverMinutes;
    difference = totalServerMinutes - totalGlobalMinutes;
    await sendDate();
    return 'Success';
  }

  saveUserVoting(usersVote) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('vote', usersVote);
  }

  @override
  void initState() {
    initiate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FattarnySplash();
  }
}

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  initialize() async {
    await getUserOrder().then((onValue) {
      if (onValue == null) {
        isButtonDisabled = false;
      } else {
        isButtonDisabled = onValue;
      }
    });
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: globals.isAdmin == '1'
                ? <Widget>[
                    IconButton(
                      splashColor: basicTheme().accentColor,
                      icon: Icon(
                        Icons.person_pin,
                        size: 30.0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return ConfirmOrdersPage();
                          }),
                        );
                      },
                    )
                  ]
                : null,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: CountdownFormatted(
              onFinish: () {
                saveUserVoting(false);
                saveUserOrder(false);

                setState(() {
                  isButtonDisabled = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return GetTimerTime();
                  }),
                );
              },
              duration:
                  Duration(hours: 0, minutes: ((serverMinutes + 30) + timeNow)),
              builder: (BuildContext ctx, String remaining) {
                return Text(remaining);
              },
            ),
          ),
          body: FutureBuilder<List<Menu>>(
            future: fetchMenus(http.Client()),
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? MenuList(menu: snapshot.data)
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SpinKitPouringHourglass(
                          size: 120.0,
                          color: basicTheme().primaryColor,
                        ),
                        Text(
                          '\nLoading Menu..',
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

class MenuList extends StatefulWidget {
  static HashMap cart = HashMap<int, int>();
  final List<Menu> menu;

  MenuList({Key key, this.menu}) : super(key: key);

  @override
  _MenuListState createState() => _MenuListState();
}

saveUserVoting(usersVote) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setBool('vote', usersVote);
}

saveUserOrder(usersVote) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setBool('order', usersVote);
}

Future<bool> getUserOrder() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool order = sharedPreferences.getBool('order');
  return order;
}

class _MenuListState extends State<MenuList> {
  // orderFunction(
  //     {String userId, int price, String quantity}) async {
  //   Map data = {
  //     'user_id': userId,
  //     'date': todayDate,
  //     'is_paid': false,
  //   };
  //   print(data);
  //   var jsonData = null;
  //   var response = await http
  //       .post('https://fattarny.herokuapp.com/orders/create_order', body: data);

  //   if (response.statusCode == 200) {
  //     jsonData = json.decode(response.body);
  //     setState(() {
  //       print(response.statusCode);
  //       print('Order Done!');
  //     });
  //   }
  // }

  orderMade({TotalOrder totaltotal}) async {
    print(totaltotal);
    var jsonData = null;
    var body = json.encode(totaltotal.toJson());
    var response = await http.post(
        'https://fattarny.herokuapp.com/orders/create_order',
        headers: {"Content-Type": "application/json"},
        body: body);
    if (response.statusCode == 200) {
      await saveUserOrder(true).then((onValue) {
        isButtonDisabled = true;
      });
      jsonData = json.decode(response.body);
      setState(() {
        print(response.statusCode);
      });
    } else {
      setState(() {
        isButtonDisabled = false;
      });
      print(response.statusCode.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {});
    return SafeArea(
      child: isButtonDisabled == false
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Divider(
                  color: basicTheme().scaffoldBackgroundColor,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: RaisedButton(
                      color: basicTheme().accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5.0),
                              bottomLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0))),
                      elevation: 3,
                      disabledElevation: 3,
                      onPressed: isButtonDisabled
                          ? null
                          : () {
                              //Button function
                              // List<Item> li;
                              List<OrderItem> li = new List<OrderItem>();
                              for (int it = 0; it < widget.menu.length; it++) {
                                if (MenuList.cart[widget.menu[it].id] > 0) {
                                  Item i = Item(
                                      id: widget.menu[it].id,
                                      name: widget.menu[it].title,
                                      price: widget.menu[it].price,
                                      restaurantId:
                                          widget.menu[it].restaurantId);
                                  li.add(OrderItem(
                                      quantity: MenuList.cart[i.id], item: i));
                                }

                                // TotalOrder(date: todayDate,isPaid: false,userId: int.parse(userId),orderItems: );
                              }
                              TotalOrder nafar = TotalOrder(
                                  totalPrice: 0,
                                  date: todayDate,
                                  isPaid: false,
                                  userId: userId,
                                  orderItems: li);
                              print(nafar);
                              if (li.length != 0) {
                                setState(() {
                                  isButtonDisabled = true;
                                });
                                orderMade(totaltotal: nafar);
                              } else {
                                Toast.show("Can't order nothing", context);
                              }
                            },
                      child: Text(
                        'Order',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: basicTheme().scaffoldBackgroundColor,
                ),
                Expanded(
                  flex: 10,
                  child: ListView.builder(
                      itemCount: widget.menu.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        MenuList.cart[widget.menu[index].id] =
                            widget.menu[index].menuQuantity;
                        return MenuListFattarny(
                          id: widget.menu[index].id,
                          name: widget.menu[index].title,
                          price: widget.menu[index].price,
                          quantityOfItem: MenuList.cart[widget.menu[index].id],
                          restaurantId: widget.menu[index].restaurantId,
                        );
                        // return Padding(
                        //   padding: const EdgeInsets.only(right: 2, left: 2),
                        //   child: Card(
                        //     elevation: 8.0,
                        //     child: ListTile(
                        //         leading: IconButton(
                        //             icon: Icon(Icons.add),
                        //             onPressed: () {
                        //               setState(() {
                        //                 x++;
                        //               });
                        //             }),
                        //         title: Text(
                        //           ' \$${widget.menu[index].price} ' +
                        //               widget.menu[index].title,
                        //           style: TextStyle(fontSize: 18.0),
                        //         ),
                        //         subtitle: Text(
                        //           'Quantity: $x',
                        //           style:
                        //               TextStyle(color: Colors.grey, fontSize: 15.0),
                        //         ),
                        //         trailing: IconButton(
                        //             icon: Icon(Icons.remove),
                        //             onPressed: () {
                        //               setState(() {
                        //                 x--;
                        //               });
                        //             })),
                        //   ),
                        // );
                      }),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Your Order Has Been Submitted',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  Text(
                    'Please pay your adminstrator',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Divider(),
                  SpinKitWave(
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? basicTheme().primaryColor
                              : basicTheme().accentColor,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }
}

Future<List<Menu>> fetchMenus(http.Client client) async {
  final response =
      await client.get('https://fattarny.herokuapp.com/items/$winner');

  // Use the compute function to run pasrseMenu in a separate isolate.
  return compute(pasrseMenu, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Menu> pasrseMenu(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Menu>((json) => Menu.fromJson(json)).toList();
}

class Menu {
  final int id;
  final int price;
  final String title;
  final int restaurantId;
  final int menuQuantity;

  Menu({this.id, this.price, this.title, this.restaurantId, this.menuQuantity});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as int,
      price: json['price'] as int,
      menuQuantity: json['count'] as int,
      title: json['name'] as String,
      restaurantId: json['restaurant_id'] as int,
    );
  }
}

class Item {
  int id;
  int restaurantId;
  String name;
  int price;
  Item({this.id, this.restaurantId, this.name, this.price});

  Map toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'price': price
    };
  }
}

class OrderItem {
  int quantity;
  Item item;
  OrderItem({this.quantity, this.item});
  Map toJson() {
    // List<Map> itemsJson = this.items.map((i) => i.toJson()).toList();
    return {'quantity': quantity, 'item': item.toJson()};
  }
}

class TotalOrder {
  List<OrderItem> orderItems;
  String userId;
  int totalPrice = 0;
  bool isPaid = false;
  String date;
  TotalOrder(
      {this.date, this.isPaid, this.orderItems, this.userId, this.totalPrice});
  Map toJson() {
    List<Map> ordersJson = this.orderItems.map((i) => i.toJson()).toList();
    return {
      'user_id': userId,
      'total_price': totalPrice,
      'date': todayDate,
      'is_paid': false,
      'order_items': ordersJson
    };
  }
}
