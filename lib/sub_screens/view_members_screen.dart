import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constant.dart';
import '../sub_screens/view_gifts_screen.dart';

final Firestore _firestore = Firestore.instance;

class ViewMembersScreen extends StatefulWidget {
  static const routeName = 'view-members-screen';
  @override
  _ViewMembersScreenState createState() => _ViewMembersScreenState();
}

class _ViewMembersScreenState extends State<ViewMembersScreen> {
  @override
  Widget build(BuildContext context) {
    final Map routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final String familyName = routeArguments['family name'];
    final String selectedEventId = routeArguments['selected event id'];
    final String familyUid = routeArguments['family uid'];
    return Scaffold(
      appBar: AppBar(
        title: Text(familyName + '\'s Members'),
        centerTitle: true,
      ),
      // body: Column(
      //   children: [
      //     SizedBox(
      //       height: 20,
      //     ),
      //     Container(
      //       height: 400,
      //       child: ListView(
      //         children: [
      //           Member(
      //             onPressFunction: () {},
      //             memberName: 'Holland Pleskac',
      //             memberType: '4 gifts',
      //           )
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
      body: StreamBuilder(
        stream: _firestore
            .collection("events")
            .document(selectedEventId)
            .collection('event members')
            .document(familyUid)
            .collection('family members')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    children: snapshot.data.documents.map(
                      (DocumentSnapshot document) {
                        return ViewMember(
                          memberName: document.documentID,
                          giftCount: document['gifts'],
                          onPressFunction: () {
                            Navigator.pushNamed(
                              context,
                              ViewGiftsScreen.routeName,
                              arguments: {
                                'member name': document.documentID,
                                'family uid': familyUid,
                                'selected event id':selectedEventId,
                              },
                            );
                          },
                        );
                      },
                    ).toList(),
                  ),
                );
              }
              // else : do this
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(),
                    Text(familyName + ' has no members'),
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
    );
  }
}

class ViewMember extends StatelessWidget {
  final String memberName;
  // final String memberType;
  // final String uid;
  // final String selectedEventID;
  final int giftCount;
  final Function onPressFunction;

  ViewMember({
    this.memberName,
    // this.memberType,
    // this.uid,
    // this.selectedEventID,
    this.giftCount,
    @required this.onPressFunction,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        onTap: onPressFunction,
        child: Card(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 45,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          hexagon(context),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(),
                              memberNameText(context, memberName),
                              memberTypeText(
                                  context, giftCount.toString() + ' Gifts'),
                              Container(),
                              // containers are here to make memberNameText and memberTypeText go nearer to each other
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget hexagon(BuildContext context) {
  return Container(
    width: 60,
    child: ClipPolygon(
      sides: 6,
      borderRadius: 5.0, // Default 0.0 degrees
      rotate: 0.0, // Default 0.0 degrees
      // boxShadows: [
      //   PolygonBoxShadow(color: Colors.black, elevation: 1.0),
      //   PolygonBoxShadow(color: Colors.grey, elevation: 5.0)
      // ],
      child: Container(
        color: kPrimaryColor,
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 25,
        ),
      ),
    ),
  );
}

Widget memberNameText(BuildContext context, String memberName) {
  return Text(
    memberName,
    style: kHeadingTextStyle.copyWith(
      fontSize: 20,
      color: kPrimaryColor,
    ),
  );
}

Widget memberTypeText(BuildContext context, String memberType) {
  return Text(
    memberType,
    style: kSubTextStyle.copyWith(
      fontSize: 15,
    ),
  );
}

class MemberDelete extends StatelessWidget {
  final String memberName;
  final String uid;
  final String selectedEventID;
  final Function updateScreenFunction;

  MemberDelete({
    @required this.memberName,
    @required this.uid,
    @required this.selectedEventID,
    @required this.updateScreenFunction,
  });
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
