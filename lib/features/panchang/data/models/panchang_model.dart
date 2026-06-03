class PanchangModel {
  final bool success;
  final PanchangData data;
  final BillingInfo billing;
  final MetaInfo meta;

  PanchangModel({
    required this.success,
    required this.data,
    required this.billing,
    required this.meta,
  });

  factory PanchangModel.fromJson(Map<String, dynamic> json) {
    print('[PCB_APP] [DEBUG] PanchangModel.fromJson - json keys: ${json.keys}');
    print('[PCB_APP] [DEBUG] PanchangModel.fromJson - success value: ${json['success']}');
    print('[PCB_APP] [DEBUG] PanchangModel.fromJson - data value: ${json['data']}');
    
    return PanchangModel(
      success: json['success'] ?? false,
      data: PanchangData.fromJson(json['data'] ?? {}),
      billing: BillingInfo.fromJson(json['billing'] ?? {}),
      meta: MetaInfo.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'billing': billing.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class PanchangData {
  final String date;
  final String location;
  final Tithi tithi;
  final Nakshatra nakshatra;
  final Yoga yoga;
  final Karana karana;
  final Vara vara;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final TimeRange rahukaal;
  final TimeRange yamagandam;
  final TimeRange gulika;
  final TimeRange abhijitMuhurta;
  final List<AuspiciousTiming> auspiciousTimings;
  final List<InauspiciousPeriod> inauspiciousPeriods;

  PanchangData({
    required this.date,
    required this.location,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.vara,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.rahukaal,
    required this.yamagandam,
    required this.gulika,
    required this.abhijitMuhurta,
    required this.auspiciousTimings,
    required this.inauspiciousPeriods,
  });  factory PanchangData.fromJson(Map<String, dynamic> json) {
    print('[PCB_APP] [DEBUG] PanchangData.fromJson - json keys: ${json.keys}');
    
    // Support coordinates & timezone for location in production v2 response
    String parsedLocation = json['location'] ?? '';
    if (parsedLocation.isEmpty && json['coordinates'] != null) {
      final lat = json['coordinates']['latitude'];
      final lon = json['coordinates']['longitude'];
      parsedLocation = 'Lat: $lat, Lon: $lon';
    } else if (parsedLocation.isEmpty && json['timezone'] != null) {
      parsedLocation = 'Timezone: ${json['timezone']}';
    }

    return PanchangData(
      date: json['date'] ?? json['datetime'] ?? '',
      location: parsedLocation,
      tithi: Tithi.fromJson(json['tithi'] ?? {}),
      nakshatra: Nakshatra.fromJson(json['nakshatra'] ?? {}),
      yoga: Yoga.fromJson(json['yoga'] ?? {}),
      karana: Karana.fromJson(json['karana'] ?? {}),
      vara: Vara.fromJson(json['vara'] ?? json['vaara'] ?? {}),
      sunrise: json['sunrise'] ?? '',
      sunset: json['sunset'] ?? '',
      moonrise: json['moonrise'] ?? '',
      moonset: json['moonset'] ?? '',
      rahukaal: TimeRange.fromJson(json['rahukaal'] ?? {}),
      yamagandam: TimeRange.fromJson(json['yamagandam'] ?? {}),
      gulika: TimeRange.fromJson(json['gulika'] ?? {}),
      abhijitMuhurta: TimeRange.fromJson(json['abhijit_muhurta'] ?? {}),
      auspiciousTimings: (json['auspicious_timings'] as List<dynamic>?)
              ?.map((e) => AuspiciousTiming.fromJson(e))
              .toList() ??
          [],
      inauspiciousPeriods: (json['inauspicious_periods'] as List<dynamic>?)
              ?.map((e) => InauspiciousPeriod.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'location': location,
      'tithi': tithi.toJson(),
      'nakshatra': nakshatra.toJson(),
      'yoga': yoga.toJson(),
      'karana': karana.toJson(),
      'vara': vara.toJson(),
      'sunrise': sunrise,
      'sunset': sunset,
      'moonrise': moonrise,
      'moonset': moonset,
      'rahukaal': rahukaal.toJson(),
      'yamagandam': yamagandam.toJson(),
      'gulika': gulika.toJson(),
      'abhijit_muhurta': abhijitMuhurta.toJson(),
      'auspicious_timings': auspiciousTimings.map((e) => e.toJson()).toList(),
      'inauspicious_periods': inauspiciousPeriods.map((e) => e.toJson()).toList(),
    };
  }
}

class Tithi {
  final String name;
  final String endTime;
  final String deity;
  final String significance;

  Tithi({
    required this.name,
    required this.endTime,
    required this.deity,
    required this.significance,
  });

  factory Tithi.fromJson(Map<String, dynamic> json) {
    return Tithi(
      name: json['name'] ?? '',
      endTime: json['end_time'] ?? '',
      deity: json['deity'] ?? json['lord'] ?? '',
      significance: json['significance'] ?? json['interpretation']?['meaning'] ?? json['interpretation']?['energy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'end_time': endTime,
      'deity': deity,
      'significance': significance,
    };
  }
}

class Nakshatra {
  final String name;
  final String endTime;
  final String deity;
  final String significance;

  Nakshatra({
    required this.name,
    required this.endTime,
    required this.deity,
    required this.significance,
  });

  factory Nakshatra.fromJson(Map<String, dynamic> json) {
    return Nakshatra(
      name: json['name'] ?? '',
      endTime: json['end_time'] ?? '',
      deity: json['deity'] ?? json['lord'] ?? '',
      significance: json['significance'] ?? json['interpretation']?['meaning'] ?? json['interpretation']?['energy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'end_time': endTime,
      'deity': deity,
      'significance': significance,
    };
  }
}

class Yoga {
  final String name;
  final String endTime;
  final String significance;

  Yoga({
    required this.name,
    required this.endTime,
    required this.significance,
  });

  factory Yoga.fromJson(Map<String, dynamic> json) {
    return Yoga(
      name: json['name'] ?? '',
      endTime: json['end_time'] ?? '',
      significance: json['significance'] ?? json['interpretation']?['meaning'] ?? json['interpretation']?['effect'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'end_time': endTime,
      'significance': significance,
    };
  }
}

class Karana {
  final String name;
  final String endTime;

  Karana({
    required this.name,
    required this.endTime,
  });

  factory Karana.fromJson(Map<String, dynamic> json) {
    return Karana(
      name: json['name'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'end_time': endTime,
    };
  }
}

class Vara {
  final String name;
  final String deity;
  final String significance;

  Vara({
    required this.name,
    required this.deity,
    required this.significance,
  });

  factory Vara.fromJson(Map<String, dynamic> json) {
    return Vara(
      name: json['name'] ?? '',
      deity: json['deity'] ?? json['lord'] ?? '',
      significance: json['significance'] ?? json['interpretation']?['meaning'] ?? json['interpretation']?['energy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'deity': deity,
      'significance': significance,
    };
  }
}

class TimeRange {
  final String start;
  final String end;

  TimeRange({
    required this.start,
    required this.end,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}

class AuspiciousTiming {
  final String name;
  final String start;
  final String end;

  AuspiciousTiming({
    required this.name,
    required this.start,
    required this.end,
  });

  factory AuspiciousTiming.fromJson(Map<String, dynamic> json) {
    return AuspiciousTiming(
      name: json['name'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start': start,
      'end': end,
    };
  }
}

class InauspiciousPeriod {
  final String name;
  final String start;
  final String end;

  InauspiciousPeriod({
    required this.name,
    required this.start,
    required this.end,
  });

  factory InauspiciousPeriod.fromJson(Map<String, dynamic> json) {
    return InauspiciousPeriod(
      name: json['name'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start': start,
      'end': end,
    };
  }
}

class BillingInfo {
  final double charged;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final String endpoint;
  final String category;

  BillingInfo({
    required this.charged,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.endpoint,
    required this.category,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) {
    return BillingInfo(
      charged: (json['charged'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      endpoint: json['endpoint'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'charged': charged,
      'currency': currency,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'endpoint': endpoint,
      'category': category,
    };
  }
}

class MetaInfo {
  final String engine;
  final String version;

  MetaInfo({
    required this.engine,
    required this.version,
  });

  factory MetaInfo.fromJson(Map<String, dynamic> json) {
    return MetaInfo(
      engine: json['engine'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'engine': engine,
      'version': version,
    };
  }
}
