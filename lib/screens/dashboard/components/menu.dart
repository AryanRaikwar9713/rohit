import 'package:flutter/material.dart';

enum BottomItem {
  home,
  search,
  reels,
  social,
  donation,
  shop,
  events,
  profile,
}

class BottomBarItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String type;
  final Widget? customIcon;
  final Widget? customActiveIcon;

  BottomBarItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.type,
    this.customIcon,
    this.customActiveIcon,
  });
}
