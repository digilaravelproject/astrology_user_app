import '../../data/models/panchang_model.dart';
import '../repositories/panchang_repository.dart';

class GetPanchangUseCase {
  final PanchangRepository repository;

  GetPanchangUseCase({required this.repository});

  Future<PanchangModel> call(String date) async {
    return await repository.getPanchangByDate(date);
  }
}
