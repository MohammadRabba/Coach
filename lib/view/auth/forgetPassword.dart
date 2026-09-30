import 'package:coatch/controller/resetPasswordController.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final ResetPasswordController controller;

  const ForgotPasswordScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final phoneNumberController =
        TextEditingController(); // Create a controller

    return Directionality(
      textDirection: TextDirection.rtl, // Important for right-to-left
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () {
              Navigator.pop(context); // Go back
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo (using the previously defined LogoPainter)
              // Center(
              //   child: Image.asset(
              //     'assets/logo3.png',
              //     height: 100,
              //   ),
              // ),
              const SizedBox(height: 20),
              const Text(
                'استرجاع كلمة السر',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'ادخل رقم هاتفك او البريد الالكتروني لاسترجاع كلمة السر الخاصة بك.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              // Lock Icon
              const Center(
                child: Icon(
                  Icons.lock_rounded,
                  size: 100,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  controller: phoneNumberController, // Assign controller
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ), // Rounded border
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () => controller.sendPasswordResetEmail(
                      phoneNumberController.text.toString(), context),
                  // onPressed: () => controller.sendVerificationCode(
                  //     phoneNumberController.text.toString(), context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        // Rounded button
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
