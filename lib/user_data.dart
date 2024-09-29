import 'package:hive/hive.dart';

part 'user_data.g.dart'; // Run flutter packages pub run build_runner build after creating this file

@HiveType(typeId: 0)
class UserData {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  String age;

  @HiveField(4)
  String workoutGoal;

  @HiveField(5)
  double height;

  @HiveField(6)
  double weight;

  @HiveField(7)
  String workoutPlan;

  UserData({
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.workoutGoal,
    required this.height,
    required this.weight,
    required this.workoutPlan,
  });
}
