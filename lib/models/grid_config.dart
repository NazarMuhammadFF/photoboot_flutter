class GridConfig {
  final String id;
  final String name;
  final double canvasWidth;
  final double canvasHeight;
  final String printBehavior; // 'normal', 'duplicate_on_4r', 'fit_to_a4'
  final List<GridSlot> slots;
  final String? overlayImage;
  final String? thumbnailImage;

  GridConfig({
    required this.id,
    required this.name,
    required this.canvasWidth,
    required this.canvasHeight,
    this.printBehavior = 'normal',
    required this.slots,
    this.overlayImage,
    this.thumbnailImage,
  });

  factory GridConfig.fromJson(Map<String, dynamic> json) {
    return GridConfig(
      id: json['id'],
      name: json['name'],
      canvasWidth: (json['canvas_width'] as num).toDouble(),
      canvasHeight: (json['canvas_height'] as num).toDouble(),
      printBehavior: json['print_behavior'] ?? 'normal',
      slots: (json['slots'] as List)
          .map((slot) => GridSlot.fromJson(slot))
          .toList(),
      overlayImage: json['overlay_image'],
      thumbnailImage: json['thumbnail_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'canvas_width': canvasWidth,
      'canvas_height': canvasHeight,
      'print_behavior': printBehavior,
      'slots': slots.map((slot) => slot.toJson()).toList(),
      'overlay_image': overlayImage,
      'thumbnail_image': thumbnailImage,
    };
  }
}

class GridSlot {
  final int id;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;

  GridSlot({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
  });

  factory GridSlot.fromJson(Map<String, dynamic> json) {
    return GridSlot(
      id: json['id'],
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
    };
  }
}
