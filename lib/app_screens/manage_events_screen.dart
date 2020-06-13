import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../logic/fire.dart';
import '../constant.dart';

final _fire = Fire();
final Firestore _firestore = Firestore.instance;

class ManageEventsScreen extends StatefulWidget {
  @override
  _ManageEventsScreenState createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  TextEditingController _displayNameForEventController =
      TextEditingController();
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _inviteController = TextEditingController();

  String uid;
  String selectedEventID;
  String selectedEventName = '';
  String isUserEvents = 'loading';

  Future getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    uid = userUid;
    print(uid);
  }

  Future getSelectedEventID() async {
    String eventID = await _firestore
        .collection("user data")
        .document(uid)
        .get()
        .then((documentSnapshot) => documentSnapshot.data['selected event']);
    selectedEventID = eventID;
    print(selectedEventID);
  }

  Future getSelectedEventName() async {
    try {
      String selEventName = await _firestore
          .collection('user data')
          .document(uid)
          .collection('my events')
          .document(selectedEventID)
          .get()
          .then(
            (docSnap) => docSnap.data['event name'],
          );

      selectedEventName = selEventName;
      print(selectedEventName);
    } catch (e) {
      selectedEventName = 'No selected event';
    }
  }

  Future checkUsersEvents(memberUid) async {
    try {
      String data = await _firestore
          .collection("user data")
          .document(uid)
          .collection('my events')
          .getDocuments()
          .then(
            (value) => value.documents[0].documentID.toString(),
          );
      if (data == null) {
        isUserEvents = null;
      } else {
        isUserEvents = 'true';
      }
    } catch (_) {
      isUserEvents = null;
    }

    // value is a query snapshot of documents
  }

  @override
  void initState() {
    getUid().then((_) {
      print("got uid");
      getSelectedEventID().then((_) {
        print("got selected event name");
        getSelectedEventName().then(
          (_) {
            print('got the selected event id');
            checkUsersEvents(uid).then(
              (_) {
                print('checked for user events');
                setState(() {});
              },
            );
          },
        );
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
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
                  //   alignment: Alignment.topCenter,
                  //   image: AssetImage(
                  //     "assets/images/virus.png",
                  //   ),
                  // ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          // SvgPicture.asset(
                          //   'assets/icons/Drcorona.svg',
                          //   width: 210,
                          //   fit: BoxFit.fitWidth,
                          //   alignment: Alignment.topCenter,
                          // ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.06,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.09),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SvgPicture.asset(
                                'assets/images/undraw_online_calendar_kvu2.svg',
                                width:
                                    MediaQuery.of(context).size.width * 0.325,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.1,
                                left: MediaQuery.of(context).size.width * 0.35,
                              ),
                              child: Text(
                                'Manage Events',
                                style: kHeadingTextStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 32,
                                ),
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
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Padding(
            //     padding: const EdgeInsets.only(left: 20),
            //     child: selectedEvent(context, selectedEventName),
            //   ),
            // ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.025,
            ),

            ///
            ///          TOP Bar
            ///

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                topBarButton(
                  context,
                  'Create Event',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          title: Text(
                            'Create an Event',
                            style: kHeadingTextStyle,
                          ),
                          content: Container(
                            height: MediaQuery.of(context).size.height * 0.19,
                            child: Column(
                              children: <Widget>[
                                displayNameInput(
                                  context: context,
                                  controller: _eventNameController,
                                  icon: Icon(
                                    Icons.near_me,
                                    color: kPrimaryColor,
                                  ),
                                  hintText: 'name of the event',
                                ),
                                displayNameInput(
                                  context: context,
                                  controller: _displayNameForEventController,
                                  icon: Icon(
                                    Icons.event_note,
                                    color: kPrimaryColor,
                                  ),
                                  hintText: 'family name (ex. Doug and Janel)',
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      color: kPrimaryColor,
                                      onPressed: () async {
                                        _fire.createEvent(
                                          uid: uid,
                                          eventName: _eventNameController.text,
                                          familyNameForEvent:
                                              _displayNameForEventController
                                                  .text,
                                          host: 'hollandpleskac@gmail.com',
                                        );

                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();

                                        await prefs.setString(
                                          'uid',
                                          uid,
                                        );
                                        await prefs.setString('alt uid', uid);

                                        Navigator.pop(context);

                                        //updates the screen after popping

                                        getSelectedEventID().then((_) {
                                          print("got selected event id");
                                          getSelectedEventName().then(
                                            (_) {
                                              print(
                                                  'got the selected event name');
                                              checkUsersEvents(uid).then(
                                                (_) {
                                                  print(
                                                      'checked for user events');
                                                  setState(() {});
                                                },
                                              );
                                            },
                                          );
                                        });
                                      },
                                      child: Text(
                                        'Create',
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
                  },
                  selectedEventID,
                ),
                // topBarButton(
                //   context,
                //   'Invite to Event',
                //   () {
                //     // showDialog(
                //     //   context: context,
                //     //   builder: (BuildContext context) {
                //     //     return AlertDialog(
                //     //       shape: RoundedRectangleBorder(
                //     //           borderRadius: BorderRadius.circular(10)),
                //     //       title: RichText(
                //     //         text: TextSpan(
                //     //           children: [
                //     //             TextSpan(
                //     //               text: "Invite to :\n",
                //     //               style: kHeadingTextStyle.copyWith(
                //     //                 fontSize: 20,
                //     //                 color: Colors.black,
                //     //               ),
                //     //             ),
                //     //             TextSpan(
                //     //               text: selectedEventName,
                //     //               style: kHeadingTextStyle.copyWith(
                //     //                 color: Colors.black,
                //     //                 fontSize: 20,
                //     //               ),
                //     //             ),
                //     //           ],
                //     //         ),
                //     //       ),
                //     //       content: Container(
                //     //         height: 100,
                //     //         child: Column(
                //     //           children: <Widget>[
                //     //             displayNameInput(
                //     //               context: context,
                //     //               controller: _inviteController,
                //     //               icon: Icon(
                //     //                 Icons.email,
                //     //                 color: kPrimaryColor,
                //     //               ),
                //     //               hintText: 'email of recipient',
                //     //             ),
                //     //             Align(
                //     //               alignment: Alignment.bottomRight,
                //     //               child: Padding(
                //     //                 padding: const EdgeInsets.only(right: 10),
                //     //                 child: RaisedButton(
                //     //                   shape: RoundedRectangleBorder(
                //     //                     borderRadius: BorderRadius.circular(2),
                //     //                   ),
                //     //                   color: kPrimaryColor,
                //     //                   onPressed: () async {
                //     //                     //fire invite member

                //     //                     String host = await _firestore
                //     //                         .collection('user data')
                //     //                         .document(uid)
                //     //                         .get()
                //     //                         .then(
                //     //                           (docSnap) =>
                //     //                               docSnap.data['email'],
                //     //                         );

                //     //                     String creationDate = await _firestore
                //     //                         .collection('events')
                //     //                         .document(selectedEventID)
                //     //                         .get()
                //     //                         .then(
                //     //                           (docSnap) =>
                //     //                               docSnap['creation date'],
                //     //                         );

                //     //                     _fire.sendInvite(
                //     //                       email: _inviteController.text,
                //     //                       eventId: selectedEventID,
                //     //                       eventName: selectedEventName,
                //     //                       uid: uid,
                //     //                       host: host,
                //     //                       creationDate: creationDate,
                //     //                       inviteType: 'event',
                //     //                     );
                //     //                     Navigator.pop(context);
                //     //                   },
                //     //                   child: Text(
                //     //                     'Invite',
                //     //                     style: kSubTextStyle.copyWith(
                //     //                         color: Colors.white, fontSize: 17),
                //     //                   ),
                //     //                 ),
                //     //               ),
                //     //             ),
                //     //           ],
                //     //         ),
                //     //       ),
                //     //     );
                //     //   },
                //     // );
                //   },
                //   selectedEventID,
                // ),
              ],
            ),

            ///
            ///     END OF TOP BAR
            ///

            SizedBox(
              height: MediaQuery.of(context).size.height*0.012,
            ),

            ///
            /// List of events
            ///

            Container(
              height: MediaQuery.of(context).size.height * 0.455,
              child: isUserEvents == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(),
                          Text('You have no events'),
                          Text('Your events will be displayed here'),
                          Container(),
                        ],
                      ),
                    )
                  : StreamBuilder(
                      stream: _firestore
                          .collection("user data")
                          .document(uid)
                          .collection('my events')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');

                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          default:
                            return Center(
                              child: ListView(
                                physics: BouncingScrollPhysics(),
                                children: snapshot.data.documents.map(
                                  (DocumentSnapshot document) {
                                    return Event(
                                      uid: uid,
                                      eventName: document['event name'],
                                      eventId: document.documentID,
                                      creationDate: document['creation date'],
                                      selectedEventId: selectedEventID,
                                      host: document['host'],
                                      function: () =>
                                          getSelectedEventID().then((_) {
                                        print("got selected event id");
                                        getSelectedEventName().then(
                                          (_) {
                                            print(
                                                'got the selected event name');
                                            checkUsersEvents(uid).then(
                                              (_) {
                                                print(
                                                    'checked for user events');
                                                setState(() {});
                                              },
                                            );
                                          },
                                        );
                                      }),
                                    );
                                  },
                                ).toList(),
                              ),
                            );
                        }
                      },
                    ),
            ),

            ///
            ///   End of List of Events
            ///
          ],
        ),
      ),
    );
  }
}

class CClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height / 1.9, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class Event extends StatefulWidget {
  final String eventName;
  final String creationDate;
  final String uid;
  final String selectedEventId;
  final String eventId;
  final Function function;
  final String host;

  const Event({
    @required this.eventName,
    @required this.creationDate,
    @required this.uid,
    @required this.selectedEventId,
    @required this.eventId,
    @required this.function,
    @required this.host,
  });

  @override
  State<StatefulWidget> createState() => _EventState();
}

class _EventState extends State<Event> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(100),
                bottomRight: Radius.circular(100),
                // bottomLeft: Radius.circular(50),
                topLeft: Radius.circular(70),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                colors: [
                  kPrimaryColor,
                  Color.fromRGBO(42, 61, 243, 1),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.07),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      eventTitleText(
                        context,
                        widget.eventName,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.01,
                      ),
                      eventSubText(
                        context,
                        widget.creationDate.toString(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.075),
                  child: IconButton(
                    onPressed: () async {
                      _fire.deleteEvent(widget.uid, widget.eventId);
                      widget.function();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget eventTitleText(BuildContext context, String eventName) {
  return Text(
    eventName,
    style: kHeadingTextStyle.copyWith(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget eventSubText(BuildContext context, String creationDate) {
  return Text(
    creationDate,
    style: kSubTextStyle.copyWith(
      color: Colors.white,
      fontSize: 15,
    ),
  );
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

Widget topBarButton(BuildContext context, String buttonTitle,
    Function onPressFunction, selectedEventId) {
  return selectedEventId == null
      ? Container()
      : InkWell(
          child: Container(
            height: MediaQuery.of(context).size.height*0.05,
            width: 160,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                //TODO : button title is only needed if invite button is on screen
                color: buttonTitle == 'Invite to Event' &&
                        (selectedEventId == 'no selected event' ||
                            selectedEventId == '')
                    ? Colors.grey
                    : Color.fromRGBO(42, 61, 243, 1)),
            child: Center(
              child: Text(
                buttonTitle,
                style: kSubTextStyle.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          onTap: onPressFunction,
        );
}

Widget selectedEvent(BuildContext context, selectedEvent) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Selected Event",
        style: kTitleTextstyle.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontSize: 28,
        ),
      ),
      Text(
        selectedEvent,
        style: kTitleTextstyle.copyWith(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}
