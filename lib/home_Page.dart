import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:umbc_hack/calorie-tracker.dart';
import 'package:umbc_hack/speech_recognition_service.dart';
import 'package:umbc_hack/user_data.dart';
import 'package:intl/intl.dart'; // For formatting dates

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechRecognitionService _speechRecognitionService =
      SpeechRecognitionService();
  Box<UserData>? userBox;
  UserData? userData;
  bool isNavigating = false; // Flag to prevent multiple triggers
  bool isCalorieTrackerOpen = false; // Track if Calorie Tracker is open

  // Sample Data
  int workoutsCompleted = 3;
  int totalWorkouts = 5;
  int caloriesBurnt = 500;
  int caloriesEaten = 450;

  double totalProtein = 20.0;
  double totalCarbs = 150.0;
  double totalFat = 80.0;

  Map<String, bool> workoutCompletion = {
    'Shoulder Press': true,
    'Bicep Curls': true,
    'Push Ups': true,
    'Leg Squats': false,
    'Tricep Dips': false,
  };

  Map<String, int> caloriesPerWorkout = {
    'Shoulder Press': 50,
    'Bicep Curls': 40,
    'Push Ups': 30,
    'Leg Squats': 60,
    'Tricep Dips': 35,
  };

  @override
  void initState() {
    super.initState();

    // Retrieve user data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        userBox = await Hive.openBox<UserData>('userDataBox');
        print("userBox ${userBox?.get('user')}");
        setState(() {
          userData = userBox?.get('user');
        });
      } catch (e) {
        print("Error accessing Hive: $e");
      }
    });

    _speechRecognitionService.initialize();
  }

  @override
  void dispose() {
    _speechRecognitionService.stopListening();
    super.dispose();
  }

  int _calculateTotalCaloriesBurnt() {
    int totalCalories = 0;
    workoutCompletion.forEach((workout, completed) {
      if (completed) {
        totalCalories += caloriesPerWorkout[workout] ?? 0;
      }
    });
    return totalCalories;
  }

  void _onWorkoutCompletionChanged(String workout, bool? isCompleted) {
    setState(() {
      workoutCompletion[workout] = isCompleted ?? false;
      workoutsCompleted = workoutCompletion.values.where((done) => done).length;
      caloriesBurnt =
          _calculateTotalCaloriesBurnt(); // Recalculate calories burnt
    });
  }

  void _onVoiceCommandDetected(String command) {
    if (!isNavigating) {
      if (command.contains("workout") ||
          command.contains("work-out") ||
          command.contains("work out")) {
        _navigateToPoseDetector();
      } else if (command.contains("track")) {
        _navigateToCalorieTracker();
      }
    }
  }

  void _navigateToPoseDetector() {
    setState(() {
      isNavigating = true;
    });
    Navigator.pushNamed(context, '/poseDetector').then((_) {
      setState(() {
        isNavigating = false;
      });
    });
  }

  void _navigateToCalorieTracker() {
    if (!isCalorieTrackerOpen) {
      setState(() {
        isCalorieTrackerOpen = true;
        isNavigating = true;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalorieTracker(
            onNutrientsExtracted: (double protein, double carbs, double fat) {
              updateNutrientIntake(protein, carbs, fat);
            },
          ),
        ),
      ).then((_) {
        setState(() {
          isCalorieTrackerOpen = false;
          isNavigating = false;
        });
      });
    }
  }

  void updateNutrientIntake(double protein, double carbs, double fat) {
    setState(() {
      totalProtein += protein;
      totalCarbs += carbs;
      totalFat += fat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Buddy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingSection(),
              const SizedBox(height: 20),
              _buildTopSection(),
              const SizedBox(height: 20),
              _buildHorizontalCalendar(),
              const SizedBox(height: 20),
              _buildTodaysWorkout(),
              const SizedBox(height: 20),
              _buildNutrientTrackingCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _speechRecognitionService.listenForCommands(_onVoiceCommandDetected);
        },
        child: const Icon(Icons.mic),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Text(
      'Hello, ${userData?.name ?? 'User'}',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTopSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCaloriesCard('Calories In', caloriesEaten),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCaloriesCard('Calories Out',
                  caloriesBurnt), // Updated to show dynamic calories burnt
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildWorkoutsCompleted(),
      ],
    );
  }

  Widget _buildWorkoutsCompleted() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 165, 148, 210),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '💪 Workouts Done',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$workoutsCompleted/$totalWorkouts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 217, 176, 99),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$value kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    final List<DateTime> weekDates = _getWeekDates();

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          bool isCompleted = index < 3;
          return _buildDateCard(date, isCompleted);
        },
      ),
    );
  }

  Widget _buildDateCard(DateTime date, bool isCompleted) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color.fromARGB(255, 233, 193, 132)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('E').format(date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('d').format(date),
            style: const TextStyle(fontSize: 16),
          ),
          if (isCompleted) const Icon(Icons.whatshot, color: Colors.red),
        ],
      ),
    );
  }

  List<DateTime> _getWeekDates() {
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  Widget _buildTodaysWorkout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Workout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildWorkoutCard('Shoulder Press', true),
        _buildWorkoutCard('Bicep Curls', true),
        _buildWorkoutCard('Push Ups', true),
        _buildWorkoutCard('Leg Squats', false),
        _buildWorkoutCard('Tricep Dips', false),
      ],
    );
  }

  Widget _buildWorkoutCard(String workoutName, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color.fromARGB(
                255, 165, 148, 210) // Background color for completed workouts
            : const Color.fromARGB(
                255, 240, 240, 240), // Background color for incomplete workouts
        borderRadius:
            BorderRadius.circular(12), // Rounded corners for a smooth look
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // Shadow effect
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: workoutCompletion[workoutName],
          onChanged: (bool? newValue) {
            _onWorkoutCompletionChanged(
                workoutName, newValue); // Update completion state
          },
        ),
        title: Text(
          workoutName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isCompleted
                ? Colors.white
                : Colors.black, // Change text color based on state
          ),
        ),
      ),
    );
  }

  // New widget to display nutrient tracking
  Widget _buildNutrientTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrient Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Protein: ${totalProtein.toStringAsFixed(1)} g',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Carbs: ${totalCarbs.toStringAsFixed(1)} g',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Fat: ${totalFat.toStringAsFixed(1)} g',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
