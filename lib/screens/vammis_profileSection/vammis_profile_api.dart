import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';
import 'package:streamit_laravel/screens/reels/reel_response_model.dart';
import 'package:streamit_laravel/screens/social/social_post_responce_Model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/models/vammis_profile_model.dart';

void respPrinter(int st, String body) {
  if (st == 200 || st == 201) {
    Logger().i(jsonDecode(body));
  } else {
    Logger().e('$st\n$body');
  }
}

class VammisProfileApi {
  /// Get User Profile by User ID
  Future<void> getUserProfile({
    required int userId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(VammisProfileResponceModel) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();

      final String url =
          'https://app.wamims.world/public/social/wamims_profile.php?user_id=$userId';

      Logger().i('Getting Vammis Profile for user: $userId');

      final response = await http.get(
        Uri.parse(url),
        headers: head ?? {},
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          onSuccess(VammisProfileResponceModel.fromJson(data));
        } catch (e) {
          Logger().e('Error parsing profile response: $e');
          onError("Response parsing failed: $e");
        }
      } else {
        onFailure(response);
      }
    } catch (e) {
      Logger().e('Error getting profile: $e');
      onError("Request failed: $e");
    }
  }

  /// Get User Posts
  Future<void> getUserPost({
    required int userId,
    required int page,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(GetSocialPostResponceModel) onSuccess,
  }) async {
    try {
      // String uri = 'https://app.wamims.world/api/posts/feed?offset=$page';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final String uri =
          'https://app.wamims.world/social/get_posts.php?logged_in_user_id=${user?.id ?? ''}&user_id=$userId&page=$page';

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final s = GetSocialPostResponceModel.fromJson(d);
        onSuccess(s);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Get User Reels
  Future<void> getUserReels({
    required int userId,
    required int page,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(GetReelsResponceModel) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();

      final user = await DB().getUser();

      final String uri =
          'https://app.wamims.world/public/social/reels/get_reels.php?user_id=${user?.id ?? ''}&profile_user_id=$userId&page=$page&limit=10';

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final s = GetReelsResponceModel.fromJson(d);
        onSuccess(s);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Follow/Unfollow User
  Future<void> followUser({
    required int targetUserId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(bool isFollowing) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      final UserData? currentUser = await DB().getUser();

      final String url = 'https://app.wamims.world/public/social/follow_api.php';

      final response = await http.post(
        Uri.parse(url),
        headers: head ?? {},
        body: jsonEncode({
          "current_user_id": currentUser?.id ?? 0,
          "target_user_id": targetUserId,
        }),
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200) {
        try {
          final d = jsonDecode(response.body);
          if (d['is_following'] != null) {
            onSuccess(
              d['is_following'] ?? false,
            );
          } else {
            onError("Invalid response format");
          }
        } catch (e) {
          onError("Response parsing failed: $e");
        }
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError("Request failed: $e");
    }
  }

  /// Update User Profile
  Future<void> updateProfile({
    required int userId,
    required String username,
    required String bio,
    String? fileUrl,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
  }) async

  {
    try {
      final head = await DB().getHeaderForRow();

      final String url = 'https://app.wamims.world/public/social/wamims_profile.php';

      // If no file_url is provided, use a static string
      final fileUrlToSend = fileUrl ?? 'default_avatar.jpg';

      final requestBody = {
        'user_id': userId,
        'username': username,
        'bio': bio,
        'file_url': fileUrlToSend,
      };

      Logger().i('Updating Vammis Profile for user: $userId');
      Logger().i('Request body: $requestBody');

      final response = await http.put(
        Uri.parse(url),
        headers: head ?? {},
        body: jsonEncode(requestBody),
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          onSuccess(data);
        } catch (e) {
          Logger().e('Error parsing update profile response: $e');
          onError("Response parsing failed: $e");
        }
      } else {
        onFailure(response);
      }
    } catch (e) {
      Logger().e('Error updating profile: $e');
      onError("Request failed: $e");
    }
  }


  //Change Profile Image
  Future<void> changeProfileImage({
    required String image,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
  }) async {
    try {
      final String uri = 'https://app.wamims.world/public/social/wamims_profile.php';

      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final request = http.MultipartRequest('POST', Uri.parse(uri));

      request.headers.addAll(head ?? {});

      // 🔥 Important Part
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar', // <- API field name
          image,   // <- image file path
        ),
      );

      request.fields['user_id'] = user?.id.toString()??'';

      // Send request
      final response = await request.send();
      final body = await http.Response.fromStream(response);

      if (body.statusCode == 200) {
        final json = jsonDecode(body.body);
        onSuccess(json);
      } else {
        onFailure(body);
      }
    } catch (e) {
      onError(e.toString());
    }
  }


  /// Get User Projects
  Future<void> getUserProjects({
    required int userId,
    required int page,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(GetProjectListResponcModel) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();

      final String uri =
          'https://app.wamims.world/public/social/impact/get_projects.php?user_id=$userId&page=$page&limit=10';

      Logger().i('Getting User Projects for user: $userId, page: $page');

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final s = GetProjectListResponcModel.fromJson(d);
        onSuccess(s);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
