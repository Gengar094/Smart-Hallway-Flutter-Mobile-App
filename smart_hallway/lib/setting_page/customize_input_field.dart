import 'package:flutter/material.dart';

class CustomTextInputField extends StatefulWidget {
  final String title;
  final String value;
  final Function(String) onChange;
  final Function() showDialog;

  CustomTextInputField({
    required this.title,
    required this.value,
    required this.onChange,
    required this.showDialog,
  });

  @override
  _CustomTextInputFieldState createState() => _CustomTextInputFieldState();
}

class _CustomTextInputFieldState extends State<CustomTextInputField> {
  String _fieldValue = '';

  @override
  void initState() {
    super.initState();
    _fieldValue = widget.value;
  }

  Future<void> _showEditDialog(BuildContext context) async {
    if (!widget.showDialog()) {
      _showError();
    } else {
      TextEditingController _controller = TextEditingController(
          text: _fieldValue);

      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.title),
            content: TextField(
              controller: _controller,
              onChanged: (newValue) {
                setState(() {
                  _fieldValue = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'New value',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  widget.onChange(_fieldValue);
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showError () {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Connection error'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK')),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: Text(_fieldValue),
      onTap: () {
        _showEditDialog(context);
      },
    );
  }
}