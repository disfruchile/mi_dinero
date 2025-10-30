// Archivo: lib/modelos/base_datos.dart

import 'package:sqflite/sqflite.dart';
import 'categorias_modelo.dart'; // Importamos para acceder a CategoriaBD.crearTabla

/// Comentario: Clase para gestionar la inicialización y la conexión a la base de datos.
class BaseDatosManager {
  static Database? _database;

  // Comentario: Nombre del archivo de la base de datos.
  static const String _nombreDB = 'finanzas_personales.db';
  
  // ⭐ Versión de la base de datos. Se incrementa a 2 para forzar la migración.
  static const int _versionDB = 2; 

  /// Comentario: Devuelve la instancia de la base de datos, inicializándola si es necesario.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    // Si la base de datos no existe, la inicializamos.
    await iniciar();
    return _database!;
  }

  /// Comentario: Inicializa la base de datos (abre o crea).
  Future<void> iniciar() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$_nombreDB';

    _database = await openDatabase(
      path,
      version: _versionDB,
      // Comentario: Función llamada cuando la base de datos es creada por primera vez.
      onCreate: (db, version) async {
        // Creamos todas las tablas necesarias.
        CategoriaBD.crearTabla(db);
        // ⭐ FUTURO: TransaccionBD.crearTabla(db);
      },
      // ⭐ Función llamada cuando la versión de la base de datos aumenta (migración).
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Comentario: Migración de la versión 1 a la 2 (añadir columnas 'color' y 'tiposAplicables').
          await db.execute('ALTER TABLE ${CategoriaBD.nombreTabla} ADD COLUMN color TEXT NOT NULL DEFAULT "#000000"');
          await db.execute('ALTER TABLE ${CategoriaBD.nombreTabla} ADD COLUMN tiposAplicables TEXT NOT NULL DEFAULT "3"');
          // Nota: El valor "3" corresponde al índice de TipoCategoria.todos.
        }
      },
    );
  }
}