import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/impact_profile_api.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/profileresponcemodel.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/use_campai_limit_responce.dart';

class ImpactProfileController extends GetxController {
  // Form Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController fundingPurposeController =
      TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State Variables
  var isLoading = false.obs;
  var accountType = 'personal'.obs;
  var errorMessage = ''.obs;

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();

  // Image Files
  Rx<File?> profileImage = Rx<File?>(null);
  Rx<File?> coverImage = Rx<File?>(null);
  RxList<File> supportingImages = <File>[].obs;

  // Organization Proof (PDF file)
  Rx<File?> organizationProof = Rx<File?>(null);

  // Profile Data
  Rx<ImpactProfileResponce?> profileResponse = Rx<ImpactProfileResponce?>(null);
  Rx<UserCampainLimitResponcModel?> userCampainLimitResponse = Rx<UserCampainLimitResponcModel?>(null);
  var isCheckingAccount = false.obs;

  @override
  void onInit() {
    super.onInit();
    clearData();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    fundingPurposeController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  // Pick Profile Image
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      toast('Error picking profile image: $e');
    }
  }

  // Pick Cover Image
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
      toast('Error picking cover image: $e');
    }
  }

  // Pick Supporting Images
  Future<void> pickSupportingImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        supportingImages.addAll(images.map((img) => File(img.path)));
      }
    } catch (e) {
      toast('Error picking supporting images: $e');
    }
  }

  // Remove Supporting Image
  void removeSupportingImage(int index) {
    if (index >= 0 && index < supportingImages.length) {
      supportingImages.removeAt(index);
    }
  }

  // Remove Profile Image
  void removeProfileImage() {
    profileImage.value = null;
  }

  // Remove Cover Image
  void removeCoverImage() {
    coverImage.value = null;
  }

  // Pick Organization Proof (PDF)
  Future<void> pickOrganizationProof() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        organizationProof.value = File(result.files.single.path!);
        toast('Organization proof selected');
      }
    } catch (e) {
      toast('Error picking organization proof: $e');
    }
  }

  // Remove Organization Proof
  void removeOrganizationProof() {
    organizationProof.value = null;
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

    if (titleController.text.trim().isEmpty) {
      toast('Please enter title');
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      toast('Please enter description');
      return false;
    }

    // Personal or Organization specific validation
    if (accountType.value == 'personal') {
      if (fullNameController.text.trim().isEmpty) {
        toast('Please enter your full name');
        return false;
      }
      if (emailController.text.trim().isEmpty) {
        toast('Please enter your email');
        return false;
      }
      if (!GetUtils.isEmail(emailController.text.trim())) {
        toast('Please enter valid email address');
        return false;
      }
      if (phoneController.text.trim().isEmpty) {
        toast('Please enter your phone number');
        return false;
      }
    } else if (accountType.value == 'organization') {
      if (fullNameController.text.trim().isEmpty) {
        toast('Please enter organization name');
        return false;
      }
      if (emailController.text.trim().isEmpty) {
        toast('Please enter organization email');
        return false;
      }
      if (!GetUtils.isEmail(emailController.text.trim())) {
        toast('Please enter valid organization email address');
        return false;
      }
      if (phoneController.text.trim().isEmpty) {
        toast('Please enter contact phone number');
        return false;
      }
      // Validate organization proof for organization type
      if (organizationProof.value == null) {
        toast('Please upload organization proof (PDF)');
        return false;
      }
    }

    if (addressLine1Controller.text.trim().isEmpty) {
      toast(accountType.value == 'personal'
          ? 'Please enter your address'
          : 'Please enter organization address');
      return false;
    }

    if (cityController.text.trim().isEmpty) {
      toast('Please enter city');
      return false;
    }

    if (stateController.text.trim().isEmpty) {
      toast('Please enter state');
      return false;
    }

    if (countryController.text.trim().isEmpty) {
      toast('Please enter country');
      return false;
    }

    if (postalCodeController.text.trim().isEmpty) {
      toast('Please enter postal code');
      return false;
    }

    return true;
  }

  // Create Impact Profile
  Future<void> createImpactProfile() async {

    if (!validateForm()) {
      toast('Please Cpmplite Form');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await ImpactProfileApi().createImpactProfile(
        accountType: accountType.value,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        fundingPurpose: fundingPurposeController.text.trim(),
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        addressLine1: addressLine1Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        country: countryController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        latitude: latitudeController.text.trim().isEmpty
            ? '0.0'
            : latitudeController.text.trim(),
        longitude: longitudeController.text.trim().isEmpty
            ? '0.0'
            : longitudeController.text.trim(),
        profileImage: profileImage.value,
        coverImage: coverImage.value,
        supportingImages: supportingImages.isEmpty ? null : supportingImages,
        organizationProof: organizationProof.value,
        onSuccess: (data) {
          isLoading.value = false;
          toast('Impact profile created successfully!');
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
            errorMessage.value =
                errorData['message'] ?? 'Failed to create profile';
            toast(errorMessage.value);
          } catch (e) {
            errorMessage.value = 'Failed to create profile';
            toast(errorMessage.value);
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
    fundingPurposeController.clear();
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressLine1Controller.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    postalCodeController.clear();
    latitudeController.clear();
    longitudeController.clear();
    profileImage.value = null;
    coverImage.value = null;
    supportingImages.clear();
    organizationProof.value = null;
    accountType.value = 'personal';
    errorMessage.value = '';
  }

  // Check Impact Account
  Future<void> checkImpactAccount() async {
    isCheckingAccount.value = true;
    errorMessage.value = '';

    try {
      await ImpactProfileApi().checkImpactAccount(
        onSuccess: (data) {
          isCheckingAccount.value = false;
          profileResponse.value = data;
          if(profileResponse.value?.data?.hasAccount??false)
            {
              ImpactProfileApi().chekUserCampainLimit(onSuccess: (d){
                userCampainLimitResponse.value = d;
              }, onError: onError);
            }
        },
        onError: (error) {
          isCheckingAccount.value = false;
          errorMessage.value = error;
          Logger().e(error);
          toast(error);
        },
        onFailure: (response) {
          isCheckingAccount.value = false;
          try {
            final errorData = jsonDecode(response.body);
            errorMessage.value =
                errorData['message'] ?? 'Failed to check account';
            toast(errorMessage.value);
          } catch (e) {
            errorMessage.value = 'Failed to check account';
            toast(errorMessage.value);
          }
        },
      );
    } catch (e) {
      isCheckingAccount.value = false;
      errorMessage.value = 'Something went wrong: $e';
      toast(errorMessage.value);
    }
  }
}
