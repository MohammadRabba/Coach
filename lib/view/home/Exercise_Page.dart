import 'package:coatch/view/home/Exercis.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:coatch/ColoreApp/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  bool _isFavorite = false;
  bool _showFullDescription = false;
  bool _isModelReady = false;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // Simulate model loading
    Future.delayed(1.seconds, () {
      setState(() {
        _isModelReady = true;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarOpacity = (_scrollOffset / 100).clamp(0, 1).toDouble();
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: AnimatedOpacity(
          opacity: appBarOpacity,
          duration: 200.ms,
          child: Text(
            widget.exercise.name,
            style: GoogleFonts.orbitron(
              color: AppColors.whiteC,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteC),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 3D Model Viewer Section
            SliverToBoxAdapter(
              child: Container(
                height: deviceSize.height * 0.4,
                decoration: BoxDecoration(
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: AppColors.primary.withOpacity(0.2),
                    //     blurRadius: 20,
                    //     spreadRadius: 2,
                    //   ),
                    // ],
                    ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isModelReady)
                      ModelViewer(
                        src: widget.exercise.modelPath,
                        alt: '3D model of ${widget.exercise.name}',
                        ar: true,
                        autoRotate: true,
                        cameraControls: true,
                        backgroundColor: Colors.transparent,
                        autoPlay: true,
                        cameraOrbit: '0deg 80deg 0.2m',
                        cameraTarget: '0m 0.2m 0m',
                      ).animate().fadeIn(duration: 500.ms)
                    // .scale(begin: 0.9, end: 1.0)
                    else
                      Container(
                        color: AppColors.background,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rotate to view 3D model',
                          style: TextStyle(
                            color: AppColors.whiteC,
                            fontSize: 12,
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Exercise Title and Basic Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.exercise.name,
                              style: GoogleFonts.orbitron(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ).animate().fadeIn(delay: 100.ms),
                            const SizedBox(height: 4),
                            _buildDifficultyIndicator(
                                    widget.exercise.difficulty)
                                .animate()
                                .fadeIn(delay: 200.ms),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _InfoPill(
                            icon: Icons.repeat,
                            value: widget.exercise.rounds.toString(),
                            label: 'Rounds',
                          ).animate().slideX(
                                begin: 0.5,
                                end: 0,
                                delay: 300.ms,
                              ),
                          const SizedBox(width: 8),
                          _InfoPill(
                            icon: Icons.fitness_center,
                            value: widget.exercise.reps.toString(),
                            label: 'Reps',
                          ).animate().slideX(
                                begin: 0.5,
                                end: 0,
                                delay: 400.ms,
                              ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Muscle Group and Equipment
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    // children: [
                    //   if (widget.exercise.muscleGroup != null)
                    //     _buildTag(widget.exercise.muscleGroup!,
                    //         AppColors.primary.withOpacity(0.2)),
                    //   if (widget.exercise.equipment != null)
                    //     _buildTag(widget.exercise.equipment!,
                    //         AppColors.secondary.withOpacity(0.2)),
                    // ],
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // Exercise Description
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _showFullDescription
                                  ? widget.exercise.description
                                  : widget.exercise.description.length > 100
                                      ? '${widget.exercise.description.substring(0, 100)}...'
                                      : widget.exercise.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.whiteC.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                            if (widget.exercise.description.length > 100)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showFullDescription =
                                          !_showFullDescription;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    _showFullDescription
                                        ? 'Show Less'
                                        : 'Read More',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Instructions Section
                  if (widget.exercise.instructions.isNotEmpty) ...[
                    _buildSectionTitle('Instructions').animate().fadeIn(
                          delay: 400.ms,
                        ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: widget.exercise.instructions
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: TextStyle(
                                            color: AppColors.blackC,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: TextStyle(
                                            color: AppColors.whiteC
                                                .withOpacity(0.9),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(
                                        delay: (500 + (entry.key * 100)).ms,
                                      ),
                                ))
                            .toList(),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 24),
                  ],

                  // Tips Section
                  if (widget.exercise.tips.isNotEmpty) ...[
                    _buildSectionTitle('Pro Tips').animate().fadeIn(
                          delay: 600.ms,
                        ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: widget.exercise.tips
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: TextStyle(
                                            color: AppColors.whiteC
                                                .withOpacity(0.9),
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(
                                        delay: (700 + (entry.key * 100)).ms,
                                      ),
                                ))
                            .toList(),
                      ),
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 24),
                  ],

                  // Start Exercise Button
                  _buildStartButton(context).animate().fadeIn(delay: 800.ms),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showStartExerciseDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start Exercise',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.blackC,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward, color: AppColors.blackC),
          ],
        ),
      ),
    );
  }

  void _showStartExerciseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.garyC.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ready to Start?',
              style: GoogleFonts.orbitron(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Exercise', widget.exercise.name),
                  _buildDetailRow('Rounds', widget.exercise.rounds.toString()),
                  _buildDetailRow('Reps', widget.exercise.reps.toString()),
                  // if (widget.exercise.duration != null)
                  //   _buildDetailRow(
                  //       'Duration', '${widget.exercise.duration} mins'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Not Now',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to exercise screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Let\'s Go!',
                      style: TextStyle(
                        color: AppColors.blackC,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.whiteC.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.whiteC,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.whiteC,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyIndicator(int difficulty) {
    return Row(
      children: [
        Text(
          'Difficulty: ',
          style: TextStyle(
            color: AppColors.whiteC.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < difficulty ? Icons.star : Icons.star_border,
              color: index < difficulty ? AppColors.primary : AppColors.garyC,
              size: 18,
            );
          }),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.whiteC.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
