import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/shops_section/product_create_controller.dart';

import '../../utils/colors.dart';

class ProductCreateScreen extends StatefulWidget {
  final int shopId;

  const ProductCreateScreen({super.key, required this.shopId});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final ProductCreateController _controller =
      Get.put(ProductCreateController());
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _comparePriceController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _pointPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  File? _featuredImage;
  final List<File> _imageGallery = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _controller.onCreateScreen.value = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _costPriceController.dispose();
    _pointPriceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _weightController.dispose();
    _controller.onCreateScreen.value = false;
    super.dispose();
  }

  Future<void> _pickFeaturedImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _featuredImage = File(image.path);
        });
      }
    } catch (e) {
      toast('Error picking image: $e');
    }
  }

  Future<void> _takeFeaturedPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _featuredImage = File(image.path);
        });
      }
    } catch (e) {
      toast('Error taking photo: $e');
    }
  }

  Future<void> _pickGalleryImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageGallery.add(File(image.path));
        });
      }
    } catch (e) {
      toast('Error picking image: $e');
    }
  }

  void _showImageSourceDialog({required bool isFeatured}) {
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
                      if (isFeatured) {
                        _pickFeaturedImage();
                      } else {
                        _pickGalleryImage();
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
                      if (isFeatured) {
                        _takeFeaturedPhoto();
                      } else {
                        _pickGalleryImage();
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

              if (_controller.productCategories.isEmpty) {
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
                  itemCount: _controller.productCategories.length,
                  itemBuilder: (context, index) {
                    final category = _controller.productCategories[index];
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

  void _createProduct() {
    if (_nameController.text.trim().isEmpty) {
      toast('Please enter product name');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      toast('Please enter description');
      return;
    }
    if (_shortDescriptionController.text.trim().isEmpty) {
      toast('Please enter short description');
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      toast('Please enter price');
      return;
    }
    if (_comparePriceController.text.trim().isEmpty) {
      toast('Please enter compare price');
      return;
    }
    if (_costPriceController.text.trim().isEmpty) {
      toast('Please enter cost price');
      return;
    }
    if(_pointPriceController.text.trim().isEmpty)
      {
        toast("Please enter Point Price");
        return;
      }
    if (_quantityController.text.trim().isEmpty) {
      toast('Please enter quantity');
      return;
    }
    if (_selectedCategoryId == null) {
      toast('Please select a category');
      return;
    }
    if (_skuController.text.trim().isEmpty) {
      toast('Please enter SKU');
      return;
    }
    if (_barcodeController.text.trim().isEmpty) {
      toast('Please enter barcode');
      return;
    }

    _controller.createProduct(
      shopId: widget.shopId,
      pointPrice: _pointPriceController.text.trim(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      shortDescription: _shortDescriptionController.text.trim(),
      price: _priceController.text.trim(),
      comparePrice: _comparePriceController.text.trim(),
      costPrice: _costPriceController.text.trim(),
      quantity: _quantityController.text.trim(),
      categoryId: _selectedCategoryId!,
      sku: _skuController.text.trim(),
      barcode: _barcodeController.text.trim(),
      weight: _weightController.text.trim().isNotEmpty
          ? _weightController.text.trim()
          : null,
      featuredImage: _featuredImage,
      imageGallery: _imageGallery.isNotEmpty ? _imageGallery : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_controller.isCreating.value,
      onPopInvoked: (didPop) {
        if (!didPop && _controller.isCreating.value) {
          Get.snackbar(
            'Upload in Progress',
            'Please wait for the product to be created',
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
                    _controller.isCreating.value ? null : () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),),
          title: Text(
            'Create Product',
            style: boldTextStyle(size: 18, color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (_controller.isCreating.value) {
            return _buildUploadProgress();
          }
          return _buildProductForm();
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
            'Creating product...',
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

  Widget _buildProductForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Image
          _buildImagePicker(
            title: 'Featured Image',
            image: _featuredImage,
            onTap: () => _showImageSourceDialog(isFeatured: true),
            onRemove: () {
              setState(() {
                _featuredImage = null;
              });
            },
          ),
          20.height,

          // Gallery Images
          _buildGalleryImages(),
          20.height,

          // Product Name
          _buildTextField(
            controller: _nameController,
            label: 'Product Name *',
            hint: 'Enter product name',
          ),
          16.height,

          // Short Description
          _buildTextField(
            controller: _shortDescriptionController,
            label: 'Short Description *',
            hint: 'Enter short description',
            maxLines: 2,
          ),
          16.height,

          // Description
          _buildTextField(
            controller: _descriptionController,
            label: 'Description *',
            hint: 'Enter product description',
            maxLines: 4,
          ),
          16.height,

          // Category
          _buildCategoryField(),
          16.height,

          // Price
          _buildTextField(
            controller: _priceController,
            label: 'Price *',
            hint: 'Enter price',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // Compare Price
          _buildTextField(
            controller: _comparePriceController,
            label: 'Compare Price *',
            hint: 'Enter compare price',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // Cost Price
          _buildTextField(
            controller: _costPriceController,
            label: 'Cost Price *',
            hint: 'Enter cost price',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // Point Price
          _buildTextField(
            controller: _pointPriceController,
            label: 'Point Price *',
            hint: 'Enter point price',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // Quantity
          _buildTextField(
            controller: _quantityController,
            label: 'Quantity *',
            hint: 'Enter quantity',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // SKU
          _buildTextField(
            controller: _skuController,
            label: 'SKU *',
            hint: 'Enter SKU',
          ),
          16.height,

          // Barcode
          _buildTextField(
            controller: _barcodeController,
            label: 'Barcode *',
            hint: 'Enter barcode',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // Weight (Optional)
          _buildTextField(
            controller: _weightController,
            label: 'Weight (Optional)',
            hint: 'Enter weight',
            keyboardType: TextInputType.number,
          ),
          32.height,

          // Create Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Create Product',
              color: appColorPrimary,
              textStyle: boldTextStyle(size: 16, color: Colors.white),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: _createProduct,
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

  Widget _buildGalleryImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gallery Images',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._imageGallery.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
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
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _imageGallery.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: () => _showImageSourceDialog(isFeatured: false),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[700]!,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: appColorPrimary,
                  size: 32,
                ),
              ),
            ),
          ],
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
