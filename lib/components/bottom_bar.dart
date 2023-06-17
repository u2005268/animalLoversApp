import 'package:animal_lovers_app/screens/animal_tracker.dart';
import 'package:animal_lovers_app/screens/donate.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  // static final List<Widget> _widgetOptions = <Widget>[
  //   AnimalTracker(),
  //   // const Text("Identify"),
  //   ProfilePage(),
  //   const Text("Species"),
  //   const Text("Community")
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Use Navigator to navigate to the selected page based on the index
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimalTracker()),
        );
      }
      // else if (index == 2) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ProfilePage()),
      //   );
      // }
    });
    // print('Tapped index is ${_selectedIndex}');
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Color(0xFF1B4332).withOpacity(0.7),
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Color(0xFF0F281D),
      backgroundColor:
          Color(0xFFD7FFD7), // Set the background color to transparent
      items: [
        BottomNavigationBarItem(
            icon: Transform.scale(
              scale:
                  1.5, // Adjust the scale value as needed to make the icon bigger
              child: ImageIcon(
                AssetImage('images/track.png'),
              ),
            ),
            label: "Tracker"),
        BottomNavigationBarItem(
            icon: Transform.scale(
              scale:
                  1.5, // Adjust the scale value as needed to make the icon bigger
              child: ImageIcon(
                AssetImage('images/identify.png'),
              ),
            ),
            label: "Identifier"),
        BottomNavigationBarItem(
            icon: Transform.scale(
              scale:
                  1.5, // Adjust the scale value as needed to make the icon bigger
              child: ImageIcon(
                AssetImage('images/species.png'),
              ),
            ),
            label: "Species"),
        BottomNavigationBarItem(
            icon: Transform.scale(
              scale:
                  1.5, // Adjust the scale value as needed to make the icon bigger
              child: ImageIcon(
                AssetImage('images/community.png'),
              ),
            ),
            label: "Community"),
      ],
    );
  }
}
