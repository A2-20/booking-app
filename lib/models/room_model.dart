class RoomModel {
  final String roomId;
  final String hotelId;
  final String roomTypeAr;
  final String roomTypeEn;
  final double pricePerNight;
  final int maxGuests;
  final bool isAvailable;
  final String? descriptionAr;
  final String? descriptionEn;
  final List<String> amenitiesAr;
  final List<String> amenitiesEn;

  RoomModel({
    required this.roomId,
    required this.hotelId,
    required this.roomTypeAr,
    required this.roomTypeEn,
    required this.pricePerNight,
    required this.maxGuests,
    this.isAvailable = true,
    this.descriptionAr,
    this.descriptionEn,
    this.amenitiesAr = const [],
    this.amenitiesEn = const [],
  });

  // Helper getters
  String getRoomType(String lang) => lang == 'ar' ? roomTypeAr : roomTypeEn;
  String? getDescription(String lang) =>
      lang == 'ar' ? descriptionAr : descriptionEn;
  List<String> getAmenities(String lang) =>
      lang == 'ar' ? amenitiesAr : amenitiesEn;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: (json['roomId'] ?? json['id'] ?? '').toString(),
      hotelId: (json['hotelId'] ?? json['hotel_id'] ?? '').toString(),
      roomTypeAr:
          json['roomTypeAr'] ?? json['room_type_ar'] ?? json['roomType'] ?? '',
      roomTypeEn:
          json['roomTypeEn'] ?? json['room_type_en'] ?? json['roomType'] ?? '',
      pricePerNight:
          (json['pricePerNight'] ?? json['price_per_night'] ?? 0.0) is num
          ? (json['pricePerNight'] ?? json['price_per_night'] ?? 0.0).toDouble()
          : double.parse(
              (json['pricePerNight'] ?? json['price_per_night'] ?? '0.0')
                  .toString(),
            ),
      maxGuests: (json['maxGuests'] ?? json['max_guests'] ?? 0) is int
          ? (json['maxGuests'] ?? json['max_guests'] ?? 0)
          : int.parse(
              (json['maxGuests'] ?? json['max_guests'] ?? '0').toString(),
            ),
      isAvailable:
          json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? true,
      descriptionAr:
          json['descriptionAr'] ??
          json['description_ar'] ??
          json['description'] as String?,
      descriptionEn:
          json['descriptionEn'] ??
          json['description_en'] ??
          json['description'] as String?,
      amenitiesAr: List<String>.from(
        json['amenitiesAr'] ?? json['amenities_ar'] ?? json['amenities'] ?? [],
      ),
      amenitiesEn: List<String>.from(
        json['amenitiesEn'] ?? json['amenities_en'] ?? json['amenities'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'hotelId': hotelId,
      'roomTypeAr': roomTypeAr,
      'roomTypeEn': roomTypeEn,
      'pricePerNight': pricePerNight,
      'maxGuests': maxGuests,
      'isAvailable': isAvailable,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'amenitiesAr': amenitiesAr,
      'amenitiesEn': amenitiesEn,
    };
  }
}
