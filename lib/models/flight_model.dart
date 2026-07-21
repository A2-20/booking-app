class FlightModel {
  final String flightId;
  final String airlineAr;
  final String airlineEn;
  final String departureCountryAr;
  final String departureCountryEn;
  final String departureCityAr;
  final String departureCityEn;
  final String arrivalCountryAr;
  final String arrivalCountryEn;
  final String arrivalCityAr;
  final String arrivalCityEn;
  final DateTime departureDate;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double price;
  final String flightClass; // economy, business
  final List<String> images;
  final List<String> attachments;

  FlightModel({
    required this.flightId,
    required this.airlineAr,
    required this.airlineEn,
    required this.departureCountryAr,
    required this.departureCountryEn,
    required this.departureCityAr,
    required this.departureCityEn,
    required this.arrivalCountryAr,
    required this.arrivalCountryEn,
    required this.arrivalCityAr,
    required this.arrivalCityEn,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.flightClass,
    this.images = const [],
    this.attachments = const [],
  });

  // Helper getters
  String getAirline(String lang) => lang == 'ar' ? airlineAr : airlineEn;
  String getDepartureCountry(String lang) =>
      lang == 'ar' ? departureCountryAr : departureCountryEn;
  String getDepartureCity(String lang) =>
      lang == 'ar' ? departureCityAr : departureCityEn;
  String getArrivalCountry(String lang) =>
      lang == 'ar' ? arrivalCountryAr : arrivalCountryEn;
  String getArrivalCity(String lang) =>
      lang == 'ar' ? arrivalCityAr : arrivalCityEn;

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      flightId: (json['flightId'] ?? json['id'] ?? '').toString(),
      airlineAr:
          (json['airlineAr'] ?? json['airline_ar'] ?? json['airline'] ?? '')
              .toString(),
      airlineEn:
          (json['airlineEn'] ?? json['airline_en'] ?? json['airline'] ?? '')
              .toString(),
      departureCountryAr:
          (json['departureCountryAr'] ??
                  json['departure_country_ar'] ??
                  json['departureCountry'] ??
                  '')
              .toString(),
      departureCountryEn:
          (json['departureCountryEn'] ??
                  json['departure_country_en'] ??
                  json['departureCountry'] ??
                  '')
              .toString(),
      departureCityAr:
          (json['departureCityAr'] ??
                  json['departure_city_ar'] ??
                  json['departureCity'] ??
                  '')
              .toString(),
      departureCityEn:
          (json['departureCityEn'] ??
                  json['departure_city_en'] ??
                  json['departureCity'] ??
                  '')
              .toString(),
      arrivalCountryAr:
          (json['arrivalCountryAr'] ??
                  json['arrival_country_ar'] ??
                  json['arrivalCountry'] ??
                  '')
              .toString(),
      arrivalCountryEn:
          (json['arrivalCountryEn'] ??
                  json['arrival_country_en'] ??
                  json['arrivalCountry'] ??
                  '')
              .toString(),
      arrivalCityAr:
          (json['arrivalCityAr'] ??
                  json['arrival_city_ar'] ??
                  json['arrivalCity'] ??
                  '')
              .toString(),
      arrivalCityEn:
          (json['arrivalCityEn'] ??
                  json['arrival_city_en'] ??
                  json['arrivalCity'] ??
                  '')
              .toString(),
      departureDate:
          DateTime.tryParse(
            (json['departureDate'] ?? json['departure_time'] ?? '').toString(),
          ) ??
          DateTime.now(),
      departureTime:
          (json['departureTime'] ??
                  (json['departure_time'] != null
                      ? json['departure_time']
                            .toString()
                            .split(' ')[1]
                            .substring(0, 5)
                      : '00:00'))
              .toString(),
      arrivalTime:
          (json['arrivalTime'] ??
                  (json['arrival_time'] != null
                      ? json['arrival_time']
                            .toString()
                            .split(' ')[1]
                            .substring(0, 5)
                      : '00:00'))
              .toString(),
      duration: (json['duration'] ?? '0h 00m').toString(),
      price: (json['price'] ?? 0.0) is num
          ? (json['price'] ?? 0.0).toDouble()
          : double.tryParse((json['price'] ?? '0.0').toString()) ?? 0.0,
      flightClass: (json['flightClass'] ?? json['flight_class'] ?? 'Economy')
          .toString(),
      images: (json['images'] as List?)?.whereType<String>().toList() ?? [],
      attachments:
          (json['attachments'] as List?)?.whereType<String>().toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flightId': flightId,
      'airlineAr': airlineAr,
      'airlineEn': airlineEn,
      'departureCountryAr': departureCountryAr,
      'departureCountryEn': departureCountryEn,
      'departureCityAr': departureCityAr,
      'departureCityEn': departureCityEn,
      'arrivalCountryAr': arrivalCountryAr,
      'arrivalCountryEn': arrivalCountryEn,
      'arrivalCityAr': arrivalCityAr,
      'arrivalCityEn': arrivalCityEn,
      'departureDate': departureDate.toIso8601String(),
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'price': price,
      'flightClass': flightClass,
    };
  }
}
