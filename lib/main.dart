import 'package:flutter/material.dart';
import 'package:letschat/UI/pages/onboarding/onboarding.dart';
import 'package:letschat/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lets Chat',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
      home: Onboarding(),
    );
  }
}
