import '../../../../core/services/network/response_model.dart';
import '../repositories/blog_repository.dart';

class BlogService {
  final BlogRepository repository;

  BlogService(this.repository);

  Future<ResponseModel> getBlogs() async {
    return await repository.getBlogs();
  }

  Future<ResponseModel> getBlogById(int id) async {
    return await repository.getBlogById(id);
  }
}
