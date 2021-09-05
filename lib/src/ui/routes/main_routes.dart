enum StaticPages { home, iotHUBApp, nasSync }

extension StaticPageRoute on StaticPages {
  String get routeName {
    const defaultRoute = '/';

    switch (this) {
      case StaticPages.home:
        return defaultRoute;
      case StaticPages.iotHUBApp:
        return '/iotHUBApp';
      case StaticPages.nasSync:
        return '/nasSync';
      default:
        return defaultRoute;
    }

  }
}
