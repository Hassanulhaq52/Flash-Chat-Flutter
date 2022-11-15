import 'package:flash_chat/constants.dart';
import 'package:flash_chat/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool showSpinner = false;
  String errorMsg;
  bool isVisible = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  child: Image.asset('images/logo.png'),
                  height: 200.0,
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardAppearance: Brightness.dark,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter Your Email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardAppearance: Brightness.dark,
                textAlign: TextAlign.center,
                obscureText: isVisible,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          if (isVisible == true) {
                            isVisible = false;
                          } else if (isVisible == false) {
                            isVisible = true;
                          }
                        });
                      },
                      icon: isVisible
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                    ),
                    hintText: 'Enter Your Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Register',
                color: Colors.blueAccent,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    print('==========> email : $email');
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);

                    if (newUser != null) {
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } on FirebaseAuthException catch (e) {
                    await Future.delayed(Duration(seconds: 1));
                    setState(() {
                      showSpinner = false;
                    });
                    switch (e.code) {
                      case 'weak-password':
                        errorMsg = 'weak password';
                        break;
                      case 'email-already-in-use':
                        errorMsg = 'The account already exists for that email.';
                        break;
                      case 'invalid-email':
                        errorMsg = 'Invalid Email';
                        break;
                      case 'too-many-requests':
                        errorMsg = "too many requests";
                        break;

                      default:
                        errorMsg = "Please check your internet connection";
                    }
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(errorMsg),
                    ));

                    print(e);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
