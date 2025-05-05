class DioBaseNetworkConfig {
  static final DioBaseNetworkConfig _instance =
      DioBaseNetworkConfig._internal();

  factory DioBaseNetworkConfig() => _instance;

  DioBaseNetworkConfig._internal();

  String nowVersionIos = "1.0.0";
  String nowVersionAndroid = "1.0.0";
  String? authorizationToken;
  String? language;
  String? appVersion;
  String? xApiKey;
  Map<String, String>? additionalHeaders;

  void updateConfig(
      {String? nowVersionIos,
      String? nowVersionAndroid,
      String? authorizationToken,
      String? shopCity,
      String? language,
      String? xApiKey,
      String? appVersion,
      Map<String, String>? additionalHeaders}) {
    this.nowVersionIos = nowVersionIos ?? this.nowVersionIos;
    this.nowVersionAndroid = nowVersionAndroid ?? this.nowVersionAndroid;
    this.authorizationToken = authorizationToken;
    this.language = language;
    this.appVersion = appVersion;
    this.xApiKey = xApiKey;
    this.additionalHeaders = additionalHeaders;
  }
}
