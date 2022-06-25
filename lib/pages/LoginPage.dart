import 'dart:async';
import 'dart:developer';

import 'package:apni_yaari/models/UIHelper.dart';
import 'package:apni_yaari/models/UserModel.dart';
import 'package:apni_yaari/pages/HomePage.dart';
import 'package:apni_yaari/pages/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CompleteProfile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Logging In..");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show Alert Dialog
      UIHelper.showAlertDialog(
          context, "An error occurred", ex.message.toString());
    }
    String uid = credential!.user!.uid;
    final auth = FirebaseAuth.instance;
    User user;
    Timer timer;
    user = auth.currentUser!;
    var checkVerified = user.emailVerified;
    UserModel newUser = UserModel(uid: uid, email: email, fullname: "", profilepic: "");
    if (credential != null) {
      if(checkVerified){
        String uid = credential.user!.uid;

        DocumentSnapshot userData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
        UserModel userModel =
        UserModel.fromMap(userData.data() as Map<String, dynamic>);

        // Go to HomePage
        print("Log In Successful!");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return HomePage(
                userModel: userModel, firebaseUser: credential!.user!);
          }),
        );
      }else{
        UIHelper.showAlertDialog(
            context,
            "You are not verified !!",
            "A verification mail has been"
                "sent to ${user.email}, Please verify yourself");
        timer = Timer.periodic(Duration(seconds: 3), (timer) async {
          user = auth.currentUser!;
          await user.reload();
          log("user verification is : ${user.emailVerified}");
          if (user.emailVerified) {
            timer.cancel();
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) {
                return CompleteProfile(
                    userModel: newUser, firebaseUser: credential!.user!);
              }),
            );
          }
        });
      }
    }
  }

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Text("Chat App", style: TextStyle(
                  //   color: Theme.of(context).colorScheme.secondary,
                  //   fontSize: 45,
                  //   fontWeight: FontWeight.bold
                  // ),),
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Image(
                      image: AssetImage("images/splash_screen_image.png"),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email Address"),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            })),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: LinearGradient(
                            colors: [Colors.red,Colors.pink],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter
                        )
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.transparent,
                        onSurface: Colors.transparent,
                        shadowColor: Colors.transparent,),

                      onPressed: (){
                        checkValues();
                      },

                      child: Center(
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xffffffff),
                            letterSpacing: -0.3858822937011719,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SignUpPage();
                  }),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
