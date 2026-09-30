import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coatch/ColoreApp/colors.dart';
import 'package:coatch/controller/loginController.dart';
import 'package:coatch/model/userModel.dart';
import 'package:coatch/view/auth/login.dart';
import 'package:coatch/view/home/home.dart';
import 'package:coatch/view/profilePage.dart/profilePage.dart';
import 'package:flutter/material.dart';

class UpdateUserProfilePage extends StatefulWidget {
  final UserModel userData;
  const UpdateUserProfilePage({super.key, required this.userData});

  @override
  State<UpdateUserProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateUserProfilePage> {
  late TextEditingController _nameController;
  String selectedLocation = 'Ramallah';
  int selectedGender = 0;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.fullName);
    selectedLocation = widget.userData.address ?? 'Ramallah';
    selectedGender = widget.userData.gender ?? 0;
    _heightController = TextEditingController(
      text: widget.userData.height == 0.0
          ? ''
          : widget.userData.height.toString(),
    );
    _weightController = TextEditingController(
      text: widget.userData.weight == 0.0
          ? ''
          : widget.userData.weight.toString(),
    );
    _phoneController = TextEditingController(text: widget.userData.phone);
  }

  Future<void> saveChanges() async {
    setState(() => _isLoading = true);

    try {
      double? bmi;
      try {
        double height = double.parse(_heightController.text);
        double weight = double.parse(_weightController.text);
        bmi = weight / (height * height);
      } catch (e) {
        bmi = 0.0;
      }

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userData.id)
          .update({
        'name': _nameController.text,
        'email': widget.userData.email,
        'phone': _phoneController.text,
        'address': selectedLocation,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'bmi': bmi,
        'gender': selectedGender,
      });

      widget.userData.fullName = _nameController.text;
      widget.userData.phone = _phoneController.text;
      widget.userData.address = selectedLocation;
      widget.userData.height = double.tryParse(_heightController.text) ?? 0.0;
      widget.userData.weight = double.tryParse(_weightController.text) ?? 0.0;
      widget.userData.bmi = bmi;
      widget.userData.gender = selectedGender;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserHomePage(
            userModel: widget.userData,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.whiteC),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserHomePage(userModel: widget.userData),
              ),
            );
          },
        ),
        title: Text(
          'Update Profile',
          style: TextStyle(
            color: AppColors.whiteC,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileForm(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileForm() {
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
            _buildProfileField(
              icon: Icons.person,
              label: "Full Name",
              controller: _nameController,
            ),
            const Divider(height: 30, color: Colors.white24),
            _buildProfileField(
              icon: Icons.phone,
              label: "Phone",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const Divider(height: 30, color: Colors.white24),
            _buildProfileField(
              icon: Icons.height,
              label: "Height (cm)",
              controller: _heightController,
              keyboardType: TextInputType.number,
            ),
            const Divider(height: 30, color: Colors.white24),
            _buildProfileField(
              icon: Icons.monitor_weight,
              label: "Weight (kg)",
              controller: _weightController,
              keyboardType: TextInputType.number,
            ),
            const Divider(height: 30, color: Colors.white24),
            _buildDropdownField(
              icon: Icons.location_on,
              label: "Location",
              value: selectedLocation,
              items: [
                'Ramallah',
                'Jenin',
                'Nablus',
                'Tolkarem',
                'BethLahem',
                'Toubas',
                'Hebron',
                'From Home(Remotly)',
              ],
              onChanged: (value) => setState(() => selectedLocation = value!),
            ),
            const Divider(height: 30, color: Colors.white24),
            _buildDropdownField(
              icon: Icons.transgender,
              label: "Gender",
              value: selectedGender == 0 ? 'Male' : 'Female',
              items: ['Male', 'Female'],
              onChanged: (value) => setState(() {
                selectedGender = value == 'Male' ? 0 : 1;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(color: AppColors.whiteC),
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: AppColors.primary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            dropdownColor: const Color.fromARGB(255, 48, 46, 46),
            style: TextStyle(color: AppColors.whiteC),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: AppColors.primary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: saveChanges,
        child: const Text(
          'Save Changes',
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
