/* 사용자 모델 구조 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pistachio/global/date.dart';
import 'package:pistachio/model/enum/enum.dart';

class PUser {
  /// attributes
  String? uid;
  String? name;
  String? nickname;
  int? weight;
  int? height;
  Sex? sex;
  Timestamp? _regDate;
  Timestamp? _dateOfBirth;
  String? collectionId;
  List<String> partyIds = [];
  List<Map<String, dynamic>> collectionIds = [];
  List<Map<String, dynamic>> goals = [];
  List<Map<String, dynamic>> records = [];

  /// accessors & mutators
  DateTime? get regDate => _regDate?.toDate();

  DateTime? get dateOfBirth => _dateOfBirth?.toDate();

  set regDate(DateTime? date) => _regDate = toTimestamp(date);

  set dateOfBirth(DateTime? date) => _dateOfBirth = toTimestamp(date);

  String? get dateOfBirthString => dateToString('yyyy-MM-dd', dateOfBirth);

  int getTodayAmounts(ActivityType type) => getAmounts(type, today, tomorrow);
  int getThisMonthAmounts(ActivityType type) {
    DateTime firstDate = DateTime(today.year, today.month, 1);
    DateTime lastDate = DateTime(today.year, today.month + 1, 1)
        .subtract(const Duration(days: 1));

    return getAmounts(type, firstDate, lastDate);
  }
  int getAmounts(ActivityType type, [DateTime? startDate, DateTime? endDate]) {
    int result = 0;

    for (var record in records) {
      if (record['type'] != type.kr) continue;
      for (var item in record['recordList']) {
        if (startDate != null && item['date'].toDate().isBefore(startDate)) continue;
        if (endDate != null && item['date'].toDate().isAfter(endDate)) continue;
        result += item['amount'] as int;
      }
    }
    return result;
  }

  /// constructors
  PUser();

  PUser.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  /// methods
  void fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    nickname = json['nickname'];
    weight = json['weight'];
    height = json['height'];
    sex = toSex(json['sex']);
    _regDate = json['regDate'];
    _dateOfBirth = json['dateOfBirth'];
    collectionId = json['collectionId'];
    partyIds = (json['partyIds'] ?? []).cast<String>();
    collectionIds = (json['collectionIds'] ?? []).cast<Map<String, dynamic>>();
    goals = (json['goals'] ?? []).cast<Map<String, dynamic>>();
    records = (json['records'] ?? []).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = uid;
    json['name'] = name;
    json['nickname'] = nickname;
    json['weight'] = weight;
    json['height'] = height;
    json['sex'] = sex?.name;
    json['regDate'] = _regDate;
    json['dateOfBirth'] = _dateOfBirth;
    json['collectionId'] = collectionId;
    json['partyIds'] = partyIds;
    json['collectionIds'] = collectionIds;
    json['goals'] = goals;
    json['records'] = records;
    return json;
  }

  static DateTime? stringToDate(String string) {
    try {
      String yy = string.substring(0, 2);
      int year = int.parse('${int.parse(yy) > 50 ? '19' : '20'}$yy');
      int month = int.parse(string.substring(2, 4));
      int day = int.parse(string.substring(4));

      if (month > 12) return null;
      if (month == 2 && day > 29) return null;
      if ([4, 6, 9, 11].contains(month) && day > 30) return null;
      if (day > 31) return null;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
}
