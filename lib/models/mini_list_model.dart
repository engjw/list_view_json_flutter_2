class MiniListModel {
  MiniListModel({required this.title, required this.id});

  final String? title;
  final String? id;

  factory MiniListModel.fromJson(Map<String, dynamic> json) {
    return MiniListModel(title: json["title"], id: json["id"]);
  }
}
