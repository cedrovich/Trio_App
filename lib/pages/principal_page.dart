import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'reservas_page.dart';
import 'perfil_page.dart';
import 'promo_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
      SnackBar(
        content: Text('Sesión cerrada', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF892E2E),
      ),
    );
  }

  final List<Widget> _paginas = [
    HomeContent(),
    ReservasPage(),
    PromoPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF892E2E),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 145.0),
          child: Image.asset(
            'lib/assets/images/logo_trio.png',
            height: 40,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Color(0xFF892E2E),
      //         ),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             CircleAvatar(
      //               radius: 40,
      //               backgroundColor: Colors.white,
      //               child: Icon(Icons.music_note, size: 40, color: Color(0xFF892E2E)),
      //             ),
      //             SizedBox(height: 10),
      //             Text(
      //               'Menú',
      //               style: GoogleFonts.roboto(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      //             ),
      //           ],
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.logout, color: Color(0xFF892E2E)),
      //         title: Text('Cerrar sesión', style: GoogleFonts.roboto(color: Color(0xFF892E2E))),
      //         onTap: () => _logout(context),
      //       ),
      //     ],
      //   ),
      // ),
      body: _paginas[_paginaActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        selectedItemColor: Color(0xFF892E2E),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Promociones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

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
          // Contenedor con imagen, texto y degradado
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage('lib/assets/images/trio.jpg'), // Asegúrate de que la imagen exista en esta ruta
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Text(
                  'Disfruta de la mejor música en vivo para tus eventos.',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Próximos Eventos:',
            style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF892E2E)),
          ),
          const SizedBox(height: 20),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Color(0xFF892E2E),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          evento,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
