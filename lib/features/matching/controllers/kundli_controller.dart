import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/kundli_request_model.dart';
import '../data/models/kundli_response_model.dart';
import '../data/models/create_kundli_request_model.dart';
import '../data/models/create_kundli_response_model.dart';
import '../data/models/kundli_list_response_model.dart';
import '../data/models/kundli_detail_response_model.dart';
import '../domain/usecases/get_birth_chart_usecase.dart';
import '../domain/usecases/create_kundli_usecase.dart';
import '../domain/usecases/get_kundli_list_usecase.dart';
import '../domain/usecases/get_kundli_by_id_usecase.dart';
import '../domain/usecases/update_kundli_usecase.dart';
import '../domain/usecases/delete_kundli_usecase.dart';

class KundliController extends GetxController {
  final GetBirthChartUseCase getBirthChartUseCase;
  final CreateKundliUseCase createKundliUseCase;
  final GetKundliListUseCase getKundliListUseCase;
  final GetKundliByIdUseCase getKundliByIdUseCase;
  final UpdateKundliUseCase updateKundliUseCase;
  final DeleteKundliUseCase deleteKundliUseCase;

  KundliController({
    required this.getBirthChartUseCase,
    required this.createKundliUseCase,
    required this.getKundliListUseCase,
    required this.getKundliByIdUseCase,
    required this.updateKundliUseCase,
    required this.deleteKundliUseCase,
  });

  // Text Controllers
  final nameController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();
  final tobController = TextEditingController();
  final pobController = TextEditingController();

