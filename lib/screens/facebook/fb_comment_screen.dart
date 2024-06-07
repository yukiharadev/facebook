import 'package:facebook/models/facebook/comment.model.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import '../../models/facebook/post.model.dart';
import '../../models/users.model.dart';
import '../../services/firebase_service.dart';
import '../../utils/facebook/fb_colors.dart';
import "package:firebase_auth/firebase_auth.dart" as auth;

class CommentScreen extends StatefulWidget {
  final String postId;
   CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommemtScreenState();
}

class _CommemtScreenState extends State<CommentScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _commentController = TextEditingController();

  void _createComment(){
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if(currentUser != null){
      _authService.createComment(
        newsId: widget.postId,
        userId: currentUser.uid,
        commentContent: _commentController.text,
      );
      _commentController.clear();
    }
  }

  @override
Widget build(BuildContext context) {
  return FutureBuilder<PostFacebookModel?>(
    future: AuthService().getPostById(widget.postId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      if (snapshot.hasData) {
        PostFacebookModel post = snapshot.data!;
        return FutureBuilder<User?>(
          future: AuthService().getUserById(post.userId),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                )
              );
            }

            if (userSnapshot.hasError) {
              return Text('Error: ${userSnapshot.error}');
            }

            if (userSnapshot.hasData) {
              User user = userSnapshot.data!;
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title:
                   Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.avatarUrl),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                  fontSize: 12, color: button_bottombar_not_selected),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${post.createdAt} - ",
                                  style:  const TextStyle(
                                      fontSize: 8,
                                      color: button_bottombar_not_selected),
                                ),
                                const Icon(
                                  Icons.public,
                                  size: 12,
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_horiz) ,
                      onPressed: () {  },
                    )
                  ],
                ),
                body:  SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ReadMoreText(
                            post.content,
                            trimLines: 2,
                            style: const TextStyle(fontSize: 12, color: Colors.black),
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'Show more',
                            moreStyle: const TextStyle(fontSize: 11, color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      // Image Layout Viewer
                      MultiImageViewer(
                        images: post.imageUrls
                            .map((url) => ImageModel(imageUrl: url))
                            .toList(),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up),
                                    onPressed: () {},
                                  ),
                                  const Text('Like')
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.comment),
                                    onPressed: () {},
                                  ),
                                  const Text('Comment')
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {},
                                  ),
                                  const Text('Share')
                                ],
                              )
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                        children:[
                                          const SizedBox(width: 5,),
                                          const Icon(Icons.thumb_up),
                                          const SizedBox(width: 5,),
                                          Text(post.likes.toString())
                                        ]
                                    ),
                                    const Text("45 Share")
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                StreamBuilder<List<CommentsFacebookModel>>(
                                  stream: _authService.getComments(widget.postId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                                      return SizedBox.shrink();
                                    }
                                    List<CommentsFacebookModel> comments = snapshot.data!;
                                    return ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        return CommentCard(comment: comments[index]);
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                bottomSheet: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 10,),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 5,),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _createComment,
                      )
                    ],
                  ),
                ),
              );
            } else {
              return const Text('No user found');
            }
          },
        );
      } else {
        return const Text('No post found');
      }
    },
  );
}
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

}
class CommentCard extends StatelessWidget {
  final CommentsFacebookModel comment;

  CommentCard({
    Key? key, required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FutureBuilder<User?>(
        future: AuthService().getUserById(comment.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            User user = snapshot.data!;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Comment content
                        Text(comment.commentContent),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Text('No user found');
          }
        },
      ),
    );
  }
}
