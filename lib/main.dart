import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'provider/provider.dart';
import 'utils/routes.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initializeApp();
  runApp(const MyApp());
}

Future<void> initializeApp() async {
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SurveyProvider()),
          ChangeNotifierProvider(create: (_) => QuestionProvider()),
          ChangeNotifierProvider(create: (_) => AnswerOptionProvider()),
          ChangeNotifierProvider(create: (_) => ParticipantProvider()),
          ChangeNotifierProvider(create: (_) => ResponseProvider()),
          ChangeNotifierProvider(create: (_) => PersonProvider()),

        ],
        child: MaterialApp(
          title: 'Autographa Survey Dashboard',
          debugShowCheckedModeBanner: false,
          onGenerateRoute: (settings) {
            final route = settings.name;
            final builder = routes[route];
            if (builder != null) {
              return MaterialPageRoute(builder: builder);
            } else {
              return null;
            }
          },
          theme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            useMaterial3: true,
          ),
          initialRoute: Routes.home,
          routes: routes,
        ));
  }
}
