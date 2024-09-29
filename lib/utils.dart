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

PushUpState? isPushUp(double angleKnee, PushUpState current) {
  final standingThreshold = 170.0;
  final squattingThreshold = 130.0;
  final margin = 5.0;

  if (current == PushUpState.complete &&
      angleKnee > (standingThreshold - margin)) {
    print('Detected Squat Init');
    return PushUpState.init;
  } else if (current == PushUpState.init &&
      angleKnee < (squattingThreshold + margin)) {
    print('Detected Squat Complete');
    return PushUpState.complete;
  }

  return null;
}
