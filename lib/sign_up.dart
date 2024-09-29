import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:umbc_hack/user_data.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _workoutPlan;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _workoutGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Name, email, password fields
                _buildTextInput('Name', _nameController),
                _buildTextInput('Email', _emailController),
                _buildTextInput('Password', _passwordController,
                    obscureText: true),
                _buildTextInput('Age', _ageController,
                    keyboardType: TextInputType.number),
                _buildTextInput('Height (m)', _heightController,
                    keyboardType: TextInputType.number),
                _buildTextInput('Weight (kg)', _weightController,
                    keyboardType: TextInputType.number),

                // Workout Goal
                const Text('Workout Goal:'),
                _buildRadioButton('Lose Weight', 'Lose Weight'),
                _buildRadioButton('Maintain Weight', 'Maintain Weight'),
                _buildRadioButton('Build Muscle', 'Build Muscle'),

                // Workout Plan
                const Text('Select Workout Plan:'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWorkoutPlanCard('Push, Pull, Leg'),
                      _buildWorkoutPlanCard('Specific Muscle'),
                      _buildWorkoutPlanCard('Random Assign'),
                    ],
                  ),
                ),

                // Sign Up button
                ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for text input
  Widget _buildTextInput(String label, TextEditingController controller,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  // Helper for radio buttons
  Widget _buildRadioButton(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _workoutGoal,
      onChanged: (String? newValue) {
        setState(() {
          _workoutGoal = newValue;
        });
      },
    );
  }

  // Helper for workout plan cards
  Widget _buildWorkoutPlanCard(String plan) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _workoutPlan = plan;
        });
      },
      child: Card(
        color: _workoutPlan == plan ? Colors.blue : Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            plan,
            style: TextStyle(
              color: _workoutPlan == plan ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      double height = double.parse(_heightController.text);
      double weight = double.parse(_weightController.text);

      // Store user data in Hive
      var userBox = Hive.box<UserData>('userDataBox');
      UserData newUser = UserData(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        age: _ageController.text,
        height: height,
        weight: weight,
        workoutGoal: _workoutGoal ?? '',
        workoutPlan: _workoutPlan ?? '', // Ensure workoutPlan is selected
      );

      // Save the user data and print debug statement
      userBox.put('user', newUser);
      print('User saved to Hive: ${newUser.name}');

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
