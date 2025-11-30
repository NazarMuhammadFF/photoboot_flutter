class TemplateConfig {
  final String id;
  final String name;
  final String imagePath; // Path to the PNG overlay
  final String gridId; // Which grid this template is compatible with
  final DateTime createdAt;

  TemplateConfig({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.gridId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TemplateConfig.fromJson(Map<String, dynamic> json) {
    return TemplateConfig(
      id: json['id'],
      name: json['name'],
      imagePath: json['image_path'],
      gridId: json['grid_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
      'grid_id': gridId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TemplateConfig copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? gridId,
    DateTime? createdAt,
  }) {
    return TemplateConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      gridId: gridId ?? this.gridId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
