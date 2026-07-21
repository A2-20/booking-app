class PackageModel {
  final String packageId;
  final String nameAr;
  final String nameEn;
  final String hotelId;
  final String? flightId;
  final int nights;
  final double totalPrice;
  final double discount;
  final String descriptionAr;
  final String descriptionEn;
  final List<String> images;
  final List<String> attachments;

  PackageModel({
    required this.packageId,
    required this.nameAr,
    required this.nameEn,
    required this.hotelId,
    this.flightId,
    required this.nights,
    required this.totalPrice,
    required this.discount,
    required this.descriptionAr,
    required this.descriptionEn,
    this.images = const [],
    this.attachments = const [],
  });

  double get finalPrice => totalPrice - discount;

  // Helper getters
  String getName(String lang) => lang == 'ar' ? nameAr : nameEn;
  String getDescription(String lang) =>
      lang == 'ar' ? descriptionAr : descriptionEn;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      packageId: json['packageId'] as String,
      nameAr: json['nameAr'] ?? json['name'] ?? '',
      nameEn: json['nameEn'] ?? json['name'] ?? '',
      hotelId: json['hotelId'] as String,
      flightId: json['flightId'] as String?,
      nights: json['nights'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      descriptionAr: json['descriptionAr'] ?? json['description'] ?? '',
      descriptionEn: json['descriptionEn'] ?? json['description'] ?? '',
      images: (json['images'] as List?)?.whereType<String>().toList() ?? [],
      attachments:
          (json['attachments'] as List?)?.whereType<String>().toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'hotelId': hotelId,
      'flightId': flightId,
      'nights': nights,
      'totalPrice': totalPrice,
      'discount': discount,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
    };
  }
}
