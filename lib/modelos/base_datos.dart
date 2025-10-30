// Archivo: lib/modelos/base_datos.dart
// Contiene la lógica de conexión general y la gestión de la base de datos SQLite.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'package:uuid/uuid.dart'; // Ya no es necesario aquí, se movió a CategoriaBD
// import 'categorias_modelo.dart'; // Ya no es necesario aquí, solo en CategoriaBD

/// Comentario: Clase Singleton que gestiona la conexión y la instancia de la base de datos SQLite.
/// Su única función es proporcionar una conexión de base de datos (`Database`).
class BaseDatosManager {
  static Database? _database;
  
  // Comentario: Acceso único a la instancia de la base de datos (Singleton).
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Comentario: Inicializa la conexión a la base de datos.
  Future<void> iniciar() async {
    await database; // Asegura que la BD esté inicializada
  }

  // Comentario: Inicializa la base de datos (crea el archivo si no existe).
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'finanzas_personales.db');
    
    // Comentario: Abrimos la base de datos, especificando la función de creación.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Comentario: Define la estructura de las tablas cuando la base de datos se crea por primera vez.
  // En este punto, solo creamos la tabla 'categorias'.
  Future<void> _onCreate(Database db, int version) async {
    // Tabla Categorias
    await db.execute('''
      CREATE TABLE categorias (
        idCategoria TEXT PRIMARY KEY,
        nombre TEXT,
        tipo INTEGER -- 0 para Entrada (Ingreso), 1 para Salida (Gasto)
      )
    ''');
    // Comentario: Si en el futuro se añaden más tablas (ej. Operaciones), se crearían aquí.
  }
  
  // Comentario: Se han eliminado todas las funciones CRUD (insertar, consultar, actualizar, eliminar)
  // ya que ahora son responsabilidad de CategoriaBD en categorias_modelo.dart.
}