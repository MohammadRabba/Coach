import 'package:coatch/ColoreApp/colors.dart';
import 'package:coatch/controller/loginController.dart';
import 'package:coatch/view/auth/login.dart';
import 'package:coatch/view/home/home.dart';
import 'package:coatch/view/profilePage.dart/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:coatch/model/userModel.dart'; // Import UserModel

class AppDrawer extends StatelessWidget {
  final UserModel model; // Add UserModel dependency

  const AppDrawer({super.key, required this.model}); // Make model required

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background, // Use AppColors for background

      child: ListView(
        children: [
          SizedBox(
            height: 250,
            // child: DrawerHeader(
            //   decoration: const BoxDecoration(
            //     color: Colors.indigo,
            //   ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.background,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  model.fullName ?? "Guest User", // Use displayName from model
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.primary),
            title: const Text("Home Page",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.whiteC)),
            onTap: () {
              Navigator.pop(context);
              // You might want to navigate to the actual home page here
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.primary),
            title: const Text("Log Out",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.whiteC)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    controller: new LoginController(),
                  ), // Replace LoginScreen with appropriate screen
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
