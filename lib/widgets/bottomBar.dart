import 'package:animal_lovers_app/screens/animal_tracker.dart';
import 'package:animal_lovers_app/screens/community_board.dart';
import 'package:animal_lovers_app/screens/identify.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:animal_lovers_app/screens/species.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    AnimalTracker(),
    ProfilePage(),
    SpeciesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Use Navigator to navigate to the selected page based on the index
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimalTracker()),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => IdentifyPage()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SpeciesPage()),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CommunityPage()),
        );
      }
    });
    // print('Tapped index is ${_selectedIndex}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Styles.secondaryColor
        ], // Specify your gradient colors
      )), // Customize the background color here
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Styles.primaryColor,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Styles.primaryColor,
        backgroundColor: Colors.transparent,
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
      ),
    );
  }
}
