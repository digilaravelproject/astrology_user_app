import 'astrologer_model.dart';

class AstrologerDetailResponseModel {
  final String status;
  final AstrologerDetailData data;

  AstrologerDetailResponseModel({required this.status, required this.data});

  factory AstrologerDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return AstrologerDetailResponseModel(
      status: json['status'] ?? '',
      data: AstrologerDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class AstrologerDetailData {
  final AstrologerModel astrologer;

  AstrologerDetailData({required this.astrologer});

  factory AstrologerDetailData.fromJson(Map<String, dynamic> json) {
    return AstrologerDetailData(
      astrologer: AstrologerModel.fromJson(json['astrologer'] ?? {}),
    );
  }
}
