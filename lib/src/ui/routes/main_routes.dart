enum StaticPages { home, hubs, nasSync }

extension StaticPageRoute on StaticPages {
  String get routeName {
    const defaultRoute = '/';
    var route = defaultRoute;

    switch (this) {
      case StaticPages.home:
        route = defaultRoute;
        break;
      case StaticPages.hubs:
        route = '/hubs';
        break;
      case StaticPages.nasSync:
        route = '/nasSync';
        break;
    }

    return route;
  }
}
