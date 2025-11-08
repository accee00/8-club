class ExperienceModel {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl;
  final String iconUrl;

  ExperienceModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.iconUrl,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      iconUrl: json['icon_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'image_url': imageUrl,
      'icon_url': iconUrl,
    };
  }

  @override
  String toString() {
    return 'ExperienceModel(id: $id, name: $name, tagline: $tagline, description: $description, imageUrl: $imageUrl, iconUrl: $iconUrl)';
  }
}
