class OverlayAd {
  final String imageUrl;
  final String? clickThroughUrl;
  final int startTime; // in seconds
  final int duration; // in seconds

  OverlayAd({
    required this.imageUrl,
    this.clickThroughUrl,
    required this.startTime,
    required this.duration,
  });
}
