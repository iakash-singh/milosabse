import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:milo/providers/user_provider.dart';
import 'package:milo/resources/auth_methods.dart';
import 'package:milo/screens/home_screen.dart';
import 'package:milo/screens/login_screen.dart';
import 'package:milo/screens/onboarding_screen.dart';
import 'package:milo/screens/signup_screen.dart';
import 'package:milo/utils/colors.dart';
import 'package:milo/widgets/loading_indicator.dart';
import 'models/user.dart' as model;
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD6UMs89-4zeoMjVdLipMT8Zlu9Vw1dpuY",
        authDomain: "milo-39b58.firebaseapp.com",
        projectId: "milo-39b58",
        storageBucket: "milo-39b58.appspot.com",
        messagingSenderId: "111573583011",
        appId: "1:111573583011:web:16fe14c50221d5f9b16b16",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Milo',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: backgroundColor,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: primaryColor,
          ),
        ),
      ),
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      home: FutureBuilder(
        future: AuthMethods()
            .getCurrentUser(FirebaseAuth.instance.currentUser != null
                ? FirebaseAuth.instance.currentUser!.uid
                : null)
            .then((value) {
          if (value != null) {
            Provider.of<UserProvider>(context, listen: false).setUser(
              model.User.fromMap(value),
            );
          }
          return value;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
