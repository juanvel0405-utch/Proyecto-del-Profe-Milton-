import 'package:flutter/material.dart';

import 'splash.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "playBloc",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xff3966da),
        appBarTheme: AppBarTheme(backgroundColor: const Color(0xff28a0e5)),
      ),
      home: const SplashScreen(),
    );
  }
}
