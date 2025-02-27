import 'package:flutter/material.dart';
import 'package:flutter_application_trio/pages/editar_perfil.dart';
import 'package:flutter_application_trio/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? _user;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select('full_name, avatar_url, phone_number, birth_date')
            .eq('user_id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _user = user;
            _profileData = response as Map<String, dynamic>;
            _isLoading = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        print('Error al cargar datos de perfil: $error');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Cancelar cualquier operación pendiente aquí si fuera necesario
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF892E2E)),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Mi Perfil',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF892E2E),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: const Color(0xFF892E2E).withOpacity(0.1),
                  backgroundImage: _profileData?['avatar_url'] != null
                      ? NetworkImage(_profileData!['avatar_url'])
                      : const AssetImage('assets/images/person.png') as ImageProvider,
                  child: _profileData?['avatar_url'] == null
                      ? const Icon(
                          Icons.person,
                          color: Color(0xFF892E2E),
                          size: 80,
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  _profileData?['full_name'] ?? _user?.email ?? 'Usuario',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF892E2E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _user?.email ?? 'Correo no disponible',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_profileData != null && _user != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditarPerfilPage(
                            profileData: _profileData!,
                            user: _user!,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Editar Perfil',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF892E2E),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.phone, 'Teléfono', _profileData?['phone_number'] ?? 'No configurado'),
                        const SizedBox(height: 15),
                        _buildInfoRow(Icons.cake, 'Fecha de nacimiento', _profileData?['birth_date'] ?? 'No configurado'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF892E2E), size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF892E2E),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
