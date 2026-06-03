import 'package:flutter/material.dart';

class AvailabilitySlot {
  final int dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const AvailabilitySlot({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}
