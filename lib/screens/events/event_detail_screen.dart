import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../utils/colors.dart';
import '../../widgets/bottom_navigation_wrapper.dart';
import '../event/get_event_responce_modle.dart';
import 'events_controller.dart';

/// Apna gradient - Events detail accent (yellow-orange)
const LinearGradient _eventDetailGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class EventDetailScreen extends StatelessWidget {
  final ShopEvents event;
  final EventsController eventsController;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.eventsController,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationWrapper(
      child: AppScaffoldNew(
        scaffoldBackgroundColor: appScreenBackgroundDark,
        topBarBgColor: transparentColor,
        appBartitleText: '',
        body: Stack(
          children: [
            // Hero Image with Gradient
            _buildHeroSection(),

            // Scrollable Content
            Positioned.fill(
              top: 280,
              child: Container(
                decoration: const BoxDecoration(
                  color: appScreenBackgroundDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: AnimatedScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: [
                    // Title Section
                    _buildTitleSection(),

                    // Quick Info Cards
                    _buildQuickInfoCards(),
                    12.height,

                    // Shop Info Card
                    if (event.shopName != null) _buildShopInfoCard(),

                    // Description
                    if (event.description != null &&
                        event.description!.isNotEmpty)
                      _buildDescriptionSection(),

                    // Event Dates
                    _buildDatesSection(),

                    // Participants Section
                    if (event.maxParticipants != null)
                      _buildParticipantsSection(),

                    // Event Rules
                    if (event.eventRules != null &&
                        event.eventRules!.isNotEmpty)
                      _buildRulesSection(),

                    // Prizes Section
                    if (event.prizes != null && event.prizes!.isNotEmpty)
                      _buildPrizesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      children: [
        // Cover Image (contain = no cut, full image visible) + tap → bottom sheet
        GestureDetector(
          onTap: () {
            final ctx = Get.context;
            if (ctx != null) _showImageBottomSheet(ctx);
          },
          child: Container(
            height: 320,
            width: Get.width,
            color: appScreenBackgroundDark,
            alignment: Alignment.center,
            child: CachedImageWidget(
              url: event.cover_image_url ?? '',
              height: 320,
              width: Get.width,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Gradient Overlay
        Container(
          height: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                appScreenBackgroundDark.withOpacity(0.7),
                appScreenBackgroundDark,
              ],
              stops: const [0.0, 0.5, 0.8, 1.0],
            ),
          ),
        ),

        // Badges
        Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              if (event.status != null)
                _buildModernBadge(
                  text: event.status!.toUpperCase(),
                  color: _getStatusColor(event.status ?? ''),
                  icon: _getStatusIcon(event.status ?? ''),
                ),

              // Featured Badge (gradient)
              if (event.isFeatured == 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _eventDetailGradient,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: _eventDetailGradient.colors.first.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        'FEATURED',
                        style: boldTextStyle(size: 11, color: Colors.black),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageBottomSheet(BuildContext context) {
    final url = event.cover_image_url ?? '';
    if (url.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: appScreenBackgroundDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: _eventDetailGradient.colors.first.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: _eventDetailGradient.colors.first.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle + gradient bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _eventDetailGradient.colors.first.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header with title and close (gradient accent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => _eventDetailGradient.createShader(b),
                    child: Text(
                      event.title ?? 'Event Image',
                      style: boldTextStyle(size: 18, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: _eventDetailGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _eventDetailGradient.colors.first.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close, size: 20, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            // Full image (contain = no cut)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: Get.width - 32,
                    height: MediaQuery.of(context).size.height * 0.55,
                    color: Colors.grey[900],
                    alignment: Alignment.center,
                    child: CachedImageWidget(
                      url: url,
                      width: Get.width - 32,
                      height: MediaQuery.of(context).size.height * 0.55,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBadge({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: boldTextStyle(size: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            event.title ?? 'No Title',
            style: boldTextStyle(size: 28, color: Colors.white),
          ),

          const SizedBox(height: 12),

          // Event Type (gradient)
          if (event.eventType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _eventDetailGradient.colors.first.withOpacity(0.25),
                    _eventDetailGradient.colors.last.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _eventDetailGradient.colors.first.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => _eventDetailGradient.createShader(b),
                    child: const Icon(Icons.event, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.eventType ?? '',
                    style: boldTextStyle(size: 14, color: _eventDetailGradient.colors.first),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Start Date Card (theme color)
          if (event.startDate != null)
            Expanded(
              child: _buildInfoCard(
                icon: Icons.play_circle_filled,
                title: 'Starts',
                value: DateFormat('MMM dd').format(event.startDate!),
                time: DateFormat('hh:mm a').format(event.startDate!),
                color: _eventDetailGradient.colors.first,
              ),
            ),

          if (event.startDate != null && event.endDate != null)
            const SizedBox(width: 12),

          // End Date Card (theme color)
          if (event.endDate != null)
            Expanded(
              child: _buildInfoCard(
                icon: Icons.stop_circle,
                title: 'Ends',
                value: DateFormat('MMM dd').format(event.endDate!),
                time: DateFormat('hh:mm a').format(event.endDate!),
                color: _eventDetailGradient.colors.last,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: secondaryTextStyle(size: 11, color: Colors.grey[400]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: boldTextStyle(size: 16, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: secondaryTextStyle(size: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[800]!,
        ),
      ),
      child: Row(
        children: [
          // Shop Logo
          if (event.shopLogo != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _eventDetailGradient.colors.first.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: CachedImageWidget(
                  url: event.shopLogo ?? '',
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          if (event.shopLogo != null) const SizedBox(width: 16),

          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => _eventDetailGradient.createShader(b),
                      child: const Icon(Icons.store, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.shopName ?? '',
                        style: boldTextStyle(size: 18, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (event.shopOwnerName != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 14, color: Colors.grey[400],),
                      const SizedBox(width: 6),
                      Text(
                        event.shopOwnerName ?? '',
                        style: secondaryTextStyle(
                          size: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[800]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _eventDetailGradient.colors.first.withOpacity(0.3),
                      _eventDetailGradient.colors.last.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _eventDetailGradient.colors.first.withOpacity(0.4),
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (b) => _eventDetailGradient.createShader(b),
                  child: const Icon(Icons.description, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About Event',
                style: boldTextStyle(size: 20, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.description ?? '',
            style: secondaryTextStyle(
              size: 15,
              color: Colors.grey[300],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _eventDetailGradient.colors.first.withOpacity(0.12),
            _eventDetailGradient.colors.last.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _eventDetailGradient.colors.first.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _eventDetailGradient.colors.first.withOpacity(0.3),
                      _eventDetailGradient.colors.last.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _eventDetailGradient.colors.first.withOpacity(0.4),
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (b) => _eventDetailGradient.createShader(b),
                  child: const Icon(Icons.calendar_today, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Event Timeline',
                style: boldTextStyle(size: 20, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Start Date (theme)
          if (event.startDate != null)
            _buildTimelineItem(
              icon: Icons.play_circle_filled,
              label: 'Start Date',
              date: DateFormat('MMM dd, yyyy').format(event.startDate!),
              time: DateFormat('hh:mm a').format(event.startDate!),
              color: _eventDetailGradient.colors.first,
            ),

          if (event.startDate != null && event.endDate != null)
            const SizedBox(height: 16),

          // End Date (theme)
          if (event.endDate != null)
            _buildTimelineItem(
              icon: Icons.stop_circle,
              label: 'End Date',
              date: DateFormat('MMM dd, yyyy').format(event.endDate!),
              time: DateFormat('hh:mm a').format(event.endDate!),
              color: _eventDetailGradient.colors.last,
            ),

          if (event.endDate != null && event.resultDate != null)
            const SizedBox(height: 16),

          // Result Date (theme)
          if (event.resultDate != null)
            _buildTimelineItem(
              icon: Icons.emoji_events,
              label: 'Result Date',
              date: DateFormat('MMM dd, yyyy').format(event.resultDate!),
              time: DateFormat('hh:mm a').format(event.resultDate!),
              color: _eventDetailGradient.colors.first,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required String date,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: secondaryTextStyle(size: 12, color: Colors.grey[400]),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: boldTextStyle(size: 15, color: Colors.white),
              ),
              Text(
                time,
                style: secondaryTextStyle(size: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    final current = event.currentParticipants ?? 0;
    final max = event.maxParticipants ?? 0;
    final available = max - current;
    final percentage = max > 0 ? (current / max) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _eventDetailGradient.colors.first.withOpacity(0.1),
            _eventDetailGradient.colors.last.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _eventDetailGradient.colors.first.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _eventDetailGradient.colors.first.withOpacity(0.3),
                      _eventDetailGradient.colors.last.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _eventDetailGradient.colors.first.withOpacity(0.4),
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (b) => _eventDetailGradient.createShader(b),
                  child: const Icon(Icons.people, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Participants',
                style: boldTextStyle(size: 20, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[800],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: _eventDetailGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats (theme colors only)
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.person,
                  label: 'Joined',
                  value: '$current',
                  color: _eventDetailGradient.colors.first,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.group,
                  label: 'Max',
                  value: '$max',
                  color: _eventDetailGradient.colors.last,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_available,
                  label: 'Available',
                  value: '$available',
                  color: _eventDetailGradient.colors.first.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: boldTextStyle(size: 18, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: secondaryTextStyle(size: 10, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: canvasColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _eventDetailGradient.colors.first.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _eventDetailGradient.colors.first.withOpacity(0.3),
                      _eventDetailGradient.colors.last.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _eventDetailGradient.colors.first.withOpacity(0.4),
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (b) => _eventDetailGradient.createShader(b),
                  child: const Icon(Icons.rule, size: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Event Rules',
                style: boldTextStyle(size: 20, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _eventDetailGradient.colors.first.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _eventDetailGradient.colors.first.withOpacity(0.25),
              ),
            ),
            child: Text(
              event.eventRules ?? '',
              style: secondaryTextStyle(
                size: 14,
                color: Colors.grey[300],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _eventDetailGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _eventDetailGradient.colors.first.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Text(
                'Prizes',
                style: boldTextStyle(size: 20, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: event.prizes!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildModernPrizeCard(event.prizes![index], index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernPrizeCard(Prize prize, int position) {
    // All prizes use theme gradient shades (no blue/purple/green/brown)
    final colors = [
      [_eventDetailGradient.colors.first, _eventDetailGradient.colors.last],
      [
        _eventDetailGradient.colors.first.withOpacity(0.7),
        _eventDetailGradient.colors.last.withOpacity(0.7),
      ],
      [
        _eventDetailGradient.colors.first.withOpacity(0.5),
        _eventDetailGradient.colors.last.withOpacity(0.5),
      ],
    ];

    final colorIndex = (position - 1) % colors.length;
    final gradientColors = colors[colorIndex];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withOpacity(0.15),
            gradientColors[1].withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Position Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${prize.position ?? position}',
                style: boldTextStyle(size: 24, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Prize Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prize.prizeTitle ?? 'Prize',
                  style: boldTextStyle(size: 18, color: Colors.white),
                ),
                if (prize.prizeDescription != null &&
                    prize.prizeDescription!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    prize.prizeDescription ?? '',
                    style: secondaryTextStyle(
                      size: 13,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (prize.prizeType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: gradientColors[0].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          prize.prizeType ?? '',
                          style: secondaryTextStyle(
                            size: 11,
                            color: gradientColors[0],
                          ),
                        ),
                      ),
                    if (prize.prizeValue != null &&
                        prize.prizeValue!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _eventDetailGradient.colors.last.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _eventDetailGradient.colors.last.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_money,
                                size: 12, color: _eventDetailGradient.colors.last,),
                            const SizedBox(width: 4),
                            Text(
                              prize.prizeValue ?? '',
                              style: boldTextStyle(
                                size: 12,
                                color: _eventDetailGradient.colors.last,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'ongoing':
        return _eventDetailGradient.colors.first;
      case 'upcoming':
        return _eventDetailGradient.colors.last;
      case 'completed':
      case 'ended':
        return Colors.grey;
      default:
        return _eventDetailGradient.colors.first;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'ongoing':
        return Icons.play_circle_filled;
      case 'upcoming':
        return Icons.schedule;
      case 'completed':
      case 'ended':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}
