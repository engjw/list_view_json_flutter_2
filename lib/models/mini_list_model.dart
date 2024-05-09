class MiniListModel {
  MiniListModel(
      {required this.title, required this.image, required this.description});

  final String? title;
  final String? image;
  final String? description;

  factory MiniListModel.fromJson(Map<String, dynamic> json) {
    return MiniListModel(
        title: json["title"],
        image: json["image"],
        description: json["description"]);
  }
}
