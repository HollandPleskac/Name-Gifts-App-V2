import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constant.dart';
import '../logic/fire.dart';

final _fire = Fire();
final _firestore = Firestore.instance;

class InvitationScreen extends StatefulWidget {
  @override
  _InvitationScreenState createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  TextEditingController _displayNameController = TextEditingController();
  String uid;
  bool isData;

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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClipPath(
              clipper: SClipper(),
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
                  //   alignment: Alignment.topLeft,
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
                            padding: const EdgeInsets.only(
                              bottom: 90,
                              left: 40,
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: SvgPicture.asset(
                                'assets/images/undraw_invite_i6u7.svg',
                                width: 150,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.075,
                              ),
                              child: Text(
                                'My Invitations',
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
            Container(
              height: 350,
              child: StreamBuilder(
                stream: _firestore
                    .collection("user data")
                    .document(uid)
                    .collection('my invites')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.active:
                      //if there is snapshot data and the list of doucments it returns is empty
                      if (snapshot.data != null &&
                          snapshot.data.documents.isEmpty == false) {
                        return Center(
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            children: snapshot.data.documents.map(
                              (DocumentSnapshot document) {
                                return Invitation(
                                  eventCreationDate: document['creation date'],
                                  hostEmail: document['host'],
                                  invitationType: document['invite type'],
                                  eventName: document['event name'],
                                  uid: uid,
                                  invitationEventId: document.documentID,
                                  displayNameController: _displayNameController,
                                  familyName: document['family name'],
                                  hostUid: document['host uid'],
                                );
                              },
                            ).toList(),
                          ),
                        );
                      }
                      // need in both places?? prevent error with no return statement
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(),
                            Container(),
                            Text('You have no invitations'),
                            Text('Your invitations will show up here'),
                            Container(),
                          ],
                        ),
                      );

                    case ConnectionState.none:
                      return Text('Connection state returned none');
                      break;
                    case ConnectionState.done:
                      return Text('Connection state finished');
                      break;
                    default:
                      return Text('nothing here');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height - 80);
    var firstControlPoint = new Offset(size.width / 4, size.height - 40);
    var firstEndPoint = new Offset(size.width / 2, size.height - 85);
    var secondControlPoint =
        new Offset(size.width - (size.width / 4), size.height - 135);
    var secondEndPoint = new Offset(size.width, size.height - 90);

    // var firstControlPoint = new Offset(size.width / 4, size.height - 120);
    // var firstEndPoint = new Offset(size.width / 2, size.height - 180);
    // var secondControlPoint =
    //     new Offset(size.width - (size.width / 4), size.height - 235);
    // var secondEndPoint = new Offset(size.width, size.height - 230);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height / 3);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class Invitation extends StatelessWidget {
  final String eventCreationDate;
  final String hostEmail;
  final String invitationType;
  final String uid;
  final String eventName;
  final String invitationEventId;
  final TextEditingController displayNameController;
  final String familyName;
  final String hostUid;

  Invitation({
    @required this.eventCreationDate,
    @required this.hostEmail,
    @required this.invitationType,
    @required this.uid,
    @required this.eventName,
    @required this.invitationEventId,
    @required this.displayNameController,
    @required this.familyName,
    @required this.hostUid,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.only(
        bottom: 30,
        left: 15,
        right: 15,
      ),
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 10,
            child: invitationCard(
              context: context,
              eventCreationDate: eventCreationDate,
              hostEmail: hostEmail,
              invitationType: invitationType,
              eventName: eventName,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 3,
            child: InvitationActions(
              eventName: eventName,
              invitationEventId: invitationEventId,
              uid: uid,
              displayNameController: displayNameController,
              creationDate: eventCreationDate,
              host: hostEmail,
              invitationType: invitationType,
              familyName: familyName,
              hostUid: hostUid,
            ),
          ),
        ],
      ),
    );
  }
}

