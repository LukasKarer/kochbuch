import 'dart:io';

import 'package:Kochbuch/material/activies/login_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cupertino/main_cupertino.dart';
import 'material/main_material.dart';

void main() async {
  await Supabase.initialize(
    url: "https://mamausggsgxpogzksyxf.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hbWF1c2dnc2d4cG9nemtzeXhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2Nzg2NTc1NTcsImV4cCI6MTk5NDIzMzU1N30.MzVJS3joALez96BvFIZp0jmq0O_GasKHgE_VsjYYwdk",
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  static final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue);
  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue, brightness: Brightness.dark);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const MaterialHomePage(pageIndex: 0, reload: true),
      );
    });
  }
}




