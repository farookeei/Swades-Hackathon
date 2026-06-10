import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/views/auth_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive design size for mobile vs tablet devices
    final size = MediaQuery.sizeOf(context);
    final designSize = size.width > 600
        ? const Size(600, 1024) // Tablet layout reference
        : const Size(375, 812);  // Mobile layout reference

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'QuickSlot Booking',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const AuthScreen(),
        );
      },
    );
  }
}
