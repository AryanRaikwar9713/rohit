import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/reels/reel_comment_response_model.dart';
import 'package:streamit_laravel/screens/reels/reels_controller.dart';

import '../reel_response_model.dart';

class ReelCommentBottomSheet extends StatefulWidget {
  final Reel reel;

  const ReelCommentBottomSheet({
    super.key,
    required this.reel,

  });

  @override
  State<ReelCommentBottomSheet> createState() => _ReelCommentBottomSheetState();
}

class _ReelCommentBottomSheetState extends State<ReelCommentBottomSheet>
    with TickerProviderStateMixin {
  late TextEditingController _commentController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final FocusNode _focusNode = FocusNode();
  

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Auto focus on comment input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0, _slideAnimation.value * MediaQuery.of(context).size.height),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                _buildHeader(),

                // Comments list
                Expanded(
                  child: _buildCommentsList(),
                ),

                // Comment input
                _buildCommentInput(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${widget.reel.stats?.commentsCount ?? 0} comments',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Obx(() {
      var controller = Get.find<ReelsController>();
      
      if(controller.commentLoading.value)
        {
          return Center(child: CircularProgressIndicator(),);
        }
      
      if(controller.comments.isEmpty)
        {
          return Center(child: Text("No comments"),);
        }
      
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.comments.length,
        itemBuilder: (context, index) {
          final comment = controller.comments.value[index];
          return _buildCommentItem(comment);
        },
      );
    });
  }

  Widget _buildCommentItem(ReelComment comment) {

    // return Text('${comment.toJson()}',style: TextStyle(color: Colors.white),);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          GestureDetector(
            onTap: () {
              // Navigate to user profile
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: false
                      ? Colors.blue
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: comment.user?.profilePicture??'',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and time
                Row(
                  children: [
                    Text(
    '${comment.user?.fullName??''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (false) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 14,
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment.createdAt??DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(
                  comment.comment??'',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // // Like and reply buttons
                // Row(
                //   children: [
                //     GestureDetector(
                //       onTap: () {
                //         // Toggle like
                //         setState(() {
                //           comment.isLiked = !comment.isLiked;
                //           comment.likes += comment.isLiked ? 1 : -1;
                //         });
                //       },
                //       child: Row(
                //         children: [
                //           Icon(
                //             comment.isLiked
                //                 ? Icons.favorite
                //                 : Icons.favorite_border,
                //             color:
                //                 comment.isLiked ? Colors.red : Colors.grey[400],
                //             size: 16,
                //           ),
                //           const SizedBox(width: 4),
                //           Text(
                //             comment.likes > 0 ? comment.likes.toString() : '',
                //             style: TextStyle(
                //               color: Colors.grey[400],
                //               fontSize: 12,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //     const SizedBox(width: 16),
                //     GestureDetector(
                //       onTap: () {
                //         // Reply to comment
                //       },
                //       child: Text(
                //         'Reply',
                //         style: TextStyle(
                //           color: Colors.grey[400],
                //           fontSize: 12,
                //         ),
                //       ),
                //     ),
                //     if (comment.replies > 0) ...[
                //       const SizedBox(width: 16),
                //       GestureDetector(
                //         onTap: () {
                //           // Show replies
                //         },
                //         child: Text(
                //           '${comment.replies} replies',
                //           style: TextStyle(
                //             color: Colors.grey[400],
                //             fontSize: 12,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ],
                // ),
              ],
            ),
          ),

          // More options
          // GestureDetector(
          //   onTap: () {
          //     _showCommentOptions(comment);
          //   },
          //   child: Icon(
          //     Icons.more_vert,
          //     color: Colors.grey[400],
          //     size: 16,
          //   ),
          // ),
        ],
      ),
    );
  }





  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom+5,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Current user profile image
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Comment input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[700]!, width: 0.5),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _addComment(value.trim());
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: () {
              if (_commentController.text.trim().isNotEmpty) {
                _addComment(_commentController.text.trim());
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _commentController.text.trim().isNotEmpty
                    ? Colors.blue
                    : Colors.grey[700],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addComment(String text) {
    print("ajkshf");
    var controller = Get.find<ReelsController>();
    controller.addCommentOnReel(reelId: widget.reel.id??0,comment: text);
    _commentController.clear();
  }

  void _showCommentOptions(ReelComment comment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionItem(Icons.copy, 'Copy', () {}),
            _buildOptionItem(Icons.report, 'Report', () {}),
            _buildOptionItem(Icons.block, 'Block', () {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

