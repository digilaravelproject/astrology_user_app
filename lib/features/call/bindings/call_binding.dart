import 'package:get/get.dart';
import '../../astrologers/controllers/astrologer_controller.dart';

class CallBinding extends Bindings {
  @override
  void dependencies() {
    // AstrologerController is already lazy in AstrologersBinding
    // This binding ensures AstrologersBinding is loaded when this route is accessed
  }
}
