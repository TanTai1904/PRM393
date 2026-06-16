import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/analyzer_provider.dart';
import 'screens/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalyzerProvider()),
      ],
      child: const JournalTrendApp(),
    ),
  );
}

class JournalTrendApp extends StatelessWidget {
  const JournalTrendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal Trend Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromARGB(255, 53, 56, 228),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF06B6D4),
          surface: Colors.white,
          error: Color(0xFFEF4444),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.light().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        ),
      ),
      home: const SearchScreen(),
    );
  }
}
