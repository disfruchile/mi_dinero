// Archivo: lib/modelos/categorias_modelo.dart
// Contiene el modelo de datos de Categoría (enum TipoOperacion) y su DAO (CategoriaBD).

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'base_datos.dart';

/// Comentario: Enumeración para diferenciar si una categoría es de Ingreso o Gasto.
enum TipoOperacion {
  ingreso, // ⭐ Corregido a minúsculas
  gasto    // ⭐ Corregido a minúsculas
}

/// Comentario: Clase que representa una categoría de gasto o ingreso.
class Categoria {
  final String idCategoria;
  final String nombre;
  final TipoOperacion tipo;

  Categoria({
    String? idCategoria,
    required this.nombre,
    required this.tipo,
  }) : idCategoria = idCategoria ?? const Uuid().v4();

  // Comentario: Convierte el objeto Categoria a un Map para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'idCategoria': idCategoria,
      'nombre': nombre,
      'tipo': tipo.index, // Guardamos el índice del enum
    };
  }

  // Comentario: Crea un objeto Categoria desde un Map de la base de datos.
  static Categoria fromMap(Map<String, dynamic> map) {
    return Categoria(
      idCategoria: map['idCategoria'] as String,
      nombre: map['nombre'] as String,
      tipo: TipoOperacion.values[map['tipo'] as int],
    );
  }
}

/// Comentario: Objeto de Acceso a Datos (DAO) para la entidad Categoria.
class CategoriaBD {
  final BaseDatosManager _dbManager;
  static const String nombreTabla = 'categorias';

  CategoriaBD(this._dbManager);

  // Comentario: Crea la tabla de Categorías en la base de datos.
  static void crearTabla(Database db) {
    db.execute('''
      CREATE TABLE $nombreTabla (
        idCategoria TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        tipo INTEGER NOT NULL 
      )
    ''');
  }

  /// Comentario: Inserta una nueva categoría en la base de datos.
  Future<void> insertarCategoria(Categoria categoria) async {
    final db = await _dbManager.database;
    await db.insert(
      nombreTabla,
      categoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Comentario: Consulta todas las categorías de la base de datos.
  Future<List<Map<String, dynamic>>> consultarCategoriasMapas() async {
    final db = await _dbManager.database;
    return db.query(nombreTabla, orderBy: 'nombre ASC');
  }

  /// Comentario: Elimina una categoría por su ID.
  Future<void> eliminarCategoria(String id) async {
    final db = await _dbManager.database;
    await db.delete(
      nombreTabla,
      where: 'idCategoria = ?',
      whereArgs: [id],
    );
  }

  /// Comentario: Actualiza una categoría existente. ⭐ FUNCIÓN AÑADIDA
  Future<void> actualizarCategoria(Categoria categoria) async {
    final db = await _dbManager.database;
    await db.update(
      nombreTabla,
      categoria.toMap(),
      where: 'idCategoria = ?',
      whereArgs: [categoria.idCategoria],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}