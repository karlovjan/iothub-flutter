enum StaticPages { home, globalPreferences, iotHUBApp, nasSync }

extension StaticPageRoute on StaticPages {
  String get routeName {
    const defaultRoute = '/';

    switch (this) {
      case StaticPages.home:
        return defaultRoute;
      case StaticPages.globalPreferences:
        return '/globalPreferences';
      case StaticPages.iotHUBApp:
        return '/iotHUBApp';
      case StaticPages.nasSync:
        return '/nasSync';
      default:
        return defaultRoute;
    }

  }
}
