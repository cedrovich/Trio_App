import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  _PromoPageState createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  int _reservasCount = 0;
  int _currentCycleCount = 0;
  bool _isLoading = true;
  bool _hasPromotion = false;

  @override
  void initState() {
    super.initState();
    _fetchUserReservas();
  }

  Future<void> _fetchUserReservas() async {
    try {
      final correo = Supabase.instance.client.auth.currentUser?.email;
      if (correo == null) {
        throw 'No se encontró el correo del usuario autenticado.';
      }

      final response = await Supabase.instance.client
          .from('eventos')
          .select()
          .eq('correo', correo) as List<dynamic>;

      if (response.isNotEmpty) {
        int totalReservas = response.length;
        int currentCycle = totalReservas % 5;

        setState(() {
          _reservasCount = totalReservas;
          _currentCycleCount = currentCycle;
          _hasPromotion = currentCycle == 0 && totalReservas > 0;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar reservas: $e'),
          backgroundColor: Color(0xFF892E2E),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Promociones',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF892E2E),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF892E2E)),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Gracias por tu preferencia!',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF892E2E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Tu progreso hacia la promoción:',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF892E2E),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CircularPercentIndicator(
                              radius: 80.0,
                              lineWidth: 12.0,
                              percent: (_currentCycleCount / 5).clamp(0.0, 1.0),
                              center: Text(
                                '$_currentCycleCount/5',
                                style: GoogleFonts.roboto(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF892E2E),
                                ),
                              ),
                              progressColor: _hasPromotion
                                  ? Colors.green
                                  : Color(0xFF892E2E),
                              backgroundColor: Colors.grey[300]!,
                              animation: true,
                              animationDuration: 1200,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _hasPromotion
                                  ? '¡Felicidades! Tu sexta reserva es gratis.'
                                  : 'Te faltan ${5 - _currentCycleCount} reservas para tu próxima serenata o evento gratis.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _hasPromotion ? Colors.green : Color(0xFF892E2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _hasPromotion
                            ? () {
                                // Lógica para redirigir a la página de reservas gratis
                              }
                            : () {
                                // Lógica para redirigir a la página de reservas normales
                              },
                        child: Text(
                          _hasPromotion
                              ? 'Agendar evento gratis'
                              : 'Agendar evento',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF892E2E),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}