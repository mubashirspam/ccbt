import 'package:flutter/material.dart';
import '../users/user_management_screen.dart';
import 'survey_widget.dart';
import 'question_widget.dart';
import 'options_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeContent(),
    const UserManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16).copyWith(bottom: 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Theme.of(context).colorScheme.primaryContainer),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Row(
                    children: [
                      Image.asset('assets/images/logo.png',
                          width: 40, height: 40),
                      SizedBox(width: 16),
                      Text(
                        'Autographa Survey',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 400,
                  height: 50,
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    splashBorderRadius: BorderRadius.circular(100),
                    dividerHeight: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                    labelStyle: const TextStyle(color: Colors.white),
                    tabs: [Tab(text: 'Home'), Tab(text: 'Users')],
                    onTap: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
                SizedBox(width: 100)
              ],
            ),
          ),
          Expanded(child: _screens[_selectedIndex])
        ],
      )),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const SurveyWidget(),
      const QuestionWidget(),
      const OptionsWidget(),
    ];
    return Row(children: [
      ...List.generate(
        screens.length,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.all(16).copyWith(right: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Theme.of(context).colorScheme.primaryContainer),
            ),
            child: screens[index],
          ),
        ),
      ),
      SizedBox(width: 16)
    ]);
  }
}
