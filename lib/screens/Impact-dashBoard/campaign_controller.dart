import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/campaign_api.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/campain_cat_responce_model.dart';

class CampaignController extends GetxController {
  final _logger = Logger();

  // Form Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController storyController = TextEditingController();
  final TextEditingController fundingGoalController = TextEditingController();
  final TextEditingController durationDaysController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State Variables
  RxBool isLoading = false.obs;
  RxBool isFetchingCategories = false.obs;
  RxString errorMessage = ''.obs;
  Rx<int?> selectedCategoryId = Rx<int?>(null);
  Rx<String?> selectedCategoryName = Rx<String?>(null);

  // Categories
  RxList<Datum> categories = <Datum>[].obs;

  // Tags
  RxList<String> tags = <String>[].obs;

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();

  // Project Images
  RxList<File> projectImages = <File>[].obs;

  // Project Documents (PDF files)
  RxList<File> projectDocuments = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    storyController.dispose();
    fundingGoalController.dispose();
    durationDaysController.dispose();
    locationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    tagController.dispose();
    super.onClose();
  }

  // Fetch Categories
  Future<void> fetchCategories() async {
    isFetchingCategories.value = true;
    errorMessage.value = '';

    try {
      await MyCampaignApi().getCategories(
        onSuccess: (data) {
          isFetchingCategories.value = false;
          if (data.success == true && data.data != null) {
            categories.value = data.data!;
          } else {
            errorMessage.value = data.message ?? 'Failed to fetch categories';
            toast(errorMessage.value);
          }
        },
        onError: (error) {
          isFetchingCategories.value = false;
          errorMessage.value = error;
          toast(error);
        },
        onFailure: (response) {
          isFetchingCategories.value = false;
          try {
            final errorData = jsonDecode(response.body);
            errorMessage.value =
                errorData['message'] ?? 'Failed to fetch categories';
            toast(errorMessage.value);
          } catch (e) {
            errorMessage.value = 'Failed to fetch categories';
            toast(errorMessage.value);
          }
        },
      );
    } catch (e) {
      isFetchingCategories.value = false;
      errorMessage.value = 'Something went wrong: $e';
      toast(errorMessage.value);
    }
  }

  // Pick Project Images
  Future<void> pickProjectImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        projectImages.addAll(images.map((img) => File(img.path)));
      }
    } catch (e) {
      toast('Error picking images: $e');
    }
  }

  // Remove Project Image
  void removeProjectImage(int index) {
    if (index >= 0 && index < projectImages.length) {
      projectImages.removeAt(index);
    }
  }

  // Pick Project Documents (PDF)
  Future<void> pickProjectDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            projectDocuments.add(File(file.path!));
          }
        }
        toast('${result.files.length} document(s) selected');
      }
    } catch (e) {
      toast('Error picking documents: $e');
    }
  }

  // Remove Project Document
  void removeProjectDocument(int index) {
    if (index >= 0 && index < projectDocuments.length) {
      projectDocuments.removeAt(index);
    }
  }

  // Add Tag
  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagController.clear();
    }
  }

  // Remove Tag
  void removeTag(int index) {
    if (index >= 0 && index < tags.length) {
      tags.removeAt(index);
    }
  }

  // Get Current Location (placeholder - you can integrate location services)
  Future<void> getCurrentLocation() async {
    // TODO: Integrate location services here
    // For now, setting default values
    latitudeController.text = '40.7128';
    longitudeController.text = '-74.0060';
    toast('Location feature coming soon');
  }

  // Validate Form
  bool validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (selectedCategoryId.value == null) {
      toast('Please select a category');
      return false;
    }

    if (titleController.text.trim().isEmpty) {
      toast('Please enter title');
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      toast('Please enter description');
      return false;
    }

    if (storyController.text.trim().isEmpty) {
      toast('Please enter story');
      return false;
    }

    if (fundingGoalController.text.trim().isEmpty) {
      toast('Please enter funding goal');
      return false;
    }

    final fundingGoal = double.tryParse(fundingGoalController.text.trim());
    if (fundingGoal == null || fundingGoal <= 0) {
      toast('Please enter a valid funding goal');
      return false;
    }

    if (durationDaysController.text.trim().isEmpty) {
      toast('Please enter duration in days');
      return false;
    }

    final durationDays = int.tryParse(durationDaysController.text.trim());
    if (durationDays == null || durationDays <= 0) {
      toast('Please enter a valid duration in days');
      return false;
    }

    if (locationController.text.trim().isEmpty) {
      toast('Please enter location');
      return false;
    }

    if (latitudeController.text.trim().isEmpty) {
      toast('Please enter latitude');
      return false;
    }

    if (longitudeController.text.trim().isEmpty) {
      toast('Please enter longitude');
      return false;
    }

    if (tags.isEmpty) {
      toast('Please add at least one tag');
      return false;
    }

    return true;
  }

  // Create Campaign
  Future<void> createCampaign() async {
    if (!validateForm()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await MyCampaignApi().createCampaign(
        categoryId: selectedCategoryId.value!,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        story: storyController.text.trim(),
        fundingGoal: double.parse(fundingGoalController.text.trim()),
        durationDays: int.parse(durationDaysController.text.trim()),
        location: locationController.text.trim(),
        latitude: latitudeController.text.trim(),
        longitude: longitudeController.text.trim(),
        tags: tags,
        projectImages: projectImages.isEmpty ? null : projectImages,
        projectDocuments: projectDocuments.isEmpty ? null : projectDocuments,
        onSuccess: (data) {
          isLoading.value = false;
          toast('Campaign created successfully!');
          clearData();
          Get.back();
        },
        onError: (error) {
          isLoading.value = false;
          errorMessage.value = error;
          toast(error);
        },
        onFailure: (response) {
          isLoading.value = false;
          try {
            final errorData = jsonDecode(response.body);
            final msg = errorData['message'] ?? 'Failed to create campaign';
            errorMessage.value = msg;
            toast(msg);
            _logger.e('Create campaign failed: ${response.statusCode} - ${response.body}');
          } catch (e) {
            errorMessage.value = 'Failed to create campaign';
            toast('Failed to create campaign (${response.statusCode})');
            _logger.e('Create campaign failed: ${response.statusCode} - ${response.body}');
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Something went wrong: $e';
      toast(errorMessage.value);
    }
  }

  // Clear Form Data
  void clearData() {
    titleController.clear();
    descriptionController.clear();
    storyController.clear();
    fundingGoalController.clear();
    durationDaysController.clear();
    locationController.clear();
    latitudeController.clear();
    longitudeController.clear();
    tagController.clear();
    selectedCategoryId.value = null;
    selectedCategoryName.value = null;
    tags.clear();
    projectImages.clear();
    projectDocuments.clear();
    errorMessage.value = '';
  }
}
