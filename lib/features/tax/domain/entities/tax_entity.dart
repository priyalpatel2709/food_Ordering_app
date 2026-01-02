class TaxEntity {
  final String id;
  final String name;
  final double rate; // as percentage, e.g. 5.0 for 5%
  final bool isActive;

  TaxEntity({
    required this.id,
    required this.name,
    required this.rate,
    this.isActive = true,
  });

  factory TaxEntity.fromJson(Map<String, dynamic> json) {
    return TaxEntity(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      rate: (json['rate'] ?? json['percentage'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'rate': rate, 'isActive': isActive};
  }
}
