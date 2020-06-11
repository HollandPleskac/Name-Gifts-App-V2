import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import './sign_up_screen.dart';
import '../logic/auth.dart';
import '../tab_page.dart';

final _auth = Auth();

final Firestore _firestore = Firestore.instance;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  var errorMessage = '';

  void login() async {
    ///
    ///
    void setUid(String uidValue, String altUidValue) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'uid',
        uidValue,
      );

      await prefs.setString('alt uid', altUidValue);
    }

    //
    //
    List authPackage = await _auth.signIn(
      context,
      _emailController.text,
      _passwordController.text,
    );

    //authPackage[0] is either success or contains the error message
    //authPackage[1] is either the user uid or null
    //authPackage[2] is the user uid or the alt user uid (used if the selected event is an invite to a family)

    if (authPackage[0] == 'success') {
      // sets the uid - authPackage[1] is the uid
      setUid(
        authPackage[1],
        authPackage[2],
      );
      // Push Replacement deletes the screen out of stack - so no using back arrow (android) to go back to the sign in page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TabPage(),
        ),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => TabPage(),
      //   ),
      // );
    } else {
      setState(() {
        errorMessage = authPackage[0];
      });
      print('authPack of 1  ' + authPackage[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              signInText(context),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Hero(
                tag: 'dash',
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Image.asset('assets/images/gift.png'),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
              ),
              signInInput(
                context: context,
                controller: _emailController,
                hintText: 'email',
                icon: Icon(
                  Icons.email,
                  color: kPrimaryColor,
                ),
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              signInInput(
                context: context,
                controller: _passwordController,
                hintText: 'password',
                icon: Icon(
                  Icons.lock,
                  color: kPrimaryColor,
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009,
              ),
              signInErrorText(context, errorMessage),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009,
              ),
              signInButton(
                context,
                () => login(),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.028,
              ),
              signInAlreadyHaveAccount(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget signInText(BuildContext context) {
  return Text(
    'Name Gifts',
    style: kHeadingTextStyle.copyWith(
      fontWeight: FontWeight.w400,
      color: kPrimaryColor,
      fontSize: 45,
    ),
  );
}

Widget signInInput({
  BuildContext context,
  String hintText,
  Icon icon,
  TextInputType keyboardType,
  TextEditingController controller,
  bool obscureText,
}) {
  return Center(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: kPrimaryColor,
          width: 2.25,
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding:
            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.045),
        child: TextFormField(
          controller: controller,
          maxLines: 1,
          keyboardType: keyboardType,
          style: kSubTextStyle.copyWith(color: kPrimaryColor),
          autofocus: false,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintStyle: kSubTextStyle.copyWith(color: kPrimaryColor),
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            hintText: hintText,
            icon: icon,
          ),
          // dont need a validator - solving the issue is done in the return from the sign in function
        ),
      ),
    ),
  );
}

Widget signInButton(
  BuildContext context,
  Function loginFunction,
) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.061,
    width: MediaQuery.of(context).size.width * 0.6,
    child: FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: kPrimaryColor,
      child: Text(
        'Sign In',
        style: kSubTextStyle.copyWith(color: Colors.white, fontSize: 21),
      ),
      onPressed: loginFunction,
    ),
  );
}

Widget signInAlreadyHaveAccount(BuildContext context) {
  return InkWell(
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Don\'t have an account? ",
            style: kSubTextStyle.copyWith(fontSize: 15.5),
          ),
          TextSpan(
            text: "Sign Up!",
            style: TextStyle(color: kPrimaryColor, fontSize: 16),
          ),
        ],
      ),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen(),
        ),
      );
    },
  );
}

Widget signInErrorText(BuildContext context, String errorMessage) {
  if (errorMessage ==
      'There is no user record corresponding to this identifier. The user may have been deleted.') {
    errorMessage = 'There is no record of this user existing';
  } else if (errorMessage == 'Given String is empty or null') {
    errorMessage = 'Fill out all fields';
  } else if (errorMessage ==
      'The password is invalid or the user does not have a password.') {
    errorMessage = 'Wrong Password';
  }
  return Container(
    child: Text(
      errorMessage,
      style: kErrorTextstyle,
    ),
  );
}
