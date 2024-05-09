import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/mini_list_model.dart';
import '../repositories/mini_list_repository.dart';

class MiniListService implements MiniListRepository {
  @override
  Future<List<MiniListModel>?> getMiniList(String searchText) async {
    final String response =
        await rootBundle.loadString('assets/data/mini_list.json');
    final List<dynamic> data = await json.decode(response);

    List<MiniListModel> miniList =
        data.map((miniJson) => MiniListModel.fromJson(miniJson)).toList();

    if (searchText.isNotEmpty) {
      miniList = miniList.where((mini) {
        return mini.title?.toLowerCase().contains(searchText.toLowerCase()) ??
            false;
      }).toList();
    }

    return miniList;
  }
}
