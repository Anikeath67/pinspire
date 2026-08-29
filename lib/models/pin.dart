
class Pin {
  final String id;
  final String imageUrl;
  final String originalUrl;
  final String photographer;
  final String category;

  const Pin({
    required this.id,
    required this.imageUrl,
    required this.originalUrl,
    required this.photographer,
    required this.category,
  });

  factory Pin.fromMap(
    Map<String, dynamic> map,
  ) {
    return Pin(
      id: '${map['id'] ?? ''}',
      imageUrl:
          map['imageUrl'] as String? ?? '',
      originalUrl:
          map['originalUrl'] as String? ??
          map['imageUrl'] as String? ??
          '',
      photographer:
          map['photographer'] as String? ??
          'Pexels creator',
      category:
          map['category'] as String? ??
          'All',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'originalUrl': originalUrl,
      'photographer': photographer,
      'category': category,
    };
  }
}