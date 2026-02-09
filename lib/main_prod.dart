import 'app_bootstrap.dart';
import 'core/config/app_config.dart';

void main() {
  final config = AppConfig.prod();
  
  bootstrap(config);
}
