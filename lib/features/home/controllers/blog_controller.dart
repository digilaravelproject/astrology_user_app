import 'package:get/get.dart';
import '../domain/models/blog_model.dart';
import '../domain/usecases/get_blogs_usecase.dart';
import '../domain/usecases/get_blog_by_id_usecase.dart';

class BlogController extends GetxController {
  final GetBlogsUseCase _getBlogsUseCase;
  final GetBlogByIdUseCase _getBlogByIdUseCase;

  BlogController({
    required GetBlogsUseCase getBlogsUseCase,
    required GetBlogByIdUseCase getBlogByIdUseCase,
  })  : _getBlogsUseCase = getBlogsUseCase,
        _getBlogByIdUseCase = getBlogByIdUseCase;

  static const List<String> blogImages = [
    'https://cdn-icons-png.flaticon.com/512/2917/2917995.png',
    'https://cdn-icons-png.flaticon.com/512/3094/3094651.png',
    'https://cdn-icons-png.flaticon.com/512/2917/2917999.png',
    'https://cdn-icons-png.flaticon.com/512/3094/3094673.png',
    'https://cdn-icons-png.flaticon.com/512/3094/3094679.png',
  ];

  final isLoading = false.obs;
  final blogs = <BlogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    try {
      isLoading.value = true;
      final result = await _getBlogsUseCase.execute();
      blogs.assignAll(result);
    } catch (e) {
      print('Error fetching blogs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<BlogModel?> fetchBlogById(int id) async {
    try {
      return await _getBlogByIdUseCase.execute(id);
    } catch (e) {
      print('Error fetching blog detail: $e');
      return null;
    }
  }

  String getBlogImage(int index) {
    return blogImages[index % blogImages.length];
  }
}
