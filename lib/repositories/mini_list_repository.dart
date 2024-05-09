import '../models/mini_list_model.dart';

abstract class MiniListRepository {
  const MiniListRepository();

  Future<List<MiniListModel>?> getMiniList(String searchText);
}
