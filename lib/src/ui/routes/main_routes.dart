enum StaticPages { home, hubs, nasSync }

extension StaticPageRoute on StaticPages {
  String get routeName {
    const defaultRoute = '/';

    switch (this) {
      case StaticPages.home:
        return defaultRoute;
      case StaticPages.hubs:
        return '/hubs';
      case StaticPages.nasSync:
        return '/nasSync';
      default:
        return defaultRoute;
    }

  }
}
