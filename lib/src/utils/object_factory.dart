class ObjectFactory {
  static final Map<Type, Function> _factories = {};

  static void registerFactory<T>(T Function(Map<String, dynamic>) factory) {
    _factories[T] = factory;
  }

  static T? create<T>(Map<String, dynamic> json) {
    final factory = _factories[T];
    if (factory != null) {
      return factory(json) as T;
    }
    return null;
  }
}
