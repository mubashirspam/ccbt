import 'package:flutter/material.dart';

import 'participant_widget.dart';
import 'person_widget.dart';
import 'response_widget.dart';

class UserManagementScreen extends StatelessWidget {
  static const String routeName = '/answers';
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const PersonWidget(),
      const ParticipantWidget(),
      const ResponseWidget(),
    ];
    return Scaffold(
      body: Row(
        children: [
          ...List.generate(
            screens.length,
            (index) => Expanded(
              child: Container(
                // padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16).copyWith(right: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // color: Theme.of(context).colorScheme.onPrimary,
                  border: Border.all(
                      color: Theme.of(context).colorScheme.primaryContainer),
                ),
                child: screens[index],
              ),
            ),
          ),
          SizedBox(width: 16)
        ],
      ),
    );
  }
}
