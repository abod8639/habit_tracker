import 'package:get/get.dart';
import 'package:habit_tracker/features/ai_chat/presentation/controllers/ai_chat_controller.dart';

class AiChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiChatController(), fenix: true);
  }
}
