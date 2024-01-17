import 'package:animal_lovers_app/screens/commentBottomSheet.dart';
import 'package:animal_lovers_app/screens/post_feed.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // Function to get user data by userId
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }

    // Return empty data if user not found
    return {};
  }

  // Function to check if the current user has liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      DocumentSnapshot postSnapshot =
          await FirebaseFirestore.instance.collection('feed').doc(postId).get();

      if (postSnapshot.exists) {
        final List<dynamic> likes = postSnapshot['likes'];

        // Check if the current user's ID is in the likes array
        return likes.contains(userId);
      }
    } catch (error) {
      print('Error checking if user has liked post: $error');
    }

    return false;
  }

  // Function to toggle like for a post
  void toggleLikeForPost(String postId, String userId) async {
    try {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('feed').doc(postId);

      bool hasLiked = await hasUserLikedPost(postId, userId);

      if (hasLiked) {
        // If the user has already liked the post, remove the like
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        // If the user has not liked the post, add the like
        await postRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (error) {
      print('Error toggling like for post: $error');
    }
  }

  void _openCommentInputBottomSheet(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CommentBottomSheet(postId: postId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Community",
      ),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostFeedPage()),
                    );
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('What’s on your mind......'),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Styles.secondaryColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('feed')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.data == null) {
                    return Text('');
                  }

                  final List<Widget> cardList =
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    final Map<String, dynamic>? data =
                        document.data() as Map<String, dynamic>?;

                    if (data != null) {
                      return FutureBuilder<Map<String, dynamic>>(
                        future: getUserData(data['userId']), // Fetch user data
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            // return CircularProgressIndicator();
                          }
                          if (userSnapshot.hasError) {
                            return Text('Error: ${userSnapshot.error}');
                          }

                          final userData = userSnapshot.data;
                          if (userData == null) {
                            // Handle the case where user data is null
                            return Text("");
                          }
                          final username = userData['username'] ?? '';
                          final userPhotoUrl = userData['photoUrl'] ?? '';

                          final postId = document.id;
                          final likes = data['likes'] ?? [];

                          // Check if the current user has liked this post
                          bool hasLiked = likes.contains(currentUser?.uid);

                          final feedTimestamp = data['timestamp'] as Timestamp;
                          final feedTime = feedTimestamp.toDate();
                          final timeDifference =
                              DateTime.now().difference(feedTime);

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

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: userPhotoUrl.isNotEmpty
                                                    ? Image.network(
                                                        userPhotoUrl)
                                                    : Image.asset(
                                                        'images/user.png'),
                                              ),
                                            ),
                                            Gap(8),
                                            Text(
                                              username,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              timeAgo,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 200,
                                      child: Image.network(
                                        data['imageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        data['description'],
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 10,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            hasLiked
                                                ? Icons.thumb_up
                                                : Icons.thumb_up_alt_outlined,
                                            color: hasLiked
                                                ? Styles.primaryColor
                                                : Colors.black,
                                          ),
                                          onPressed: () {
                                            // Toggle like for the post
                                            toggleLikeForPost(
                                                postId, currentUser?.uid ?? '');
                                          },
                                        ),
                                        Text(data['likes']?.length.toString() ??
                                            "0"),
                                        Gap(8),
                                        IconButton(
                                          icon:
                                              Icon(Icons.mode_comment_outlined),
                                          onPressed: () {
                                            _openCommentInputBottomSheet(
                                                postId);
                                          },
                                        ),
                                        Text(data['comments']
                                                ?.length
                                                .toString() ??
                                            "0"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // Handle the case where document data is missing
                      return Container(); // You can return an empty container or another placeholder widget
                    }
                  }).toList();

                  return ListView(
                    children: cardList,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
