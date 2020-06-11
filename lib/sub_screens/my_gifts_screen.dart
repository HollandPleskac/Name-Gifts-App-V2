import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constant.dart';
import '../logic/fire.dart';

final _fire = Fire();

final Firestore _firestore = Firestore.instance;

class MyGiftsScreen extends StatefulWidget {
  static const routeName = 'my-gifts-screen';
  @override
  _MyGiftsScreenState createState() => _MyGiftsScreenState();
}

class _MyGiftsScreenState extends State<MyGiftsScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _giftNameController = TextEditingController();
    final TextEditingController _giftPriceController = TextEditingController();
    final TextEditingController _giftLinkController = TextEditingController();
    final TextEditingController _giftDescriptionController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final Map routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final String memberName = routeArguments['member name'];
    final String selectedEventId = routeArguments['selected event id'];
    final String uid = routeArguments['uid'];
    String errorMessage = '';
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(memberName + ' \'s Gifts'),
        centerTitle: true,
        actions: [
          AddGift(
            uid: uid,
            eventId: selectedEventId,
            memberName: memberName,
            formKey: _formKey,
            giftNameController: _giftNameController,
            giftPriceController: _giftPriceController,
            giftDescriptionController: _giftDescriptionController,
            giftLinkController: _giftLinkController,
            errorMessage: errorMessage,
          )
        ],
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection("events")
            .document(selectedEventId)
            .collection('event members')
            .document(uid)
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
                        return editGift(
                          context: context,
                          eventId: selectedEventId,
                          familyUid: uid,
                          giftName: document.documentID,
                          giftPrice: document['price'].toDouble(),
                          memberName: memberName,
                          giftNameController: _giftNameController,
                          giftPriceController: _giftPriceController,
                          giftLinkController: _giftLinkController,
                          giftDescriptionController: _giftDescriptionController,
                          giftLink: document['link'],
                          giftDescription: document['description'],
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

Widget editGift({
  BuildContext context,
  String giftName,
  double giftPrice,
  String familyUid,
  String eventId,
  String memberName,
  TextEditingController giftNameController,
  TextEditingController giftPriceController,
  TextEditingController giftLinkController,
  TextEditingController giftDescriptionController,
  String giftLink,
  String giftDescription,
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
                        icon: Icon(
                          (Icons.edit),
                          color: Colors.blue,
                          size: 28,
                        ),
                        onPressed: () {
                          giftNameController.text = giftName;
                          giftPriceController.text = giftPrice.toString();
                          giftLinkController.text = giftLink;
                          giftDescriptionController.text = giftDescription;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                title: Text(
                                  'Edit : ' + giftName,
                                  style: kHeadingTextStyle,
                                ),
                                content: Container(
                                  height: 250,
                                  child: Column(
                                    children: <Widget>[
                                      EditGiftInput(
                                        controller: giftNameController,
                                        icon: Icon(
                                          Icons.near_me,
                                          color: kPrimaryColor,
                                        ),
                                        hintText: 'gift name',
                                      ),
                                      EditGiftInput(
                                        controller: giftPriceController,
                                        icon: Icon(
                                          Icons.monetization_on,
                                          color: kPrimaryColor,
                                        ),
                                        hintText: 'gift price',
                                      ),
                                      EditGiftInput(
                                        controller: giftLinkController,
                                        icon: Icon(
                                          Icons.link,
                                          color: kPrimaryColor,
                                        ),
                                        hintText: 'link',
                                      ),
                                      EditGiftInput(
                                        controller: giftDescriptionController,
                                        icon: Icon(
                                          Icons.description,
                                          color: kPrimaryColor,
                                        ),
                                        hintText: 'description',
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            color: kPrimaryColor,
                                            onPressed: () {
                                             _fire.updateGift(
                                               uid: familyUid,
                                               eventId: eventId,
                                               giftName: giftName,
                                               memberName: memberName,
                                               newGiftDescription: giftDescriptionController.text,
                                               newGiftLink: giftLinkController.text,
                                               newGiftName: giftNameController.text,
                                               newGiftPrice: double.parse(giftPriceController.text).toDouble(),
                                             );
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Update',
                                              style: kSubTextStyle.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 17),
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      IconButton(
                        icon: Icon(
                          (Icons.delete_forever),
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: () {
                          _fire.removeGift(
                              memberName, giftName, familyUid, eventId);
                        },
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

class AddGift extends StatelessWidget {
  final String eventId;
  final String memberName;
  final String uid;
  final GlobalKey<FormState> formKey;
  final TextEditingController giftNameController;
  final TextEditingController giftPriceController;
  final TextEditingController giftLinkController;
  final TextEditingController giftDescriptionController;
  final String errorMessage;

  AddGift({
    this.eventId,
    this.memberName,
    this.uid,
    this.formKey,
    this.giftNameController,
    this.giftPriceController,
    this.giftLinkController,
    this.giftDescriptionController,
    this.errorMessage,
  });
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        giftPriceController.text = '';
        giftNameController.text = '';
        giftLinkController.text = '';
        giftDescriptionController.text = '';
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              // this container and single child scroll view allow for the sheet being pushed up
              child: AddGiftBottomSheet(
                eventId: eventId,
                memberName: memberName,
                uid: uid,
                formKey: formKey,
                giftPriceController: giftPriceController,
                giftNameController: giftNameController,
                giftDescriptionController: giftDescriptionController,
                giftLinkController: giftLinkController,
                errorMessage: errorMessage,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddGiftBottomSheet extends StatelessWidget {
  final String uid;
  final String memberName;
  final String eventId;
  final GlobalKey<FormState> formKey;
  final TextEditingController giftNameController;
  final TextEditingController giftPriceController;
  final TextEditingController giftLinkController;
  final TextEditingController giftDescriptionController;
  final String errorMessage;
  AddGiftBottomSheet({
    this.uid,
    this.memberName,
    this.eventId,
    this.formKey,
    this.giftNameController,
    this.giftPriceController,
    this.giftLinkController,
    this.giftDescriptionController,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF737373),
      //wrap with new container and set color to 0xFF737373 to see round corners
      //height: 300,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Add a Gift',
                style: kHeadingTextStyle,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: AddGiftForm(
                uid: uid,
                eventId: eventId,
                memberName: memberName,
                formKey: formKey,
                giftNameController: giftNameController,
                giftPriceController: giftPriceController,
                giftLinkController: giftLinkController,
                giftDescriptionController: giftDescriptionController,
                errorMessage: errorMessage,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddGiftForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController giftNameController;
  final TextEditingController giftPriceController;
  final TextEditingController giftLinkController;
  final TextEditingController giftDescriptionController;
  final String memberName;
  final String uid;
  final String eventId;
  String errorMessage;
  AddGiftForm({
    this.formKey,
    this.giftNameController,
    this.giftPriceController,
    this.memberName,
    this.uid,
    this.eventId,
    this.errorMessage,
    this.giftDescriptionController,
    this.giftLinkController,
  });

  @override
  _AddGiftFormState createState() => _AddGiftFormState();
}

class _AddGiftFormState extends State<AddGiftForm> {
  // static String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: AddGiftTextEntry(
                hintText: 'Gift Name',
                icon: Icon(Icons.near_me),
                controller: widget.giftNameController,
                inputType: TextInputType.text,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: AddGiftTextEntry(
                hintText: 'Gift Price',
                icon: Icon(Icons.monetization_on),
                controller: widget.giftPriceController,
                inputType: TextInputType.number,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: AddGiftTextEntry(
                hintText: 'Gift Link',
                icon: Icon(Icons.link),
                controller: widget.giftLinkController,
                inputType: TextInputType.text,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: AddGiftTextEntry(
                hintText: 'Gift Description',
                icon: Icon(Icons.description),
                controller: widget.giftDescriptionController,
                inputType: TextInputType.text,
              ),
            ),
            Center(
              child: Text(
                widget.errorMessage,
                style: kErrorTextstyle,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FlatButton(
                  color: Colors.white,
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kPrimaryColor,
                    ),
                  ),
                  onPressed: () async {
                    if (widget.giftPriceController.text == '' ||
                        widget.giftPriceController.text == null ||
                        widget.giftNameController.text == '' ||
                        widget.giftNameController.text == null ||
                        widget.giftLinkController.text == null ||
                        widget.giftLinkController.text == '' ||
                        widget.giftDescriptionController.text == null ||
                        widget.giftDescriptionController.text == '') {
                      setState(() {
                        widget.errorMessage = 'fill out all fields';
                      });
                    } else {
                      String isSuccess = await _fire.addGift(
                        widget.memberName,
                        widget.giftNameController.text,
                        widget.uid,
                        widget.eventId,
                        double.parse(widget.giftPriceController.text)
                            .toDouble(),
                        widget.giftLinkController.text,
                        widget.giftDescriptionController.text,
                      );
                      print('success? ' + isSuccess);
                      if (isSuccess == 'success') {
                        setState(() {
                          widget.errorMessage = '';
                        });
                        widget.giftPriceController.text = '';
                        widget.giftNameController.text = '';
                        widget.giftLinkController.text = '';
                        widget.giftDescriptionController.text = '';
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          widget.errorMessage = isSuccess;
                        });
                        print('something went wrong when adding a gift');
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddGiftTextEntry extends StatelessWidget {
  final String hintText;
  final Icon icon;
  final TextEditingController controller;
  final TextInputType inputType;

  AddGiftTextEntry({
    @required this.hintText,
    @required this.icon,
    @required this.controller,
    @required this.inputType,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      child: TextFormField(
        keyboardType: inputType,
        controller: controller,
        maxLines: 1,
        style: TextStyle(color: Colors.grey[700], fontSize: 16),
        autofocus: false,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Color.fromRGBO(126, 126, 126, 1),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[700],
          ),
          hintText: hintText,
          icon: icon,
        ),
      ),
    );
  }
}

class EditGiftInput extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Icon icon;
  final String startingText;

  EditGiftInput({this.hintText, this.controller, this.icon, this.startingText});
  @override
  Widget build(BuildContext context) {
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
          // dont need a validator - solving the issue is done in the return from the sign in function
        ),
      ),
    );
  }
}
