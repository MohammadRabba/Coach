import 'package:flutter/material.dart';

import 'package:coatch/ColoreApp/colors.dart';
import 'package:coatch/controller/loginController.dart';
import 'package:coatch/controller/signUpController.dart';
import 'package:coatch/view/auth/login.dart';

class SignupScreen extends StatefulWidget {
  final SignUpController controller;

  const SignupScreen({super.key, required this.controller});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedLocation = 'Ramallah';
  final TextEditingController hieghtController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String gender = 'Male';
  int selectedGender = 0;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  bool _isDatePickerOpen = false;
  DateTime? _selectedDate;
  ValueNotifier userCredential = ValueNotifier('');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    setState(() => _isDatePickerOpen = true);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.background,
              onSurface: AppColors.whiteC,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppColors.background),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }

    setState(() => _isDatePickerOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              // Logo with fade and slight scale animation
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/images/logo-Photoroom.jpg',
                    height: 250,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Form fields with staggered animations
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildFormFields(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Name Field
        _buildAnimatedField(
          controller: nameController,
          hintText: 'Full Name',
          index: 0,
        ),
        const SizedBox(height: 20),

        // Phone Field
        _buildAnimatedField(
          controller: phoneController,
          hintText: 'Phone Number',
          isPhone: true,
          index: 1,
        ),
        const SizedBox(height: 20),

        // Email Field
        _buildAnimatedField(
          controller: emailController,
          hintText: 'Email',
          index: 2,
        ),
        const SizedBox(height: 20),

        // Password Field
        _buildAnimatedField(
          controller: passwordController,
          hintText: 'Password',
          isPassword: true,
          index: 3,
        ),
        const SizedBox(height: 20),

        // Confirm Password Field
        _buildAnimatedField(
          controller: confirmPasswordController,
          hintText: 'Confirm password',
          isPassword: true,
          index: 4,
        ),
        DropdownButton<String>(
          value: gender,
          onChanged: (String? newValue) {
            setState(() {
              if (newValue == 'Male') {
                selectedGender = 0;
              } else {
                selectedGender = 1;
              }
            });
          },
          items: <String>[
            'Male',
            'Female',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        _buildAnimatedField(
          controller: hieghtController,
          hintText: 'Hieght',
          isNumber: true,
          index: 5,
        ),
        const SizedBox(height: 20),
        _buildAnimatedField(
          controller: weightController,
          hintText: 'Weight',
          isNumber: true,
          index: 6,
        ),
        const SizedBox(height: 20),
        DropdownButton<String>(
          value: selectedLocation,
          onChanged: (String? newValue) {
            setState(() {
              selectedLocation = newValue!;
            });
          },
          items: <String>[
            'Ramallah',
            'Jenin',
            'Nablus',
            'Tolkarem',
            'BethLahem',
            'Toubas',
            'Hebron',
            'From Home(Remotly)',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Date of Birth Field with custom animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildDateField(),
        ),
        const SizedBox(height: 20),

        // Signup Button with scale animation
        ScaleTransition(
          scale: CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
          ),
          child: _buildSignupButton(),
        ),
        const SizedBox(height: 20),

        // OR Divider
        _buildOrDivider(),
        const SizedBox(height: 10),

        // Google Signup
        _buildGoogleSignup(),
        const SizedBox(height: 20),

        // Login Prompt
        _buildLoginPrompt(),
      ],
    );
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required String hintText,
    required int index,
    bool isPassword = false,
    bool isNumber = false,
    bool isPhone = false,
  }) {
    final delay = 0.1 * index;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, 1.0, curve: Curves.easeIn),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: AppColors.primary,
              selectionColor: Color.fromARGB(153, 255, 208, 0),
              selectionHandleColor: AppColors.primary,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: isPhone
                ? TextInputType.phone
                : isNumber
                    ? TextInputType.number
                    : TextInputType.text,
            style: const TextStyle(fontFamily: "FFS", color: AppColors.whiteC),
            decoration: InputDecoration(
              prefixText: isPhone ? '+972 ' : null,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.white50,
                fontSize: 13,
                fontFamily: "FFS",
                fontWeight: FontWeight.w100,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.primary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: isPhone ? AppColors.garyC : AppColors.primary,
                  width: isPhone ? 1.2 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.9,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        labelStyle: TextStyle(color: Colors.white), // Label color
        hintText: _selectedDate == null
            ? 'Select your date of birth'
            : "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
        hintStyle: TextStyle(color: Colors.white70), // Hint text color
        suffixIcon:
            const Icon(Icons.calendar_today, color: Colors.white), // Icon color
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white54), // Border color when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white), // Border color when focused
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red), // Border color when error
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.red), // Border color when focused with error
        ),
        fillColor: Colors.white.withOpacity(0.1), // Background color
        filled: true, // Required for fillColor to work
      ),
      style: TextStyle(color: Colors.white), // Text color
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (_selectedDate == null) {
          return 'Please select your date of birth';
        }
        return null;
      },
      cursorColor: Colors.white, // Cursor color
    );
  }

  Widget _buildSignupButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(_isDatePickerOpen ? 0.95 : 1.0),
      child: ElevatedButton(
        onPressed: () {
          // Button press animation
          // _animationController.reset();
          // _animationController.forward();

          widget.controller.model.email = emailController.text;
          widget.controller.model.fullName = nameController.text;
          widget.controller.model.phone = phoneController.text;
          widget.controller.model.password = passwordController.text;
          widget.controller.model.height =
              double.parse(hieghtController.text) ?? 0.0;
          widget.controller.model.weight =
              double.parse(weightController.text) ?? 0.0;

          double? bmi;
          double height = double.parse(hieghtController.text);
          double weight = double.parse(weightController.text);
          bmi = weight / (height * height);
          // widget.controller.signUpWithPhoneNumber(
          //     nameController.text, phoneController.text, context);
          widget.controller.createUser(
              widget.controller.model.fullName ?? '',
              widget.controller.model.phone ?? '',
              widget.controller.model.email ?? '',
              widget.controller.model.password ?? '',
              _selectedDate ?? DateTime.now(),
              selectedLocation,
              widget.controller.model.height ?? 0.0,
              widget.controller.model.weight ?? 0.0,
              bmi,
              selectedGender,
              DateTime.now(),
              context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 50),
        ),
        child: const Text(
          'Signup',
          style: TextStyle(
            color: AppColors.background,
            fontFamily: "FFS",
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.white50)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'OR',
              style: TextStyle(
                color: AppColors.white50,
                fontFamily: 'FFS',
                fontSize: 14,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.white50)),
        ],
      ),
    );
  }

  Widget _buildGoogleSignup() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          await widget.controller.signInWithGoogle(context);
          // Navigator.push(
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, animation, secondaryAnimation) =>
          //         LoginScreen(controller: LoginController()),
          //     transitionsBuilder:
          //         (context, animation, secondaryAnimation, child) {
          //       var fadeTransition =
          //           Tween(begin: 0.0, end: 1.0).animate(animation);
          //       return FadeTransition(opacity: fadeTransition, child: child);
          //     },
          //   ),
          // );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white50.withOpacity(0.3)),
          ),
          child: Image.asset(
            'assets/images/google-icon.png',
            height: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LoginScreen(controller: LoginController())),
          );
        },
        child: const Text.rich(
          TextSpan(
            text: 'You have an account?',
            style: TextStyle(
              color: AppColors.white50,
              fontFamily: "FFS",
              fontSize: 13,
            ),
            children: [
              TextSpan(
                text: '  Login now',
                style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: "FFS",
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
