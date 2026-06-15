


import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/auth_provider.dart';
import '../providers/rides_provider.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<AuthVm>(create: (_) => AuthVm()),
  ChangeNotifierProvider<RideProvider>(create: (_) => RideProvider()),
];