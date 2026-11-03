import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/router.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/household_provider.dart';
import 'providers/item_provider.dart';
import 'services/auth_service.dart';
import 'services/household_service.dart';
import 'services/item_service.dart';
import 'services/user_service.dart';

Future<void> main() async {
  // Necessário antes de qualquer plugin ser usado antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR');

  final authProvider = AuthProvider(AuthService(UserService()));
  final householdProvider = HouseholdProvider(HouseholdService(), authProvider);
  final itemProvider = ItemProvider(ItemService(), householdProvider);
  runApp(
    App(
      authProvider: authProvider,
      householdProvider: householdProvider,
      itemProvider: itemProvider,
      router: createRouter(authProvider, householdProvider),
    ),
  );
}
