import 'package:coatch/model/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordController extends ChangeNotifier {
  final UserModel model = UserModel();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';
  int? resendToken;

  Future<void> sendVerificationCode(String phone, BuildContext context) async {
    if (!isValidPhoneNumber(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number")),
      );
      return;
    }

    try {
      showLoading(context);

      await _auth.verifyPhoneNumber(
        phoneNumber: '+970$phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          hideLoading(context);
          Navigator.pop(context); // Example: Navigate after auto-verification
        },
        verificationFailed: (FirebaseAuthException e) {
          hideLoading(context);
          print('Verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification Failed: ${e.message}')),
          );
        },
        codeSent: (String id, int? token) {
          verificationId = id;
          resendToken = token;
          hideLoading(context);
          Navigator.pushNamed(context, '/otp', arguments: phone);
        },
        codeAutoRetrievalTimeout: (String id) {
          verificationId = id;
          print('Auto-retrieval timeout: $id');
        },
        forceResendingToken: resendToken,
      );
    } catch (e) {
      hideLoading(context);
      print('Error sending verification code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending verification code")),
      );
    }
  }

  Future<void> sendPasswordResetEmail(
      String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password Reset, Check Your Email")),
      );
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An Error Occure")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You don't have an account")),
      );
    }
  }

  // Future<void> verifyPhoneNumber(String smsCode, BuildContext context) async {
  //   try {
  //     showLoading(context);
  //     final PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: smsCode,
  //     );

  //     await _auth.signInWithCredential(credential);
  //     hideLoading(context);

  //     Navigator.pushNamed(context, '/home');
  //   } catch (e) {
  //     hideLoading(context);
  //     print('Error verifying phone number: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Invalid Code or Verification Failed")),
  //     );
  //   }
  // }

  bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^[0-9]{9}$'); // Adjust for your region
    return regex.hasMatch(phone);
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
