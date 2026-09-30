import 'package:coatch/controller/loginController.dart';
import 'package:coatch/model/userModel.dart';
import 'package:coatch/view/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  final UserModel userModel;
  const MainPage({super.key, required this.userModel});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _modelSource = ''; // Initialize as empty
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModelInBackground();
  }

  Future<void> _loadModelInBackground() async {
    // Simulate loading a model from a network or doing some heavy processing
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _modelSource = 'assets/pushup.glb'; // Update the model source
      _isLoading = false; // Loading is complete
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.orbitronTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.cyanAccent),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cyberpunk 3D'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    controller: LoginController(),
                  ),
                ),
              );
            },
          ),
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                )
              : Container(
                  height: 400,
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ModelViewer(
                    src: _modelSource,
                    alt: "A 3D model of a ramen shop",
                    ar: true,
                    autoRotate: true,
                    cameraControls: true,
                    backgroundColor: Colors.transparent,
                  ),
                ),
        ),
      ),
    );
  }
}
