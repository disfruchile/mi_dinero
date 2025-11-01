// Archivo: lib/modelos/base_datos.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // Para usar path.join
import 'categorias_modelo.dart'; // Importamos para acceder a CategoriaBD.nombreTabla
import 'cuentas_modelo.dart'; // Importación necesaria para CuentaBD.crearTabla
import 'operaciones_modelo.dart'; // ⭐ NUEVA IMPORTACIÓN: Necesaria para OperacionBD.crearTabla

/// Comentario: Clase para gestionar la inicialización y la conexión a la base de datos.
class BaseDatosManager {
  static Database? _database;

  // Comentario: Nombre del archivo de la base de datos.
  static const String _nombreDB = 'finanzas_personales.db';
  
  // ⭐ VERSIÓN ACTUALIZADA: Se incrementa a 5 para incluir la tabla de Operaciones.
  static const int _versionDB = 5; 

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
    final path = join(databasePath, _nombreDB); // Usamos path.join

    _database = await openDatabase(
      path,
      version: _versionDB,
      // Comentario: Función llamada cuando la base de datos es creada por primera vez (versión 5).
      onCreate: (db, version) async {
        // Creamos la tabla de Cuentas (Desde V4).
        await db.execute(CuentaBD.crearTabla);
        
        // Creamos la tabla de Categorías (Desde V1).
        CategoriaBD.crearTabla(db); 
        
        // ⭐ NUEVA CREACIÓN: Creamos la tabla de Operaciones (Desde V5).
        await db.execute(OperacionBD.crearTabla);
      },
      // Función llamada cuando la versión de la base de datos aumenta (migración).
      onUpgrade: (db, oldVersion, newVersion) async {
        // --- Migración de Versión 1 a Versión 2: Añadir columnas (color, tiposAplicables) ---
        if (oldVersion < 2) {
          // Comentario: Añadir las columnas 'color' y 'tiposAplicables' para la versión 2.
          await db.execute('ALTER TABLE ${CategoriaBD.nombreTabla} ADD COLUMN color TEXT NOT NULL DEFAULT "#000000"');
          await db.execute('ALTER TABLE ${CategoriaBD.nombreTabla} ADD COLUMN tiposAplicables TEXT NOT NULL DEFAULT "3"');
        }
        
        // --- Migración de Versión 2 a Versión 3: Eliminar columna (tipo) ---
        if (oldVersion < 3) {
             // Comentario: Se elimina la columna 'tipo' recreando la tabla de Categorías.
             await db.execute('''
               CREATE TABLE temp_categorias (
                  idCategoria TEXT PRIMARY KEY,
                  nombre TEXT NOT NULL,
                  color TEXT NOT NULL DEFAULT "#000000",
                  tiposAplicables TEXT NOT NULL DEFAULT "3"
                )
             ''');
             await db.execute('''
               INSERT INTO temp_categorias (idCategoria, nombre, color, tiposAplicables)
               SELECT idCategoria, nombre, color, tiposAplicables FROM ${CategoriaBD.nombreTabla}
             ''');
             await db.execute('DROP TABLE ${CategoriaBD.nombreTabla}');
             await db.execute('ALTER TABLE temp_categorias RENAME TO ${CategoriaBD.nombreTabla}');
        }
        
        // --- Migración de Versión 3 a Versión 4: Crear tabla de Cuentas ---
        if (oldVersion < 4) {
            // Se crea la tabla 'cuentas' (necesario si el usuario ha estado usando la BD sin ella)
            await db.execute(CuentaBD.crearTabla);
        }

        // ⭐ Migración de Versión 4 a Versión 5: Crear tabla de Operaciones
        if (oldVersion < 5) {
            // Se crea la tabla 'operaciones' para manejar ingresos, gastos y transferencias.
            await db.execute(OperacionBD.crearTabla);
        }
      },
    );
  }
}
