class MatrimonyProfileModel {
  final int? id;
  final int? userId;
  final String createdFor;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String height;
  final String maritalStatus;
  final String location;
  final String education;
  final String jobTitle;
  final String annualIncome;
  final String about;
  final String? profilePhoto;
  final String? panCardNumber;
  final String? drivingLicenceNumber;
  final String? aadhaarCardNumber;
  final String? updatedAt;
  final String? createdAt;

  MatrimonyProfileModel({
    this.id,
    this.userId,
    required this.createdFor,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.maritalStatus,
    required this.location,
    required this.education,
    required this.jobTitle,
    required this.annualIncome,
    required this.about,
    this.profilePhoto,
    this.panCardNumber,
    this.drivingLicenceNumber,
    this.aadhaarCardNumber,
    this.updatedAt,
    this.createdAt,
  });

  factory MatrimonyProfileModel.fromJson(Map<String, dynamic> json) {
    return MatrimonyProfileModel(
      id: json['id'],
      userId: json['user_id'],
      createdFor: json['created_for'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      height: json['height'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      location: json['location'] ?? '',
      education: json['education'] ?? '',
      jobTitle: json['job_title'] ?? '',
      annualIncome: json['annual_income'] ?? '',
      about: json['about'] ?? '',
      profilePhoto: json['profile_photo'],
      panCardNumber: json['pan_card_number'],
      drivingLicenceNumber: json['driving_licence_number'],
      aadhaarCardNumber: json['aadhar_card_number'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
    );
  }

  int get age {
    if (dateOfBirth.isEmpty) return 0;
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  Map<String, String> toFormFields() {
    return {
      'created_for': createdFor,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'height': height,
      'marital_status': maritalStatus,
      'location': location,
      'education': education,
      'job_title': jobTitle,
      'annual_income': annualIncome,
      'about': about,
      if (panCardNumber != null) 'pan_card_number': panCardNumber!,
      if (drivingLicenceNumber != null) 'driving_licence_number': drivingLicenceNumber!,
      if (aadhaarCardNumber != null) 'aadhar_card_number': aadhaarCardNumber!,
    };
  }
}

