import 'package:flutter/material.dart';
import 'package:streamit_laravel/configs.dart';

/// Instagram-style: gradient ring when user has active story (24h), white ring when no story.
const LinearGradient _storyRingGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class WamimsProfileAvtar extends StatelessWidget {
  /// When true: yellow-orange gradient border (active story). When false: white border.
  final bool story;
  /// When true (and story is true): ring at 50% opacity (seen). When false: full yellow (unseen).
  final bool storySeen;
  final String image;
  final double? radious;
  final double? borderWidth;
  final Function()? onTap;
  const WamimsProfileAvtar({
    this.borderWidth,
    this.story = false,
    this.storySeen = false,
    this.radious,
    this.onTap,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double ringWidth = borderWidth ?? 3;
    final bool useStoryRing = story;
    final double ringOpacity = (story && storySeen) ? 0.5 : 1.0;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: useStoryRing
            ? null
            : Border.all(color: Colors.white, width: ringWidth),
        gradient: useStoryRing
            ? LinearGradient(
                colors: _storyRingGradient.colors
                    .map((c) => c.withOpacity(ringOpacity))
                    .toList(),
                begin: _storyRingGradient.begin,
                end: _storyRingGradient.end,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: useStoryRing
                ? _storyRingGradient.colors.first.withOpacity(0.4 * ringOpacity)
                : Colors.white.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(ringWidth),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: (radious ?? 50) * 2,
          width: (radious ?? 50) * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0D0D0D),
          ),
          padding: const EdgeInsetsGeometry.all(2),
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadiusGeometry.circular((radious ?? 50) * 2),
            child: Image.network(
              '${resolveImageUrl(image, pathPrefix: 'storage/avatars/')}?v=${DateTime.now().millisecondsSinceEpoch}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person_rounded, color: Colors.white, size: (radious ?? 50) * 1.5);
              },
            ),
          ),
        ),
      ),
    );
  }
}
