// Archivo: lib/modelos/operaciones_modelo.dart
// Contiene el modelo de datos de Operación y su DAO (OperacionBD).

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'base_datos.dart'; // Para acceder a BaseDatosManager

/// Comentario: Define el tipo de movimiento financiero.
enum TipoOperacion {
  ingreso,
  gasto,
  transferencia,
}

/// Comentario: Clase que representa una Operación (Transacción).
class Operacion {
  final String idOperacion;
  final TipoOperacion tipo;
  final double monto;
  final DateTime fecha;
  final String descripcion;
  final String idCuenta; // Cuenta origen (para ingreso/gasto/transferencia)
  final String idCategoria; // ⭐ OBLIGATORIO: Categoría asociada (Gasto/Ingreso)
  final String? idCuentaDestino; // Solo usado en Transferencia

  Operacion({
    String? idOperacion,
    required this.tipo,
    required this.monto,
    required this.fecha,
    this.descripcion = '',
    required this.idCuenta,
    required this.idCategoria, // ⭐ OBLIGATORIO
    this.idCuentaDestino,
  }) : idOperacion = idOperacion ?? const Uuid().v4();

  // Comentario: Convierte el objeto Operacion a un Map para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'idOperacion': idOperacion,
      'tipo': tipo.index,
      'monto': monto,
      'fecha': fecha.millisecondsSinceEpoch,
      'descripcion': descripcion,
      'idCuenta': idCuenta,
      'idCategoria': idCategoria, // ⭐ Campo obligatorio
      'idCuentaDestino': idCuentaDestino,
    };
  }

  // Comentario: Crea un objeto Operacion desde un Map de la base de datos.
  static Operacion fromMap(Map<String, dynamic> map) {
    return Operacion(
      idOperacion: map['idOperacion'] as String,
      tipo: TipoOperacion.values[map['tipo'] as int],
      monto: map['monto'] as double,
      fecha: DateTime.fromMillisecondsSinceEpoch(map['fecha'] as int),
      descripcion: map['descripcion'] as String,
      idCuenta: map['idCuenta'] as String,
      idCategoria: map['idCategoria'] as String, // ⭐ Lectura de campo obligatorio
      idCuentaDestino: map['idCuentaDestino'] as String?,
    );
  }
}

/// Comentario: Objeto de Acceso a Datos (DAO) para la entidad Operacion.
class OperacionBD {
  final BaseDatosManager _dbManager;
  static const String nombreTabla = 'operaciones';

  OperacionBD(this._dbManager);

  // Comentario: Sentencia SQL para crear la tabla de Operaciones.
  static const String crearTabla = '''
    CREATE TABLE $nombreTabla (
      idOperacion TEXT PRIMARY KEY,
      tipo INTEGER NOT NULL,
      monto REAL NOT NULL,
      fecha INTEGER NOT NULL,
      descripcion TEXT,
      idCuenta TEXT NOT NULL,
      idCategoria TEXT NOT NULL,
      idCuentaDestino TEXT,
      -- Claves foráneas (aunque Sqflite no las fuerza por defecto, son buenas para el diseño)
      FOREIGN KEY (idCuenta) REFERENCES cuentas (idCuenta) ON DELETE CASCADE,
      FOREIGN KEY (idCategoria) REFERENCES categorias (idCategoria) ON DELETE NO ACTION
    )
  ''';

  // ⭐️ Método: Inserta una nueva operación.
  Future<void> insertarOperacion(Operacion operacion) async {
    final db = await _dbManager.database;
    await db.insert(nombreTabla, operacion.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ⭐️ Método: Consulta todas las operaciones de la base de datos.
  Future<List<Map<String, dynamic>>> consultarOperacionesMapas() async {
    final db = await _dbManager.database;
    // Ordenamos por fecha descendente para que las más recientes aparezcan primero.
    return db.query(nombreTabla, orderBy: 'fecha DESC');
  }

  // ⭐️ Método: Consulta las operaciones filtradas por una cuenta específica.
  Future<List<Map<String, dynamic>>> consultarOperacionesPorCuenta(String idCuenta) async {
    final db = await _dbManager.database;
    // Se filtran las operaciones donde la cuenta es el origen O el destino (para transferencias).
    return db.query(
      nombreTabla,
      where: 'idCuenta = ? OR idCuentaDestino = ?',
      whereArgs: [idCuenta, idCuenta],
      orderBy: 'fecha DESC',
    );
  }
  
  // ⭐️ Método: Actualiza una operación existente.
  Future<void> actualizarOperacion(Operacion operacion) async {
    final db = await _dbManager.database;
    await db.update(
      nombreTabla,
      operacion.toMap(),
      where: 'idOperacion = ?',
      whereArgs: [operacion.idOperacion],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ⭐️ Método: Elimina una operación por su ID.
  Future<void> eliminarOperacion(String id) async {
    final db = await _dbManager.database;
    await db.delete(
      nombreTabla,
      where: 'idOperacion = ?',
      whereArgs: [id],
    );
  }
}
