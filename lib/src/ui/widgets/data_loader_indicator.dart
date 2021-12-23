import 'package:flutter/material.dart';

abstract class DataLoadingIndicator extends StatelessWidget {
  DataLoadingIndicator(this._title);

  // Fields in a Widget subclass are always marked "final".

  final Widget _title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          _title,
        ],
      ),
    );
  }
}

class DataLoadingIndicatorTitle extends StatelessWidget {
  DataLoadingIndicatorTitle(this._title);

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

  CommonDataLoadingIndicator() : super(DataLoadingIndicatorTitle(LOADING_TEXT));
}

class LoggingIndicator extends DataLoadingIndicator {
  static const LOGGING_TEXT = 'Logging ...';

  LoggingIndicator() : super(DataLoadingIndicatorTitle(LOGGING_TEXT));
}
