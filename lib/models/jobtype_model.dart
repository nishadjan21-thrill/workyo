class JobTypeModel {
  final String id;
  final String category;
  final Map<String, dynamic> name;
  final List<dynamic> keywords;

  JobTypeModel({
    required this.id,
    required this.category,
    required this.name,
    required this.keywords,
  });

  factory JobTypeModel.fromFirestore(String id, Map<String, dynamic> data) {
    return JobTypeModel(
      id: id,
      category: data['category'] ?? '',
      name: data['name'] ?? {},
      keywords: data['keywords'] ?? [],
    );
  }

  String getName(String lang) {
    return name[lang] ?? name['en'] ?? '';
  }
}
