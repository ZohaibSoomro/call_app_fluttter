import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final String okBtnText;

  const ConfirmationDialog(
      {super.key, required this.onConfirm, this.okBtnText = 'Delete'});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmation'),
      content: const Text("Are you sure you want to delete this conversation?"),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: Text(
            okBtnText,
            style: TextStyle(
              color: okBtnText == "Delete" ? Colors.red : Colors.black,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            onConfirm(); // Execute the callback
          },
        ),
      ],
    );
  }
}
