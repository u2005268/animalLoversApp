import 'package:flutter/material.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:gap/gap.dart';

class SpeciesInfoPage extends StatelessWidget {
  final Map<String, String> speciesData;
  final VoidCallback toggleFavoriteStatus;

  SpeciesInfoPage({
    required this.speciesData,
    required this.toggleFavoriteStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "",
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Styles.secondaryColor,
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_left_sharp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${speciesData['commonName']}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${speciesData['scientificName']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Gap(10),
            // Add a bordered table for displaying additional information
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    buildTableRow('Class', speciesData['class']),
                    buildTableRow('Order', speciesData['order']),
                    buildTableRow('Main Prey', speciesData['main_prey']),
                    buildTableRow('Habitat', speciesData['habitat']),
                    buildTableRow('Predators', speciesData['predators']),
                    buildTableRow('Diet', speciesData['diet']),
                    buildTableRow(
                        'Favourite Food', speciesData['favorite_food']),
                    buildTableRow('Color', speciesData['color']),
                    buildTableRow('Skin Type', speciesData['skin_type']),
                    buildTableRow('Lifespan', speciesData['lifespan']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow buildTableRow(String label, String? value) {
    return TableRow(
      children: [
        TableCell(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Styles.primaryColor,
                width: 2.0,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 50.0, // Set a minimum height for the cell
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Styles.primaryColor,
                width: 2.0,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 50.0, // Set a minimum height for the cell
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
