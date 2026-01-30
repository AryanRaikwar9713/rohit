import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/video_channel/modals/channel_model.dart';
import 'package:streamit_laravel/screens/video_channel/video_channel_api.dart';


class VideoChannelController extends GetxController
{

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  RxBool hasChannel = false.obs;
  RxBool loading = false.obs;

  final Rxn<VideoChannel> channel = Rxn<VideoChannel>();


  final api = VideoChannelApi();



  getChannel() async
  {
    loading.value = true;
    try {
      await api.getChannel(onSuccess: (r){
        this.hasChannel.value = r.hasChannel??false;
        this.channel.value = r.channel;
        loading.value = false;
      }, onError: (e){
        loading.value = false;
      }, onFail: (e){
        toast("Failed To get Channel ${e.statusCode}");
        loading.value = false;
      });


    } catch (e) {
      Logger().e("Error in Function $e");
      loading.value = false;
    }
  }



}