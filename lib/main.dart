import 'package:enade_presenca/screens/lista_alunos_screen.dart';
import 'package:enade_presenca/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Definindo as novas cores para fácil acesso em todo o app
const Color darkBlueBackground = Color(0xFF122640);
const Color brightGreenTitle = Color(0xFF33DB89);
const Color cardBackgroundColor = Color(0xFF1A3251);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bckduokvdrilytrebwpw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJja2R1b2t2ZHJpbHl0cmVid3B3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxOTE3MDksImV4cCI6MjA3MDc2NzcwOX0.HVNfOGetJT-L9uTEXhRaxhJIBfJ_3-sX39ZjAIZ6G0A',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Presença ENADE',
      theme: _buildTheme(context), // Aplicando nosso novo tema dark
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.session != null) {
            return const ListaAlunosScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }

  // Função que constrói o tema visual do aplicativo
  ThemeData _buildTheme(BuildContext context) {
    // Usamos ThemeData.dark() como base para um tema escuro
    final baseTheme = ThemeData.dark(useMaterial3: true);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: darkBlueBackground,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: brightGreenTitle, // O verde será a cor primária de interações
        secondary: brightGreenTitle,
        onPrimary: Colors.black, // Cor do texto sobre a cor primária
        surface: cardBackgroundColor, // Cor de superfície para cards, etc.
        background: darkBlueBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBlueBackground,
        elevation: 0, // Sem sombra para um visual mais "flat"
        titleTextStyle: GoogleFonts.montserrat(
          color: brightGreenTitle, // Título da AppBar em verde
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: brightGreenTitle), // Ícones da AppBar em verde
      ),
      textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme).apply(
        bodyColor: Colors.white, // Cor padrão do texto
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackgroundColor,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brightGreenTitle,
          foregroundColor: Colors.black, // Texto do botão em preto para contraste
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackgroundColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}