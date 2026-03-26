class PlanModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final int durationDays;
  final String status;
  final List<String> features;
  final String? createdAt;
  final String? updatedAt;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.status,
    required this.features,
    this.createdAt,
    this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      status: json['status'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
