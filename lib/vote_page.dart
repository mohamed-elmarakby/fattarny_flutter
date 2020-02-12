import 'dart:convert';
import 'package:fattarny/globals/global.dart' as globals;
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:fattarny/confirm_orders_page.dart';
import 'package:fattarny/menu_Page.dart';
import 'package:fattarny/widgets/splashFattarny.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

String userId = '', userPassword = '';
Future<String> getUserId() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String userId = sharedPreferences.getString('id');
  return userId;
}

Future<String> getUserPassword() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String userId = sharedPreferences.getString('password');
  return userId;
}

Future<bool> getUserVote() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool voted = sharedPreferences.getBool('vote');
  return voted;
}

Future<String> getVoteDate() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String dateVoted = sharedPreferences.getString('date');
  return dateVoted;
}

Future<List<Restaurant>> fetchRestaurants(http.Client client) async {
  final response =
      await client.get('https://fattarny.herokuapp.com/restaurants');

  // Use the compute function to run parseRestaurants in a separate isolate.
  return compute(parseRestaurants, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Restaurant> parseRestaurants(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Restaurant>((json) => Restaurant.fromJson(json)).toList();
}

class Restaurant {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Restaurant({this.albumId, this.id, this.title, this.url, this.thumbnailUrl});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      albumId: json['albumId'] as int,
      id: json['id'] as int,
      title: json['name'] as String,
      url: json['image_url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}

String timeGlobal, todayDate, sharedPrefDate;
double differenceInHours;
int differenceHours,
    differenceMinutes,
    serverHours,
    serverMinutes,
    globalHours,
    globalMinutes,
    totalServerMinutes,
    totalGlobalMinutes;
bool inVoteRegion = false, didVote = false, sharePrefVote = false;

class GetTimerTime extends StatefulWidget {
  @override
  _GetTimerTimeState createState() => _GetTimerTimeState();
}

checkAuthority(String id, String password) async {
  Map data = {'user_id': id, 'password': password};
  print(data);
  var jsonData = null;
  //checking user's info
  var response =
      await http.post('https://fattarny.herokuapp.com/users/login', body: data);

  if (response.statusCode == 200) {
    jsonData = json.decode(response.body);
    globals.isAdmin = jsonData['is_admin'];
  }
}

class _GetTimerTimeState extends State<GetTimerTime> {
  Future<int> minutesNow() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var convertDatatoJSON = jsonDecode(response.body);
    todayDate = convertDatatoJSON['datetime'].toString().substring(0, 10);
    globals.globalTodayDate = todayDate;
    timeGlobal = convertDatatoJSON['datetime'].toString().substring(11, 16);
    globalHours = int.parse(timeGlobal.toString().substring(0, 2));
    globalMinutes = int.parse(timeGlobal.toString().substring(3));
    timeNow = globalMinutes;
    if (timeNow - serverMinutes < 0) {
      timeNow = timeNow + 60;
    } else if (timeNow - serverMinutes >= 0) {
      timeNow = -timeNow;
    }
    return timeNow;
  }

  getServerTime() async {
    Map data = {'date': todayDate};
    print(data);
    var jsonData = null;
    //checking user's info
    var response1 = await http.get('https://fattarny.herokuapp.com/votingTime');

    if (response1.statusCode == 200) {
      jsonData = json.decode(response1.body);
      globals.timeServer = jsonData['start_time'];
      print(globals.timeServer);
      print('serever time recieved!');
      // getWinnerID();
    }
  }
  //add a global var for current time from server time

  final String url = 'http://worldtimeapi.org/api/timezone/Africa/Cairo';

  Future<void> initializationSequence() async {
    await getServerTime();
    await getVoteDate().then((onValue) {
      if (onValue == null) {
        sharedPrefDate = '';
      } else {
        sharedPrefDate = onValue;
      }
    });
    await getUserVote().then((onValue) {
      sharePrefVote = onValue;
      if (sharePrefVote == true) {
        // setState(() {
        sharePrefVote = true;
        // });
      } else {
        // setState(() {
        sharePrefVote = false;
        // });
      }
    });
    await getJsonData();
    await minutesNow();
    await getUserId().then((onValue) {
      userId = onValue;
    });
    await getUserPassword().then((onValue) {
      userPassword = onValue;
    });
    await checkAuthority(userId, userPassword);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return BasedOnTimePage;
      }),
    );
    // getUserVote().then((onValue) {
    //   setState(() {
    //     didVote = onValue;
    //   });
    // });
  }

  @override
  void initState() {
    print('init state');
    super.initState();
    initializationSequence();
    print('BasedOnTime: $BasedOnTimePage');
  }

  dynamic BasedOnTimePage;
  Future<String> getJsonData() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    BasedOnTimePage = VotingPage();
    var convertDatatoJSON = jsonDecode(response.body);
    todayDate = convertDatatoJSON['datetime'].toString().substring(0, 10);
    timeGlobal = convertDatatoJSON['datetime'].toString().substring(11, 16);
    globalHours = int.parse(timeGlobal.toString().substring(0, 2));
    globalMinutes = int.parse(timeGlobal.toString().substring(3));
    totalGlobalMinutes = (globalHours * 60) + globalMinutes;
    //server time in 24 hours time
    //begining voting & ordering time
    String timeServer = globals.timeServer;
    serverHours = int.parse(timeServer.toString().substring(0, 2));
    serverMinutes = int.parse(timeServer.toString().substring(3));
    totalServerMinutes = (serverHours * 60) + serverMinutes;

    int difference = totalServerMinutes - totalGlobalMinutes;
    if (difference <= 0 && difference >= -15) {
      // setState(() {
      inVoteRegion = true;
      BasedOnTimePage = VotingPage();
      // });
      differenceHours = 0;
      differenceMinutes = 15 + difference;
    } else if (difference < -15 && difference > -30) {
      // setState(() {
      if (todayDate == sharedPrefDate) {
        getUserVote().then((onValue) {
          if (onValue) {
            saveUserVoting(true).then((onValue) {
              setState(() {
                getUserOrder().then((onValue) {
                  if (onValue == null || onValue == false) {
                    saveUserOrder(false);
                  } else {
                    saveUserOrder(true);
                  }
                });
                BasedOnTimePage = LoadMenu();
              });
            });
          } else if (onValue == null || onValue == false) {
            saveUserVoting(false).then((onValue) {
              setState(() {
                getUserOrder().then((onValue) {
                  if (onValue == null || onValue == false) {
                    saveUserOrder(false);
                  } else {
                    saveUserOrder(true);
                  }
                });
                BasedOnTimePage = LoadMenu();
              });
            });
          }
        });
      } else {
        inVoteRegion = false;
        saveUserOrder(false);
        BasedOnTimePage = LoadMenu();
      }

      // });
    } else {
      if (totalServerMinutes < totalGlobalMinutes) {
        differenceInHours =
            24 + ((totalServerMinutes - totalGlobalMinutes) / 60);
        differenceHours = differenceInHours.toInt();
        differenceMinutes =
            ((differenceInHours - differenceHours) * 60).toInt();
        // setState(() {
        BasedOnTimePage = VotingPage();
        // });
      } else if (totalServerMinutes > totalGlobalMinutes) {
        differenceInHours = ((totalServerMinutes - totalGlobalMinutes) / 60);
        differenceHours = differenceInHours.toInt();
        differenceMinutes =
            ((differenceInHours - differenceHours) * 60).toInt();
      }
    }
    return 'Success';
  }

  @override
  Widget build(BuildContext context) {
    return FattarnySplash();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('out of timer page');
    super.dispose();
  }
}

