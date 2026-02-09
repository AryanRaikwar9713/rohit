import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';
import 'package:streamit_laravel/screens/donation/model/project_detail_responce_model.dart';
import 'package:streamit_laravel/screens/donation_history_section/model/donation_history_history_responce.dart';
import 'package:streamit_laravel/screens/social/social_api.dart';


class DonationProject{


  Future<void> donateToImpactProject({
    required int projectId,
    required double boltAmount,
    required String message,
    required void Function(Map<String, dynamic> data) onSuccess,
    required void Function(http.Response) onFailure,
    required void Function(String error) onError,
  }) async {
    const String url = "https://app.wamims.world/public/social/impact/donate.php";

    try {
      final head = await DB().getHeaderForRow();
      final UserData? user = await DB().getUser();

      // Validate project_id
      if (projectId <= 0) {
        onError("Invalid project ID");
        return;
      }

      final body = jsonEncode({
        "user_id": user?.id ?? 0,
        "project_id": projectId,
        "bolt_amount": boltAmount.toString(),
        "message": message,
        "is_anonymous": 0,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: head ?? {},
        body: body,
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        onSuccess(jsonRes);
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }



  Future<void> getImpactProjectDetails({
    required int projectId,
    required void Function(ProjectDetailResponcModel data) onSuccess,
    required void Function(String error) onError,
  }) async {
    final String url =
        "https://app.wamims.world/public/social/impact/get_projects_fixed.php?action=get_project_details&project_id=$projectId";

    try {
      final head = await DB().getHeaderForRow();

      final response = await http.get(
        Uri.parse(url),
        headers: head ?? {},
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        onSuccess(ProjectDetailResponcModel.fromJson(jsonRes));
      } else {
        onError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      onError(e.toString());
    }
  }



  Future<void> getUserDonationHistory({
    required int page,
    required void Function(DonationHistoryReponceModel data) onSuccess,
    required void Function(String error) onError,
  }) async
  {




    try {
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final String url =
          "https://app.wamims.world/public/social/impact/donation_history.php?user_id=${user?.id}&page=$page&limit=10";

      final response = await http.get(
        Uri.parse(url),
        headers: head ?? {},
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        onSuccess(DonationHistoryReponceModel.fromJson(jsonRes));
      } else {
        onError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      onError(e.toString());
    }
  }



  Future<void> getImpactProjects({
    required int page,
    required void Function(GetProjectListResponcModel data) onSuccess,
    required void Function(String error) onError,
  }) async {
    final url = Uri.parse(
      'https://app.wamims.world/social/impact/get_projects.php?page=$page&limit=10',
    );

    try {

      final head = await DB().getHeaderForRow();

      final response = await http.get(
        url,
        headers:head,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        onSuccess(GetProjectListResponcModel.fromJson(data));
      } else {
        onError('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      onError('Error: $e');
    }
  }






}