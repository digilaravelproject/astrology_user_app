class GiftModel {
  final int id;
  final String title;
  final String iconUrl;
  final String? description;
  final String price;

  GiftModel({
    required this.id,
    required this.title,
    required this.iconUrl,
    this.description,
    required this.price,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      description: json['description'],
      price: json['price']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon_url': iconUrl,
      'description': description,
      'price': price,
    };
  }
}
