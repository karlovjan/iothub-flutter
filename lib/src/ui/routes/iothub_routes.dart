import 'package:iothub/src/ui/routes/main_routes.dart';

enum IOTHUBStaticPages{
  devices
}

extension IOTHUBStaticPageRoute on IOTHUBStaticPages {
  String get routeName {
    var route = StaticPages.hubs.routeName;

    switch(this){
      case IOTHUBStaticPages.devices:
        route += '/devices';
        break;
    }

    return route;
  }

}