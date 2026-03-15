import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_api.dart';
import 'package:streamit_laravel/utils/colors.dart';

/// Apna gradient - Add Story (yellow-orange)
const LinearGradient _addStoryGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  String? mediaUrl;

  TextEditingController captionController = TextEditingController();
  TextEditingController tagSearchController = TextEditingController();

  /// Selected tagged user IDs (for request body).
  final RxList<int> _taggedUserIds = <int>[].obs;
  final RxList<_TagUser> _searchResults = <_TagUser>[].obs;
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appScreenBackgroundDark,
              Color(0xFF0f0d0a),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBody(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCaptionBar(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
      ),
      title: ShaderMask(
        shaderCallback: (b) => _addStoryGradient.createShader(b),
        child: Text(
          'Add Story',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCaptionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            appScreenBackgroundDark.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1510),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _addStoryGradient.colors.first.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: captionController,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a caption...',
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: _createStory,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _addStoryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _addStoryGradient.colors.last.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createStory() async {
    if (mediaUrl == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => WillPopScope(
          child: const Center(
            child: CircularProgressIndicator(),
          ),
          onWillPop: () async {
            return false;
          },),
    );

    await StoryApi().createStory(
      mediaUrl: mediaUrl!,
      caption: (captionController.text.trim().isNotEmpty)
          ? captionController.text.trim()
          : null,
      taggedUserIds: _taggedUserIds.toList(),
      onSuccess: () {
        toast("Story Created Successfully");
        Navigator.pop(context);
      },
      onError: onError,
      onFail: (d) {
        toast("Failed To create Story with ${d.statusCode}");
      },
    );

    //
    Navigator.pop(context);
    return;
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mediaUrl == null)
            _buildEmptyState()
          else ...[
            if (mediaUrl.isImage)
              _buildImagePreview()
            else if (mediaUrl.isVideo)
              const Center(
                child: Text(
                  'This is Video',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
          const SizedBox(height: 24),
          _buildTagPeopleSection(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.file(File(mediaUrl!), fit: BoxFit.cover),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: _selectimage,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: _addStoryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color:
                        _addStoryGradient.colors.last.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Change',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectimage() async {
    final reselt = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4'],
    );

    if (reselt != null) {
      mediaUrl = reselt.files.first.path;
      setState(() {});
    }
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          const SizedBox(height: 40),
          // Main tap area - card style
          GestureDetector(
            onTap: _selectimage,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 280),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1510),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _addStoryGradient.colors.first.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _addStoryGradient.colors.first.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _addStoryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: _addStoryGradient.colors.last.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (b) => _addStoryGradient.createShader(b),
                    child: Text(
                      'Add Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add a photo or video',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Story tips card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1510).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _addStoryGradient.colors.first.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: _addStoryGradient.colors.first),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Photo or video • Stays 24 hours • Add a caption when ready',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTagPeopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tag people',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final tags = _taggedUserIds.toList();
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final user in _searchResults
                  .where((u) => tags.contains(u.id))
                  .toList())
                _buildTagChip(user),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearching = true;
                  });
                  _openTagSearchSheet();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _addStoryGradient.colors.first
                          .withValues(alpha: 0.6),
                    ),
                    color: const Color(0xFF1a1510),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.person_add_alt_1,
                          color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Tag people',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTagChip(_TagUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: _addStoryGradient,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '@${user.username}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              _taggedUserIds.remove(user.id);
            },
            child: const Icon(Icons.close, size: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Future<void> _openTagSearchSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tag people',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: tagSearchController,
                    onChanged: (value) async {
                      await _searchUsers(value.trim());
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white70, size: 20),
                      hintText: 'Search username',
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1a1510),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    if (_searchResults.isEmpty &&
                        tagSearchController.text.isEmpty) {
                      return const Center(
                        child: Text(
                          'Start typing to search people',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      );
                    }
                    if (_searchResults.isEmpty) {
                      return const Center(
                        child: Text(
                          'No users found',
                          style:
                              TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (ctx, index) {
                        final user = _searchResults[index];
                        final selected = _taggedUserIds.contains(user.id);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade800,
                            child: Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          subtitle: Text(
                            '@${user.username}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          trailing: selected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.greenAccent, size: 20)
                              : const Icon(Icons.radio_button_unchecked,
                                  color: Colors.white38, size: 20),
                          onTap: () {
                            if (selected) {
                              _taggedUserIds.remove(user.id);
                            } else {
                              _taggedUserIds.add(user.id);
                            }
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _isSearching = false;
      });
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      return;
    }
    try {
      final raw = await StoryApi().searchUsersForTag(query: query);
      final mapped = raw
          .map((e) => _TagUser(
                id: e['id'] as int? ?? 0,
                username: (e['username'] as String? ?? '').trim(),
                name: (e['name'] as String? ?? '').trim(),
              ))
          .where((u) => u.id > 0 && u.username.isNotEmpty)
          .toList();
      _searchResults
        ..clear()
        ..addAll(mapped);
    } catch (_) {
      // ignore; UI will just show "No users found"
    }
  }

}

class _TagUser {
  final int id;
  final String username;
  final String name;

  _TagUser({
    required this.id,
    required this.username,
    required this.name,
  });
}
