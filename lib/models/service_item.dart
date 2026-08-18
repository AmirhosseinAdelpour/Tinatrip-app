import 'package:flutter/material.dart';

enum ServiceAccent { primary, secondary, accent, error }

class ServiceItem {
  final String label;
  final IconData icon;
  final String? url;
  final ServiceAccent accent;
  final bool opensForm;

  const ServiceItem({
    required this.label,
    required this.icon,
    this.url,
    required this.accent,
    this.opensForm = false,
  });
}

class TravelTool {
  final String label;
  final IconData icon;
  final String url;

  const TravelTool({
    required this.label,
    required this.icon,
    required this.url,
  });
}
