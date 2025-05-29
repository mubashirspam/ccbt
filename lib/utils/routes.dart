import '../view/view.dart';

class Routes {
  static const String home = '/';
  static const String survey = '/survey';
  static const String question = '/question';
  static const String options = '/options';
  static const String answers = '/answers';
}

final routes = {
  Routes.home: (context) => const HomeScreen(),
  Routes.answers: (context) => const UserManagementScreen(),
};
