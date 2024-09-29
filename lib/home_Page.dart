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
  SpeechRecognitionService _speechRecognitionService =
      SpeechRecognitionService();

  Box<UserData>? userBox;
  UserData? userData;

  bool isNavigating = false;

  // Sample Data
  int workoutsCompleted = 3;
  int totalWorkouts = 5;
  int caloriesBurnt = 500;
  int caloriesEaten = 450;

  double totalProtein = 20.0;
  double totalCarbs = 150.0;
  double totalFat = 80.0;

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

  void _onVoiceCommandDetected(String command) {
    print('hehe,${command}');
    if (command.contains("workout") ||
        command.contains("Work-out") ||
        command.contains("work-out") ||
        command.contains("work") ||
        command.contains("work out")) {
      isNavigating = true;

      Navigator.pushNamed(context, '/poseDetector').then((_) {
        isNavigating = false;
      });
    } else if (command.contains("track")) {
      print('hehe123,${command}');
      isNavigating = true;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CalorieTracker(
                  onNutrientsExtracted:
                      (double protein, double carbs, double fat) {
                    updateNutrientIntake(protein, carbs, fat);
                  },
                )),
      ).then((_) {
        isNavigating = false;
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
              const SizedBox(
                height: 20,
              ),
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
              child: _buildCaloriesCard('Calories Out', caloriesBurnt),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildWorkoutsCompleted(),
      ],
    );
  }

  Widget _buildWorkoutsCompleted() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/workout');
      },
      child: Container(
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
    return Card(
      color:
          isCompleted ? const Color.fromARGB(255, 165, 148, 210) : Colors.white,
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (bool? newValue) {
            setState(() {
              isCompleted = newValue ?? false;
            });
          },
        ),
        title: Text(workoutName),
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