class VotingPage extends StatefulWidget {
  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  initializer() async {
    if (todayDate != sharedPrefDate) {
      await getUserVote().then((onValue) {
        // setState(() {
        if (onValue == null) {
          didVote = false;
          //Last update
          saveUserVoting(false);
          saveUserOrder(false);
        } else {
          getUserOrder().then((onValue) {
            if (onValue == null || onValue == false) {
              saveUserOrder(false);
            } else {
              saveUserOrder(true);
            }
          });
          didVote = false;
        }
        // });
      });
    } else {
      if (didVote != sharePrefVote) {
        if (sharePrefVote == null || sharePrefVote == false) {
          // setState(() {
          didVote = false;
          //Last update
          saveUserVoting(false);
          saveUserOrder(false);
          // });
        } else if (sharePrefVote == true) {
          // setState(() {
          saveUserVoting(true);
          didVote = true;
          // });
        }
      }
    }
  }

  @override
  void initState() {
    initializer();
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
            title: inVoteRegion
                ? CountdownFormatted(
                    onFinish: () {
                      inVoteRegion = false;
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return LoadMenu();
                          }),
                        );
                      });
                    },
                    duration: Duration(
                        hours: differenceHours,
                        minutes: ((serverMinutes + 15) + timeNow)),
                    builder: (BuildContext ctx, String remaining) {
                      return Text(remaining);
                    },
                  )
                : Text('Voting'),
          ),
          body: inVoteRegion == false
              ? Center(
                  child: CountdownFormatted(
                    onFinish: () {
                      setState(() {
                        inVoteRegion = true;
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return GetTimerTime();
                          }),
                        );
                      });
                    },
                    duration: Duration(
                        hours: differenceHours, minutes: differenceMinutes),
                    builder: (BuildContext ctx, String remaining) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            remaining,
                            style: TextStyle(fontSize: 32, color: Colors.black),
                          ),
                          Divider(),
                          Text('Left to vote',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black))
                        ],
                      );
                    },
                  ),
                )
              : FutureBuilder<List<Restaurant>>(
                  future: fetchRestaurants(http.Client()),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? RestaurantsList(restaurants: snapshot.data)
                        : Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SpinKitPouringHourglass(
                                size: 120.0,
                                color: basicTheme().primaryColor,
                              ),
                              Text(
                                '\nLoading..',
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

class RestaurantsList extends StatefulWidget {
  final List<Restaurant> restaurants;

  RestaurantsList({Key key, this.restaurants}) : super(key: key);

  @override
  _RestaurantsListState createState() => _RestaurantsListState();
}

saveUserVoting(usersVote) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setBool('vote', usersVote);
}

saveVoteDate(usersVote) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString('date', todayDate);
}

