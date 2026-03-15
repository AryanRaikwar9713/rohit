import 'package:get/get.dart';
import 'package:streamit_laravel/screens/messaging/message_api.dart';
import 'package:streamit_laravel/screens/messaging/models/message_models.dart';

class MessageInboxController extends GetxController {
  final RxList<MessageConversation> conversations = <MessageConversation>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  Future<void> loadConversations() async {
    isLoading.value = true;
    error.value = '';
    MessageApi.getConversations(
      onSuccess: (list) {
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        conversations.assignAll(list);
        isLoading.value = false;
      },
      onError: (msg) {
        error.value = msg;
        isLoading.value = false;
      },
    );
  }
}
