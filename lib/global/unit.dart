import 'package:get/get.dart';
import 'package:pistachio/global/number.dart';
import 'package:pistachio/model/class/exercises.dart';
import 'package:pistachio/model/enum/enum.dart';
import 'package:pistachio/presenter/model/user.dart';
import 'package:pistachio/presenter/page/register.dart';

// 사용자의 체중
int get weight => Get.find<UserPresenter>().loggedUser.weight
    ?? Get.find<RegisterPresenter>().newcomer.weight ?? 0;

// 사용자의 신장
int get height => Get.find<UserPresenter>().loggedUser.height
    ?? Get.find<RegisterPresenter>().newcomer.height ?? 0;

// 1분 간 소모 칼로리
Map<ActivityType, double> get calories => {
  ActivityType.distance: (
      Walking.calorie * .5 + Jogging.calorie * .3 + Running.calorie * .2
  ) / 15,
  ActivityType.height: StairClimbing.calorie / 15,
  ActivityType.weight: MuscularExercise.calorie / 15,
};

// 속력 (거리: 분/분, 높이: 층/분, 무게: 회/분)
Map<ActivityType, int> get velocities => {
  ActivityType.distance: 1,
  ActivityType.height: StairClimbing.velocity.ceil(),
  ActivityType.weight: MuscularExercise.velocity.ceil(),
};

// 활동별 소모 칼로리
int convertToCalories(ActivityType type, int amount) {
  double velocity = velocities[type]!.toDouble();
  return (calories[type]! * velocity * amount).ceil();
}

// 거리 변환
int convertDistance(int amount, DistanceUnit src, DistanceUnit dst) {
  double velocity = Walking.velocity * .8
      + Jogging.velocity * .1 + Running.velocity * .1;
  const double kilometerPerStep = 0.00074;

  double value = amount.toDouble();
  int direction = dst.index - src.index;

  switch(direction) {
    case -2:
      value /= (velocity * kilometerPerStep); break;
    case -1:
      if (dst == DistanceUnit.step) value /= kilometerPerStep;
      if (dst == DistanceUnit.minute) value /= velocity;
      break;
    case 1:
      if (dst == DistanceUnit.kilometer) value *= kilometerPerStep;
      if (dst == DistanceUnit.step) value *= velocity;
      break;
    case 2:
      value *= (velocity * kilometerPerStep); break;
  }

  return value.ceil();
}

String unitDistance(int amount) {
  if (amount > 100000) return '${toLocalString(amount ~/ 10000)}만보';
  return '${toLocalString(amount)}보';
}

// 무게 변환 (회 -> kg)
int convertWeight(int amount) => amount * weight;
