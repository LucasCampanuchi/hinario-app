import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../layout/colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      debugShowCheckedModeBanner: false,
      title: 'Hinário',
      builder: (context, child) => SafeArea(
        top: false,
        bottom: true,
        child: child ?? const SizedBox.shrink(),
      ),
      theme: ThemeData(
        // Cores principais - usando colorScheme como base
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.newPrimary,
          primary: AppColors.newPrimary,
          secondary: AppColors.newPrimary,
        ),
        scaffoldBackgroundColor: Colors.white,

        // Transição das telas abertas com Navigator (playlists, sala ao vivo...).
        // A padrão do Android (zoom) troca a árvore de widgets no início da
        // volta e o leitor de PDF quebra ("RenderBox was not laid out:
        // RenderTransform"). Usamos o mesmo deslize com fade das rotas do
        // Modular, que mantém a árvore estável durante a animação.
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: SlideFadePageTransitionsBuilder()},
        ),

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
              color: AppColors.newPrimary.withValues(alpha: 0.5),
              width: 1.5,
            ),
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
          hintStyle: TextStyle(
            color: AppColors.newPrimary.withValues(alpha: 0.6),
          ),
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
          style: TextButton.styleFrom(foregroundColor: AppColors.newPrimary),
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
          linearTrackColor: AppColors.newPrimary.withValues(alpha: 0.2),
          circularTrackColor: AppColors.newPrimary.withValues(alpha: 0.2),
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
            return AppColors.newPrimary.withValues(alpha: 0.6);
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
              return AppColors.newPrimary.withValues(alpha: 0.5);
            }
            return Colors.grey.withValues(alpha: 0.3);
          }),
        ),

        // Slider
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.newPrimary,
          thumbColor: AppColors.newPrimary,
          inactiveTrackColor: AppColors.newPrimary.withValues(alpha: 0.3),
        ),

        // TabBar
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.newPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.newPrimary,
        ),

        // Menus (⋮): fundo branco e texto/ícones escuros. Sem isso os ícones
        // herdavam o branco do AppBar e sumiam no menu.
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(color: Color(0xFF1F2937), fontSize: 15),
        ),

        // Card
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),

        // Divider
        dividerTheme: DividerThemeData(
          color: AppColors.newPrimary.withValues(alpha: 0.2),
          thickness: 1,
        ),

        // Icon Theme
        iconTheme: IconThemeData(color: AppColors.newPrimary),

        // Usar useMaterial3 para evitar problemas de compatibilidade
        useMaterial3: true,
      ),
    );
  }
}

/// Deslize da direita + fade, sem zoom nem snapshot.
class SlideFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const SlideFadePageTransitionsBuilder();

  static final Animatable<Offset> _slide = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(_slide),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
