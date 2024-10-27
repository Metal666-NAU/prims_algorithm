import 'package:flutter/material.dart';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/root/root.dart' as root;
import 'pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  ThemeData get _appTheme {
    final flavor = catppuccin.mocha;

    final themeData = ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: flavor.mauve,
        onPrimary: flavor.base,
        secondary: flavor.maroon,
        onSecondary: flavor.base,
        tertiary: flavor.flamingo,
        onTertiary: flavor.base,
        surface: flavor.mantle,
        onSurface: flavor.text,
        error: flavor.red,
        onError: flavor.base,
      ),
    );

    return themeData.copyWith(
      cardTheme: themeData.cardTheme.copyWith(color: flavor.crust),
      sliderTheme: themeData.sliderTheme.copyWith(
        inactiveTrackColor: themeData.colorScheme.primary.withAlpha(64),
      ),
    );
  }

  const MyApp({super.key});

  @override
  Widget build(final context) => BlocProvider(
        create: (final context) => root.Bloc()..add(const root.Startup()),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: _appTheme,
          home: const HomePage(),
        ),
      );
}
