class AstrologerGalleryModel {
  final int id;
  final int astrologerId;
  final String image;
  final String imagePath;
  final String createdAt;
  final String updatedAt;

  AstrologerGalleryModel({
    required this.id,
    required this.astrologerId,
    required this.image,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AstrologerGalleryModel.fromJson(Map<String, dynamic> json) {
    return AstrologerGalleryModel(
      id: json['id'] ?? 0,
      astrologerId: json['astrologer_id'] ?? 0,
      image: json['image'] ?? '',
      imagePath: json['image_path'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
