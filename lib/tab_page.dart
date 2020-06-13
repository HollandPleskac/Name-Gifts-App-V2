import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

import './app_screens/invitation_screen.dart';
import './app_screens/home_screen.dart';
import './app_screens/manage_events_screen.dart';
import './app_screens/my_members_screen.dart';
import './app_screens/profile_screen.dart';


class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  /////////////////////////////
  //////////////////////////
  //////////////////////////////
  ////////////////////
  int selectedIndex = 0;

  PageController controller = PageController();

  List<GButton> tabs = new List();

  List<Color> colors = [
    Colors.orange,
    Colors.pink,
    Colors.amber,
    Colors.green,
    Colors.blue,
  ];

  List<Widget> _screens = <Widget>[
    HomeScreen(),
    MyMembersScreen(),
    ManageEventsScreen(),
    InvitationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    var padding = EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 5,
    );
    double gap = 30;

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: Colors.pink,
      iconColor: Colors.black,
      textColor: Colors.pink,
      iconSize: 24,
      padding: padding,
      icon: LineIcons.home,
      text: 'Home',
    ));

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: Colors.purple,
      iconColor: Colors.black,
      textColor: Colors.purple,
      iconSize: 24,
      padding: padding,
      icon: LineIcons.group,
      text: 'Members',
    ));

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: Colors.amber[600],
      iconColor: Colors.black,
      textColor: Colors.amber[600],
      iconSize: 24,
      padding: padding,
      icon: Icons.event,
      text: 'Events',
    ));

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: Colors.green,
      iconColor: Colors.black,
      textColor: Colors.green,
      iconSize: 24,
      padding: padding,
      icon: LineIcons.envelope,
      text: 'Invitations',
    ));

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: Colors.teal,
      iconColor: Colors.black,
      textColor: Colors.teal,
      iconSize: 24,
      padding: padding,
      icon: LineIcons.user,
      text: 'Profile',
    ));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView.builder(
        onPageChanged: (page) {
          setState(() {
            selectedIndex = page;
          });
        },
        controller: controller,
        itemBuilder: (context, index) {
          return Container(
            child: _screens[index],
          );
        },
        itemCount: tabs.length, // Can be null
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(100)),
              boxShadow: [
                BoxShadow(
                    spreadRadius: -10,
                    blurRadius: 60,
                    color: Colors.black.withOpacity(.20),
                    offset: Offset(0, 15))
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
            child: GNav(
                tabs: tabs,
                selectedIndex: selectedIndex,
                onTabChange: (index) {
                  print(index);
                  setState(() {
                    selectedIndex = index;
                  });
                  controller.jumpToPage(index);
                }),
        ),
          ),
      ),
    );
  }
}
