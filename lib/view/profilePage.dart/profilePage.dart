import 'package:coatch/ColoreApp/colors.dart';
import 'package:coatch/model/userModel.dart';
import 'package:coatch/view/home/home.dart';
import 'package:coatch/view/profilePage.dart/updateProfile.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  final UserModel model;
  const UserProfile({super.key, required this.model});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildProfileCard(),
            const SizedBox(height: 30),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
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
        const SizedBox(height: 16),
        Text(
          widget.model.fullName ?? 'No Name',
          style: const TextStyle(
            fontSize: 24,
            color: AppColors.whiteC,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.model.email ?? 'No Email',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.whiteC,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: const Color.fromARGB(255, 48, 46, 46),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileItem(
              icon: Icons.phone,
              label: "Phone",
              value: widget.model.phone ?? 'Not provided',
            ),
            const Divider(height: 30),
            _buildProfileItem(
              icon: Icons.height,
              label: "Height",
              value: "${widget.model.height ?? 0.0} cm",
            ),
            const Divider(height: 30),
            _buildProfileItem(
              icon: Icons.monitor_weight,
              label: "Weight",
              value: "${widget.model.weight ?? 0.0} kg",
            ),
            const Divider(height: 30),
            _buildProfileItem(
              icon: widget.model.gender == 0 ? Icons.male : Icons.female,
              label: "Gender",
              value: widget.model.gender == 0 ? 'Male' : 'Female',
            ),
            const Divider(height: 30),
            _buildProfileItem(
              icon: Icons.monitor_heart,
              label: "BMI",
              value: widget.model.bmi?.toStringAsFixed(1) ?? '0.0',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.whiteC,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => UpdateUserProfilePage(
                userData: widget.model,
              ),
            ),
          );
        },
        child: const Text(
          'Update Profile',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.background,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
