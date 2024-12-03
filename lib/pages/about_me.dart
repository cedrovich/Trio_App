import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acerca de Nosotros',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF892E2E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'lib/assets/images/trio.jpg',
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sobre Nosotros',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF892E2E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Somos Semblanzas Trío, un grupo dedicado a ofrecer música de alta calidad en cada presentación. Nuestro repertorio está compuesto por los géneros más emblemáticos de la música mexicana y latina. Cada integrante aporta un talento único que garantiza una experiencia inolvidable.',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            Text(
              'Nuestros Integrantes',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF892E2E),
              ),
            ),
            const SizedBox(height: 10),
            _buildMemberInfo(
              name: 'Ernesto Vega',
              role: '1ra voz',
              description:
                  ' Ernesto lidera con su potente y carismática voz, cautivando al público en cada presentación.',
              image: 'lib/assets/images/integrante3.jpg',
              isImageLeft: true,
              imageWidth: 140,
              imageHeight: 180,
            ),
            const SizedBox(height: 10),
            _buildMemberInfo(
              name: 'Rodrigo Gaxiola',
              role: '2da voz y Guitarra',
              description:
                  'Rodrigo combina su pasión por la música con su talento en la guitarra, creando melodías que enriquecen cada actuación.',
              image: 'lib/assets/images/integrante2.jpg',
              isImageLeft: false,
              imageWidth: 140,
              imageHeight: 180,
            ),
            const SizedBox(height: 10),
            _buildMemberInfo(
              name: 'Fernando Pastrana',
              role: '3ra voz y Requinto',
              description:
                  'Fernando aporta un estilo único con su dominio del requinto, complementando perfectamente las armonías del grupo.',
              image: 'lib/assets/images/integrante1.jpg',
              isImageLeft: true,
              imageWidth: 140,
              imageHeight: 180,
            ),
            const SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'lib/assets/images/trio2.jpg',
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberInfo({
    required String name,
    required String role,
    required String description,
    required String image,
    required bool isImageLeft,
    double imageWidth = 80,
    double imageHeight = 80,
  }) {
    return Row(
      children: [
        if (isImageLeft)
          _buildImage(image, imageWidth, imageHeight)
        else
          const SizedBox.shrink(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF892E2E),
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isImageLeft)
          _buildImage(image, imageWidth, imageHeight)
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildImage(String image, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        image,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
