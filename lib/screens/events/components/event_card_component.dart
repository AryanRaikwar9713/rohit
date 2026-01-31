import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/colors.dart';
import '../../event/get_event_responce_modle.dart';

/// Apna gradient - Events screen accent
const LinearGradient _eventGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

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
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _eventGradient.colors.first.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover Image (contain = no cut, full image visible)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[900],
                    alignment: Alignment.center,
                    child: CachedImageWidget(
                      url: event.cover_image_url ?? '',
                      height: 200,
                      width: Get.width,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Featured Badge (gradient)
                if (event.isFeatured == 1)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: _eventGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _eventGradient.colors.first.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Featured',
                        style: boldTextStyle(size: 12, color: Colors.black),
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
                      decoration: BoxDecoration(
                        color: _getStatusColor(event.status ?? ''),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 0.5,
                        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title ?? 'No Title',
                          style: boldTextStyle(size: 18, color: white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.width,
                      // Event Type (gradient accent)
                      if (event.eventType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _eventGradient.colors.first.withOpacity(0.25),
                                _eventGradient.colors.last.withOpacity(0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _eventGradient.colors.first.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            event.eventType ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _eventGradient.colors.first,
                            ),
                          ),
                        ),
                    ],
                  ),
                  10.height,
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
                  12.height,

                  // Redeem Points (gradient CTA)
                  _buildGradientButton(
                    title: 'Redeem Points',
                    onTap: () {},
                  ),
                  10.height,
                  Row(
                    children: [
                      Expanded(
                        child: _buildOutlineButton(
                          title: 'Price',
                          onTap: () {},
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: _buildOutlineButton(
                          title: 'Leader Board',
                          onTap: () {},
                        ),
                      ),
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
        return _eventGradient.colors.first;
      case 'upcoming':
        return _eventGradient.colors.last;
      case 'completed':
      case 'ended':
        return Colors.grey;
      default:
        return _eventGradient.colors.first;
    }
  }

  Widget _buildGradientButton({
    required String title,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: _eventGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _eventGradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            title,
            style: boldTextStyle(size: 15, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String title,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[800]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _eventGradient.colors.first.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: secondaryTextStyle(size: 14, color: white),
          ),
        ),
      ),
    );
  }
}
