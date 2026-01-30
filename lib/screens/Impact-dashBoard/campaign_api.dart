import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/campain_cat_responce_model.dart';
import 'package:streamit_laravel/screens/social/social_api.dart';

class MyCampaignApi {
  // Get Categories
  Future<void> getCategories({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(CampainCategoryResponce) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      UserData? userId = await DB().getUser();

      String url =
          'https://app.wamims.world/public/social/impact/submit_project_fixed.php?action=get_categories';

      Logger().i('Fetching Campaign Categories for user: ${userId?.id}');

      final response = await http.post(
        Uri.parse(url),
        headers: head,
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          onSuccess(CampainCategoryResponce.fromJson(data));
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

  // Create Campaign
  Future<void> createCampaign({
    required int categoryId,
    required String title,
    required String description,
    required String story,
    required double fundingGoal,
    required int durationDays,
    required String location,
    required String latitude,
    required String longitude,
    required List<String> tags,
    List<File>? projectImages,
    List<File>? projectDocuments,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      UserData? userId = await DB().getUser();

      String url =
          'https://app.wamims.world/public/social/impact/submit_project_fixed.php';

      Logger().i('Creating Campaign for user: ${userId?.id}');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll(head);

      // Add form fields
      request.fields['user_id'] = (userId?.id ?? 0).toString();
      request.fields['category_id'] = categoryId.toString();
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['story'] = story;
      request.fields['funding_goal'] = fundingGoal.toString();
      request.fields['duration_days'] = durationDays.toString();
      request.fields['location'] = location;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;

      // Add tags
      for (int i = 0; i < tags.length; i++) {
        request.fields['tags[$i]'] = tags[i];
      }

      // Add project images
      if (projectImages != null && projectImages.isNotEmpty) {
        for (int i = 0; i < projectImages.length; i++) {
          var image = projectImages[i];
          if (image.existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'project_images[$i]',
                image.path,
              ),
            );
            Logger().i('Added project_image[$i]: ${image.path}');
          }
        }
      }

      // Add project documents
      if (projectDocuments != null && projectDocuments.isNotEmpty) {
        for (int i = 0; i < projectDocuments.length; i++) {
          var document = projectDocuments[i];
          if (document.existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'project_documents[$i]',
                document.path,
              ),
            );
            Logger().i('Added project_document[$i]: ${document.path}');
          }
        }
      }

      Logger().i(request.fields);
      Logger().i('Request files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          onSuccess(data);
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

  Future<void> getImpactProjects(
      {required int page,
      required Null Function(dynamic data) onSuccess,
      required Null Function(dynamic error) onError}) async {}
}
