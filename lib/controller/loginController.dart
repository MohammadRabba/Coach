import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coatch/view/home/MainPage.dart';
import 'package:coatch/view/home/home.dart';
import 'package:coatch/view/profilePage.dart/updateProfile.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coatch/model/userModel.dart';

// notification note = notification();
List<Map<String, dynamic>> notifications = [];

class LoginController extends ChangeNotifier {
  final UserModel model = UserModel();

  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await fetchUserData(user.uid, context);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                UserHomePage(
              userModel: model,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Fade transition
              var fadeTransition =
                  Tween(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(opacity: fadeTransition, child: child);
            },
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchUserData(String userId, BuildContext context) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.data() as Map<String, dynamic>;
        model.fullName = userData['name'] as String?;
        model.phone = userData['phone'] as String?;
        model.email = userData['email'] as String?;
        model.address = userData['address'] as String?;
        model.type = userData['type'] as String? ?? '0';
        model..height = userData['height'] as double? ?? 0.0;
        if (userData['weight'] is int) {
          model..weight = (userData['weight'] as int?)?.toDouble() ?? 0.0;
        } else {
          model..weight = userData['weight'] as double? ?? 0.0;
        }
        model..gender = userData['gender'] as int? ?? 0;
        if (userData['registrationDate'] is Timestamp) {
          model.registrationDate =
              (userData['registrationDate'] as Timestamp?)?.toDate();
        } else {
          model.registrationDate = userData['registrationDate'] as DateTime?;
        }
        model.bmi = userData['bmi'] as double?;
        // mytoken = userSnapshot['token'];

        model.id = userId;

        // if (myid != '') {
        //   await note.getNotificationsCounter(myid);
        // }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You don't have an account")),
        );
        return;
      }

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? firebaseUser = userCredential.user;

        // Check if the user exists in Firebase Firestore
        if (firebaseUser != null) {
          // Check if the user document exists in Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('user')
              .doc(firebaseUser.uid)
              .get();
          await fetchUserData(firebaseUser.uid, context);

          notifyListeners();
          if (!userDoc.exists) {
            // User does not exist, create new user data
            model.fullName = googleUser.displayName;
            model.email = googleUser.email;
            model.id = firebaseUser.uid;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateUserProfilePage(
                  userData: model,
                ),
              ),
            );
            print("User created in Firestore.");
          } else if (userDoc.exists) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    UserHomePage(
                  userModel: model,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  // Fade transition
                  var fadeTransition =
                      Tween(begin: 0.0, end: 1.0).animate(animation);
                  return FadeTransition(opacity: fadeTransition, child: child);
                },
              ),
            );
          } else {
            print("User already exists in Firestore.");
          }

          // Optionally, you can fetch the user data here if needed
          // fetchUserData(firebaseUser.uid, context);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }

  Future<void> createGoogleProfile(String name, String phone, String email,
      String password, DateTime date, String uid, BuildContext context) async {
    try {
      await FirebaseFirestore.instance // Corrected typo here
          .collection('user')
          .doc(uid) // Use the UID as the document ID
          .set({
        'name': name,
        'phone': phone,
        'email': email, 'photo': '',
        'date': date.toIso8601String(), // Store as ISO 8601 String(),
        'type': "0", 'address': '', 'gender': 0, 'height': 0.0, 'weight': 0.0,
        'bmi': 0.0, 'registrationDate': DateTime.now(),
      });
      UserModel googleModel =
          UserModel(fullName: name, email: email, id: uid, phone: phone);
    } catch (e) {
      print('Error creating user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating user profile')));
    }
  }

  void saveUserDataToPrefs(String email, String password, bool check) async {
    if (check == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);
      prefs.setString('password', password);
    }
  }
}
