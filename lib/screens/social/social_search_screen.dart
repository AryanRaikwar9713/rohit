import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/wammis_search/searchApi.dart';
import 'package:streamit_laravel/screens/wammis_search/search_result_responce_model.dart';
import 'package:streamit_laravel/utils/colors.dart';

class SocialSearchScreen extends StatefulWidget {
  const SocialSearchScreen({super.key});

  @override
  State<SocialSearchScreen> createState() => _SocialSearchScreenState();
}

class _SocialSearchScreenState extends State<SocialSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchApi _searchApi = SearchApi();
  bool _isLoading = false;
  SearchResultReponceModel? _searchResults;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _searchApi.searchApi(
      query,
      onSuccess: (result) async {
        setState(() {
          _searchResults = result;
          _isLoading = false;
        });
      },
      onError: (error) async {
        setState(() {
          _isLoading = false;
        });
        toast(error);
      },
      onFailed: (response) async {
        setState(() {
          _isLoading = false;
        });
        toast("Search failed: ${response.statusCode}");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColorDark,
      appBar: AppBar(
        backgroundColor: appBackgroundColorDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search posts, users...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = null;
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
            if (value.length >= 2) {
              _performSearch(value);
            } else {
              setState(() {
                _searchResults = null;
              });
            }
          },
          onSubmitted: _performSearch,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: appColorPrimary,
              ),
            )
          : _searchResults == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      16.height,
                      Text(
                        'Search for posts, users, and more',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults == null || _searchResults!.data == null || _searchResults!.data!.results == null) {
      return const SizedBox();
    }

    final results = _searchResults!.data!.results!;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[600],
            ),
            16.height,
            Text(
              'No results found',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Group results by content type
    final posts = results.where((r) => r.contentType == 'post').toList();
    final users = results.where((r) => r.contentType == 'user').toList();
    final reels = results.where((r) => r.contentType == 'reel').toList();
    final projects = results.where((r) => r.contentType == 'project').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (posts.isNotEmpty) ...[
            Text(
              'Posts',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            12.height,
            ...posts.map((post) => _buildPostItem(post)),
            24.height,
          ],
          if (reels.isNotEmpty) ...[
            Text(
              'Reels',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            12.height,
            ...reels.map((reel) => _buildReelItem(reel)),
            24.height,
          ],
          if (users.isNotEmpty) ...[
            Text(
              'Users',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            12.height,
            ...users.map((user) => _buildUserItem(user)),
            24.height,
          ],
          if (projects.isNotEmpty) ...[
            Text(
              'Projects',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            12.height,
            ...projects.map((project) => _buildProjectItem(project)),
          ],
        ],
      ),
    );
  }

  Widget _buildPostItem(Result post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) 12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.contentTitle != null)
                  Text(
                    post.contentTitle!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (post.contentDescription != null) ...[
                  4.height,
                  Text(
                    post.contentDescription!,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelItem(Result reel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reel.imageUrl != null && reel.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                reel.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[800],
                  child: const Icon(Icons.video_library, color: Colors.grey),
                ),
              ),
            ),
          if (reel.imageUrl != null && reel.imageUrl!.isNotEmpty) 12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_circle_outline, color: appColorPrimary, size: 16),
                    4.width,
                    Text(
                      'Reel',
                      style: GoogleFonts.poppins(
                        color: appColorPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                4.height,
                if (reel.contentTitle != null)
                  Text(
                    reel.contentTitle!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildUserItem(Result user) {
    final extraData = user.extraData;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[800],
            backgroundImage: user.imageUrl != null && user.imageUrl!.isNotEmpty
                ? NetworkImage(user.imageUrl!)
                : null,
            child: user.imageUrl == null || user.imageUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.contentTitle ?? 'User',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (extraData?.email != null) ...[
                  4.height,
                  Text(
                    extraData!.email!,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(Result project) {
    final extraData = project.extraData;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                project.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[800],
                  child: const Icon(Icons.folder, color: Colors.grey),
                ),
              ),
            ),
          if (project.imageUrl != null && project.imageUrl!.isNotEmpty) 12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.contentTitle ?? 'Project',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (project.contentDescription != null) ...[
                  4.height,
                  Text(
                    project.contentDescription!,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (extraData != null && extraData.fundingPercentage != null) ...[
                  8.height,
                  Text(
                    '${extraData.fundingPercentage}% funded',
                    style: GoogleFonts.poppins(
                      color: appColorPrimary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
