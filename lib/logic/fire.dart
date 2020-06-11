import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';

import '../app_screens/invitation_screen.dart';

final Firestore _firestore = Firestore.instance;

class Fire {
  //checks if the selected event is a family invite - if so returns uid of the family invite
  Future<String> determineSelectedEventType(String userUid) async {
    String selectedEvent = await _firestore
        .collection('user data')
        .document(userUid)
        .get()
        .then((docSnap) => docSnap.data['selected event']);
    if (selectedEvent == '' || selectedEvent == 'no selected event') {
      return userUid;
    }

    print('SeLECTED EVENT + ' + selectedEvent);

    String eventType = await _firestore
        .collection('user data')
        .document(userUid)
        .collection('my events')
        .document(selectedEvent)
        .get()
        .then((docSnap) => docSnap.data['event type']);

    if (eventType == 'family') {
      String hostUid = await _firestore
          .collection('user data')
          .document(userUid)
          .collection('my events')
          .document(selectedEvent)
          .get()
          .then((docSnap) => docSnap.data['host uid']);
      print('RETURNING HOST UID + ' + hostUid);
      return hostUid;
    }
    return userUid;
  }

  ///
  ///
  ///                              Create an Account
  ///
  ///
  void createAccount(String userUid, String email) {
    _firestore.collection('user data').document(userUid).setData(
      {
        'email': email,
        'selected event': 'no selected event',
      },
    );
  }
  // does not work without setting some random string to selected event
  // just setting 'selected event':'' does not work

  ///
  ///
  ///                                Create an Event
  ///
  ///
  void createEvent(
      {String eventName, String uid, String host, String familyNameForEvent}) {
    var _randomString = randomAlphaNumeric(20);

    _firestore
        .collection("user data")
        .document(uid)
        .collection('my events')
        .document(_randomString)
        .setData(
      {
        'event name': eventName,
        'host': host,
        'creation date': DateFormat.yMMMMd('en_US').format(
          DateTime.now(),
        ),
        'event type': 'event',
        'host uid': uid,
      },
    );

    _firestore.collection('events').document(_randomString).setData(
      {
        'event name': eventName,
        'host': host,
        'creation date': DateFormat.yMMMMd('en_US').format(
          DateTime.now(),
        )
      },
    );

    createFamilyInEvent(
        uid: uid,
        eventId: _randomString,
        familyName: familyNameForEvent,
        host: host);
    // _randomString here is the event id

    setSelectedEvent(uid, _randomString);
  }

  void createFamilyInEvent(
      {String uid, String eventId, String familyName, String host}) {
    _firestore
        .collection("events")
        .document(eventId)
        .collection('event members')
        .document(uid)
        .setData(
      {
        'family name': familyName,
        'host': host,
        'members': 0,
        'gifts': 0,
      },
    );
  }

  void setSelectedEvent(String uid, String eventId) {
    _firestore.collection("user data").document(uid).updateData(
      {
        'selected event': eventId,
      },
    );
  }

  ///
  ///
  ///                            Remove Event
  ///
  ///
  void deleteEvent(String uid, String eventId) async {
    _firestore
        .collection('user data')
        .document(uid)
        .collection('my events')
        .document(eventId)
        .delete();

    //check remaining members
    //this makes sure that if there are multiple members in an event and if one person deletes the event, the other members can stay
    int membersRemaining = await _firestore
        .collection('events')
        .document(eventId)
        .collection('event members')
        .getDocuments()
        .then(
          (querySnap) => querySnap.documents.length,
        );

    if (membersRemaining == 1) {
      _firestore
          .collection('events')
          .document(eventId)
          .collection('event members')
          .document(uid)
          .delete();
      _firestore.collection('events').document(eventId).delete();
    } else {
      _firestore
          .collection('events')
          .document(eventId)
          .collection('event members')
          .document(uid)
          .delete();
    }

    String _selectedEvent = await _firestore
        .collection('user data')
        .document(uid)
        .get()
        .then((docSnapshot) => docSnapshot.data['selected event'].toString());

    if (_selectedEvent == eventId) {
      // sets the selected event to nothing if selected event id equals the id of event just deleted
      setSelectedEvent(uid, '');
    }
  }

  ///
  ///
  ///                                            Add a member to event
  ///
  ///
  void addDependantMember({String memberName, String uid, String eventId}) {
    _firestore
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid)
        .collection('family members')
        .document(memberName)
        .setData(
      {
        'linked': '',
        'member type': 'dependant member',
        'gifts': 0,
      },
    );

    // transaction updates the count of total members in family

