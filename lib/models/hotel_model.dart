class HotelModel {
  final String hotelId;
  final String nameAr;
  final String nameEn;
  final String cityAr;
  final String cityEn;
  final String countryAr;
  final String countryEn;
  final int stars;
  final String descriptionAr;
  final String descriptionEn;
  final double rating;
  final List<String> images;
  final List<String> amenitiesAr;
  final List<String> amenitiesEn;
  final String? addressAr;
  final String? addressEn;
  final List<String> attachments;
  final int favoritesCount;

  HotelModel({
    required this.hotelId,
    required this.nameAr,
    required this.nameEn,
    required this.cityAr,
    required this.cityEn,
    required this.countryAr,
    required this.countryEn,
    required this.stars,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.rating,
    this.images = const [],
    this.amenitiesAr = const [],
    this.amenitiesEn = const [],
    this.addressAr,
    this.addressEn,
    this.attachments = const [],
    this.favoritesCount = 0,
  });

  // Helper getters for UI
  String getName(String lang) => lang == 'ar' ? nameAr : nameEn;
  String getCity(String lang) => lang == 'ar' ? cityAr : cityEn;
  String getCountry(String lang) => lang == 'ar' ? countryAr : countryEn;
  String getDescription(String lang) =>
      lang == 'ar' ? descriptionAr : descriptionEn;
  String? getAddress(String lang) => lang == 'ar' ? addressAr : addressEn;
  List<String> getAmenities(String lang) =>
      lang == 'ar' ? amenitiesAr : amenitiesEn;

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      hotelId: (json['hotelId'] ?? json['id'] ?? '').toString(),
      nameAr:
          (json['nameAr'] ??
                  json['name_ar'] ??
                  json['name'] ??
                  json['nameAr'] ??
                  '')
              .toString(),
      nameEn:
          (json['nameEn'] ??
                  json['name_en'] ??
                  json['name'] ??
                  json['nameEn'] ??
                  '')
              .toString(),
      cityAr: (json['cityAr'] ?? json['city_ar'] ?? json['city'] ?? '')
          .toString(),
      cityEn: (json['cityEn'] ?? json['city_en'] ?? json['city'] ?? '')
          .toString(),
      countryAr:
          (json['countryAr'] ?? json['country_ar'] ?? json['country'] ?? '')
              .toString(),
      countryEn:
          (json['countryEn'] ?? json['country_en'] ?? json['country'] ?? '')
              .toString(),
      stars: (json['stars'] ?? 0) is int
          ? (json['stars'] ?? 0)
          : int.tryParse((json['stars'] ?? '0').toString()) ?? 0,
      descriptionAr:
          (json['descriptionAr'] ??
                  json['description_ar'] ??
                  json['description'] ??
                  '')
              .toString(),
      descriptionEn:
          (json['descriptionEn'] ??
                  json['description_en'] ??
                  json['description'] ??
                  '')
              .toString(),
      rating: (json['rating'] ?? 0) is num
          ? (json['rating'] ?? 0).toDouble()
          : double.tryParse((json['rating'] ?? '0.0').toString()) ?? 0.0,
      images: (json['images'] as List?)?.whereType<String>().toList() ?? [],
      amenitiesAr:
          (json['amenitiesAr'] ??
                  json['amenities_ar'] ??
                  json['amenities'] as List?)
              ?.whereType<String>()
              .toList() ??
          [],
      amenitiesEn:
          (json['amenitiesEn'] ??
                  json['amenities_en'] ??
                  json['amenities'] as List?)
              ?.whereType<String>()
              .toList() ??
          [],
      addressAr:
          json['addressAr'] as String? ??
          json['address_ar'] as String? ??
          json['address'] as String?,
      addressEn:
          json['addressEn'] as String? ??
          json['address_en'] as String? ??
          json['address'] as String?,
      attachments:
          (json['attachments'] as List?)?.whereType<String>().toList() ?? [],
      favoritesCount:
          (json['favorites_count'] as num?)?.toInt() ??
          (json['favoritesCount'] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotelId': hotelId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'cityAr': cityAr,
      'cityEn': cityEn,
      'countryAr': countryAr,
      'countryEn': countryEn,
      'stars': stars,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'rating': rating,
      'images': images,
      'amenitiesAr': amenitiesAr,
      'amenitiesEn': amenitiesEn,
      'addressAr': addressAr,
      'addressEn': addressEn,
      'favorites_count': favoritesCount,
    };
  }
}
