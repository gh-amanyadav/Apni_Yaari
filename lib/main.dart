import 'package:apni_yaari/models/FirebaseHelper.dart';
import 'package:apni_yaari/models/UserModel.dart';
import 'package:apni_yaari/pages/CompleteProfile.dart';
import 'package:apni_yaari/pages/HomePage.dart';
import 'package:apni_yaari/pages/LoginPage.dart';
import 'package:apni_yaari/pages/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null) {
    // Logged In
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel != null) {
      if(currentUser.emailVerified && (thisUserModel.fullname != "" || thisUserModel.profilepic != "")){
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser, checkUserProfile: true,));
      }else if (currentUser.emailVerified == false){
        Fluttertoast.showToast(msg: "you are not verified while previous sign in.");
        runApp(const LoginPage());
      }else if(thisUserModel.fullname == "" || thisUserModel.profilepic == ""){
        Fluttertoast.showToast(msg: "You have not Completed your profile");
        runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser, checkUserProfile: false,));
      }
    }
    else {
      runApp(const MyApp());
    }
  }
  else {
    // Not logged in
    runApp(const MyApp());
  }
}


// Not Logged In
class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
        secondary:  Colors.pink,
      )),
      home: const LoginPage(),
    );
  }
}


// Already Logged In
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  final bool checkUserProfile;
  const MyAppLoggedIn({Key? key, required this.userModel, required this.firebaseUser, required this.checkUserProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
        secondary:  Colors.pink,
      ),),
      home: checkUserProfile ? HomePage(userModel: userModel, firebaseUser: firebaseUser) :
      CompleteProfile(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}