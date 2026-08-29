import '../models/blog_model.dart';
import '../services/blog_service.dart';

class GetBlogsUseCase {
  final BlogService _blogService;

  GetBlogsUseCase(this._blogService);

  Future<List<BlogModel>> execute() async {
    final response = await _blogService.getBlogs();

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap =
            response.body as Map<String, dynamic>;
        final List<dynamic> list = bodyMap['blogs'] ?? [];
        return list
            .map((e) => BlogModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing blogs: $e');
      }
    }

    return [];
  }
}
