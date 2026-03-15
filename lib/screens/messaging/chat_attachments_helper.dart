import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

/// Result of picking an attachment to send in chat.
class ChatAttachmentResult {
  final String type; // image, video, audio, file
  final List<int> fileBytes;
  final String fileName;
  final String? body; // caption or label

  ChatAttachmentResult({
    required this.type,
    required this.fileBytes,
    required this.fileName,
    this.body,
  });
}

/// Picks image from gallery. Returns null if cancelled or error.
Future<ChatAttachmentResult?> pickImageFromGallery() async {
  try {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null) return null;
    final bytes = await xFile.readAsBytes();
    final name = xFile.name.isNotEmpty ? xFile.name : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return ChatAttachmentResult(type: 'image', fileBytes: bytes, fileName: name);
  } catch (e) {
    toast('Failed to pick image: $e');
    return null;
  }
}

/// Takes photo from camera.
Future<ChatAttachmentResult?> pickImageFromCamera() async {
  try {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (xFile == null) return null;
    final bytes = await xFile.readAsBytes();
    final name = xFile.name.isNotEmpty ? xFile.name : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return ChatAttachmentResult(type: 'image', fileBytes: bytes, fileName: name);
  } catch (e) {
    toast('Failed to take photo: $e');
    return null;
  }
}

/// Picks video from gallery or camera. [fromCamera] = true for camera.
Future<ChatAttachmentResult?> pickVideo({bool fromCamera = false}) async {
  try {
    final picker = ImagePicker();
    final xFile = await picker.pickVideo(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (xFile == null) return null;
    final bytes = await xFile.readAsBytes();
    final name = xFile.name.isNotEmpty ? xFile.name : 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    return ChatAttachmentResult(type: 'video', fileBytes: bytes, fileName: name);
  } catch (e) {
    toast('Failed to pick video: $e');
    return null;
  }
}

/// Picks document or audio file (file_picker).
/// Allowed: pdf, doc, docx, txt, zip, m4a, mp3, etc.
Future<ChatAttachmentResult?> pickDocumentOrAudio() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'zip', 'm4a', 'mp3', 'wav', 'aac'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    final name = file.name;
    if (bytes == null || name.isEmpty) {
      toast('Could not read file');
      return null;
    }
    final ext = name.split('.').last.toLowerCase();
    final isAudio = ['m4a', 'mp3', 'wav', 'aac'].contains(ext);
    return ChatAttachmentResult(
      type: isAudio ? 'audio' : 'file',
      fileBytes: bytes,
      fileName: name,
    );
  } catch (e) {
    toast('Failed to pick file: $e');
    return null;
  }
}

/// Gets current location and returns a text body to send (maps link).
/// Sends as normal text message; no backend "location" type.
Future<String?> getLocationText() async {
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      toast('Please enable location services');
      return null;
    }
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested != LocationPermission.whileInUse && requested != LocationPermission.always) {
        toast('Location permission denied');
        return null;
      }
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    final lat = pos.latitude;
    final lng = pos.longitude;
    return '📍 Location: https://www.google.com/maps?q=$lat,$lng';
  } catch (e) {
    toast('Failed to get location: $e');
    return null;
  }
}
