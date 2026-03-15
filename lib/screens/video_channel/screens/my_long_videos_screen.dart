import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/video_channel/long_video_api.dart';
import 'package:streamit_laravel/screens/video_channel/modals/long_video_model.dart';
import 'package:streamit_laravel/utils/colors.dart';

class MyLongVideosController extends GetxController {
  final LongVideoApi api = LongVideoApi();
  final RxList<LongVideoItem> videos = <LongVideoItem>[].obs;
  final RxBool loading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVideos();
  }

  Future<void> loadVideos() async {
    loading.value = true;
    error.value = '';
    await api.listMyVideos(
      onSuccess: (list) {
        videos.assignAll(list);
        loading.value = false;
      },
      onError: (e) {
        error.value = e;
        videos.clear();
        loading.value = false;
      },
      onFail: (_) {
        videos.clear();
        loading.value = false;
      },
    );
  }

  Future<void> pickAndUploadVideo() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    Get.dialog(
      _UploadDialog(videoPath: file.path),
      barrierDismissible: false,
    );
  }

  void deleteVideo(LongVideoItem video, VoidCallback onDeleted) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Delete video?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${video.title}"? This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () async {
              Get.back();
              await api.deleteVideo(
                videoId: video.id,
                onSuccess: () {
                  toast('Video deleted');
                  videos.removeWhere((e) => e.id == video.id);
                  onDeleted();
                },
                onError: (e) => toast(e),
                onFail: (_) => toast('Failed to delete'),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _UploadDialog extends StatefulWidget {
  final String videoPath;

  const _UploadDialog({required this.videoPath});

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _thumbnailPath;
  bool _uploading = false;

  Future<void> _pickThumbnail() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
      if (file != null && mounted) {
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) setState(() => _thumbnailPath = file.path);
      }
    } catch (e) {
      if (mounted) toast('Could not pick image: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: const Text('Upload long video', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            12.height,
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            12.height,
            Row(
              children: [
                Text('Thumbnail (optional)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _uploading ? null : _pickThumbnail,
                  icon: Icon(Icons.image, size: 18, color: _thumbnailPath != null ? appColorPrimary : Colors.white70),
                  label: Text(_thumbnailPath != null ? 'Selected ✓' : 'Pick image', style: TextStyle(color: _thumbnailPath != null ? appColorPrimary : Colors.white70, fontSize: 12)),
                ),
              ],
            ),
            if (_thumbnailPath != null) ...[8.height, Text('Thumbnail added. Upload to continue.', style: TextStyle(color: Colors.white54, fontSize: 11))],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _uploading ? null : () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
        TextButton(
          onPressed: _uploading
              ? null
              : () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) {
                    toast('Enter a title');
                    return;
                  }
                  setState(() => _uploading = true);
                  final controller = Get.find<MyLongVideosController>();
                  await controller.api.uploadVideo(
                    filePath: widget.videoPath,
                    title: title,
                    description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                    thumbnailPath: _thumbnailPath,
                    onSuccess: () {
                      Get.back();
                      toast('Uploaded');
                      controller.loadVideos();
                    },
                    onError: (e) {
                      setState(() => _uploading = false);
                      toast(e);
                    },
                    onFail: (_) {
                      setState(() => _uploading = false);
                      toast('Upload failed');
                    },
                  );
                },
          child: _uploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Upload', style: TextStyle(color: appColorPrimary)),
        ),
      ],
    );
  }
}

class MyLongVideosScreen extends StatelessWidget {
  const MyLongVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyLongVideosController());
    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        title: const Text('My long videos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: appScreenBackgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.loading.value && controller.videos.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.white54));
        }
        if (controller.videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library_outlined, size: 64, color: Colors.white.withOpacity(0.4)),
                16.height,
                Text('No long videos yet', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18)),
                8.height,
                Text('Upload full-length videos from the + button below', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadVideos,
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.videos.length,
            itemBuilder: (context, index) {
              final v = controller.videos[index];
              return Card(
                color: Colors.white.withOpacity(0.06),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: v.thumbnailUrl != null && v.thumbnailUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(v.thumbnailUrl!, width: 72, height: 48, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 72,
                          height: 48,
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.videocam, color: Colors.white38),
                        ),
                  title: Text(v.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: v.description != null && v.description!.isNotEmpty
                      ? Text(v.description!, style: TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)
                      : null,
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    color: Colors.grey.shade900,
                    onSelected: (value) {
                      if (value == 'edit') {
                        toast('Edit screen: use update API when ready');
                      } else if (value == 'delete') {
                        controller.deleteVideo(v, () {});
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                  onTap: () {
                    if (v.videoUrl != null && v.videoUrl!.isNotEmpty) {
                      // Could open video player here
                      toast('Play: ${v.title}');
                    } else {
                      toast('Video URL not available');
                    }
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.pickAndUploadVideo,
        backgroundColor: appColorPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
