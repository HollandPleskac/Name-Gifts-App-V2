import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './auth_screens/sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<String> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString('user uid', null);
    String uid = prefs.getString('uid');
    print(uid);
    return uid;
  }

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      // () async => getUser() == null ||
      //         await getUser() == '' ||
      //         
      //     ? Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => SignInScreen(),
      //         ),
      //       )
      //     : Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => TabPage(),
      //         ),
      //       ),
      () async => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignInScreen(),
              ),
            )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: 'dash',
              child: Container(
                width: MediaQuery.of(context).size.width*0.45,
                child: Image.asset('assets/images/gift.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
