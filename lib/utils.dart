import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:umbc_hack/models/push_up_model.dart';

double calculateAngle(PoseLandmark firstLandmark, PoseLandmark midLandmark,
    PoseLandmark lastLandmark) {
  final radians = math.atan2(
          lastLandmark.y - midLandmark.y, lastLandmark.x - midLandmark.x) -
      math.atan2(
          firstLandmark.y - midLandmark.y, firstLandmark.x - midLandmark.x);

  double degrees = radians * 180.0 / math.pi;
  degrees = degrees.abs();

  if (degrees > 180.0) {
    degrees = 360.0 - degrees;
  }

  return degrees;
}

PushUpState? isPushUp(double angleElbow, PushUpState current) {
  final downThreshold = 60.0;
  final upThreshold = 80.0;
  final margin = 10.0;

  if (current == PushUpState.complete && angleElbow > (upThreshold - margin)) {
    print('Detected Push-Up Init');
    return PushUpState.init;
  } else if (current == PushUpState.init &&
      angleElbow < (downThreshold + margin)) {
    print('Detected Push-Up Complete');
    return PushUpState.complete;
  }

  return null;
}
