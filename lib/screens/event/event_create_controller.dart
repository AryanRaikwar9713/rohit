import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/event/event_api.dart';

class EventCreateController extends GetxController {
  // Form controllers
  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Rx<DateTime?> startDateController = Rx<DateTime?>(null);
  Rx<DateTime?> endDateController = Rx<DateTime?>(null);
  Rx<DateTime?> resultDateController = Rx<DateTime?>(null);
  final TextEditingController maxParticipantsController =
      TextEditingController();
  final TextEditingController entryFeeController = TextEditingController();
  final TextEditingController eventRuleController = TextEditingController();

  // State
  final RxBool isCreating = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final Rx<File?> coverImage = Rx<File?>(null);
  final RxList<String> eventRules = <String>[].obs;
  final RxList<Map<String, String>> prizes = <Map<String, String>>[].obs;
  final Rx<String?> selectedPrizeType=Rx<String?>(null);
  final Rx<String?> selectedEventType=Rx<String?>(null);

  // Prize form controllers
  final TextEditingController prizePositionController = TextEditingController();
  final TextEditingController prizeTitleController = TextEditingController();
  final TextEditingController prizeDescriptionController =
      TextEditingController();
  final TextEditingController prizeValueController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  RxString? selectedIsFeatured =''.obs;


  @override
  void onClose() {
    eventTitleController.dispose();
    selectedEventType.value=null;
    descriptionController.dispose();

    maxParticipantsController.dispose();
    entryFeeController.dispose();
    eventRuleController.dispose();
    prizePositionController.dispose();
    selectedPrizeType.value=null;
    prizeTitleController.dispose();
    prizeDescriptionController.dispose();
    prizeValueController.dispose();
    productIdController.dispose();
    super.onClose();
  }

  Future<void> pickCoverImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        coverImage.value = File(image.path);
      }
    } catch (e) {
      toast('Error picking image: $e');
    }
  }

  Future<void> takeCoverPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        coverImage.value = File(image.path);
      }
    } catch (e) {
      toast('Error taking photo: $e');
    }
  }

  void addEventRule() {
    if (eventRuleController.text.trim().isNotEmpty) {
      eventRules.add(eventRuleController.text.trim());
      eventRuleController.clear();
    }
  }

  void removeEventRule(int index) {
    eventRules.removeAt(index);
  }

  void addPrize() {
    if (prizePositionController.text.trim().isEmpty ||
        selectedPrizeType.value==null ||
        prizeTitleController.text.trim().isEmpty ||
        prizeValueController.text.trim().isEmpty) {
      toast('Please fill all required prize fields');
      return;
    }

    prizes.add({
      'position': prizePositionController.text.trim(),
      'prize_type': selectedPrizeType.value??'',
      'prize_title': prizeTitleController.text.trim(),
      'prize_description': prizeDescriptionController.text.trim(),
      'prize_value': prizeValueController.text.trim(),
      'product_id': productIdController.text.trim(),
    });

    // Clear prize form
    prizePositionController.clear();
    selectedPrizeType.value=null;
    prizeTitleController.clear();
    prizeDescriptionController.clear();
    prizeValueController.clear();
    productIdController.clear();
  }

  void removePrize(int index) {
    prizes.removeAt(index);
  }

  Future<void> createEvent() async {
    // Validation
    if (eventTitleController.text.trim().isEmpty) {
      toast('Please enter event title');
      return;
    }
    if (selectedEventType.value==null) {
      toast('Please enter event type');
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      toast('Please enter description');
      return;
    }
    if (startDateController.value ==null) {
      toast('Please select start date');
      return;
    }
    if (endDateController.value == null) {
      toast('Please select end date');
      return;
    }
    if (resultDateController.value == null) {
      toast('Please select result date');
      return;
    }
    if (maxParticipantsController.text.trim().isEmpty) {
      toast('Please enter max participants');
      return;
    }
    if (entryFeeController.text.trim().isEmpty) {
      toast('Please enter entry fee');
      return;
    }
    if (selectedIsFeatured == null) {
      toast('Please select if event is featured');
      return;
    }
    if (coverImage.value == null) {
      toast('Please select cover image');
      return;
    }
    if (eventRules.isEmpty) {
      toast('Please add at least one event rule');
      return;
    }
    if (prizes.isEmpty) {
      toast('Please add at least one prize');
      return;
    }

    isCreating.value = true;
    uploadProgress.value = 0.0;

    try {
      await Event().createEvent(
        eventTitle: eventTitleController.text.trim(),
        eventType: selectedEventType.value??'',
        description: descriptionController.text.trim(),
        startDate: startDateController.value?.toIso8601String()??'',
        endDate: endDateController.value?.toIso8601String()??'',
        resultDate: resultDateController.value?.toIso8601String()??'',
        maxParticipants: maxParticipantsController.text.trim(),
        entryFee: entryFeeController.text.trim(),
        isFeatured: selectedIsFeatured?.value??'',
        eventRules: eventRules.toList(),
        coverImage: coverImage.value!.path,
        prizes: prizes.toList(),
        onProgress: (progress) {
          uploadProgress.value = progress;
        },
        onError: (error) {
          isCreating.value = false;
          toast('Error: $error');
        },
        onFailure: (response) {
          isCreating.value = false;
          toast('Failed to create event: ${response.statusCode}');
        },
        onSuccess: (eventId) {
          isCreating.value = false;
          toast('Event created successfully!');
          Get.back();
        },
      );
    } catch (e) {
      isCreating.value = false;
      toast('Error creating event: $e');
    }
  }



  final Map<String, String> eventTypeMap = {
    'contest': 'Contest',
    'giveaway': 'Giveaway',
    'quiz': 'Quiz',
    'lottery': 'Lottery',
    'raffle': 'Raffle',
    'tournament': 'Tournament',
    'challenge': 'Challenge',
  };


  final Map<String, String> prizeTypeMap = {
    'cash': 'Cash',
    'product': 'Product',
    'coupon': 'Coupon',
    'points': 'Points',
    'voucher': 'Voucher',
    'gift_card': 'Gift Card',
    'discount': 'Discount',
  };



}
