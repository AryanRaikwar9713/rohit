import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/social/comment_responce_model.dart';
import 'package:streamit_laravel/screens/social/social_controller.dart';
import 'package:streamit_laravel/screens/social/social_post_card.dart';
import 'package:streamit_laravel/screens/social/social_post_responce_Model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/utils/colors.dart';



class UserPostViewScreen extends StatefulWidget {
  const UserPostViewScreen({super.key});

  @override
  State<UserPostViewScreen> createState() => _UserPostViewScreenState();
}

class _UserPostViewScreenState extends State<UserPostViewScreen> {

  final ScrollController scrollController  = ScrollController();
  final VammisProfileController controller = Get.find<VammisProfileController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener((){onScroll();});
  }

  void onScroll()
  {
    if(scrollController.position.pixels==scrollController.position.maxScrollExtent)
      {
        controller.loadMorePost();
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      //
      appBar: AppBar(
        title:  const Text("Posts",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),),
      ),

      //


      body: Obx((){
        return ListView.builder(
          controller: scrollController,
            itemCount: controller.userPosts.length,
            itemBuilder: (context, index){
            
            final SocialPost p = controller.userPosts.value[index];
            
            return  SocialPostCard(
              profilenavigation: false,
              post:p,

              onFollowTap: () async {
                controller.followUser(int.parse(
                    p.user?.userId ??
                        '0',),);
              },

              //Like
              onLike: ()async{controller.likePost(int.parse(p.postId??"0"));},

              //ImageTap
              onImageTap: ()async{
                await showDialog(
                  context: context,
                  builder: (context) => Blur(
                    blur: 7,
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: Colors.transparent,
                      elevation: 0,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide.none,
                        gapPadding: 0,
                      ),
                      child: Hero(
                          tag: p.postId ??
                              '',
                          child: Image.network(
                            p
                                .imageUrl ??
                                '',
                            fit: BoxFit.contain,
                          ),),
                    ),
                  ),
                );
              },


              //Comment
              onComment: ()async{
                controller.getPostComment(int.parse(
                    p.postId ?? '0',),);
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _CommentBottomSheet(
                    postId: int.parse(
                        p.postId ??
                            '0',),
                  ),
                );
                controller.resateCommentData();

              },

              //Share
              onSare: ()async{
                Clipboard.setData(const ClipboardData(
                    text:
                    "https://play.google.com/store/apps/details?id=com.anytimeott.live",),);
                toast("Url Copied");
              },
            );
            },
        );
      }),

    );
  }
}




class _CommentBottomSheet extends StatefulWidget {
  final int postId;
  const _CommentBottomSheet({required this.postId});

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  final _commentController = TextEditingController();

  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Get.find<VammisProfileController>().loadMoreComment(widget.postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VammisProfileController>();

    return Obx(() {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: appScreenBackgroundDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      "Comments",
                      style: boldTextStyle(size: 18, color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey[700]),

              // Comments List
              if (controller.commentLoading.value)
                const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),)
              else
                Expanded(
                  child: controller.comments.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "No Comments",
                          style: secondaryTextStyle(
                              size: 14, color: Colors.grey,),
                        ),
                        if (kDebugMode) ...[
                          Obx(
                                () => Text(
                              controller.comments.length.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Obx(
                                () => Text(
                              controller.commentPage.value.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    padding:
                    const EdgeInsets.symmetric(vertical: 8),
                    itemCount: controller.comments.length,
                    itemBuilder: (context, index) {
                      final SocialPostComment comment = controller.comments[index];

                      // return Text("${c.toJson()}",style: TextStyle(color: Colors.white),);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8,),
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
                                    imageUrl:
                                    comment.user?.profileImage ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Container(
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
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Username and time
                                  Row(
                                    children: [
                                      Text(
                                        '${comment.user?.firstName} ${comment.user?.lastName}',
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
                                        '${(comment.createdAt?.hour ?? 0).toString().padLeft(2, '0')} : ${(comment.createdAt?.minute ?? 0).toString().padLeft(2, '0')} ${(comment.createdAt?.hour ?? 0) < 12 ? 'AM' : 'PM'}',
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
                                    comment.comment ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),

                            // More options
                            // GestureDetector(
                            //   onTap: () {
                            //     // _showCommentOptions(comment);
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
                    },
                  ),
                ),

              // Bottom TextField with keyboard padding
              Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _commentController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: InputBorder.none,
                    hintText: "Add a comment...",
                    hintStyle: secondaryTextStyle(size: 14, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: appColorPrimary),
                      onPressed: () async {
                        if (_commentController.text.isEmpty) return;
                        final controller = (Get.isRegistered<VammisProfileController>())
                            ? Get.find<VammisProfileController>()
                            : Get.put(VammisProfileController());
                        await controller.commentOnPost(
                            widget.postId, _commentController.text.trim(),);
                        _commentController.clear();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
