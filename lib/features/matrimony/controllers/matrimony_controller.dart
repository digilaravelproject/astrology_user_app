import 'package:get/get.dart';

class MatrimonyController extends GetxController {
  final RxBool isRegistered = false.obs;
  final RxString searchQuery = ''.obs;

  // Full customer list
  final RxList<Map<String, dynamic>> allCustomers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    allCustomers.value = List.generate(10, (index) => {
      'name': index % 2 == 0 ? 'Swapna Deshmukh' : 'Riya Sharma',
      'age': index % 2 == 0 ? '27' : '29',
      'city': index % 2 == 0 ? 'Pune' : 'Mumbai',
      'state': 'Maharashtra',
      'education': 'MBA',
      'profession': 'Teacher',
      'religion': 'Hindu',
      'caste': 'Deshmukh',
      'language': 'Marathi (Mother Tongue)',
      'imageUrl': index % 2 == 0 ? 'https://randomuser.me/api/portraits/women/60.jpg' : 'https://randomuser.me/api/portraits/women/64.jpg',
      'isMale': false,
    });
  }

  // Reactive filtered list based on search query
  List<Map<String, dynamic>> get filteredCustomers {
    if (searchQuery.value.isEmpty) {
      return allCustomers;
    }
    
    final query = searchQuery.value.toLowerCase();
    return allCustomers.where((c) {
      final name = c['name'].toString().toLowerCase();
      final city = c['city'].toString().toLowerCase();
      final religion = c['religion'].toString().toLowerCase();
      final caste = c['caste'].toString().toLowerCase();
      
      return name.contains(query) || 
             city.contains(query) || 
             religion.contains(query) || 
             caste.contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setRegistered(bool value) {
    isRegistered.value = value;
  }
}
