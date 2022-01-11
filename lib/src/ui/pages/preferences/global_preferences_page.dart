import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum AppTheme {
  light,
  dark,
}

final InjectedTheme theme = RM.injectTheme<AppTheme>(
  lightThemes: {
    AppTheme.light: ThemeData.light(),
    AppTheme.dark: ThemeData.light()
  },
  darkThemes: {
    AppTheme.light: ThemeData.dark(),
    AppTheme.dark: ThemeData.dark(),
  },
  persistKey: 'appTheme',
);

class GlobalPreferencesPage extends StatelessWidget {
  const GlobalPreferencesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OnReactive(
          () => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Dark theme'),
                  const SizedBox(
                    width: 8,
                  ),
                  Switch(
                    value: theme.isDarkTheme,
                    onChanged: (_) => theme.toggle(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
