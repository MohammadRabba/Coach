import 'package:coatch/controller/loginController.dart';
import 'package:coatch/model/userModel.dart';
import 'package:coatch/view/auth/login.dart';
import 'package:coatch/view/home/MainPage.dart';
import 'package:coatch/view/profilePage.dart/updateProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Import for ChangeNotifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import for FirebaseFirestore

class SignUpController extends ChangeNotifier {
  final UserModel model = UserModel();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;
  
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("Google sign-in was canceled");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        String? name = googleUser.displayName;
        String? email = googleUser.email;
        String uid = userCredential.user!.uid;
        String? phoneNumber = userCredential.user!.phoneNumber;

        print("Name: $name");
        print("Email: $email");
        print("UID: $uid");
        print("Phone: $phoneNumber");

        _showLoadingDialog(context);

        // 🔍 Check if user already exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user') // تأكد إن اسم الكولكشن مطابق للواقع
            .doc(uid)
            .get();

        _hideLoadingDialog(context);

        if (userDoc.exists) {
          // ✅ Account exists → Navigate to Home or Main Page
          print("User already has an account.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome back, $name!')),
          );

          LoginController login = new LoginController();
          login.signInWithGoogle(context);
        } else if (!userDoc.exists) {
          // ❌ No account → Ask to complete profile
          print("New user, go to profile setup.");

          UserModel model = UserModel(
            id: uid,
            fullName: name,
            phone: phoneNumber,
            email: email,
            type: "0",
            address: 'Ramallah',
            photo: "",
          );

          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateUserProfilePage(
                userData: model,
              ),
            ),
          );
        }
      } else {
        print("Failed to sign in with Google");
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
    } catch (e) {
      print("Exception during Google sign-in: $e");
    }
  }

  Future<void> createUser(
      String name,
      String phone,
      String email,
      String password,
      DateTime date,
      String address,
      double hieght,
      double weight,
      double bmi,
      int gender,
      DateTime registrationTime,
      BuildContext context) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: model.email ?? '',
        password: model.password ?? '',
      );

      if (credential.user != null) {
        _showLoadingDialog(context);

        await _createUserProfile(name, phone, email, password, date,
            credential.user!.uid, address, hieght, weight, gender, context);
        _showLoadingDialog(context);

// استخدم Future.delayed عشان تسمح للDialog إنه يظهر قبل الـ push
        await Future.delayed(const Duration(milliseconds: 300));
        _hideLoadingDialog(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Created Successfully")),
        );
// شيل الـ _hideLoadingDialog مؤقتًا هنا
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              controller: new LoginController(),
            ),
          ),
        );

// بعد ما ترجع من UpdateUserProfilePage شيل الـDialog
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The account already exists for that email.')));
      }
    } catch (e) {
      print('Error creating user: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error creating user')));
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _createUserProfile(
      String name,
      String phone,
      String email,
      String password,
      DateTime date,
      String uid,
      String address,
      double height,
      double weight,
      int gender,
      BuildContext context) async {
    try {
      double bmi = weight / (height * height);
      await FirebaseFirestore.instance.collection('user').doc(uid).set(
        {
          'name': name, 'email': email,
          'phone': phone,
          'address': address,
          'height': height ?? 0.0,
          'weight': weight ?? 0.0,
          'bmi': bmi, 'registrationDate': DateTime.now(),
          'type': "0",
          'photo': "image", // Only add photo if uploaded
          'gender': gender, // Add gender to the data
        },
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  controller: LoginController(),
                )),
      );
      _hideLoadingDialog(context);
    } catch (e) {
      print('Error creating user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating user profile')));
    }
  }
}
