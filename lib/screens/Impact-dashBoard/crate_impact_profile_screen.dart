import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/impact_profile_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';

class CrateImpactProfileScreen extends StatefulWidget {
  const CrateImpactProfileScreen({super.key});

  @override
  State<CrateImpactProfileScreen> createState() =>
      _CrateImpactProfileScreenState();
}

class _CrateImpactProfileScreenState extends State<CrateImpactProfileScreen> {
  late final ImpactProfileController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = Get.isRegistered<ImpactProfileController>()
        ? Get.find<ImpactProfileController>()
        : Get.put(ImpactProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Create Impact Profile',
          style: boldTextStyle(size: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: appColorPrimary,
                ),
              )
            : Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeaderSection(),
                      24.height,

                      // Account Type Section
                      _buildAccountTypeSection(controller),
                      24.height,

                      // Basic Information Section
                      _buildSectionTitle('Basic Information'),
                      16.height,
                      _buildTextField(
                        controller: controller.titleController,
                        label: 'Title',
                        hint: 'Enter campaign title',
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter title';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      _buildTextField(
                        controller: controller.descriptionController,
                        label: 'Description',
                        hint: 'Describe your campaign',
                        icon: Icons.description,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      _buildTextField(
                        controller: controller.fundingPurposeController,
                        label: 'Funding Purpose',
                        hint: 'What will the funds be used for?',
                        icon: Icons.account_balance_wallet,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter funding purpose';
                          }
                          return null;
                        },
                      ),
                      24.height,

                      // Personal/Organization Information Section
                      Obx(
                        () => controller.accountType.value == 'personal'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Personal Information'),
                                  16.height,
                                  _buildTextField(
                                    controller: controller.fullNameController,
                                    label: 'Full Name',
                                    hint: 'Enter your full name',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter full name';
                                      }
                                      return null;
                                    },
                                  ),
                                  16.height,
                                  _buildTextField(
                                    controller: controller.emailController,
                                    label: 'Email',
                                    hint: 'Enter your email',
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter email';
                                      }
                                      if (!GetUtils.isEmail(value.trim())) {
                                        return 'Please enter valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  16.height,
                                  _buildTextField(
                                    controller: controller.phoneController,
                                    label: 'Phone',
                                    hint: 'Enter your phone number',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  24.height,
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                      'Organization Information'),
                                  16.height,
                                  _buildTextField(
                                    controller: controller.fullNameController,
                                    label: 'Organization Name',
                                    hint: 'Enter organization name',
                                    icon: Icons.business,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter organization name';
                                      }
                                      return null;
                                    },
                                  ),
                                  16.height,
                                  _buildTextField(
                                    controller: controller.emailController,
                                    label: 'Organization Email',
                                    hint: 'Enter organization email',
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter email';
                                      }
                                      if (!GetUtils.isEmail(value.trim())) {
                                        return 'Please enter valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  16.height,
                                  _buildTextField(
                                    controller: controller.phoneController,
                                    label: 'Contact Phone',
                                    hint: 'Enter contact phone number',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  24.height,
                                ],
                              ),
                      ),

                      // Address Information Section
                      _buildSectionTitle('Address Information'),
                      16.height,
                      _buildTextField(
                        controller: controller.addressLine1Controller,
                        label: 'Address Line 1',
                        hint: 'Enter your address',
                        icon: Icons.home,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.cityController,
                              label: 'City',
                              hint: 'City',
                              icon: Icons.location_city,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: _buildTextField(
                              controller: controller.stateController,
                              label: 'State',
                              hint: 'State',
                              icon: Icons.map,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      16.height,
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.countryController,
                              label: 'Country',
                              hint: 'Country',
                              icon: Icons.public,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: _buildTextField(
                              controller: controller.postalCodeController,
                              label: 'Postal Code',
                              hint: 'Postal Code',
                              icon: Icons.markunread_mailbox,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      16.height,
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.latitudeController,
                              label: 'Latitude',
                              hint: '0.0',
                              icon: Icons.location_on,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: _buildTextField(
                              controller: controller.longitudeController,
                              label: 'Longitude',
                              hint: '0.0',
                              icon: Icons.location_on,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          12.width,
                          IconButton(
                            onPressed: controller.getCurrentLocation,
                            icon: const Icon(Icons.my_location,
                                color: appColorPrimary),
                            tooltip: 'Get Current Location',
                          ),
                        ],
                      ),
                      24.height,

                      // Images Section
                      _buildSectionTitle('Images'),
                      16.height,
                      _buildImagePickerSection(controller),
                      24.height,

                      // Organization Proof Section (only for organization type)
                      Obx(
                        () => controller.accountType.value == 'organization'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Organization Proof'),
                                  16.height,
                                  _buildOrganizationProofSection(controller),
                                  24.height,
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Submit Button
                      _buildSubmitButton(controller),
                      24.height,
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff232526),
            Color(0xff414345),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            size: 48,
            color: appColorPrimary,
          ),
          12.height,
          Text(
            'Create Your Impact Profile',
            style: boldTextStyle(size: 22, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          8.height,
          Text(
            'Start your crowdfunding campaign and make a difference',
            style: secondaryTextStyle(size: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeSection(ImpactProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundBlackDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Type',
            style: boldTextStyle(size: 16, color: Colors.white),
          ),
          12.height,
          Row(
            children: [
              Expanded(
                child: _buildAccountTypeOption(
                  controller: controller,
                  type: 'personal',
                  label: 'Personal',
                  icon: Icons.person,
                ),
              ),
              12.width,
              Expanded(
                child: _buildAccountTypeOption(
                  controller: controller,
                  type: 'organization',
                  label: 'Organization',
                  icon: Icons.business,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeOption({
    required ImpactProfileController controller,
    required String type,
    required String label,
    required IconData icon,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.accountType.value = type,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: controller.accountType.value == type
                ? const LinearGradient(
                    colors: [Color(0xff232526), Color(0xff414345)],
                  )
                : null,
            color:
                controller.accountType.value == type ? null : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.accountType.value == type
                  ? appColorPrimary
                  : Colors.grey[700]!,
              width: controller.accountType.value == type ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              8.height,
              Text(
                label,
                style: primaryTextStyle(
                  size: 14,
                  color: Colors.white,
                  weight: controller.accountType.value == type
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff232526),
                Color(0xff414345),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        10.width,
        Text(
          title,
          style: boldTextStyle(size: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundBlackDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: primaryTextStyle(size: 16, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: secondaryTextStyle(size: 14, color: Colors.white70),
          hintStyle: secondaryTextStyle(size: 14, color: Colors.grey),
          prefixIcon: Icon(icon, color: appColorPrimary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildImagePickerSection(ImpactProfileController controller) {
    return Column(
      children: [
        // Profile Image
        Obx(
          () => _buildImagePicker(
            title: 'Profile Image',
            image: controller.profileImage.value,
            onPick: controller.pickProfileImage,
            onRemove: controller.removeProfileImage,
          ),
        ),
        16.height,

        // Cover Image
        Obx(
          () => _buildImagePicker(
            title: 'Cover Image',
            image: controller.coverImage.value,
            onPick: controller.pickCoverImage,
            onRemove: controller.removeCoverImage,
          ),
        ),
        16.height,

        // Supporting Images
        _buildSupportingImagesSection(controller),
      ],
    );
  }

  Widget _buildImagePicker({
    required String title,
    required File? image,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundBlackDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: boldTextStyle(size: 16, color: Colors.white),
          ),
          12.height,
          if (image != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: onPick,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[700]!,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    8.height,
                    Text(
                      'Tap to add $title',
                      style: secondaryTextStyle(size: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSupportingImagesSection(ImpactProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundBlackDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Supporting Images',
                style: boldTextStyle(size: 16, color: Colors.white),
              ),
              TextButton.icon(
                onPressed: controller.pickSupportingImages,
                icon: const Icon(Icons.add, color: appColorPrimary, size: 20),
                label: Text(
                  'Add Images',
                  style: primaryTextStyle(size: 14, color: appColorPrimary),
                ),
              ),
            ],
          ),
          12.height,
          Obx(
            () => controller.supportingImages.isEmpty
                ? GestureDetector(
                    onTap: controller.pickSupportingImages,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                          4.height,
                          Text(
                            'Add supporting images',
                            style: secondaryTextStyle(
                                size: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      controller.supportingImages.length,
                      (index) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              controller.supportingImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  controller.removeSupportingImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationProofSection(ImpactProfileController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBackgroundBlackDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Organization Proof (PDF)',
                  style: boldTextStyle(size: 16, color: Colors.white),
                ),
                if (controller.organizationProof.value != null)
                  IconButton(
                    onPressed: controller.removeOrganizationProof,
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Remove',
                  ),
              ],
            ),
            12.height,
            if (controller.organizationProof.value != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[700]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: appColorPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: appColorPrimary,
                        size: 32,
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.organizationProof.value!.path
                                .split('/')
                                .last,
                            style:
                                primaryTextStyle(size: 14, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.height,
                          Text(
                            'PDF Document',
                            style: secondaryTextStyle(
                                size: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: controller.pickOrganizationProof,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[700]!,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      8.height,
                      Text(
                        'Upload Organization Proof (PDF)',
                        style: secondaryTextStyle(size: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      4.height,
                      Text(
                        'Required for organization accounts',
                        style: secondaryTextStyle(
                            size: 12, color: Colors.grey[600]!),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ImpactProfileController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.createImpactProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: appColorPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    12.width,
                    Text(
                      'Create Impact Profile${kDebugMode?'${controller.isLoading.value}':''}',
                      style: boldTextStyle(size: 18, color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
