import 'dart:async';
import 'dart:math' as math;
import 'package:coatch/ColoreApp/colors.dart';
import 'package:coatch/controller/loginController.dart';
import 'package:coatch/model/userModel.dart';
import 'package:coatch/view/auth/login.dart';
import 'package:coatch/view/chat/chatListPage.dart';
import 'package:coatch/view/home/Exercis.dart';
import 'package:coatch/view/home/Exercise_Page.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  final UserModel userModel;
  MainPage({super.key, required this.userModel});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isLoading = true;
  int _currentIndex = 0;
  Timer? _loadingTimer; // Add a Timer variable

  List<Exercise> allExercises = [
    Exercise(
      name: 'Stomach Crunch',
      description: 'A basic stomach crunch to strengthen abdominal muscles.',
      rounds: 3,
      reps: 15,
      modelPath: 'assets/models/1stomach.glb',
      difficulty: 2,
      muscleGroup: 'Stomach',
      instructions: [
        'Lie on your back',
        'Lift your shoulders without pulling your neck'
      ],
      tips: ['Exhale on the way up', 'Keep movements controlled'],
    ),
    Exercise(
      name: 'Stomach Bicycle',
      description: 'A bicycle crunch exercise for obliques and abs.',
      rounds: 3,
      reps: 20,
      modelPath: 'assets/models/2stomachBic.glb',
      difficulty: 3,
      muscleGroup: 'Stomach',
      instructions: ['Bring opposite elbow to knee', 'Keep your core engaged'],
      tips: ['Don’t rush', 'Focus on rotation'],
    ),
    Exercise(
      name: 'Stomach Rotation',
      description: 'Rotational core exercise to engage obliques.',
      rounds: 3,
      reps: 20,
      modelPath: 'assets/models/3stomachRot.glb',
      difficulty: 2,
      muscleGroup: 'Stomach',
      instructions: ['Twist your torso left and right', 'Keep your core tight'],
      tips: ['Use full range of motion', 'Keep breathing steady'],
    ),
    Exercise(
      name: 'Push Up',
      description: 'A push-up exercise to strengthen chest and arm muscles.',
      rounds: 3,
      reps: 12,
      modelPath: 'assets/models/4push-up.glb',
      difficulty: 2,
      muscleGroup: 'Chest',
      instructions: ['Keep your back straight', 'Lower your body slowly'],
      tips: ['Warm up before starting', 'Breathe regularly'],
    ),
    Exercise(
      name: 'Squat',
      description: 'A squat exercise to strengthen thigh and glute muscles.',
      rounds: 4,
      reps: 15,
      modelPath: 'assets/models/5Squats.glb',
      difficulty: 3,
      muscleGroup: 'Legs',
      instructions: ['Keep knees behind toes', 'Go as low as comfortable'],
      tips: ['Use a chair if balance is difficult', 'Keep your core tight'],
    ),
    Exercise(
      name: 'Circular Run',
      description: 'Run in small circles to improve agility and endurance.',
      rounds: 2,
      reps: 60, // seconds
      modelPath: 'assets/models/6circular-run.glb',
      difficulty: 1,
      muscleGroup: 'Cardio',
      instructions: [
        'Run in place in a circular motion',
        'Keep light on your feet'
      ],
      tips: ['Stay on toes', 'Maintain balance'],
    ),
    Exercise(
      name: 'Feet Stretch',
      description: 'Foot mobility and flexibility exercise.',
      rounds: 2,
      reps: 10,
      modelPath: 'assets/models/7Feet.glb',
      difficulty: 1,
      muscleGroup: 'Feet',
      instructions: ['Rotate your ankles', 'Stretch toes outward'],
      tips: ['Do both feet', 'Hold stretch for a few seconds'],
    ),
    Exercise(
      name: 'Pike Walk',
      description: 'Full body mobility and stretch movement.',
      rounds: 2,
      reps: 10,
      modelPath: 'assets/models/8Pike-Walk.glb',
      difficulty: 2,
      muscleGroup: 'Full Body',
      instructions: [
        'Bend at the waist',
        'Walk hands forward to plank position'
      ],
      tips: ['Keep legs as straight as possible', 'Engage core throughout'],
    ),
    Exercise(
      name: 'Jumping Jacks',
      description:
          'Cardio exercise to increase heart rate and warm up the body.',
      rounds: 3,
      reps: 30,
      modelPath: 'assets/models/9Jumping-Jacks.glb',
      difficulty: 1,
      muscleGroup: 'Cardio',
      instructions: [
        'Jump feet apart while raising arms overhead',
        'Return to start position'
      ],
      tips: ['Maintain rhythm', 'Breathe continuously'],
    ),
    Exercise(
      name: 'Jump Push-Up',
      description: 'Advanced explosive push-up exercise.',
      rounds: 3,
      reps: 10,
      modelPath: 'assets/models/10Jump-Push-Upglb.glb',
      difficulty: 4,
      muscleGroup: 'Chest',
      instructions: [
        'Push up explosively from the floor',
        'Clap or lift hands briefly'
      ],
      tips: ['Control your landing', 'Keep core tight'],
    ),
    Exercise(
      name: 'Burpees',
      description: 'Full-body movement combining squats, push-ups, and jumps.',
      rounds: 3,
      reps: 15,
      modelPath: 'assets/models/11Burpees1.glb',
      difficulty: 4,
      muscleGroup: 'Full Body',
      instructions: ['Squat down, kick legs back, push-up, jump up'],
      tips: ['Pace yourself', 'Focus on smooth transitions'],
    ),
    Exercise(
      name: 'Box Jump',
      description: 'Explosive leg exercise using a box or platform.',
      rounds: 3,
      reps: 12,
      modelPath: 'assets/models/12BOX-JUMP.glb',
      difficulty: 3,
      muscleGroup: 'Legs',
      instructions: ['Stand in front of box', 'Jump onto box and land softly'],
      tips: ['Use arms for momentum', 'Step down carefully'],
    ),
  ];

  List<Exercise> filteredExercises = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _simulateLoading();
    filteredExercises = allExercises;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _loadingTimer?.cancel(); // Cancel the timer in dispose()

    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredExercises = allExercises.where((ex) {
        return ex.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      // Navigation logic based on the bottom navigation bar index
      if (index == 0) {
        // Navigate to Chat Page (replace with your actual ChatPage)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Text('Chat Page')),
        );
      } else if (index == 1) {
        // Stay on the current Home/Exercise list page
        // No navigation needed here as this is the current page
      } else if (index == 2) {
        // Navigate to Profile Page (replace with your actual ProfilePage)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Text('Profile Page')),
        );
      }
    });
  }

  Future<void> _simulateLoading() async {
    _loadingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildExerciseCard(Exercise ex) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailPage(exercise: ex),
          ),
        );
      },
      child: Card(
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ex.name,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ex.description,
                style: TextStyle(color: AppColors.garyC, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _infoChip('Rounds: ${ex.rounds}'),
                  const SizedBox(width: 2),
                  _infoChip('Reps: ${ex.reps}'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ModelViewer(
                    src: ex.modelPath,
                    alt: '3D model for ${ex.name}',
                    ar: true,
                    autoRotate: false,
                    cameraControls: true,
                    backgroundColor: Colors.transparent,
                    autoPlay: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.orbitronTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: AppColors.primary),
        ),
      ),
      home: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      style: TextStyle(color: AppColors.primary),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.search, color: AppColors.primary),
                        hintText: 'Search Exercises',
                        hintStyle: TextStyle(
                            color: AppColors.primary.withOpacity(0.5)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredExercises.isEmpty
                          ? Center(
                              child: Text(
                                'No exercises found.',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: filteredExercises.length,
                              itemBuilder: (context, index) {
                                return _buildExerciseCard(
                                    filteredExercises[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
