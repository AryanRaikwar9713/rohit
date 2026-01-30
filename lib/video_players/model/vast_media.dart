class VastMedia {
  final List<String> mediaUrls;
  final List<String> clickThroughUrls;
  final List<String> clickTrackingUrls;
  final int? skipDuration;

  VastMedia({
    required this.mediaUrls,
    required this.clickThroughUrls,
    required this.clickTrackingUrls,
    this.skipDuration,
  });
}
