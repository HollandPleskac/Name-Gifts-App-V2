//Test Changes in Github

import 'package:flutter/material.dart';

import './splash_screen.dart';
import './sub_screens/view_members_screen.dart';
import './sub_screens/view_gifts_screen.dart';
import './sub_screens/my_gifts_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      home: SplashScreen(),
      routes: ({
        ViewMembersScreen.routeName:(context) => ViewMembersScreen(),
        ViewGiftsScreen.routeName:(context) => ViewGiftsScreen(),
        MyGiftsScreen.routeName:(context) => MyGiftsScreen(),
      }),
    );
  }
}


// NOTE ON ALT UID
// - this uid is used to store either a copy of the uid of the user or
//   the uid of the person hosting a shared event (such as if the user is invited to a family)
// - using this uid allows a user in a shared event to commit to the right part of the database
// - the alt uid can also be a copy of the user uid
// - processes in the app that involve adding stuff (members / events) to database
//   use that alt uid