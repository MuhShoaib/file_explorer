import 'package:flutter/material.dart';

void showDepth(Map<String, dynamic> item, int depth, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Depth'),
        content: Text('Depth of ${item['title']} is $depth'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
