// Archivo: lib/modelos/base_datos.dart

import 'package:sqflite/sqflite.dart';
import 'categorias_modelo.dart'; // Importamos para acceder a CategoriaBD.nombreTabla

/// Comentario: Clase para gestionar la inicialización y la conexión a la base de datos.
class BaseDatosManager {
  static Database? _database;

  // Comentario: Nombre del archivo de la base de datos.
  static const String _nombreDB = 'finanzas_personales.db';
  
  // ⭐ Versión de la base de datos. Se incrementa a 3 para forzar la migración
  //    debido a la eliminación de la columna 'tipo'.
  static const int _versionDB = 3; 

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
      // Comentario: Función llamada cuando la base de datos es creada por primera vez (versión 3).
      onCreate: (db, version) async {
        CategoriaBD.crearTabla(db);
        // ⭐ FUTURO: TransaccionBD.crearTabla(db);
      },
      // ⭐ Función llamada cuando la versión de la base de datos aumenta (migración).
      onUpgrade: (db, oldVersion, newVersion) async {
        // --- Migración de Versión 1 a Versión 2: Añadir columnas (color, tiposAplicables) ---
        if (oldVersion < 2) {
          // Comentario: Añadir las columnas 'color' y 'tiposAplicables' para la versión 2.
          await db.execute('ALTER TABLE ${CategoriaBD.nombreTabla} ADD COLUMN color TEXT NOT NULL DEFAULT "#000000"');
          await db.execute('ALTER TABLE ${CategoriaBD.nombreTabla} ADD COLUMN tiposAplicables TEXT NOT NULL DEFAULT "3"');
        }
        
        // --- Migración de Versión 2 a Versión 3: Eliminar columna (tipo) ---
        if (oldVersion < 3) {
             // Comentario: Se elimina la columna 'tipo' recreando la tabla para no perder datos existentes.
             
             // 1. Crear una tabla temporal con el nuevo esquema (sin 'tipo').
             await db.execute('''
                CREATE TABLE temp_categorias (
                    idCategoria TEXT PRIMARY KEY,
                    nombre TEXT NOT NULL,
                    color TEXT NOT NULL DEFAULT "#000000",
                    tiposAplicables TEXT NOT NULL DEFAULT "3"
                )
             ''');
             
             // 2. Copiar los datos relevantes de la tabla vieja a la nueva.
             //    (idCategoria, nombre, color, tiposAplicables)
             await db.execute('''
                INSERT INTO temp_categorias (idCategoria, nombre, color, tiposAplicables)
                SELECT idCategoria, nombre, color, tiposAplicables FROM ${CategoriaBD.nombreTabla}
             ''');
             
             // 3. Eliminar la tabla vieja.
             await db.execute('DROP TABLE ${CategoriaBD.nombreTabla}');
             
             // 4. Renombrar la tabla temporal a la tabla final.
             await db.execute('ALTER TABLE temp_categorias RENAME TO ${CategoriaBD.nombreTabla}');
        }
      },
    );
  }
}