// Archivo: lib/main.dart
// PUNTO DE ENTRADA DE LA APLICACIÓN. Configuración de la BD Multiplataforma e inyección de Providers.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

// Dependencias de Base de Datos
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Modelos y Lógica
import 'modelos/base_datos.dart';
import 'modelos/categorias_modelo.dart';
import 'logica/categorias_logica.dart';
// IMPORTACIONES DE CUENTAS
import 'modelos/cuentas_modelo.dart';
import 'logica/cuentas_logica.dart';

import 'vistas/pantalla_principal.dart';

/// Comentario: Configura la fábrica de la base de datos según la plataforma de ejecución.
void _inicializarDatabaseFactory() {
  // Comentario: Si estamos en la Web, usamos la fábrica web.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Comentario: Para Escritorio (Windows, Linux, macOS), usamos FFI.
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Comentario: Para Android/iOS, sqflite se inicializa automáticamente.
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

  // 2. Crear los DAOs
  final CategoriaBD categoriaBD = CategoriaBD(bdManager);
  // ⭐ NUEVO: Creamos el DAO de Cuentas.
  final CuentaBD cuentaBD = CuentaBD(bdManager); 

  // 3. Crear la Lógica (Gestión de Estado) de Categorías
  final CategoriaGestion categoriaGestion = CategoriaGestion(categoriaBD);
  await categoriaGestion.cargarCategorias();

  // 4. Crear la Lógica de Cuentas
  // ⭐ CORRECCIÓN DE ERROR: Ahora pasamos el DAO de Cuentas.
  final CuentaGestion cuentaGestion = CuentaGestion(cuentaBD); 

  // Iniciar la aplicación e inyectar el estado (ChangeNotifier).
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CategoriaGestion>(
          create: (_) => categoriaGestion,
        ),
        // Proveedor de Cuentas
        ChangeNotifierProvider<CuentaGestion>(
          create: (_) => cuentaGestion,
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