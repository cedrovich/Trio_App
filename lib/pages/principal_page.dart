import 'package:flutter/material.dart';
import 'reservas_page.dart'; // Importa la página de reservas
import 'package:supabase_flutter/supabase_flutter.dart'; // Para cerrar sesión

class PrincipalPage extends StatelessWidget {
  const PrincipalPage({super.key});

  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Redirige al LoginPage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trío Semblanzas'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Opciones',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                // Acción para la opción Perfil
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sección de Perfil próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () {
                // Acción para la opción Ajustes
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sección de Ajustes próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('Preguntas frecuentes'),
              onTap: () {
                // Acción para la opción Preguntas frecuentes
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sección de Preguntas frecuentes próximamente')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Reservar'),
              onTap: () {
                // Redirige a la página de reservas
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReservasPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => _logout(context), // Llama al método para cerrar sesión
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido al Trío Semblanzas',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Disfruta de la mejor música en vivo para tus eventos.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Próximos Eventos:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('- Concierto en CDMX - 5 de diciembre'),
            const Text('- Festival de música clásica - 15 de diciembre'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReservasPage()),
                  );
                },
                child: const Text('¡Contrátanos ya!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
