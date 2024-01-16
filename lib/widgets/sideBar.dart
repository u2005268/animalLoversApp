import 'package:animal_lovers_app/screens/donate.dart';
import 'package:animal_lovers_app/screens/feeds_history.dart';
import 'package:animal_lovers_app/screens/info.dart';
import 'package:animal_lovers_app/screens/login.dart';
import 'package:animal_lovers_app/screens/news.dart';
import 'package:animal_lovers_app/screens/observation_history.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:animal_lovers_app/widgets/sidebarListtile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);

  // @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: UserAccountsDrawerHeader(
                accountName: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Adjust the alignment as needed
                        children: [
                          Image.asset(
                            'images/anp.png',
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Animal Neighbours Project",
                          style: TextStyle(
                            color: Colors.black, // Set the text color to black
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                accountEmail: const Text(""),
                // currentAccountPicture: Center(child: Image.asset('images/anp.png')),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),
            SidebarListtile(
              icon: Icons.remove_red_eye_outlined,
              text: " My Observation",
              onTap: () {
                Navigator.pop(context); // Close the sidebar
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ObservationHistoryPage()),
                );
              },
            ),
            SidebarListtile(
              icon: Icons.rss_feed_outlined,
              text: "My Feeds",
              onTap: () {
                Navigator.pop(context); // Close the sidebar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedsHistoryPage()),
                );
              },
            ),
            // SidebarListtile(
            //   icon: Icons.notifications_none_outlined,
            //   text: "Notification",
            //   onTap: () => Navigator.pop(context),
            // ),
            SidebarListtile(
              icon: Icons.newspaper_outlined,
              text: "News",
              onTap: () {
                Navigator.pop(context); // Close the sidebar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsPage()),
                );
              },
            ),
            SidebarListtile(
              icon: Icons.monetization_on_outlined,
              text: "Donate",
              onTap: () {
                Navigator.pop(context); // Close the sidebar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonatePage()),
                );
              },
            ),
            SidebarListtile(
              icon: Icons.info_outline,
              text: "Info",
              onTap: () {
                Navigator.pop(context); // Close the sidebar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoPage()),
                );
              },
            ),
            SidebarListtile(
              icon: Icons.person_3_outlined,
              text: "Profile",
              onTap: () {
                Navigator.pop(context); // Close the sidebar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            SidebarListtile(
              icon: Icons.logout_outlined,
              text: "Logout",
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Do you really want to logout?"),
                        actions: [
                          MaterialButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No",
                                  style: TextStyle(color: Colors.blue))),
                          MaterialButton(
                              onPressed: () {
                                // Navigator.pop(context);
                                signOut(context);
                              },
                              child: Text("Yes",
                                  style: TextStyle(color: Colors.blue)))
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context); // Close the sidebar
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      showStatusPopup(context, true);
    } catch (e) {
      print("Error during sign-out: $e");
      showStatusPopup(context, false);
    }
  }

  void showStatusPopup(BuildContext context, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Container(
            width: 200.0,
            height: 200.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuccess
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 80.0,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                SizedBox(height: 20.0),
                Text(
                  isSuccess ? 'Successful' : 'Unsuccessful',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
