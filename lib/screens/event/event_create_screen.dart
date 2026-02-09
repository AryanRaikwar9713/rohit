import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/event/event_create_controller.dart';

import '../../utils/colors.dart';

class EventCreateScreen extends StatelessWidget {
  const EventCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventCreateController controller = Get.put(EventCreateController());

    return PopScope(
      canPop: !controller.isCreating.value,
      onPopInvoked: (didPop) {
        if (!didPop && controller.isCreating.value) {
          Get.snackbar(
            'Upload in Progress',
            'Please wait for the event to be created',
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
                    controller.isCreating.value ? null : () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),),
          title: Text(
            'Create Event',
            style: boldTextStyle(size: 18, color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isCreating.value) {
            return _buildUploadProgress(controller);
          }
          return _buildEventForm(controller, context);
        }),
      ),
    );
  }

  Widget _buildUploadProgress(EventCreateController controller) {
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
                  value: controller.uploadProgress.value,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(appColorPrimary),
                ),),
          ),
          32.height,
          Obx(() => Text(
                '${(controller.uploadProgress.value * 100).toInt()}%',
                style: boldTextStyle(size: 24, color: Colors.white),
              ),),
          16.height,
          Text(
            'Creating event...',
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

  Widget _buildEventForm(
      EventCreateController controller, BuildContext context,) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          _buildImagePicker(controller),
          20.height,

          // Event Title
          _buildTextField(
            controller: controller.eventTitleController,
            label: 'Event Title *',
            hint: 'Enter event title',
          ),
          16.height,

          // Event Type
          _builDropDown<String?>(
            label: 'Select Event Type',
              items:[
            for(final MapEntry v in controller.eventTypeMap.entries)
              DropdownMenuItem(
                  value:v.key, child: Text(v.value),),
          ], value: controller.selectedEventType.value, onChanged: (d){
            controller.selectedEventType.value = d??'';
          },),
          16.height,

          // Description
          _buildTextField(
            controller: controller.descriptionController,
            label: 'Description *',
            hint: 'Enter event description',
            maxLines: 4,
          ),
          16.height,

          // Start Date
          Row(
            children: [
              //
              Expanded(
                  child: _buildDateTim(
                      context: context,
                      value: controller.startDateController.value,
                      onChanged: (d) {
                        controller.startDateController.value = d;
                      },
                      label: "Start Time",),),
              10.width,

              //
              Expanded(
                child: _buildDateTim(
                    context: context,
                    value: controller.endDateController.value,
                    onChanged: (d) {
                      controller.endDateController.value = d;
                    },
                    label: "End Time",),
              ),
            ],
          ),
          16.height,

          // Result Date
          SizedBox(
            width: double.infinity,
            child: _buildDateTim(
                context: context,
                onChanged: (d) {
                  controller.resultDateController.value = d;
                },
                value: controller.resultDateController.value,
                label: 'Result Date',),
          ),
          16.height,

          // Max Participants
          _buildTextField(
            controller: controller.maxParticipantsController,
            label: 'Max Participants *',
            hint: 'Enter max participants',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // Entry Fee
          _buildTextField(
            controller: controller.entryFeeController,
            label: 'Entry Fee *',
            hint: 'Enter entry fee',
            keyboardType: TextInputType.number,
          ),
          16.height,

          // Is Featured
          _buildIsFeaturedField(controller),
          16.height,

          // Event Rules
          _buildEventRulesSection(controller),
          20.height,

          // Prizes
          _buildPrizesSection(controller),
          32.height,

          // Create Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Create Event',
              color: appColorPrimary,
              textStyle: boldTextStyle(size: 16, color: Colors.white),
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => controller.createEvent(),
            ),
          ),
          32.height,
        ],
      ),
    );
  }

  Widget _buildImagePicker(EventCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Image *',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Obx(() {
          if (controller.coverImage.value != null) {
            return Stack(
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
                      controller.coverImage.value!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      controller.coverImage.value = null;
                    },
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
            );
          }
          return GestureDetector(
            onTap: () => _showImageSourceDialog(controller),
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
                    'Add Cover Image',
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
          );
        }),
      ],
    );
  }

  void _showImageSourceDialog(EventCreateController controller) {
    showModalBottomSheet(
      context: Get.context!,
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
                      controller.pickCoverImage();
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
                      controller.takeCoverPhoto();
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

  Widget _builDropDown<T>(

      {
        required String label,
        required List<DropdownMenuItem<T>> items,
        required T value,
      required Function(T?) onChanged,}) {
    return DropdownButtonFormField<T>(
      style: const TextStyle(color: Colors.white,fontSize: 16),
      decoration: InputDecoration(

        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        label: Text(
          label,
          style: primaryTextStyle(size: 16, color: Colors.white),
        ),
      ),
      initialValue: value,
        items: items, onChanged: onChanged,);
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

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: appColorPrimary,
                      onPrimary: Colors.white,
                      surface: Colors.grey[900]!,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: appColorPrimary,
                        onPrimary: Colors.white,
                        surface: Colors.grey[900]!,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                final DateTime dateTime = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  time.hour,
                  time.minute,
                );
                controller.text =
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
              }
            }
          },
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
                    controller.text.isEmpty ? 'Select $label' : controller.text,
                    style: primaryTextStyle(
                      size: 16,
                      color:
                          controller.text.isEmpty ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTim({
    DateTime? value,
    required String label,
    required BuildContext context,
    required Function(DateTime?) onChanged,
  }) {
    final month = {
      1: 'January',
      2: 'February',
      3: 'March',
      4: 'April',
      5: 'May',
      6: 'June',
      7: 'July',
      8: 'August',
      9: 'September',
      10: 'October',
      11: 'November',
      12: 'December',
    };

    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime(5000),);
        onChanged(d);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,),
              ),
              5.height,
              if (value == null) ...[
                Text(
                  'Select $label',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600,),
                ),
              ] else ...[
                Text(
                  '${value.day} ${month[value.month]}\n${value.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,),
                ),
              ],
            ],
          ),),
    );
  }

  Widget _buildIsFeaturedField(EventCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Is Featured *',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.selectedIsFeatured?.value = '1';
                  controller.update();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: controller.selectedIsFeatured?.value == '1'
                        ? appColorPrimary.withOpacity(0.2)
                        : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.selectedIsFeatured?.value == '1'
                          ? appColorPrimary
                          : Colors.grey[700]!,
                    ),
                  ),
                  child: Text(
                    'Yes',
                    textAlign: TextAlign.center,
                    style: primaryTextStyle(
                      size: 16,
                      color: controller.selectedIsFeatured?.value == '1'
                          ? appColorPrimary
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            16.width,
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.selectedIsFeatured?.value = '0';
                  controller.update();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: controller.selectedIsFeatured?.value == '0'
                        ? appColorPrimary.withOpacity(0.2)
                        : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.selectedIsFeatured?.value == '0'
                          ? appColorPrimary
                          : Colors.grey[700]!,
                    ),
                  ),
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: primaryTextStyle(
                      size: 16,
                      color: controller.selectedIsFeatured?.value == '0'
                          ? appColorPrimary
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventRulesSection(EventCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Rules *',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.eventRuleController,
                style: primaryTextStyle(size: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter event rule',
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
            ),
            8.width,
            AppButton(
              text: 'Add',
              color: appColorPrimary,
              textStyle: boldTextStyle(size: 14, color: Colors.white),
              onTap: () => controller.addEventRule(),
            ),
          ],
        ),
        12.height,
        Obx(() {
          if (controller.eventRules.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Text(
                'No rules added yet',
                style: secondaryTextStyle(size: 14, color: Colors.grey),
              ),
            );
          }
          return Column(
            children: controller.eventRules.asMap().entries.map((entry) {
              final index = entry.key;
              final rule = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        rule,
                        style: primaryTextStyle(size: 14, color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.removeEventRule(index),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPrizesSection(EventCreateController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prizes *',
          style: boldTextStyle(size: 16, color: Colors.white),
        ),
        8.height,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            children: [
              _buildTextField(
                controller: controller.prizePositionController,
                label: 'Position',
                hint: 'e.g., 1, 2, 3',
                keyboardType: TextInputType.number,
              ),
              12.height,
              //Event Type
              _builDropDown(
                label: 'Select Prize Type',
                items: controller.prizeTypeMap.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                value:controller.selectedPrizeType.value,
                onChanged: (value) {
                  controller.selectedPrizeType.value = value;
                },
              ),
              12.height,
              _buildTextField(
                controller: controller.prizeTitleController,
                label: 'Prize Title',
                hint: 'e.g., iPhone 15 Pro',
              ),
              12.height,
              _buildTextField(
                controller: controller.prizeDescriptionController,
                label: 'Prize Description',
                hint: 'Enter prize description',
                maxLines: 2,
              ),
              12.height,
              _buildTextField(
                controller: controller.prizeValueController,
                label: 'Prize Value',
                hint: 'e.g., 999.00',
                keyboardType: TextInputType.number,
              ),
              12.height,
              _buildTextField(
                controller: controller.productIdController,
                label: 'Product ID (if product type)',
                hint: 'Enter product ID',
                keyboardType: TextInputType.number,
              ),
              16.height,
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Add Prize',
                  color: appColorPrimary,
                  textStyle: boldTextStyle(size: 14, color: Colors.white),
                  onTap: () => controller.addPrize(),
                ),
              ),
            ],
          ),
        ),
        12.height,
        Obx(() {
          if (controller.prizes.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Text(
                'No prizes added yet',
                style: secondaryTextStyle(size: 14, color: Colors.grey),
              ),
            );
          }
          return Column(
            children: controller.prizes.asMap().entries.map((entry) {
              final index = entry.key;
              final prize = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Position: ${prize['position']} - ${prize['prize_title']}',
                            style: boldTextStyle(size: 14, color: Colors.white),
                          ),
                          4.height,
                          Text(
                            'Type: ${prize['prize_type']} | Value: ${prize['prize_value']}',
                            style: secondaryTextStyle(
                                size: 12, color: Colors.grey,),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.removePrize(index),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
