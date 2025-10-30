// Archivo: lib/main.dart
// PUNTO DE ENTRADA DE LA APLICACIÓN. Configuración de la BD Multiplataforma e inyección de Providers.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

// ⭐ Dependencias de Base de Datos
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Modelos y Lógica
import 'modelos/base_datos.dart';
import 'modelos/categorias_modelo.dart';
import 'logica/categorias_logica.dart';
import 'vistas/pantalla_principal.dart';

/// Comentario: Configura la fábrica de la base de datos según la plataforma de ejecución.
void _inicializarDatabaseFactory() {
  if (kIsWeb) {
    // Para Web (requiere 'dart run sqflite_common_ffi_web:setup')
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Para Escritorio (Windows, Linux, macOS)
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Para Android/iOS, sqflite se inicializa automáticamente.
  }
}

/// Comentario: Función principal asíncrona que inicializa la aplicación.
void main() async {
  // Asegura que los bindings de Flutter estén inicializados.
  WidgetsFlutterBinding.ensureInitialized();

  _inicializarDatabaseFactory();

  // 1. Inicializar la Conexión a la BD
  final BaseDatosManager bdManager = BaseDatosManager();
  await bdManager.iniciar();

  // 2. Crear el DAO de Categorías
  final CategoriaBD categoriaBD = CategoriaBD(bdManager);

  // 3. Crear la Lógica de Categorías
  final CategoriaGestion categoriaGestion = CategoriaGestion(categoriaBD);

  // 4. Cargar el estado inicial
  await categoriaGestion.cargarCategorias();

  // Iniciar la aplicación e inyectar el estado (ChangeNotifier).
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CategoriaGestion>(
          create: (_) => categoriaGestion,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Comentario: Widget principal de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Dinero App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}