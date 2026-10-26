import 'package:astro_user/features/home/data/models/blog_model.dart';
import 'package:astro_user/features/home/data/datasources/blog_service.dart';

class GetBlogByIdUseCase {
  final BlogService _blogService;

  GetBlogByIdUseCase(this._blogService);

  Future<BlogModel?> execute(int id) async {
    final response = await _blogService.getBlogById(id);

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap = response.body as Map<String, dynamic>;
        final Map<String, dynamic> blogJson = bodyMap['blog'] as Map<String, dynamic>;
        return BlogModel.fromJson(blogJson);
      } catch (e) {
        print('Error parsing blog detail: $e');
      }
    }

    return null;
  }
}
