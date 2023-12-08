import 'package:animal_lovers_app/screens/donate.dart';
import 'package:animal_lovers_app/screens/info.dart';
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
              text: "Observation",
              onTap: () => Navigator.pop(context),
            ),
            SidebarListtile(
              icon: Icons.rss_feed_outlined,
              text: "My Feeds",
              onTap: () => Navigator.pop(context),
            ),
            SidebarListtile(
              icon: Icons.notifications_none_outlined,
              text: "Notification",
              onTap: () => Navigator.pop(context),
            ),
            SidebarListtile(
              icon: Icons.newspaper_outlined,
              text: "News",
              onTap: () => Navigator.pop(context),
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
                              onPressed: () async {
                                Navigator.pop(context);
                                await GoogleSignIn().signOut();
                                FirebaseAuth.instance.signOut();
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
}
