/* 컬렉션 프리젠터 */

import 'dart:convert';

import 'package:pistachio/model/class/collection.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// collections.json 파일 관련
class CollectionPresenter extends GetxController {
  static String asset = 'assets/json/data/collections.json';
  static List<Collection> collections = [];

  static Future importFile() async {
    String string = await rootBundle.loadString(asset);
    List<dynamic> list = jsonDecode(string);
    collections = list.map((json) => Collection.fromJson(json)).toList();
  }

  static Collection? getCollection(String id) => collections
      .firstWhereOrNull((collection) => collection.id == id);
}