Widget invitationCard({
  BuildContext context,
  String eventCreationDate,
  String invitationType,
  String hostEmail,
  String eventName,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Text(
          eventCreationDate + ' | Invited to ' + invitationType,
          style: kSubTextStyle.copyWith(fontSize: 18),
        ),
      ),
      Container(
        height: 160,
        width: double.infinity,
        child: Card(
          elevation: 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Icon(
                    Icons.insert_invitation,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    eventName.toString(),
                    style: kHeadingTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Icon(
                    Icons.email,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    hostEmail,
                    style: kHeadingTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    ],
  );
}

class InvitationActions extends StatelessWidget {
  final String eventName;
  final String uid;
  final String invitationEventId;
  final TextEditingController displayNameController;
  final String creationDate;
  final String host;
  final String invitationType;
  final String familyName;
  final String hostUid;

  InvitationActions({
    @required this.eventName,
    @required this.uid,
    @required this.invitationEventId,
    @required this.displayNameController,
    @required this.creationDate,
    @required this.host,
    @required this.invitationType,
    @required this.familyName,
    @required this.hostUid,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 160,
          width: double.infinity,
          child: Card(
            color: kPrimaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                AcceptInviteToEvent(
                  eventName: eventName,
                  uid: uid,
                  invitationEventId: invitationEventId,
                  displayNameController: displayNameController,
                  creationDate: creationDate,
                  host: host,
                  invitationType: invitationType,
                  familyName: familyName,
                  hostUid: hostUid,
                ),
                DeleteInvite(
                  uid: uid,
                  invitationEventId: invitationEventId,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }
}

class DeleteInvite extends StatefulWidget {
  final String uid;
  final String invitationEventId;

  DeleteInvite({
    @required this.uid,
    @required this.invitationEventId,
  });
  @override
  _DeleteInviteState createState() => _DeleteInviteState();
}

class _DeleteInviteState extends State<DeleteInvite> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.delete_outline,
        color: Colors.white,
      ),
      onPressed: () {
        _fire.deleteInvite(
          widget.uid,
          widget.invitationEventId,
        );
        setState(() {});
      },
    );
  }
}

class AcceptInviteToEvent extends StatefulWidget {
  final String eventName;
  final String uid;
  final String invitationEventId;
  final String creationDate;
  final TextEditingController displayNameController;
  final String host;
  final String invitationType;
  final String familyName;
  final String hostUid;
  AcceptInviteToEvent({
    @required this.eventName,
    @required this.uid,
    @required this.invitationEventId,
    @required this.creationDate,
    @required this.displayNameController,
    @required this.host,
    @required this.invitationType,
    @required this.familyName,
    @required this.hostUid,
  });

  @override
  _AcceptInviteToEventState createState() => _AcceptInviteToEventState();
}

class _AcceptInviteToEventState extends State<AcceptInviteToEvent> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
      onPressed: () async {
        print('tried to join ' + widget.invitationType);
        widget.invitationType == 'event'
            ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(
                      'Join ' + widget.eventName.toString(),
                      style: kHeadingTextStyle,
                    ),
                    content: Container(
                      height: 110,
                      child: Column(
                        children: <Widget>[
                          displayNameInput(
                            context: context,
                            controller: widget.displayNameController,
                            icon: Icon(
                              Icons.event_note,
                              color: kPrimaryColor,
                            ),
                            hintText: 'family name (ex. Doug and Janel)',
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                color: kPrimaryColor,
                                onPressed: () {
                                  _fire.acceptInvite(
                                    displayNameForEvent:
                                        widget.displayNameController.text,
                                    eventName: widget.eventName,
                                    uid: widget.uid,
                                    invitationEventId: widget.invitationEventId,
                                    creationDate: widget.creationDate,
                                    host: widget.host,
                                    inviteType: widget.invitationType,
                                  );

                                  
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Text(
                                  'Join',
                                  style: kSubTextStyle.copyWith(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(
                      'Join ' + widget.familyName.toString(),
                      style: kHeadingTextStyle,
                    ),
                    content: Container(
                      height: 110,
                      child: Column(
                        children: <Widget>[
                          displayNameInput(
                            context: context,
                            controller: widget.displayNameController,
                            icon: Icon(
                              Icons.event_note,
                              color: kPrimaryColor,
                            ),
                            hintText: 'member name (ex. Holland)',
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                color: kPrimaryColor,
                                onPressed: () async {
                                  print('TRYING TO ACCEPT INVITE');
                                  _fire.acceptInviteToFamily(
                                    displayNameForFamily:
                                        widget.displayNameController.text,
                                    eventName: widget.eventName,
                                    uid: widget.uid,
                                    invitationEventId: widget.invitationEventId,
                                    creationDate: widget.creationDate,
                                    host: widget.host,
                                    hostUid: widget.hostUid,
                                    inviteType: widget.invitationType,
                                  );
                                  print('DONE ACCEPTING INVITE');
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  print('TRYING TO SET SHARED PREFERENCES');
                                  prefs.setString('alt uid', widget.hostUid);
                                  print('DONE WITH SETTING SHARED PREFERENCES');

                                  Navigator.pop(context);
                                  print('POPPED THE SCREEN');
                                  setState(() {});
                                  print('DONE SETTING STATE');
                                },
                                child: Text(
                                  'Join',
                                  style: kSubTextStyle.copyWith(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
        // : _fire.acceptInviteToFamily(
        //     displayNameForFamily: widget.displayNameController.text,
        //     eventName: widget.eventName,
        //     uid: widget.uid,
        //     invitationEventId: widget.invitationEventId,
        //     creationDate: widget.creationDate,
        //     host: widget.host,
        //     hostUid: widget.hostUid,
        //     inviteType: widget.invitationType,
        //   );
        // when invited to family the host uid will be used
        //SharedPreferences prefs = await SharedPreferences.getInstance();
        //prefs.setString('alt uid', widget.hostUid);

        //Navigator.pop(context);

        //setState(() {});
      },
    );
  }
}

Widget displayNameInput({
  BuildContext context,
  TextEditingController controller,
  Icon icon,
  String hintText,
}) {
  return Center(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        controller: controller,
        maxLines: 1,
        style: kSubTextStyle,
        autofocus: false,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintStyle: kSubTextStyle,
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            hintText: hintText,
            icon: icon),
      ),
    ),
  );
}
