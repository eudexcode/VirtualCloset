import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context).welcomeMessage,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}