class _RestaurantsListState extends State<RestaurantsList> {
  voteFunction(String idUser, String restaurantId, String date) async {
    Map data = {
      'user_id': idUser,
      'id': restaurantId,
      'date': date,
    };
    print(data);
    var jsonData = null;
    var response =
        await http.post('https://fattarny.herokuapp.com/votes', body: data);

    if (response.statusCode == 200) {
      getUserId().then((onValue) {
        setState(() {
          userId = onValue;
          print(userId);
        });
      });
      setState(() {
        didVote = true;
      });
      saveUserVoting(didVote).then((onValue) {
        setState(() {
          didVote = true;
        });
      });
      saveVoteDate(todayDate).then((onValue) {});
      jsonData = json.decode(response.body);
      setState(() {
        print(response.statusCode);
      });
    }
    if (response.statusCode == 401) {
      setState(() {});
      print(response.statusCode.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    final double widthScreen = mediaQueryData.size.width;
    final double appBarHeight = kToolbarHeight;
    final double paddingTop = mediaQueryData.padding.top;
    final double paddingBottom = mediaQueryData.padding.bottom;
    final double heightScreen =
        mediaQueryData.size.height - paddingBottom - paddingTop - appBarHeight;
    return SafeArea(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: didVote == false ? 2 : 1,
          childAspectRatio: widthScreen / heightScreen,
        ),
        itemCount: didVote == false ? widget.restaurants.length : 1,
        itemBuilder: (context, index) {
          return didVote == false
              ? Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {
                      final snackBar = SnackBar(
                        content: Text('Double tap to confirm your vote'),
                        duration: Duration(seconds: 1),
                      );

                      // Find the Scaffold in the widget tree and use
                      // it to show a SnackBar.
                      Scaffold.of(context).showSnackBar(snackBar);
                    },
                    onDoubleTap: () {
                      //add user id here
                      voteFunction(userId,
                          widget.restaurants[index].id.toString(), todayDate);
                    },
                    child: Image.network(
                      widget.restaurants[index].url,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Thanks for your vote',
                        style: TextStyle(color: Colors.black, fontSize: 32),
                      ),
                      Text(
                        'Calculating the winning Restaurant',
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
                );
        },
      ),
    );
  }
}

int crossAxisCount = 2;
