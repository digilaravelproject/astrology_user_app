class MatchingResponseModel {
  final bool success;
  final MatchingData data;
  final BillingInfo billing;
  final MetaInfo meta;

  MatchingResponseModel({
    required this.success,
    required this.data,
    required this.billing,
    required this.meta,
  });

  factory MatchingResponseModel.fromJson(Map<String, dynamic> json) {
    return MatchingResponseModel(
      success: json['success'] ?? false,
      data: MatchingData.fromJson(json['data'] ?? {}),
      billing: BillingInfo.fromJson(json['billing'] ?? {}),
      meta: MetaInfo.fromJson(json['meta'] ?? {}),
    );
  }
}

class MatchingData {
  final double compatibilityScore;
  final int maxScore;
  final double percentage;
  final String verdict;
  final String recommendation;
  final GunaMilan gunaMilan;
  final Doshas doshas;

  MatchingData({
    required this.compatibilityScore,
    required this.maxScore,
    required this.percentage,
    required this.verdict,
    required this.recommendation,
    required this.gunaMilan,
    required this.doshas,
  });

  factory MatchingData.fromJson(Map<String, dynamic> json) {
    return MatchingData(
      compatibilityScore: (json['compatibility_score'] ?? 0).toDouble(),
      maxScore: json['max_score'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      verdict: json['verdict'] ?? '',
      recommendation: json['recommendation'] ?? '',
      gunaMilan: GunaMilan.fromJson(json['guna_milan'] ?? {}),
      doshas: Doshas.fromJson(json['doshas'] ?? {}),
    );
  }
}

class GunaMilan {
  final GunaDetail varna;
  final GunaDetail vashya;
  final GunaDetail tara;
  final GunaDetail yoni;
  final GunaDetail grahaMaitri;
  final GunaDetail gana;
  final GunaDetail bhakoot;
  final GunaDetail nadi;

  GunaMilan({
    required this.varna,
    required this.vashya,
    required this.tara,
    required this.yoni,
    required this.grahaMaitri,
    required this.gana,
    required this.bhakoot,
    required this.nadi,
  });

  factory GunaMilan.fromJson(Map<String, dynamic> json) {
    return GunaMilan(
      varna: GunaDetail.fromJson(json['varna'] ?? {}),
      vashya: GunaDetail.fromJson(json['vashya'] ?? {}),
      tara: GunaDetail.fromJson(json['tara'] ?? {}),
      yoni: GunaDetail.fromJson(json['yoni'] ?? {}),
      grahaMaitri: GunaDetail.fromJson(json['graha_maitri'] ?? {}),
      gana: GunaDetail.fromJson(json['gana'] ?? {}),
      bhakoot: GunaDetail.fromJson(json['bhakoot'] ?? {}),
      nadi: GunaDetail.fromJson(json['nadi'] ?? {}),
    );
  }

  Map<String, GunaDetail> toMap() {
    return {
      'varna': varna,
      'vashya': vashya,
      'tara': tara,
      'yoni': yoni,
      'graha_maitri': grahaMaitri,
      'gana': gana,
      'bhakoot': bhakoot,
      'nadi': nadi,
    };
  }
}

class GunaDetail {
  final dynamic score; // Can be int or double
  final int max;
  final String description;

  GunaDetail({
    required this.score,
    required this.max,
    required this.description,
  });

  factory GunaDetail.fromJson(Map<String, dynamic> json) {
    return GunaDetail(
      score: json['score'] ?? 0,
      max: json['max'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class Doshas {
  final ManglikDosha manglik;
  final NadiDosha nadiDosha;

  Doshas({
    required this.manglik,
    required this.nadiDosha,
  });

  factory Doshas.fromJson(Map<String, dynamic> json) {
    return Doshas(
      manglik: ManglikDosha.fromJson(json['manglik'] ?? {}),
      nadiDosha: NadiDosha.fromJson(json['nadi_dosha'] ?? {}),
    );
  }
}

class ManglikDosha {
  final ManglikDetail male;
  final ManglikDetail female;

  ManglikDosha({
    required this.male,
    required this.female,
  });

  factory ManglikDosha.fromJson(Map<String, dynamic> json) {
    return ManglikDosha(
      male: ManglikDetail.fromJson(json['male'] ?? {}),
      female: ManglikDetail.fromJson(json['female'] ?? {}),
    );
  }
}

class ManglikDetail {
  final bool present;
  final String? intensity;
  final String? cancelledBy;

  ManglikDetail({
    required this.present,
    this.intensity,
    this.cancelledBy,
  });

  factory ManglikDetail.fromJson(Map<String, dynamic> json) {
    return ManglikDetail(
      present: json['present'] ?? false,
      intensity: json['intensity'],
      cancelledBy: json['cancelled_by'],
    );
  }
}

class NadiDosha {
  final bool present;
  final String severity;
  final List<String> remedies;

  NadiDosha({
    required this.present,
    required this.severity,
    required this.remedies,
  });

  factory NadiDosha.fromJson(Map<String, dynamic> json) {
    return NadiDosha(
      present: json['present'] ?? false,
      severity: json['severity'] ?? '',
      remedies: (json['remedies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
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
}