  // Data
  final Rx<KundliResponseModel?> kundliData = Rx<KundliResponseModel?>(null);
  final Rx<CreateKundliResponseModel?> createdKundliData = Rx<CreateKundliResponseModel?>(null);
  final Rx<KundliDetailResponseModel?> kundliDetailData = Rx<KundliDetailResponseModel?>(null);
  final RxList<KundliItem> kundliList = <KundliItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingList = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt editingKundliId = 0.obs; // 0 means create mode, >0 means edit mode
  final RxString selectedLatitude = ''.obs;
  final RxString selectedLongitude = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKundliList();
  }

  @override
  void onClose() {
    nameController.dispose();
    genderController.dispose();
    dobController.dispose();
    tobController.dispose();
    pobController.dispose();
    super.onClose();
  }

  void clearControllers() {
    nameController.clear();
    genderController.clear();
    dobController.clear();
    tobController.clear();
    pobController.clear();
    selectedLatitude.value = '';
    selectedLongitude.value = '';
    editingKundliId.value = 0; // Reset to create mode
  }

  Future<void> fetchKundliById(int id) async {
    try {
      isLoadingDetail.value = true;
      errorMessage.value = '';

      print('[KUNDLI_APP] [DEBUG] Controller: Fetching kundli by id: $id');
      final result = await getKundliByIdUseCase.call(id);
      
      kundliDetailData.value = result;
      editingKundliId.value = id;
      selectedLatitude.value = result.data.latitude?.toString() ?? '';
      selectedLongitude.value = result.data.longitude?.toString() ?? '';
      
      print('[KUNDLI_APP] [DEBUG] Controller: Data received - name: ${result.data.name}, gender: ${result.data.gender}');
      print('[KUNDLI_APP] [DEBUG] Controller: Formatted date: ${result.data.formattedDate}');
      print('[KUNDLI_APP] [DEBUG] Controller: Formatted time: ${result.data.formattedTime}');
      
      // Fill the controllers with the data
      nameController.text = result.data.name;
      genderController.text = result.data.gender.substring(0, 1).toUpperCase() + result.data.gender.substring(1);
      dobController.text = result.data.formattedDate;
      tobController.text = result.data.formattedTime;
      pobController.text = result.data.place;
      
      print('[KUNDLI_APP] [DEBUG] Controller: Controllers filled');
      print('[KUNDLI_APP] [DEBUG] Controller: nameController.text = ${nameController.text}');
      print('[KUNDLI_APP] [DEBUG] Controller: genderController.text = ${genderController.text}');
      print('[KUNDLI_APP] [DEBUG] Controller: dobController.text = ${dobController.text}');
      print('[KUNDLI_APP] [DEBUG] Controller: tobController.text = ${tobController.text}');
      print('[KUNDLI_APP] [DEBUG] Controller: pobController.text = ${pobController.text}');
      print('[KUNDLI_APP] [DEBUG] Controller: Kundli data loaded for editing');
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Controller: Failed to fetch kundli: $e');
      errorMessage.value = 'Failed to load kundli: $e';
      rethrow;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchKundliList({int perPage = 15}) async {
    try {
      isLoadingList.value = true;
      errorMessage.value = '';

      print('[KUNDLI_APP] [DEBUG] Controller: Fetching kundli list');
      final result = await getKundliListUseCase.call(perPage: perPage);
      
      print('[KUNDLI_APP] [DEBUG] Controller: Result received, data count: ${result.data.length}');
      kundliList.value = result.data;
      print('[KUNDLI_APP] [DEBUG] Controller: kundliList.value set, length: ${kundliList.length}');
      print('[KUNDLI_APP] [DEBUG] Controller: First item name: ${kundliList.isNotEmpty ? kundliList.first.name : "empty"}');
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Controller: Failed to fetch kundli list: $e');
      errorMessage.value = 'Failed to load kundli list: $e';
    } finally {
      isLoadingList.value = false;
      print('[KUNDLI_APP] [DEBUG] Controller: isLoadingList set to false');
    }
  }

  Future<void> createKundli({
    required String name,
    required String gender,
    required String birthDate,
    required String birthTime,
    required String latitude,
    required String longitude,
    required String datetime,
    String? place,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final request = CreateKundliRequestModel(
        name: name,
        gender: gender,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
        place: place,
      );

      print('[KUNDLI_APP] [DEBUG] Controller: Creating kundli');
      final result = await createKundliUseCase.call(request);
      
      createdKundliData.value = result;
      print('[KUNDLI_APP] [DEBUG] Controller: Kundli created successfully');
      
      // Refresh the list after creating
      await fetchKundliList();
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Controller: Failed to create kundli: $e');
      errorMessage.value = 'Failed to create kundli: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateKundli({
    required int id,
    required String name,
    required String gender,
    required String birthDate,
    required String birthTime,
    required String latitude,
    required String longitude,
    required String datetime,
    String? place,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final request = CreateKundliRequestModel(
        name: name,
        gender: gender,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
        place: place,
      );

      print('[KUNDLI_APP] [DEBUG] Controller: Updating kundli id: $id');
      final result = await updateKundliUseCase.call(id, request);
      
      createdKundliData.value = result;
      print('[KUNDLI_APP] [DEBUG] Controller: Kundli updated successfully');
      
      // Refresh the list after updating
      await fetchKundliList();
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Controller: Failed to update kundli: $e');
      errorMessage.value = 'Failed to update kundli: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteKundli(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('[KUNDLI_APP] [DEBUG] Controller: Deleting kundli id: $id');
      await deleteKundliUseCase.call(id);
      
      print('[KUNDLI_APP] [DEBUG] Controller: Kundli deleted successfully');
      
      // Remove from local list immediately for better UX
      kundliList.removeWhere((item) => item.id == id);
      
      // Refresh the list from server
      await fetchKundliList();
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Controller: Failed to delete kundli: $e');
      errorMessage.value = 'Failed to delete kundli: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchKundliData({
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    required String datetime,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final request = KundliRequestModel(
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
      );

      print('[KUNDLI_APP] [DEBUG] Controller: Fetching kundli data');
      print('[KUNDLI_APP] [DEBUG] Controller: Request - birthDate: $birthDate, birthTime: $birthTime');
      print('[KUNDLI_APP] [DEBUG] Controller: Request - latitude: $latitude, longitude: $longitude');
      print('[KUNDLI_APP] [DEBUG] Controller: Request - datetime: $datetime');
      
      final result = await getBirthChartUseCase.call(request);
      
      kundliData.value = result;
      print('[KUNDLI_APP] [DEBUG] Controller: Kundli data set successfully');
      print('[KUNDLI_APP] [DEBUG] Controller: Response - date: ${result.data.birthDetails.date}');
      print('[KUNDLI_APP] [DEBUG] Controller: Response - time: ${result.data.birthDetails.time}');
      print('[KUNDLI_APP] [DEBUG] Controller: Response - place: ${result.data.birthDetails.place}');
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Controller: Failed to load kundli: $e');
      errorMessage.value = 'Failed to load kundli data: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get planets grouped by house for chart display
  Map<int, List<String>> getPlanetsGroupedByHouse() {
    if (kundliData.value == null) return {};
    
    final Map<int, List<String>> grouped = {};
    for (var planet in kundliData.value!.data.planets) {
      if (!grouped.containsKey(planet.house)) {
        grouped[planet.house] = [];
      }
      grouped[planet.house]!.add(planet.shortName);
    }
    return grouped;
  }

  // Get current mahadasha info
  String getCurrentMahadashaInfo() {
    if (kundliData.value == null) return '';
    final current = kundliData.value!.data.dashas.current;
    return '${current.mahadasha} - ${current.antardasha}';
  }

  // Get yogas present
  List<Yoga> getPresentYogas() {
    if (kundliData.value == null) return [];
    return kundliData.value!.data.yogas.where((y) => y.present).toList();
  }
}
