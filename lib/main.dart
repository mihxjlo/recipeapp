import 'package:flutter/material.dart';
import 'package:recipe_app/services/notification_service.dart';
import 'screens/categories_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    await NotificationService().scheduleDailyRecipeNotification(
      hour: now.hour,
      minute: now.minute + 2,
    );
    print('Test: Notification set for ${now.hour}:${now.minute + 2}');
  } catch(e) {
    print('Error initializing: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Recipes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const CategoriesScreen(),
    );
  }
}
