import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:umbc_hack/user_data.dart';
import 'package:umbc_hack/home_Page.dart';
import 'package:umbc_hack/models/push_up_model.dart';
import 'package:umbc_hack/sign_in.dart';
import 'package:umbc_hack/sign_up.dart';
import 'package:umbc_hack/views/pose_detection_view.dart';
import 'package:umbc_hack/welcome_screen.dart';
import 'package:umbc_hack/workout_video.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserDataAdapter());
  var userDataBox = await Hive.openBox<UserData>('userDataBox');
  await userDataBox.clear();
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error fetching available cameras: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PushUpCounter(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'inter',
          useMaterial3: true,
        ),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => WelcomeScreen(),
          '/signin': (context) => SignInScreen(),
          '/signup': (context) => SignUpScreen(),
          '/home': (context) => HomePage(),
          '/poseDetector': (context) => PoseDetectorView(),
          '/workout': (context) => WorkoutVideo(),
        },
      ),
    );
  }
}

class NoCameraScreen extends StatelessWidget {
  const NoCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Camera Available'),
      ),
      body: const Center(
        child: Text('This device does not have a camera available.'),
      ),
    );
  }
}
