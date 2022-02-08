import 'package:flutter/material.dart';

abstract class DataLoadingIndicator extends StatelessWidget {
  const DataLoadingIndicator(
    this._title, {
    Key? key,
  }) : super(key: key);

  // Fields in a Widget subclass are always marked "final".

  final Widget _title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          _title,
        ],
      ),
    );
  }
}

class DataLoadingIndicatorTitle extends StatelessWidget {
  const DataLoadingIndicatorTitle(
    this._title, {
    Key? key,
  }) : super(key: key);

  final String _title;

  @override
  Widget build(BuildContext context) {
    return Text(
      _title,
      style: Theme.of(context).primaryTextTheme.headline6,
    );
  }
}

class CommonDataLoadingIndicator extends DataLoadingIndicator {
  static const LOADING_TEXT = 'Data loading ...';

  const CommonDataLoadingIndicator({
    Key? key,
  }) : super(const DataLoadingIndicatorTitle(LOADING_TEXT), key: key);
}

class LoggingIndicator extends DataLoadingIndicator {
  static const LOGGING_TEXT = 'Logging ...';

  const LoggingIndicator({
    Key? key,
  }) : super(const DataLoadingIndicatorTitle(LOGGING_TEXT), key: key);
}

class PreferencesLoadingIndicator extends DataLoadingIndicator {
  static const LOADING_TEXT = 'Logging preferences...';

  const PreferencesLoadingIndicator({
    Key? key,
  }) : super(const DataLoadingIndicatorTitle(LOADING_TEXT), key: key);
}
