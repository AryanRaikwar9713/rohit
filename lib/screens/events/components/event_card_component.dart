import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/shops_section/shop_profile_screen.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../event/get_event_responce_modle.dart';

class EventCardComponent extends StatelessWidget {
  final ShopEvents event;
  final VoidCallback onTap;
  final void Function(int shopId) onShopClip;

  const EventCardComponent({
    super.key,
    required this.event,
    required this.onTap,
    required this.onShopClip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: boxDecorationDefault(
          borderRadius: BorderRadius.circular(12),
          color: canvasColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedImageWidget(
                    url: event.cover_image_url ?? '',
                    height: 200,
                    width: Get.width,
                    fit: BoxFit.cover,
                  ),
                ),
                // Featured Badge
                if (event.isFeatured == 1)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: boxDecorationDefault(
                        borderRadius: BorderRadius.circular(20),
                        color: appColorPrimary,
                      ),
                      child: Text(
                        'Featured',
                        style: boldTextStyle(size: 12, color: white),
                      ),
                    ),
                  ),
                // Status Badge
                if (event.status != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: boxDecorationDefault(
                        borderRadius: BorderRadius.circular(20),
                        color: _getStatusColor(event.status ?? ''),
                      ),
                      child: Text(
                        event.status!.toUpperCase(),
                        style: boldTextStyle(size: 11, color: white),
                      ),
                    ),
                  ),
              ],
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title ?? 'No Title',
                          style: boldTextStyle(size: 20, color: white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      3.width,
                      
                      // Event Type
                      if (event.eventType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: boxDecorationDefault(
                            borderRadius: BorderRadius.circular(6),
                            color: appColorPrimary.withOpacity(0.2),
                          ),
                          child: Text(
                            event.eventType ?? '',
                            style: secondaryTextStyle(
                              size: 12,
                              color: appColorPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  5.height,
                  // Shop Info
                  if (event.shopName != null)
                    InkWell(
                      onTap: (){


                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[500]?.withOpacity(.1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.shopLogo != null)
                              CachedImageWidget(
                                url: event.shopLogo ?? '',
                                height: 35,
                                width: 35,
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRect(12),
                            if (event.shopLogo != null)
                              5.width,
                            Expanded(
                              child: Text(
                                event.shopName ?? '',
                                style: secondaryTextStyle(
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  8.height,
                  // Description
                  if (event.description != null &&
                      event.description!.isNotEmpty)
                    Text(
                      event.description ?? '',
                      style: secondaryTextStyle(
                        size: 14,
                        color: Colors.grey[300],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  5.height,

                  // Date and Participants Info
                  Row(
                    children: [
                      // Start Date
                      if (event.startDate != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              6.width,
                              Expanded(
                                child: Text(
                                  event.startDate != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(event.startDate!)
                                      : 'N/A',
                                  style: secondaryTextStyle(
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Participants
                      if (event.maxParticipants != null)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              6.width,
                              Text(
                                '${event.currentParticipants ?? 0}/${event.maxParticipants}',
                                style: secondaryTextStyle(
                                  size: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  8.height,

                  _buildButton(
                    title: 'Redeem Points',
                    onTap: () {
                      // Handle join event logic
                    },
                  ),
                  5.height,
                  Row(
                    children: [
                      Expanded(child: _buildButton(
                        title: 'Price',
                        onTap: () {
                          // Handle join event logic
                        },
                      )),
                      5.width,
                      Expanded(child: _buildButton(
                        title: 'Leader Board',
                        onTap: () {
                          // Handle join event logic
                        },
                      )),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'ongoing':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'completed':
      case 'ended':
        return Colors.grey;
      default:
        return btnColor;
    }
  }

  _buildButton({
    required String title,
    VoidCallback? onTap,
})
  {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[400]?.withOpacity(.1),
        border: Border.all(color: Colors.grey,width: .5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(title ?? '',style: secondaryTextStyle(color: white),),
    );
    }
}
