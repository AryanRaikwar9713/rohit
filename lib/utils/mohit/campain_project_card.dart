import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';
import 'package:streamit_laravel/screens/donation/project_detail_screen.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/utils/colors.dart';

class CampaignProjectCard extends StatelessWidget {
  final Project project;
  const CampaignProjectCard({required this.project,super.key});

  @override
  Widget build(BuildContext context) {

    const double brds = 5;

    final imageUrl =
    project.projectImages != null && project.projectImages!.isNotEmpty
        ? project.projectImages!.first
        : null;

    return GestureDetector(

      //
      onTap: () {Get.to(() => ProjectDetailScreen(id: project.id ?? 0));},

      //
      child: Container(
        margin: const EdgeInsets.only(bottom: 16,left: 5,right: 5),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(brds),
          border: Border.all(color: Colors.grey[800]!),
          boxShadow: const[
            BoxShadow(
              color: Colors.black54,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:  BorderRadius.vertical(
                  top: Radius.circular(brds),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: appColorPrimary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[800],
                child: const Icon(
                  Icons.folder,
                  color: Colors.grey,
                  size: 50,
                ),
              ),

            // Project Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (project.title != null && project.title!.isNotEmpty)
                    Text(
                      project.title!,
                      style: boldTextStyle(size: 18, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  0.height,

                  // Description
                  if (project.description != null &&
                      project.description!.isNotEmpty)
                    Text(
                      project.description!,
                      style:
                      secondaryTextStyle(size: 14, color: Colors.white70),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  8.height,

                  // Progress Bar
                  if (project.fundingPercentage != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: secondaryTextStyle(
                                  size: 12, color: Colors.white70,),
                            ),
                            Text(
                              '${project.fundingPercentage!.toStringAsFixed(0)}%',
                              style: secondaryTextStyle(
                                  size: 12, color: appColorPrimary,),
                            ),
                          ],
                        ),
                        6.height,
                        LinearProgressIndicator(
                          value: (project.fundingPercentage ?? 0) / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(appColorPrimary),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),

                  12.height,

                  // Stats Row
                  Row(
                    children: [
                      if (project.fundingRaised != null &&
                          project.fundingGoal != null) ...[
                        Expanded(
                          child: _buildProjectStat(
                            '${project.fundingRaised!.toStringAsFixed(0)}',
                            'Raised',
                            Icons.flag,
                            useBoltIcon: true,
                          ),
                        ),
                        8.width,
                        Expanded(
                          child: _buildProjectStat(
                            '${project.fundingGoal}',
                            'Goal',
                            Icons.flag,
                            useBoltIcon: true,
                          ),
                        ),
                      ],
                      if (project.daysRemaining != null) ...[
                        8.width,
                        Expanded(
                          child: _buildProjectStat(
                            '${project.daysRemaining}',
                            'Days Left',
                            Icons.access_time,
                          ),
                        ),
                      ],
                    ],
                  ),

                  12.height,

                  // Additional Info
                  Row(
                    children: [
                      if (project.donorsCount != null) ...[
                        const Icon(Icons.people, size: 16, color: Colors.white70),
                        4.width,
                        Text(
                          '${project.donorsCount} donors',
                          style: secondaryTextStyle(
                              size: 12, color: Colors.white70,),
                        ),
                      ],
                      if (project.location != null &&
                          project.location!.isNotEmpty) ...[
                        16.width,
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.white70,),
                        4.width,
                        Expanded(
                          child: Text(
                            project.location!,
                            style: secondaryTextStyle(
                                size: 12, color: Colors.white70,),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildProjectStat(String value, String label, IconData icon, {bool useBoltIcon = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(3),
        boxShadow:  const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          useBoltIcon
              ? Image.asset(
                  "assets/icons/boalt_Icons.png",
                  height: 16,
                  width: 16,
                  color: appColorPrimary,
                )
              : Icon(icon, size: 16, color: appColorPrimary),
          6.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: boldTextStyle(size: 12, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: secondaryTextStyle(size: 10, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
