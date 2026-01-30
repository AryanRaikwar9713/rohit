import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/location_api.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/campaign_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  late final CampaignController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CampaignController>()
        ? Get.find<CampaignController>()
        : Get.put(CampaignController());

    autoFillLocation();
  }


  void autoFillLocation() async
  {
    try{
      var api = LocationApi();
      Placemark? place = await api.getUserPlacemark();
      Position? location = await api.getUserLocation();

      if(place!=null)
        {
          String address = "${place.name}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
          controller.locationController.text = address;
        }
      if(location!=null)
        {
          controller.latitudeController.text = location.latitude.toString();
          controller.longitudeController.text = location.longitude.toString();
        }


    }
    catch(e){
      Logger().e("Can Not Auto Fill Location Information");
    }
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
          'Create Campaign',
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

                      // Category Selection
                      _buildCategorySection(),
                      24.height,

                      // Basic Information Section
                      _buildSectionTitle('Basic Information'),
                      16.height,
                      _buildTextField(
                        controller: controller.titleController,
                        label: 'Campaign Title',
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
                        hint: 'Brief description of your campaign',
                        icon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      _buildTextField(
                        controller: controller.storyController,
                        label: 'Story',
                        hint: 'Tell your story in detail...',
                        icon: Icons.book,
                        maxLines: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your story';
                          }
                          return null;
                        },
                      ),
                      24.height,

                      // Funding Information Section
                      _buildSectionTitle('Funding Information'),
                      16.height,
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.fundingGoalController,
                              label: 'Funding Goal',
                              hint: '0.00',
                              icon: Icons.attach_money,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                final amount = double.tryParse(value.trim());
                                if (amount == null || amount <= 0) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          12.width,
                          Expanded(
                            child: _buildTextField(
                              controller: controller.durationDaysController,
                              label: 'Duration (Days)',
                              hint: '60',
                              icon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                final days = int.tryParse(value.trim());
                                if (days == null || days <= 0) {
                                  return 'Invalid days';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      24.height,

                      // Location Information Section
                      _buildSectionTitle('Location Information'),
                      16.height,
                      _buildTextField(
                        controller: controller.locationController,
                        label: 'Location',
                        hint: 'Enter location (e.g., New York, USA)',
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                      16.height,
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.latitudeController,
                              label: 'Latitude',
                              hint: '0.0',
                              icon: Icons.my_location,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
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
                              controller: controller.longitudeController,
                              label: 'Longitude',
                              hint: '0.0',
                              icon: Icons.my_location,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          12.width,
                          IconButton(
                            onPressed: controller.getCurrentLocation,
                            icon: const Icon(Icons.gps_fixed,
                                color: appColorPrimary),
                            tooltip: 'Get Current Location',
                          ),
                        ],
                      ),
                      24.height,

                      // Tags Section
                      _buildTagsSection(),
                      24.height,

                      // Project Images Section
                      _buildProjectImagesSection(),
                      24.height,

                      // Project Documents Section
                      _buildProjectDocumentsSection(),
                      24.height,

                      // Submit Button
                      _buildSubmitButton(),
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
            Icons.campaign,
            size: 48,
            color: appColorPrimary,
          ),
          12.height,
          Text(
            'Start Your Campaign',
            style: boldTextStyle(size: 22, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          8.height,
          Text(
            'Create a compelling campaign and make a difference',
            style: secondaryTextStyle(size: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
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
            Text(
              'Category',
              style: boldTextStyle(size: 16, color: Colors.white),
            ),
            12.height,
            if (controller.isFetchingCategories.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    color: appColorPrimary,
                  ),
                ),
              )
            else if (controller.categories.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No categories available',
                  style: secondaryTextStyle(size: 14, color: Colors.grey),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.categories.map((category) {
                  final isSelected =
                      controller.selectedCategoryId.value == category.id;
                  return GestureDetector(
                    onTap: () {
                      controller.selectedCategoryId.value = category.id;
                      controller.selectedCategoryName.value = category.name;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xff232526), Color(0xff414345)],
                              )
                            : null,
                        color: isSelected ? null : Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? appColorPrimary : Colors.grey[700]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (category.icon != null &&
                              category.icon!.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: category.icon!,
                              width: 24,
                              height: 24,
                              errorWidget: (context, url, error) => Icon(
                                Icons.category,
                                size: 24,
                                color:
                                    isSelected ? appColorPrimary : Colors.grey,
                              ),
                            )
                          else
                            Icon(
                              Icons.category,
                              size: 24,
                              color: isSelected ? appColorPrimary : Colors.grey,
                            ),
                          8.width,
                          Text(
                            category.name ?? 'Unknown',
                            style: primaryTextStyle(
                              size: 14,
                              color: Colors.white,
                              weight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
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
    return TextFormField(
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
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tags'),
        16.height,
        Container(
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
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.tagController,
                      style: primaryTextStyle(size: 16, color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Add Tag',
                        hintText: 'Enter tag and press +',
                        labelStyle:
                            secondaryTextStyle(size: 14, color: Colors.white70),
                        hintStyle:
                            secondaryTextStyle(size: 14, color: Colors.grey),
                        prefixIcon:
                            const Icon(Icons.tag, color: appColorPrimary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      onFieldSubmitted: (_) => controller.addTag(),
                    ),
                  ),
                  12.width,
                  IconButton(
                    onPressed: controller.addTag,
                    icon: const Icon(Icons.add_circle, color: appColorPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: appColorPrimary.withOpacity(0.2),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              12.height,
              Obx(
                () => controller.tags.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No tags added yet',
                          style:
                              secondaryTextStyle(size: 14, color: Colors.grey),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          controller.tags.length,
                          (index) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff232526), Color(0xff414345)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: appColorPrimary,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.tags[index],
                                  style: primaryTextStyle(
                                      size: 14, color: Colors.white),
                                ),
                                8.width,
                                GestureDetector(
                                  onTap: () => controller.removeTag(index),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Project Images'),
        16.height,
        Container(
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
                    'Project Images',
                    style: boldTextStyle(size: 16, color: Colors.white),
                  ),
                  TextButton.icon(
                    onPressed: controller.pickProjectImages,
                    icon: const Icon(Icons.add_photo_alternate,
                        color: appColorPrimary, size: 20),
                    label: Text(
                      'Add Images',
                      style: primaryTextStyle(size: 14, color: appColorPrimary),
                    ),
                  ),
                ],
              ),
              12.height,
              Obx(
                () => controller.projectImages.isEmpty
                    ? GestureDetector(
                        onTap: controller.pickProjectImages,
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
                                'Add project images',
                                style: secondaryTextStyle(
                                    size: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: controller.projectImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  controller.projectImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () =>
                                      controller.removeProjectImage(index),
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
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Project Documents (PDF)'),
        16.height,
        Container(
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
                    'Documents',
                    style: boldTextStyle(size: 16, color: Colors.white),
                  ),
                  TextButton.icon(
                    onPressed: controller.pickProjectDocuments,
                    icon: const Icon(Icons.upload_file,
                        color: appColorPrimary, size: 20),
                    label: Text(
                      'Add PDFs',
                      style: primaryTextStyle(size: 14, color: appColorPrimary),
                    ),
                  ),
                ],
              ),
              12.height,
              Obx(
                () => controller.projectDocuments.isEmpty
                    ? GestureDetector(
                        onTap: controller.pickProjectDocuments,
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
                                'Upload PDF documents',
                                style: secondaryTextStyle(
                                    size: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.projectDocuments.length,
                        itemBuilder: (context, index) {
                          final document = controller.projectDocuments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        document.path.split('/').last,
                                        style: primaryTextStyle(
                                            size: 14, color: Colors.white),
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
                                IconButton(
                                  onPressed: () =>
                                      controller.removeProjectDocument(index),
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed:
              controller.isLoading.value ? null : controller.createCampaign,
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
                    const Icon(Icons.campaign, color: Colors.white),
                    12.width,
                    Text(
                      'Create Campaign',
                      style: boldTextStyle(size: 18, color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
