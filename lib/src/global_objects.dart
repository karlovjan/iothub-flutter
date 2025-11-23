import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/global_preferences_repository.dart';

final preferences = GlobalPreferencesRepository();

OnBuilder<T> getFutureBuilder<T>({
  Key? key,
  required Future<T> Function() creator,
  required Widget Function(ReactiveModel<T> rm) builder,
  required void Function()? onWaiting,
  required void Function(dynamic err, VoidCallback refresh)? onError,
  T? initialData,
}) {
  return OnBuilder<T>.createFuture(
      initialState: initialData,
      creator: creator,
      builder: builder,
      sideEffects: SideEffects.onAll(
          onWaiting: onWaiting, onError: onError, onData: (data) {}));
}
