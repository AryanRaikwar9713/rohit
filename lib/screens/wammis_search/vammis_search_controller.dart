import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/donation/project_detail_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/screens/wammis_search/searchApi.dart';
import 'package:streamit_laravel/screens/wammis_search/search_result_responce_model.dart';
import 'package:streamit_laravel/utils/colors.dart';

class VammisSearchController extends GetxController {
  Rx<TextEditingController> searchController = TextEditingController().obs;

  RxBool searching = false.obs;

  RxList<Result> search = <Result>[].obs;

  Future<void> getSearch() async {
    search.value = [];
    if (searchController.value.text.isEmpty) {
      searching.value = false;
      return;
    } else {
      searching.value = true;

      await SearchApi().searchApi(
        searchController.value.text,
        onSuccess: (SearchResultReponceModel responce) async {
          search.value = responce.data?.results ?? [];
        },
        onError: (String e) async {
          toast(e);
        },
        onFailed: (http.Response responce) async {
          search.clear();
          toast(responce.statusCode.toString());
        },
      );
    }
    print("${searchController.value.text}  ${searching.value}");
  }

  Widget searchView() {
    return GestureDetector(
      key: const ValueKey('searchView'),
      onTap: () {
        // Don't close on tap - let users interact with results
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: double.infinity,
        color: Colors.black.withOpacity(0.5),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
            ),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: cardBackgroundBlackDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: appColorPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search Results',
                          style: boldTextStyle(
                            size: 16,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      if (search.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4,),
                          decoration: BoxDecoration(
                            color: appColorPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${search.length}',
                            style: secondaryTextStyle(
                              size: 12,
                              color: appColorPrimary,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: secondaryTextColor,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          searching.value = false;
                        },
                      ),
                    ],
                  ),
                ),
                // Search Results List
                Flexible(
                  child: search.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: search.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[800],
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            final item = search[index];
                            return _SearchResultCard(result: item);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: boldTextStyle(
              size: 16,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: secondaryTextStyle(
              size: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Result result;
  const _SearchResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (result.contentType == 'user') {
          final user = await DB().getUser();
          Get.to(VammisProfileScreen(
            popButton: true,
              userId: result.contentId ?? 0,
              isOwnProfile: user?.id == result.contentId,),);
        }
        if (result.contentType == 'project') {
          Get.to(ProjectDetailScreen(id: result.contentId ?? 0));
        }
      },
      child: Container(
        height: 80, // Fixed height for consistency
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Image/Icon based on contentType
            _buildContentImage(),
            const SizedBox(width: 12),
            // Content details
            Expanded(
              child: _buildContentDetails(),
            ),
            // Type indicator icon
            _buildTypeIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentImage() {
    const size = 56.0; // Slightly smaller to fit in fixed height

    if (result.contentType == 'user') {
      // User profile image - circular
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: appColorPrimary.withOpacity(0.5), width: 2),
        ),
        child: ClipOval(
          child: result.imageUrl != null && result.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: result.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child:
                        const Icon(Icons.person, color: Colors.grey, size: 28),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child:
                        const Icon(Icons.person, color: Colors.grey, size: 28),
                  ),
                )
              : Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.person, color: Colors.grey, size: 28),
                ),
        ),
      );
    } else {
      // Post/Reel/Project image - rounded rectangle
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[800],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: result.imageUrl != null && result.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: result.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: Icon(
                      _getPlaceholderIcon(),
                      color: Colors.grey[600],
                      size: 28,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: Icon(
                      _getPlaceholderIcon(),
                      color: Colors.grey[600],
                      size: 28,
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[800],
                  child: Icon(
                    _getPlaceholderIcon(),
                    color: Colors.grey[600],
                    size: 28,
                  ),
                ),
        ),
      );
    }
  }

  Widget _buildContentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          result.contentTitle ?? 'Untitled',
          style: boldTextStyle(
            size: 15,
            color: primaryTextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Description (if available) - only show if space allows
        if (result.contentDescription != null &&
            result.contentDescription!.isNotEmpty)
          Text(
            result.contentDescription!,
            style: secondaryTextStyle(
              size: 12,
              color: secondaryTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),
        // Additional info based on type
        _buildAdditionalInfo(),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    final extraData = result.extraData;

    switch (result.contentType) {
      case 'user':
        return Row(
          children: [
            if (extraData?.followersCount != null) ...[
              const Icon(Icons.people, size: 12, color: secondaryTextColor),
              const SizedBox(width: 4),
              Text(
                '${_formatCount(extraData!.followersCount!)} followers',
                style: secondaryTextStyle(size: 11, color: secondaryTextColor),
              ),
            ],
          ],
        );

      case 'post':
        return Row(
          children: [
            if (extraData?.likesCount != null) ...[
              Icon(Icons.favorite, size: 12, color: Colors.red[400]),
              const SizedBox(width: 4),
              Text(
                _formatCount(extraData!.likesCount!),
                style: secondaryTextStyle(size: 11, color: secondaryTextColor),
              ),
              const SizedBox(width: 12),
            ],
            if (extraData?.commentsCount != null) ...[
              const Icon(Icons.comment, size: 12, color: secondaryTextColor),
              const SizedBox(width: 4),
              Text(
                _formatCount(extraData!.commentsCount!),
                style: secondaryTextStyle(size: 11, color: secondaryTextColor),
              ),
            ],
          ],
        );

      case 'reel':
        return Row(
          children: [
            if (extraData?.viewsCount != null) ...[
              const Icon(Icons.play_circle_outline,
                  size: 12, color: secondaryTextColor,),
              const SizedBox(width: 4),
              Text(
                '${_formatCount(extraData!.viewsCount!)} views',
                style: secondaryTextStyle(size: 11, color: secondaryTextColor),
              ),
            ],
          ],
        );

      case 'project':
        return Row(
          children: [
            if (extraData?.fundingPercentage != null) ...[
              const Icon(Icons.trending_up, size: 12, color: appColorPrimary),
              const SizedBox(width: 4),
              Text(
                '${extraData!.fundingPercentage}% funded',
                style: secondaryTextStyle(
                  size: 11,
                  color: appColorPrimary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
            if (extraData?.donorsCount != null) ...[
              const SizedBox(width: 12),
              Text(
                '${_formatCount(extraData!.donorsCount!)} donors',
                style: secondaryTextStyle(size: 11, color: secondaryTextColor),
              ),
            ],
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (result.contentType) {
      case 'user':
        icon = Icons.person;
        color = Colors.blue[400]!;
        break;
      case 'post':
        icon = Icons.image;
        color = Colors.green[400]!;
        break;
      case 'reel':
        icon = Icons.video_library;
        color = Colors.purple[400]!;
        break;
      case 'project':
        icon = Icons.favorite;
        color = appColorPrimary;
        break;
      default:
        icon = Icons.search;
        color = Colors.grey[400]!;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  IconData _getPlaceholderIcon() {
    switch (result.contentType) {
      case 'post':
        return Icons.image;
      case 'reel':
        return Icons.video_library;
      case 'project':
        return Icons.favorite;
      default:
        return Icons.image;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
