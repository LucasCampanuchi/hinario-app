import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../layout/colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      debugShowCheckedModeBanner: false,
      title: 'Hinário',
      theme: ThemeData(
        // Cores principais - usando colorScheme como base
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.newPrimary,
          primary: AppColors.newPrimary,
          secondary: AppColors.newPrimary,
        ),
        scaffoldBackgroundColor: Colors.white,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.newPrimary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),

        // Inputs / TextFields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.newPrimary, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: AppColors.newPrimary.withOpacity(0.5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.newPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: TextStyle(color: AppColors.newPrimary),
          hintStyle: TextStyle(color: AppColors.newPrimary.withOpacity(0.6)),
          floatingLabelStyle: TextStyle(color: AppColors.newPrimary),
          prefixIconColor: AppColors.newPrimary,
          suffixIconColor: AppColors.newPrimary,
        ),

        // Botões Elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.newPrimary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        // Botões de Texto
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.newPrimary,
          ),
        ),

        // Botões Outlined
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.newPrimary,
            side: BorderSide(color: AppColors.newPrimary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // FloatingActionButton
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.newPrimary,
          foregroundColor: Colors.white,
        ),

        // Progress Indicators
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColors.newPrimary,
          linearTrackColor: AppColors.newPrimary.withOpacity(0.2),
          circularTrackColor: AppColors.newPrimary.withOpacity(0.2),
        ),

        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.newPrimary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
        ),

        // Radio
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.newPrimary;
            }
            return AppColors.newPrimary.withOpacity(0.6);
          }),
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.newPrimary;
            }
            return Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.newPrimary.withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.3);
          }),
        ),

        // Slider
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.newPrimary,
          thumbColor: AppColors.newPrimary,
          inactiveTrackColor: AppColors.newPrimary.withOpacity(0.3),
        ),

        // TabBar
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.newPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.newPrimary,
        ),

        // Card
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Divider
        dividerTheme: DividerThemeData(
          color: AppColors.newPrimary.withOpacity(0.2),
          thickness: 1,
        ),

        // Icon Theme
        iconTheme: IconThemeData(
          color: AppColors.newPrimary,
        ),

        // Usar useMaterial3 para evitar problemas de compatibilidade
        useMaterial3: true,
      ),
    );
  }
}
