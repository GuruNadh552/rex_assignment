import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/claims_provider.dart';
import 'services/claims_service.dart';
import 'screens/startup_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ClaimsProvider(
            LocalClaimsService(),
          ),
        ),
      ],
      child: const RexApp(),
    ),
  );
}

class RexApp extends StatelessWidget {
  const RexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const StartupScreen(),
    );
  }
}