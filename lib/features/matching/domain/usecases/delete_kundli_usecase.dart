import 'package:astro_user/features/matching/domain/repositories/kundli_repository.dart';

class DeleteKundliUseCase {
  final KundliRepository repository;

  DeleteKundliUseCase({required this.repository});

  Future<void> call(int id) async {
    return await repository.deleteKundli(id);
  }
}
