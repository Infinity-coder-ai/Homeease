import 'package:flutter/material.dart';

/// Multi-select weekday picker for availability slots.
class DaysPickerDialog extends StatefulWidget {
  const DaysPickerDialog({super.key});

  @override
  State<DaysPickerDialog> createState() => _DaysPickerDialogState();
}

class _DaysPickerDialogState extends State<DaysPickerDialog> {
  final Set<int> _days = <int>{};

  void _toggle(int value) {
    setState(() {
      if (_days.contains(value)) {
        _days.remove(value);
      } else {
        _days.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick days'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dayCheckbox('Monday', 0),
          _dayCheckbox('Tuesday', 1),
          _dayCheckbox('Wednesday', 2),
          _dayCheckbox('Thursday', 3),
          _dayCheckbox('Friday', 4),
          _dayCheckbox('Saturday', 5),
          _dayCheckbox('Sunday', 6),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _days.isEmpty ? null : () => Navigator.pop(context, _days.toList()),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _dayCheckbox(String label, int value) {
    return CheckboxListTile(
      value: _days.contains(value),
      onChanged: (_) => _toggle(value),
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
