import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/use_campai_limit_responce.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/profileresponcemodel.dart';
import 'package:streamit_laravel/screens/social/social_api.dart';

class ImpactProfileApi {
  Future<void> createImpactProfile({
    required String accountType,
    required String title,
    required String description,
    required String fundingPurpose,
    required String fullName,
    required String email,
    required String phone,
    required String addressLine1,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    required String latitude,
    required String longitude,
    File? profileImage,
    File? coverImage,
    List<File>? supportingImages,
    File? organizationProof,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      final UserData? userId = await DB().getUser();

      final String url =
          'https://app.wamims.world/public/social/impact/create_crowdfunding_account.php';

      Logger().i('Creating Impact Profile for user: ${userId?.id}');

      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll(head ?? {});

      // Add form fields
      request.fields['user_id'] = (userId?.id ?? 0).toString();
      request.fields['account_type'] = accountType;
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['funding_purpose'] = fundingPurpose;
      request.fields['full_name'] = fullName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['address_line_1'] = addressLine1;
      request.fields['city'] = city;
      request.fields['state'] = state;
      request.fields['country'] = country;
      request.fields['postal_code'] = postalCode;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;

      // Add profile image
      if (profileImage != null && profileImage.existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            profileImage.path,
          ),
        );
        Logger().i('Added profile_image: ${profileImage.path}');
      }

      // Add cover image
      if (coverImage != null && coverImage.existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'cover_image',
            coverImage.path,
          ),
        );
        Logger().i('Added cover_image: ${coverImage.path}');
      }

      // Add supporting images
      if (supportingImages != null && supportingImages.isNotEmpty) {
        for (int i = 0; i < supportingImages.length; i++) {
          final image = supportingImages[i];
          if (image.existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'supporting_images[$i]',
                image.path,
              ),
            );
            Logger().i('Added supporting_image: ${image.path}');
          }
        }
      }

      // Add organization proof (only for organization type)
      if (accountType == 'organization' &&
          organizationProof != null &&
          organizationProof.existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'organization_proof',
            organizationProof.path,
          ),
        );
        Logger().i('Added organization_proof: ${organizationProof.path}');
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

  // Check if user has impact account
  Future<void> checkImpactAccount({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(ImpactProfileResponce) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      final UserData? userId = await DB().getUser();

      final String url =
          'https://app.wamims.world/public/social/impact/check_account.php?user_id=${userId?.id ?? 0}';

      Logger().i('Checking Impact Account for user: ${userId?.id}');

      final response = await http.get(
        Uri.parse(url),
        headers: head ?? {},
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          onSuccess(ImpactProfileResponce.fromJson(data));
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


  Future<void> chekUserCampainLimit({
    required void Function(UserCampainLimitResponcModel data) onSuccess,
    required void Function(String error) onError,
  }) async {
    const String url =
        "https://app.wamims.world/public/social/impact/submit_project_fixed.php?action=get_limits";

    try {
      final head = await DB().getHeaderForRow();
      final UserData? userId = await DB().getUser();


      final response = await http.post(Uri.parse(url),headers: head ?? {},body: jsonEncode({
        "user_id": userId?.id ?? 0,
      }),);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        onSuccess(UserCampainLimitResponcModel.fromJson(data));
      } else {
        onError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      onError(e.toString());
    }
  }


}
