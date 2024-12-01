import 'package:flutter/material.dart';
import 'package:flutter_application_trio/pages/editar_perfil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Obtener usuario actual autenticado
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null) {
        // Consultar tabla de perfiles para obtener información adicional
        final response = await Supabase.instance.client
            .from('users') // Asegúrate de que este nombre coincida con tu tabla
            .select()
            .eq('user_id', user.id)
            .single();

        setState(() {
          _user = user;
          _profileData = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error al cargar datos de perfil: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              // Navegar a la página de inicio de sesión
              // Navigator.of(context).pushReplacement(...)
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Foto de perfil
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[300],
                backgroundImage: _user?.userMetadata?['avatar_url'] != null
                  ? NetworkImage(_user!.userMetadata!['avatar_url'])
                  : AssetImage('assets/images/person.png') as ImageProvider,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              SizedBox(height: 20),
              
              // Nombre del usuario
              Text(
                _profileData?['full_name'] ?? _user?.email ?? 'Usuario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 10),
              
              // Correo electrónico
              Text(
                _user?.email ?? 'Correo no disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditarPerfilPage(
                            profileData: _profileData!, 
                            user: _user!
                          ),
                        ),
                      );
                    },
                    child: Text('Editar Perfil'),
                  ),
                  SizedBox(width: 20),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Navegar a página de configuración
                  //   },
                  //   child: Text('Configuración'),
                  // ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Información adicional del perfil
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Teléfono:'),
                          Text(_profileData?['phone_number'] ?? 'No configurado'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fecha de nacimiento:'),
                          Text(_profileData?['birth_date'] ?? 'No configurado'),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text('Fecha de registro:'),
                      //     Text(_user?.createdAt != null 
                      //       ? '${_user!.createdAt.day}/${_user!.createdAt.month}/${_user!.createdAt.year}' 
                      //       : 'Fecha no disponible'),
                      //   ],
                      // ),
                    ],
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

