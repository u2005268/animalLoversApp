import 'package:flutter/material.dart';

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
                isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
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
