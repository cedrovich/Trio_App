import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart'; // Importa HomePage
// ignore: unused_import
import 'pages/principal_page.dart'; // Importa PrincipalPage
// ignore: unused_import
import 'pages/reservas_page.dart'; // Importa ReservasPage

const supabaseUrl = 'https://pggtliopkuymentnklow.supabase.co'; // URL de tu proyecto en Supabase
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnZ3RsaW9wa3V5bWVudG5rbG93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2MzE4OTcsImV4cCI6MjA0ODIwNzg5N30.HO87zVfpPOwBh0Cj0YVp2LowCHM750W49tbSmNkzfYQ'; // Clave pública (anonKey)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la tira de debug
      title: 'Trio App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(), // Pantalla principal
    );
  }
}
