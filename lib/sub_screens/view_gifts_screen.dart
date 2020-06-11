import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

final Firestore _firestore = Firestore.instance;

class ViewGiftsScreen extends StatefulWidget {
  static const routeName = 'view-gifts-screen';
  @override
  _ViewGiftsScreenState createState() => _ViewGiftsScreenState();
}

class _ViewGiftsScreenState extends State<ViewGiftsScreen> {
  @override
  Widget build(BuildContext context) {
    final Map routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final String memberName = routeArguments['member name'];
    final String familyUid = routeArguments['family uid'];
    final String selectedEventId = routeArguments['selected event id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(memberName + '\'s Gifts'),
        centerTitle: true,
      ),
      // body: ListView(
      //   children: [
      //     gift(
      //       context: context,
      //       eventId: 't',
      //       giftName: 'new car',
      //       giftPrice: 98,
      //       memberName: 'Holland Pleskac',
      //       familyUid: 't',
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
            .document(memberName)
            .collection('gifts')
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
                        return viewGift(
                          context: context,
                          eventId: selectedEventId,
                          familyUid: familyUid,
                          giftName: document.documentID,
                          giftPrice: document['price'].toDouble(),
                          memberName: memberName,
                          url: document['link'],
                          description: document['description'],
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
                    Text(memberName + ' has no gifts'),
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

Widget viewGift({
  BuildContext context,
  String giftName,
  double giftPrice,
  String familyUid,
  String eventId,
  String memberName,
  String url,
  String description,
}) {
  return Column(
    children: <Widget>[
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.01,
      ),
      Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: InkWell(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                  side: BorderSide(width: 1.5, color: Colors.grey[300]),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * 0.02,
                  vertical: MediaQuery.of(context).size.height * 0.0085,
                ),
                child: ListTile(
                  leading: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.025),
                    child: Icon(
                      LineIcons.gift,
                      size: 40,
                      color: Colors.blue[600],
                    ),
                  ),
                  title: Text(
                    giftName,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        color: Colors.grey[500],
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.002,
                          horizontal: MediaQuery.of(context).size.width * 0.013,
                        ),
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.0025),
                        child: Text(
                          '\$' + giftPrice.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.005,
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Description'),
                              content: Text(description),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.description,
                          size: 28,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      IconButton(
                        icon: Icon(
                          (Icons.link),
                          size: 28,
                        ),
                        onPressed: () async {
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            final snackBar = SnackBar(
                              content: Text('Error Launching Url!'),
                              action: SnackBarAction(
                                label: 'Hide',
                                onPressed: () {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                },
                              ),
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                          }
                        },
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                    ],
                  ),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
