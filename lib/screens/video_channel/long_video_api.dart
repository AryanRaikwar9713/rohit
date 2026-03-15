import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';
import 'package:streamit_laravel/screens/video_channel/modals/long_video_model.dart';

/// API for long-form videos (upload, list, edit, delete).
/// Backend: see docs/BACKEND_COMPLETE_SPEC.txt section 4.
const String _baseUrl = 'https://wamims.international/public/social/long_video_api.php';

class LongVideoApi {
  /// List public user-uploaded long videos for Long page. Pagination: page (1-based), limit per page.
  /// Backend: long_video_api.php?action=list_public with post body page=&limit= (or query params).
  /// Returns videos + hasMore (true if more pages exist).
  Future<LongVideoListResult> listPublicLongVideos({int page = 1, int limit = 10}) async {
    try {
      final head = await DB().getHeaderForForm();
      final response = await http.post(
        Uri.parse('$_baseUrl?action=list_public&page=$page&limit=$limit'),
        headers: head ?? {},
      );
      respPrinter(response.statusCode, response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final d = jsonDecode(response.body) as Map<String, dynamic>;
          final list = d['videos'] is List
              ? (d['videos'] as List).map((e) => LongVideoItem.fromJson(Map<String, dynamic>.from(e as Map))).toList()
              : <LongVideoItem>[];
          final hasMore = d['has_more'] == true || (list.length >= limit && list.isNotEmpty);
          return LongVideoListResult(videos: list, hasMore: hasMore);
        } catch (_) {
          return LongVideoListResult(videos: <LongVideoItem>[], hasMore: false);
        }
      }
      return LongVideoListResult(videos: <LongVideoItem>[], hasMore: false);
    } catch (e) {
      Logger().e('LongVideoApi listPublicLongVideos: $e');
      return LongVideoListResult(videos: <LongVideoItem>[], hasMore: false);
    }
  }

  Future<void> listMyVideos({
    required void Function(List<LongVideoItem>) onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {
      final head = await DB().getHeaderForForm();
      final response = await http.post(
        Uri.parse('$_baseUrl?action=list_my_videos'),
        headers: head ?? {},
      );
      respPrinter(response.statusCode, response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final d = jsonDecode(response.body) as Map<String, dynamic>;
          final list = d['videos'] is List
              ? (d['videos'] as List).map((e) => LongVideoItem.fromJson(Map<String, dynamic>.from(e as Map))).toList()
              : <LongVideoItem>[];
          onSuccess(list);
        } catch (_) {
          onSuccess(<LongVideoItem>[]);
        }
      } else {
        onFail(response);
      }
    } catch (e) {
      onError(e.toString());
      Logger().e('LongVideoApi listMyVideos: $e');
    }
  }

  Future<void> uploadVideo({
    required String filePath,
    required String title,
    String? description,
    String? thumbnailPath,
    required void Function() onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {
      final head = await DB().getHeaderForForm();
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl?action=upload'));
      request.headers.addAll(head ?? {});
      request.fields['title'] = title;
      if (description != null && description.isNotEmpty) request.fields['description'] = description;
      request.files.add(await http.MultipartFile.fromPath('video', filePath));
      if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('thumbnail', thumbnailPath));
      }
      final response = await request.send();
      final res = await response.stream.bytesToString();
      respPrinter(response.statusCode, res);
      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess();
      } else {
        onFail(http.Response(res, response.statusCode));
      }
    } catch (e) {
      onError(e.toString());
      Logger().e('LongVideoApi uploadVideo: $e');
    }
  }

  Future<void> updateVideo({
    required int videoId,
    String? title,
    String? description,
    String? thumbnailPath,
    required void Function() onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {
      final head = await DB().getHeaderForForm();
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl?action=update'));
      request.headers.addAll(head ?? {});
      request.fields['video_id'] = videoId.toString();
      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('thumbnail', thumbnailPath));
      }
      final response = await request.send();
      final res = await response.stream.bytesToString();
      respPrinter(response.statusCode, res);
      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess();
      } else {
        onFail(http.Response(res, response.statusCode));
      }
    } catch (e) {
      onError(e.toString());
      Logger().e('LongVideoApi updateVideo: $e');
    }
  }

  Future<void> deleteVideo({
    required int videoId,
    required void Function() onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {
      final head = await DB().getHeaderForForm();
      final response = await http.post(
        Uri.parse('$_baseUrl?action=delete'),
        headers: head ?? {},
        body: {'video_id': videoId.toString()},
      );
      respPrinter(response.statusCode, response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess();
      } else {
        onFail(response);
      }
    } catch (e) {
      onError(e.toString());
      Logger().e('LongVideoApi deleteVideo: $e');
    }
  }
}
