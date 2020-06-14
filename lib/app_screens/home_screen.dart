import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../logic/fire.dart';
import '../constant.dart';
import '../sub_screens/view_members_screen.dart';

final Firestore _firestore = Firestore.instance;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

final _fire = Fire();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //List<String> eventsList = ['Pleskac Christmas List 2020', 'testing'];

  //selectedeventDisplay - got w/function
  //selectedEvent(NAME OF EVENT IMPORTANT) - always null in beginning changed with program (dropdown item selected)
  //selectedEventId - got w/function
  //uid - got w/function

  TextEditingController _inviteController = TextEditingController();

  String selectedEventDisplay = '';
  String selectedEvent;
  String selectedEventID;
  String uid;
  String isEventData = 'loading';
  String altUid;

  Future getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');
    String alternateUid = prefs.getString('alt uid');

    uid = userUid;
    altUid = alternateUid;
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

  Future getSelectedEventDisplay() async {
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

      selectedEventDisplay = selEventName;
      print(selectedEventDisplay);
    } catch (e) {
      selectedEventDisplay = 'No events';
    }
  }

  Future checkEventData(eventId) async {
    try {
      String data = await _firestore
          .collection("events")
          .document(eventId)
          .collection('event members')
          .getDocuments()
          .then(
            (value) => value.documents[0].documentID.toString(),
          );
      if (data == null) {
        isEventData = null;
      } else {
        isEventData = 'true';
      }
    } catch (_) {
      isEventData = null;
    }

    // value is a query snapshot of documents
  }

  Future setSelectedEventIdInFirestore(String newSelectedEventName) async {
    String newSelectedEventId = await _firestore
        .collection('user data')
        .document(uid)
        .collection('my events')
        .where('event name', isEqualTo: newSelectedEventName)
        .getDocuments()
        .then((value) => value.documents[0].documentID);
    print('FEEEDING UID + ' + uid);

    updateSelectedEventDataInApp(newSelectedEventId, newSelectedEventName);

    _fire.setSelectedEvent(uid, selectedEventID);
  }

  void updateSelectedEventDataInApp(newId, newEventName) async {
    setState(() {
      selectedEventID = newId;

      selectedEvent = newEventName;

      selectedEventDisplay = newEventName;
    });
  }

  @override
  void initState() {
    getUid().then((_) {
      print("got uid");
      getSelectedEventID().then((_) {
        print("got selected event display");
        getSelectedEventDisplay().then(
          (_) {
            print('got the selected event id');
            checkEventData(selectedEventID).then(
              (_) {
                print('checked event data');
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
        child: Column(
          children: <Widget>[
            ClipPath(
              clipper: MyClipper(),
              child: Container(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  top: MediaQuery.of(context).size.height * 0.06,
                  right: MediaQuery.of(context).size.width * 0.05,
                ),
                height: MediaQuery.of(context).size.height * 0.39,
                //height:350
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
                  //   image: AssetImage("assets/images/virus.png"),
                  // ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.07),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SvgPicture.asset(
                                'assets/images/undraw_online_articles_79ff.svg',
                                width:
                                    MediaQuery.of(context).size.height * 0.245,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'View Selected Event',
                              style: kHeadingTextStyle.copyWith(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.08,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.011,
            ),
            ////
            ////
            ////
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.045,
              ),
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.045,
              ),
              height: MediaQuery.of(context).size.height * 0.073,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Color(0xFFE5E5E5),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("user data")
                      .document(uid)
                      .collection('my events')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Text("Loading.....");
                    else {
                      List<DropdownMenuItem> dropdownEvents = [];
                      for (int i = 0; i < snapshot.data.documents.length; i++) {
                        DocumentSnapshot documentSnapshot =
                            snapshot.data.documents[i];
                        dropdownEvents.add(
                          DropdownMenuItem(
                            child: Text(
                              documentSnapshot['event name'],
                              style: kSubTextStyle.copyWith(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: "${documentSnapshot['event name']}",
                          ),
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.event,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.045,
                          ),
                          Expanded(
                            child: DropdownButton(
                              isExpanded: true,
                              underline: SizedBox(),
                              icon: Container(
                                margin: EdgeInsets.only(top: 2),
                                child: Icon(Icons.arrow_drop_down),
                              ),
                              value: selectedEvent,
                              items: dropdownEvents,
                              onChanged: (newEventSelected) async {
                                await setSelectedEventIdInFirestore(
                                  newEventSelected,
                                );
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                // update the alt uid
                                await prefs.setString(
                                    'alt uid',
                                    await _fire
                                        .determineSelectedEventType(uid));
                              },
                              hint: Text(
                                selectedEventDisplay,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.028),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.045),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Families\n",
                              style: kTitleTextstyle,
                            ),
                            TextSpan(
                              text: selectedEventDisplay,
                              style: TextStyle(
                                color: kTextLightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      // TODO : invite a group to the current event
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: (selectedEventID == 'no selected event' ||
                                  selectedEventID == '')
                              ? Colors.grey
                              : Colors.black,
                        ),
                        onPressed: (selectedEventID == 'no selected event' ||
                                selectedEventID == '')
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      title: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Invite Family to : \n",
                                              style: kHeadingTextStyle.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.048,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: selectedEventDisplay,
                                              style: kHeadingTextStyle.copyWith(
                                                color: Colors.black,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.048,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      content: Container(
                                        height: 100,
                                        child: Column(
                                          children: <Widget>[
                                            displayNameInput(
                                              context: context,
                                              controller: _inviteController,
                                              icon: Icon(
                                                Icons.email,
                                                color: kPrimaryColor,
                                              ),
                                              hintText: 'email of recipient',
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                  color: kPrimaryColor,
                                                  onPressed: () async {
                                                    //fire invite member

                                                    String host =
                                                        await _firestore
                                                            .collection(
                                                                'user data')
                                                            .document(uid)
                                                            .get()
                                                            .then(
                                                              (docSnap) =>
                                                                  docSnap.data[
                                                                      'email'],
                                                            );

                                                    String creationDate =
                                                        await _firestore
                                                            .collection(
                                                                'events')
                                                            .document(
                                                                selectedEventID)
                                                            .get()
                                                            .then(
                                                              (docSnap) => docSnap[
                                                                  'creation date'],
                                                            );

                                                    _fire.sendInvite(
                                                      email: _inviteController
                                                          .text,
                                                      eventId: selectedEventID,
                                                      eventName:
                                                          selectedEventDisplay,
                                                      uid: uid,
                                                      host: host,
                                                      creationDate:
                                                          creationDate,
                                                      inviteType: 'event',
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Text(
                                                      'Invite',
                                                      style: kSubTextStyle
                                                          .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 17,
                                                      ),
                                                    ),
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
                      ),
                      // Text(
                      //   "View Event",
                      //   style: TextStyle(
                      //     color: kPrimaryColor,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.028,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.31,
              child: isEventData == null
                  ? Center(
                      child: Text('No events'),
                    )
                  : StreamBuilder(
                      stream: _firestore
                          .collection("events")
                          .document(selectedEventID)
                          .collection('event members')
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
                              // child: ListView(
                              //   scrollDirection: Axis.horizontal,
                              //   physics: BouncingScrollPhysics(),
                              //   children: snapshot.data.documents.map(
                              //     (DocumentSnapshot document) {
                              //       return family(
                              //         context: context,
                              //         familyName: document['family name'],
                              //         gifts: document['gifts'],
                              //         members: document['members'],
                              //         uid: uid,
                              //         selectedEvent: selectedEvent,
                              //         selectedEventId: selectedEventID,
                              //         familyUid: document.documentID,
                              //       );
                              //     },
                              //   ).toList(),
                              // ),
                              child: GridView.count(
                                primary: false,
                                padding: const EdgeInsets.all(40),
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 15,
                                crossAxisCount: 2,
                                children: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  return familyGrid(
                                    familyName: document['family name'],
                                    familyUID: document.documentID,
                                    context: context,
                                    selectedEventId: selectedEventID,
                                  );
                                }).toList(),
                              ),
                            );
                        }
                      },
                    ),
            ),
            // Container(
            //   height: 250,
            //   child: ListView(
            //     scrollDirection: Axis.horizontal,
            //     physics: BouncingScrollPhysics(),
            //     children: <Widget>[
            //       family(context),
            //       family(context),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

Widget familyGrid({
  String familyName,
  String familyUID,
  BuildContext context,
  String selectedEventId,
}) {
  return InkWell(
    child: Container(
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   begin: Alignment.topRight,
                  //   end: Alignment.bottomLeft,
                  //   colors: [
                  //     Color(0xFF3383CD),
                  //     Color(0xFF11249F),
                  //   ],
                  // ),
                  color: Color(0xFF11249F),
                  image: DecorationImage(
                    image: AssetImage('assets/images/virus.png'),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                    ),
                    child: Text(
                      familyName,
                      style: kSubTextStyle.copyWith(
                          color: Colors.black, fontSize: 15.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    onTap: () => Navigator.pushNamed(
      context,
      ViewMembersScreen.routeName,
      arguments: {
        'family name': familyName,
        'family uid': familyUID,
        'selected event id': selectedEventId,
      },
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
