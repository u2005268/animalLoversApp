import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/showStatusPopUp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;

  const CommentBottomSheet({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final DateTime currentTime = DateTime.now();

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  void _submitComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final Timestamp timestamp = Timestamp.fromDate(currentTime);

    if (currentUser == null || _commentController.text.isEmpty) {
      return;
    }

    final comment = _commentController.text;
    final commentId = '${currentUser.uid}_${timestamp.seconds}';

    try {
      // Update the 'comments' field array within the post document
      await FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postId)
          .update({
        'comments': FieldValue.arrayUnion([
          {
            'commentId': commentId,
            'userId': currentUser.uid,
            'comment': comment,
            'timestamp': timestamp,
          },
        ]),
      });

      // Clear the comment text field
      _commentController.clear();
    } catch (error) {
      print('Error adding comment: $error');
    }
  }

  // Method to check if the current user is the owner of the post
  bool isPostOwner(String userId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && userId == currentUser.uid;
  }

  // Method to check if the current user is the owner of the comment
  bool isCommentOwner(String userId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && userId == currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.7, // Adjust the height as needed
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(color: Styles.primaryColor, width: 1.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: Styles.primaryColor),
                onPressed: _submitComment,
              ),
            ),
          ),
          Gap(5),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('feed')
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // return CircularProgressIndicator(); // Loading indicator
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('No comments available');
                }

                final postDocument = snapshot.data as DocumentSnapshot;
                final comments = postDocument['comments'] as List<dynamic>;

                // Sort the comments list based on timestamp
                final sortedComments = List.from(comments);
                sortedComments.sort((a, b) => (b['timestamp'] as Timestamp)
                    .compareTo(a['timestamp'] as Timestamp));

                if (sortedComments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "No comments yet......",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: sortedComments.length,
                    itemBuilder: (context, index) {
                      final commentData =
                          sortedComments[index] as Map<String, dynamic>;
                      final userId = commentData['userId'];

                      // Check if the current user is the owner of the post or the comment
                      bool canDeleteComment =
                          isPostOwner(widget.postId) || isCommentOwner(userId);

                      return FutureBuilder(
                        future: _fetchUserData(userId),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData ||
                              userSnapshot.data == null) {
                            return ListTile(
                              title: Text('Loading...'),
                            );
                          }

                          final userData =
                              userSnapshot.data as Map<String, dynamic>;

                          final username = userData.containsKey('username')
                              ? userData['username']
                              : 'Unknown';

                          final commentText = commentData.containsKey('comment')
                              ? commentData['comment']
                              : 'No comment available';

                          final userPhotoUrl = userData['photoUrl'];

                          final commentTimestamp =
                              commentData['timestamp'] as Timestamp;
                          final commentTime = commentTimestamp.toDate();
                          final timeDifference =
                              DateTime.now().difference(commentTime);

                          String timeAgo;

                          if (timeDifference.inDays >= 365) {
                            final years = (timeDifference.inDays / 365).floor();
                            timeAgo = '$years ${years == 1 ? 'year' : 'years'}';
                          } else if (timeDifference.inDays >= 30) {
                            final months = (timeDifference.inDays / 30).floor();
                            timeAgo =
                                '$months ${months == 1 ? 'month' : 'months'}';
                          } else if (timeDifference.inDays >= 1) {
                            timeAgo =
                                '${timeDifference.inDays} ${timeDifference.inDays == 1 ? 'day' : 'days'}';
                          } else if (timeDifference.inHours >= 1) {
                            timeAgo =
                                '${timeDifference.inHours} ${timeDifference.inHours == 1 ? 'hour' : 'hours'}';
                          } else if (timeDifference.inMinutes >= 1) {
                            timeAgo =
                                '${timeDifference.inMinutes} ${timeDifference.inMinutes == 1 ? 'minute' : 'minutes'}';
                          } else {
                            timeAgo =
                                '${timeDifference.inSeconds} ${timeDifference.inSeconds == 1 ? 'second' : 'seconds'}';
                          }

                          return Card(
                            elevation: 2.0,
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5.0),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(username),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(commentText),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: userPhotoUrl != null
                                    ? Image.network(
                                        userPhotoUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'images/user.png',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              onLongPress: () {
                                // Check if the current user is the owner of the post or the comment
                                if (canDeleteComment) {
                                  _showDeleteConfirmationDialog(
                                      widget.postId,
                                      commentData['commentId'],
                                      commentData['comment'],
                                      commentData['userId'],
                                      commentData['timestamp'] as Timestamp);
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to show a delete confirmation dialog for comments
  void _showDeleteConfirmationDialog(String postId, String commentId,
      String comment, String userId, Timestamp timestamp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete"),
          content: Text("Are you sure you want to delete this comment?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "No",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform the delete operation
                _deleteComment(postId, commentId, comment, userId, timestamp);
                Navigator.of(context).pop();
              },
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to delete a comment
  void _deleteComment(String postId, String commentId, String comment,
      String userId, Timestamp timestamp) async {
    try {
      await FirebaseFirestore.instance.collection('feed').doc(postId).update({
        'comments': FieldValue.arrayRemove([
          {
            'commentId': commentId,
            'userId': userId,
            'comment': comment,
            'timestamp': timestamp,
          },
        ]),
      });
      // Show a success message
      showStatusPopup(context, true);
    } catch (error) {
      print('Error deleting comment: $error');
      showStatusPopup(context, false);
    }
  }
}
