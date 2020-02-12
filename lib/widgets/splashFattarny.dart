import 'package:fattarny/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class FattarnySplash extends StatelessWidget {
  FattarnySplash();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        child: Container(
          color: basicTheme().primaryColor,
          child: Column(
            children: <Widget>[
              Image.asset('assets/images/logo.png'),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SpinKitPouringHourglass(
                  color: Colors.white,
                  size: 50,
                ),
              )
            ],
          ),
        )
        // child: SplashScreen(
        //     seconds: duration,
        //     backgroundColor: basicTheme().primaryColor,
        //     image: Image.asset('assets/images/logo.png'),
        //     photoSize: MediaQuery.of(context).size.width / 2,
        //     navigateAfterSeconds: destination),
        ,
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