    final DocumentReference postRef = Firestore.instance
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid);
    _firestore.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(postRef,
            <String, dynamic>{'members': postSnapshot.data['members'] + 1});
      }
    });
  }

  ///
  ///
  ///                                       remove a member
  ///
  ///
  void deleteDependantMember({String memberName, String uid, String eventId}) {
    _firestore
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid)
        .collection('family members')
        .document(memberName)
        .delete();

    // transaction is called up update the amount of family members

    final DocumentReference postRef = Firestore.instance
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid);
    _firestore.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(postRef,
            <String, dynamic>{'members': postSnapshot.data['members'] - 1});
      }
    });
  }

  ///
  ///
  ///                                   Invite a member to an Event / Accept an invite to an Event
  ///
  ///
  void sendInvite({
    String uid,
    String eventId,
    String email,
    String eventName,
    String host,
    String creationDate,
    String inviteType,
    String familyName,
  }) async {
    String uidOfPersonRecievingInvite = await _firestore
        .collection('user data')
        .where('email', isEqualTo: email)
        .getDocuments()
        .then(
          (querySnap) => querySnap.documents[0].documentID.toString(),
        );

    _firestore
        .collection("user data")
        .document(uidOfPersonRecievingInvite)
        .collection('my invites')
        .document(eventId)
        .setData(
      {
        'event name': eventName,
        'host': host,
        'invite type': inviteType,
        'host uid': uid,
        'creation date': creationDate,
        'family name': familyName,
        //fam name is only really used for invite to family - it is null if inviting to event
      },
    );
  }

  void acceptInvite({
    String eventName,
    String uid,
    String invitationEventId,
    String displayNameForEvent,
    String creationDate,
    String host,
    String inviteType,
  }) {
    // adds the user to the event
    _firestore
        .collection("user data")
        .document(uid)
        .collection('my events')
        .document(invitationEventId)
        .setData(
      {
        'event name': eventName,
        'display name': displayNameForEvent,
        'event type': inviteType,
        'host': host,
        'creation date': creationDate,
      },
    );

    //initializes members value and gifts value as well as display name
    _firestore
        .collection('events')
        .document(invitationEventId)
        .collection('event members')
        .document(uid)
        .setData(
      {
        'family name': displayNameForEvent,
        'host': host,
        'members': 0,
        'gifts': 0,
        'creationDate': creationDate,
      },
    );

    // deletes the events out of invites list
    _firestore
        .collection("user data")
        .document(uid)
        .collection('my invites')
        .document(invitationEventId)
        .delete();

    setSelectedEvent(uid, invitationEventId);
  }

  void acceptInviteToFamily({
    String eventName,
    String uid,
    String invitationEventId,
    String displayNameForFamily,
    String creationDate,
    String host,
    String inviteType,
    String hostUid,
  }) {
    // adds the user to the event
    _firestore
        .collection("user data")
        .document(uid)
        .collection('my events')
        .document(invitationEventId)
        .setData(
      {
        'event name': eventName,
        'display name': displayNameForFamily,
        'event type': inviteType,
        'host': host,
        'creation date': creationDate,
        'host uid': hostUid,
      },
    );

    //initializes and gifts value as well as display name
    _firestore
        .collection('events')
        .document(invitationEventId)
        .collection('event members')
        .document(hostUid)
        .collection('family members')
        .document(displayNameForFamily)
        .setData(
      {
        'gifts': 0,
        'member type': 'independent member',
        'linked': uid,
      },
    );

    // deletes the events out of invites list
    _firestore
        .collection("user data")
        .document(uid)
        .collection('my invites')
        .document(invitationEventId)
        .delete();

    setSelectedEvent(uid, invitationEventId);
  }

  void deleteInvite(String uid, String invitationEventId) {
    _firestore
        .collection('user data')
        .document(uid)
        .collection('my invites')
        .document(invitationEventId)
        .delete();
  }

  ///
  ///
  ///                                                 Delete Account clear firebase
  ///
  ///

  void deleteAccountInDatabase(String uid) {
    _firestore.collection('user data').document(uid).delete();
  }

  ///
  ///
  ///                                                 Add/Remove Gifts
  ///
  ///

  Future<String> addGift(
      String memberName,
      String giftName,
      String uid,
      String eventId,
      double giftPrice,
      String giftLink,
      String giftDescription) async {
    List potentialGiftsWithSameGiftName = await _firestore
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid)
        .collection('family members')
        .document(memberName)
        .collection('gifts')
        .where('name', isEqualTo: giftName)
        .getDocuments()
        .then(
          (value) => value.documents,
        );
    if (potentialGiftsWithSameGiftName.isEmpty) {
      _firestore
          .collection('events')
          .document(eventId)
          .collection('event members')
          .document(uid)
          .collection('family members')
          .document(memberName)
          .collection('gifts')
          .document(giftName)
          .setData(
        {
          'price': giftPrice,
          'name': giftName,
          'link': giftLink,
          'description': giftDescription,
        },
      );

      final DocumentReference postRef = Firestore.instance
          .collection('events')
          .document(eventId)
          .collection('event members')
          .document(uid)
          .collection('family members')
          .document(memberName);
      _firestore.runTransaction(
        (Transaction tx) async {
          DocumentSnapshot postSnapshot = await tx.get(postRef);
          if (postSnapshot.exists) {
            await tx.update(postRef,
                <String, dynamic>{'gifts': postSnapshot.data['gifts'] + 1});
          }
        },
      );
      return 'success';
    } else {
      return 'name already taken';
    }
  }

  void removeGift(
      String memberName, String giftName, String uid, String eventId) {
    _firestore
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid)
        .collection('family members')
        .document(memberName)
        .collection('gifts')
        .document(giftName)
        .delete();

    final DocumentReference postRef = Firestore.instance
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid)
        .collection('family members')
        .document(memberName);
    _firestore.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(postRef,
            <String, dynamic>{'gifts': postSnapshot.data['gifts'] - 1});
      }
    });
  }

  void updateGift({
    String eventId,
    String uid,
    String memberName,
    String giftName,
    String newGiftDescription,
    String newGiftLink,
    String newGiftName,
    double newGiftPrice,
  }) {
    _firestore
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid)
        .collection('family members')
        .document(memberName)
        .collection('gifts')
        .document(giftName)
        .delete();
    _firestore
        .collection('events')
        .document(eventId)
        .collection('event members')
        .document(uid)
        .collection('family members')
        .document(memberName)
        .collection('gifts')
        .document(newGiftName)
        .setData({
      'name': newGiftName,
      'link': newGiftLink,
      'price': newGiftPrice,
      'description': newGiftDescription,
    });
  }
}
