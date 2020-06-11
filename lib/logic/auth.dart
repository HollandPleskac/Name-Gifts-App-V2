import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './fire.dart';
import '../tab_page.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

final _fire = Fire();

class Auth {
  Future<List> signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      AuthResult _result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseUser _user = _result.user;

      _fire.createAccount(_user.uid, email);

      return ['success', _user.uid, _user.uid];
    } catch (e) {
      return [e.message.toString(), ''];
    }
  }

  Future<List> signIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      AuthResult _result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser _user = _result.user;

      String userUid = await _fire.determineSelectedEventType(_user.uid);

      return ['success', _user.uid,userUid];
    } catch (e) {
      return [e.message.toString(), ''];
    }
  }

  void signOut() async {
    await _firebaseAuth.signOut();
    print('signed out with email and password');
  }

  void deleteAccount() async {
    var user = await _firebaseAuth.currentUser();

    user.delete();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
}
