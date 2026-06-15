enum Flavor { prod, dev }

class AppConfig {
  String appName = "";
  String baseUrl = "";
  Flavor flavor = Flavor.dev;

  static AppConfig shared = AppConfig.create();

  factory AppConfig.create({
    String appName = "",
    String baseUrl = "",
    Flavor flavor = Flavor.dev,
  }) {
    return shared = AppConfig(appName, baseUrl, flavor);
  }
  AppConfig(this.appName, this.baseUrl, this.flavor);
}