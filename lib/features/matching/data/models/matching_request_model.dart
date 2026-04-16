class MatchingRequestModel {
  final PersonDetails boy;
  final PersonDetails girl;

  MatchingRequestModel({
    required this.boy,
    required this.girl,
  });

  Map<String, dynamic> toJson() {
    return {
      'boy': boy.toJson(),
      'girl': girl.toJson(),
    };
  }
}

class PersonDetails {
  final String dateOfBirth;
  final String timeOfBirth;
  final double latitude;
  final double longitude;

  PersonDetails({
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'date_of_birth': dateOfBirth,
      'time_of_birth': timeOfBirth,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
