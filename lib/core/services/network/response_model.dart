class ResponseModel {
  final bool isSuccess;
  final String message;
  final dynamic body;
  final int? statusCode;
  final List<ErrorDetail>? errors;
  final String? token;

  const ResponseModel({
    required this.isSuccess,
    required this.message,
    this.body,
    this.statusCode,
    this.errors,
    this.token,
  });

  /// Factory method to create ResponseModel from JSON
  factory ResponseModel.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    final res = json['res']?.toString().toLowerCase();
    final status = json['status']?.toString().toLowerCase();
    final success = (statusCode == 200 || statusCode == 201 || statusCode == null) &&
        (res == 'success' ||
         status == 'success' ||
         status == 'true' ||
         json['status'] == true ||
         json['status'] == 1 ||
         json['status'] == 200 ||
         json['success'] == true ||
         json['success'] == 1 ||
         json.containsKey('auth') ||
         json.containsKey('astrologers') ||
         json.containsKey('data') ||
         json.containsKey('wallet') ||
         json.containsKey('user') ||
         json.containsKey('token'));

    List<ErrorDetail>? errors;
    if (json['errors'] is Map) {
      errors = [];
      (json['errors'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errors!.add(ErrorDetail(code: key, message: value.first.toString()));
        } else {
          errors!.add(ErrorDetail(code: key, message: value.toString()));
        }
      });
    } else if (json['errors'] is List) {
      errors = (json['errors'] as List)
          .map((e) => ErrorDetail.fromJson(e))
          .toList();
    }

    return ResponseModel(
      isSuccess: success && (statusCode == 200 || statusCode == 201 || statusCode == null),
      message: json['msg']?.toString() ??
          json['message']?.toString() ??
          json['Message']?.toString() ??
          (success ? 'Success' : 'Something went wrong'),
      body: json['data'] ?? json['body'] ?? json, // Fallback to full json if no data key
      statusCode: statusCode,
      errors: errors,
      token: json['token']?.toString(),
    );
  }

  /// Convert this model back to JSON
  Map<String, dynamic> toJson() => {
    'isSuccess': isSuccess,
    'message': message,
    'data': body,
    'statusCode': statusCode,
    'errors': errors?.map((e) => e.toJson()).toList(),
  };

  /// Create a copy with updated fields
  ResponseModel copyWith({
    bool? isSuccess,
    String? message,
    dynamic body,
    int? statusCode,
    List<ErrorDetail>? errors,
    String? token,
  }) {
    return ResponseModel(
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      body: body ?? this.body,
      statusCode: statusCode ?? this.statusCode,
      errors: errors ?? this.errors,
      token: token ?? this.token,
    );
  }

  /// For easier debugging
  @override
  String toString() {
    return 'ResponseModel(isSuccess: $isSuccess, '
        'message: $message, '
        'statusCode: $statusCode, '
        'errors: $errors, '
        'body: $body)';
  }
}

/// Represents error detail (if any)
class ErrorDetail {
  final String? code;
  final String? message;

  const ErrorDetail({this.code, this.message});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      code: json['code']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
  };

  @override
  String toString() => 'ErrorDetail(code: $code, message: $message)';
}
