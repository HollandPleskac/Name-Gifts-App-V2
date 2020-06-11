import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../auth_screens/sign_in_screen.dart';
import '../logic/auth.dart';
import '../constant.dart';
import '../logic/fire.dart';

final _auth = Auth();
final _fire = Fire();

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String uid;

  Future getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    uid = userUid;
    print(uid);
  }

  @override
  void initState() {
    getUid().then((_) {
      print("got uid");
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          ClipPath(
            clipper: CClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.39,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3383CD),
                    Color(0xFF11249F),
                  ],
                ),
                // image: DecorationImage(
                //   alignment: Alignment.topRight,
                //   image: AssetImage(
                //     "assets/images/virus.png",
                //   ),
                // ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 120, bottom: 02),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SvgPicture.asset(
                              'assets/images/undraw_mobile_web_2g8b.svg',
                              width: 150,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.12,
                            ),
                            child: Text(
                              'Profile',
                              style: kHeadingTextStyle.copyWith(
                                  color: Colors.white, fontSize: 32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              accountSignOut(context),
              accountDelete(context, uid),
            ],
          ),
        ],
      ),
    );
  }
}

// class SClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = new Path();
//     path.lineTo(0, size.height - 160);
//     var firstControlPoint = new Offset(size.width / 4, size.height - 103);
//     var firstEndPoint = new Offset(size.width / 2, size.height - 170);
//     var secondControlPoint =
//         new Offset(size.width - (size.width / 4), size.height - 240);
//     var secondEndPoint = new Offset(size.width, size.height - 220);

//     // var firstControlPoint = new Offset(size.width / 4, size.height - 120);
//     // var firstEndPoint = new Offset(size.width / 2, size.height - 180);
//     // var secondControlPoint =
//     //     new Offset(size.width - (size.width / 4), size.height - 235);
//     // var secondEndPoint = new Offset(size.width, size.height - 230);

//     path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
//         firstEndPoint.dx, firstEndPoint.dy);
//     path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
//         secondEndPoint.dx, secondEndPoint.dy);

//     path.lineTo(size.width, size.height / 3);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }

class CClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 90);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 90);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

Widget accountDelete(
  BuildContext context,
  String uid,
) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    height: 60,
    child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: kRedColor,
      child: Text(
        'Delete Account',
        style: kSubTextStyle.copyWith(color: Colors.white, fontSize: 18),
      ),
      onPressed: () async {
        _fire.deleteAccountInDatabase(uid);
        _auth.deleteAccount();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', '');
        prefs.setString('selected event id', '');
        prefs.setString('selected event name', '');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
          ),
        );
      },
    ),
  );
}

Widget accountSignOut(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    height: 60,
    child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: kGreenColor,
      child: Text(
        'Sign Out',
        style: kSubTextStyle.copyWith(color: Colors.white, fontSize: 18),
      ),
      onPressed: () async {
        _auth.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', '');
        prefs.setString('selected event id', '');
        prefs.setString('selected event name', '');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
          ),
        );
      },
    ),
  );
}

Widget viewEmail(BuildContext context) {
  return Text(
    'hollandpleskac@gmail.com',
    style: kHeadingTextStyle.copyWith(fontSize: 26),
  );
}
