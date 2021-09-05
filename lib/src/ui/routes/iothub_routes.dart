import 'package:iothub/src/ui/routes/main_routes.dart';

enum IOTHUBStaticPages { hubs, devices, dashboard }

extension IOTHUBStaticPageRoute on IOTHUBStaticPages {
  String get routeName {
    switch (this) {
      case IOTHUBStaticPages.hubs:
        return '/hubs';
      case IOTHUBStaticPages.dashboard:
        return '/dashboard';
      case IOTHUBStaticPages.devices:
        return '/devices';
    }
  }

  String get fullPath {
    return StaticPages.iotHUBApp.routeName + routeName;
  }
}
