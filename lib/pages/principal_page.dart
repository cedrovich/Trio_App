import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'reservas_page.dart'; // Importa la página de reservas
import 'perfil_page.dart'; // Crea esta página si aún no existe
import 'package:supabase_flutter/supabase_flutter.dart'; // Para cerrar sesión

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  int _paginaActual = 0;

  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada')),
    );
  }

  // Lista de páginas principales
  final List<Widget> _paginas = [
    HomeContent(), // Contenido de inicio (Home)
    ReservasPage(), // Página de reservas
    PerfilPage(), // Página de perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
    padding: const EdgeInsets.only(left: 55.0), // Ajusta este valor según sea necesario
    child: Image.asset(
      'lib/assets/images/logo_trio.png',
      height: 60, // Ajusta la altura de la imagen
    ),
  ),
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
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: _paginas[_paginaActual], // Cambia el contenido según la página actual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// Widget para la página principal (contenido de inicio)
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> eventos = [
      'Concierto en CDMX - 5 de diciembre',
      'Festival de música clásica - 15 de diciembre',
      'Boda privada en Monterrey - 20 de diciembre',
      'Evento corporativo en Guadalajara - 30 de diciembre',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'lib/assets/images/logo_trio.png', // Ruta de tu imagen
            height: 80, // Ajusta la altura según sea necesario
            fit: BoxFit.contain, // Ajusta cómo se muestra la imagen
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
          // CarouselSlider para los próximos eventos
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
            ),
            items: eventos.map((evento) {
              return Builder(
                builder: (BuildContext context) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          evento,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Center(
            // child: ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const ReservasPage()),
            //     );
            //   },
            //   child: const Text('¡Contrátanos ya!'),
            // ),
          ),
        ],
      ),
    );
  }
}
