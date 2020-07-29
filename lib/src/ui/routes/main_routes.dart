enum StaticPages{
  home, hubs
}


extension StaticPageRoute on StaticPages {
  String get routeName {
    const defaultRoute = '/';
    var route = defaultRoute;

    switch(this){
      case StaticPages.home:
        route = defaultRoute;
        break;
      case StaticPages.hubs:
        route = '/hubs';
        break;
    }

    return route;
  }

}