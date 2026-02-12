import 'dart:convert';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/donation/campainApi.dart';
import 'package:streamit_laravel/screens/donation/model/project_detail_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_api.dart';

class ProjectDetailController extends GetxController
{
  RxBool loading = true.obs;
  Rx<ProjectDetail> detail = ProjectDetail().obs;
  /// Creator avatar from vammis profile (when project API returns empty)
  RxString creatorAvatarUrl = ''.obs;

  // Store project ID separately to ensure it's always available
  int? _projectId;

  int? get projectId => _projectId ?? detail.value.id;

  Future<void> getProject(int id) async {
    try {
      if (id <= 0) {
        loading.value = false;
        toast('Invalid project ID');
        return;
      }

      creatorAvatarUrl.value = '';
      _projectId = id; // Store ID immediately
      loading.value = true;

      await DonationProject().getImpactProjectDetails(
          projectId: id,
          onSuccess: (d) {
            Logger().i("Project data loaded successfully");
            if(d.data?.project != null) {
              detail.value = d.data!.project!;
              // Ensure ID is set
              if (detail.value.id == null || detail.value.id == 0) {
                detail.value.id = id;
              }
              _projectId = detail.value.id ?? id;
              // If creator avatar is empty, fetch from vammis profile (same as profile page)
              _fetchCreatorAvatarIfNeeded();
            } else {
              Logger().w("Project data is null");
              toast('Failed to load project details');
            }
            loading.value = false;
          },
          onError: (e) {
            loading.value = false;
            Logger().e("Error loading project: $e");
            toast('Failed to load project: $e');
          },);
    } catch (e) {
      loading.value = false;
      Logger().e("Exception loading project: $e");
      toast('Failed to load project details');
    }
  }

  Future<void> donate(double amount, String message) async {
    try {
      // Use stored project ID or detail ID
      final projectIdToUse = _projectId ?? detail.value.id;
      
      if (projectIdToUse == null || projectIdToUse <= 0) {
        Logger().e("Invalid project ID: $_projectId, detail.id: ${detail.value.id}");
        toast('Invalid project ID. Please refresh the page.');
        return;
      }
      
      if (amount <= 0) {
        toast('Please enter a valid amount');
        return;
      }

      if (message.trim().isEmpty) {
        toast('Please enter a message');
        return;
      }

      Logger().i("Donating $amount bolts to project $projectIdToUse");
      
      await DonationProject().donateToImpactProject(
        projectId: projectIdToUse,
        boltAmount: amount,
        message: message.trim(),
        onSuccess: (d) {
          Logger().i("Donation successful");
          toast('Donation successful!');
          // Refresh project details to get updated data
          getProject(projectIdToUse);
        },
        onFailure: (d) {
          try {
            final responseBody = jsonDecode(d.body);
            final errorMessage = responseBody['message'] ?? 'Donation failed';
            Logger().e("Donation failed: ${d.statusCode} - $errorMessage");
            toast(errorMessage.toString());
          } catch (e) {
            Logger().e("Error parsing donation failure: $e");
            toast('Donation failed: ${d.statusCode}');
          }
        },
        onError: (e) {
          Logger().e("Donation error: $e");
          toast('Error: $e');
        },
      );
    } catch (e) {
      Logger().e("Exception in donate: $e");
      toast('Something went wrong. Please try again.');
    }
  }

  /// Fetch creator avatar from vammis profile API when project API returns empty
  void _fetchCreatorAvatarIfNeeded() {
    final creator = detail.value.creator;
    if (creator == null || creator.id == null) return;
    final existingAvatar = creator.avatar ?? '';
    if (existingAvatar.isNotEmpty && (existingAvatar.startsWith('http') || existingAvatar.startsWith('https'))) return;

    VammisProfileApi().getUserProfile(
      userId: creator.id!,
      onSuccess: (profile) {
        final avatar = profile.data?.user?.avatarUrl ?? profile.data?.user?.avatar;
        if (avatar != null && avatar.toString().trim().isNotEmpty) {
          creatorAvatarUrl.value = avatar.toString().trim();
        }
      },
      onFailure: (_) {},
      onError: (_) {},
    );
  }
}
