import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/shops_section/shop_controller.dart';

import '../../utils/colors.dart';

class ShopRegistrationScreen extends StatefulWidget {
  const ShopRegistrationScreen({super.key});

  @override
  State<ShopRegistrationScreen> createState() => _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState extends State<ShopRegistrationScreen> {
  final ShopController _controller = Get.put(ShopController());
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  File? _logoImage;
  File? _coverImage;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _controller.onRegistrationScreen.value = true;
    // Load categories when screen opens
    _controller.loadShopCategories();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressLine1Controller.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _websiteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _controller.onRegistrationScreen.value = false;
    super.dispose();
  }

  Future<void> _pickLogoImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _logoImage = File(image.path);
        });
      }
    } catch (e) {
      toast('Error picking logo: $e');
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
        });
      }
    } catch (e) {
      toast('Error picking cover image: $e');
    }
  }

  Future<void> _takeLogoPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _logoImage = File(image.path);
        });
      }
    } catch (e) {
      toast('Error taking logo photo: $e');
    }
  }

  Future<void> _takeCoverPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
        });
      }
    } catch (e) {
      toast('Error taking cover photo: $e');
    }
  }

  void _showImageSourceDialog({required bool isLogo}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            20.height,
            Text(
              'Select Image Source',
              style: boldTextStyle(size: 18, color: Colors.white),
            ),
            20.height,
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      if (isLogo) {
                        _pickLogoImage();
                      } else {
                        _pickCoverImage();
                      }
                    },
                  ),
                ),
                16.width,
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      if (isLogo) {
                        _takeLogoPhoto();
                      } else {
                        _takeCoverPhoto();
                      }
                    },
                  ),
                ),
              ],
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: appColorPrimary, size: 32),
            8.height,
            Text(
              title,
              style: primaryTextStyle(size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            20.height,
            Text(
              'Select Category',
              style: boldTextStyle(size: 18, color: Colors.white),
            ),
            20.height,
            Obx(() {
              if (_controller.isLoadingCategories.value) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: appColorPrimary),
                  ),
                );
              }

              if (_controller.categories.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.category_outlined,
                            size: 50, color: Colors.grey,),
                        16.height,
                        Text(
                          'No categories available',
                          style: primaryTextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: _controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = _controller.categories[index];
                    return ListTile(
                      title: Text(
                        category.name ?? '',
                        style: primaryTextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.id;
                          _categoryController.text = category.name ?? '';
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _registerShop() {
    if (_shopNameController.text.trim().isEmpty) {
      toast('Please enter shop name');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      toast('Please enter description');
      return;
    }
    if (_selectedCategoryId == null) {
      toast('Please select a category');
      return;
    }
    if (_cityController.text.trim().isEmpty) {
      toast('Please enter city');
      return;
    }
    if (_countryController.text.trim().isEmpty) {
      toast('Please enter country');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      toast('Please enter phone number');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      toast('Please enter email');
      return;
    }
    if (_addressLine1Controller.text.trim().isEmpty) {
      toast('Please enter address');
      return;
    }
    if (_stateController.text.trim().isEmpty) {
      toast('Please enter state');
      return;
    }
    if (_postalCodeController.text.trim().isEmpty) {
      toast('Please enter postal code');
      return;
    }

    _controller.registerShop(
      shopName: _shopNameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      website: _websiteController.text.trim().isNotEmpty
          ? _websiteController.text.trim()
          : null,
      latitude: _latitudeController.text.trim().isNotEmpty
          ? _latitudeController.text.trim()
          : null,
      longitude: _longitudeController.text.trim().isNotEmpty
          ? _longitudeController.text.trim()
          : null,
      logoPath: _logoImage?.path,
      coverImagePath: _coverImage?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_controller.isRegistering.value,
      onPopInvoked: (didPop) {
        if (!didPop && _controller.isRegistering.value) {
          Get.snackbar(
            'Upload in Progress',
            'Please wait for the registration to complete',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      },
      child: Scaffold(
        backgroundColor: appScreenBackgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          leading: Obx(() => IconButton(
                onPressed:
                    _controller.isRegistering.value ? null : () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),),
          title: Text(
            'Register Shop',
            style: boldTextStyle(size: 18, color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (_controller.isRegistering.value) {
            return _buildUploadProgress();
          }
          return _buildRegistrationForm();
        }),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: appColorPrimary, width: 3),
            ),
            child: Obx(() => CircularProgressIndicator(
                  value: _controller.uploadProgress.value,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(appColorPrimary),
                ),),
          ),
          32.height,
          Obx(() => Text(
                '${(_controller.uploadProgress.value * 100).toInt()}%',
                style: boldTextStyle(size: 24, color: Colors.white),
              ),),
          16.height,
          Text(
            'Registering your shop...',
            style: primaryTextStyle(size: 16, color: Colors.white),
          ),
          8.height,
          Text(
            "Please don't close the app",
            style: secondaryTextStyle(size: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Image
          _buildImagePicker(
            title: 'Shop Logo',
            image: _logoImage,
            onTap: () => _showImageSourceDialog(isLogo: true),
            onRemove: () {
              setState(() {
                _logoImage = null;
              });
            },
          ),
          20.height,

          // Cover Image
          _buildImagePicker(
            title: 'Cover Image',
            image: _coverImage,
            onTap: () => _showImageSourceDialog(isLogo: false),
            onRemove: () {
              setState(() {
                _coverImage = null;
              });
            },
          ),
          20.height,

          // Shop Name
          _buildTextField(
            controller: _shopNameController,
            label: 'Shop Name *',
            hint: 'Enter shop name',
          ),
          16.height,

          // Description
          _buildTextField(
            controller: _descriptionController,
            label: 'Description *',
            hint: 'Enter shop description',
            maxLines: 4,
          ),
          16.height,

          // Category
          _buildCategoryField(),
          16.height,

          // City
          _buildTextField(
            controller: _cityController,
            label: 'City *',
            hint: 'Enter city',
          ),
          16.height,

          // Country
          _buildTextField(
            controller: _countryController,
            label: 'Country *',
            hint: 'Enter country',
          ),
          16.height,

          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'Phone *',
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
          ),
          16.height,

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email *',
            hint: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
          ),
          16.height,

          // Address Line 1
          _buildTextField(
            controller: _addressLine1Controller,
            label: 'Address Line 1 *',
            hint: 'Enter address',
            maxLines: 2,
          ),
          16.height,

          // State
          _buildTextField(
            controller: _stateController,
            label: 'State *',
            hint: 'Enter state',
          ),
          16.height,

          // Postal Code
          _buildTextField(
            controller: _postalCodeController,
            label: 'Postal Code *',
            hint: 'Enter postal code',
          ),
          16.height,

          // Website (Optional)
          _buildTextField(
            controller: _websiteController,
            label: 'Website (Optional)',
            hint: 'Enter website URL',
            keyboardType: TextInputType.url,
          ),
          16.height,

          // Latitude (Optional)
          _buildTextField(
            controller: _latitudeController,
            label: 'Latitude (Optional)',
            hint: 'Enter latitude',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // Longitude (Optional)
          _buildTextField(
            controller: _longitudeController,
            label: 'Longitude (Optional)',
            hint: 'Enter longitude',
            keyboardType: TextInputType.number,
          ),
          32.height,

          // Register Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Register Shop',
              color: appColorPrimary,
              textStyle: boldTextStyle(size: 16, color: Colors.white),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: _registerShop,
            ),
          ),
          32.height,
        ],
      ),
    );
  }

  Widget _buildImagePicker({
    required String title,
    required File? image,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        if (image != null)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: appColorPrimary,
                    size: 48,
                  ),
                  12.height,
                  Text(
                    'Add $title',
                    style: boldTextStyle(size: 16, color: appColorPrimary),
                  ),
                  4.height,
                  Text(
                    'Tap to select from gallery or camera',
                    style: secondaryTextStyle(size: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: primaryTextStyle(size: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: secondaryTextStyle(size: 14, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: appColorPrimary),
            ),
            filled: true,
            fillColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _categoryController.text.isEmpty
                        ? 'Select category'
                        : _categoryController.text,
                    style: primaryTextStyle(
                      size: 16,
                      color: _categoryController.text.isEmpty
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
