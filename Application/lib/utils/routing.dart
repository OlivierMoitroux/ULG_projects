import '../pages/lorem_page.dart';
import 'package:gps_tracer/pages/settings/privacy_policy_tmp.dart';
import 'package:gps_tracer/pages/settings/about_page.dart';
import 'package:gps_tracer/pages/auth/register_page.dart';
import 'package:gps_tracer/pages/debug/rights_manager_page.dart';
import 'package:gps_tracer/pages/debug/background_state_page.dart';
import 'package:gps_tracer/pages/debug/settings_debug_page.dart';
import 'package:gps_tracer/pages/debug/background_config_page.dart';
import 'package:gps_tracer/pages/debug/coord_list_page.dart';
import 'package:gps_tracer/pages/debug/trajectory_list_page.dart';

/// The set of routes to navigate between screens
final routes = {
  '/lorem': (context) => new LoremPage(),
  '/privacy_policy_tmp' : (context) => new PrivacyPolicyPage(),
  '/about' : (context) => new AboutPage(),
  '/register_page' : (context) => new RegisterPage(),
  '/rights_manager': (context) => new RightsPage(),
  '/background_state' : (context) => new BackgroundStatePage(),
  '/background_config' : (context) => new BackgroundConfigPage(),
  '/debug_settings_page' : (context) => new SettingsDebugPage(),
  '/coordinates_list_page' : (context) => new CoordinatesListPage(),
  '/trajectory_list_page' : (context) => new TrajectoryListPage(),
};