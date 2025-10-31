// Archivo: lib/logica/cuentas_logica.dart
// Contiene la lógica de negocio y gestión de estado (Provider) para las Cuentas.

import 'package:flutter/material.dart';
import '../modelos/cuentas_modelo.dart';

/// Comentario: Clase que maneja la lógica de negocio y el estado de las Cuentas.
/// Extiende ChangeNotifier para notificar a los widgets sobre los cambios.
class CuentaGestion with ChangeNotifier {
  final CuentaBD _cuentaBD;
  List<Cuenta> _cuentas = [];
  bool _isInitialized = false;

  // Comentario: Getter para la lista de cuentas (solo lectura externa).
  List<Cuenta> get cuentas => [..._cuentas]; 

  // Comentario: Getter para saber si la inicialización ha terminado.
  bool get isInitialized => _isInitialized;

  // Comentario: Constructor que requiere una instancia del DAO de Cuentas.
  CuentaGestion(this._cuentaBD) {
    // Inicia la carga de datos al crearse la instancia.
    _cargarCuentas(); 
  }

  /// Comentario: Carga todas las cuentas desde la base de datos a la memoria.
  Future<void> _cargarCuentas() async {
    _cuentas = await _cuentaBD.consultarCuentas();
    _isInitialized = true;
    notifyListeners();
  }

  /// Comentario: Añade una nueva cuenta a la BD y a la lista local.
  Future<void> agregarCuenta(Cuenta cuenta) async {
    // Se inserta la cuenta en la BD. La BD debería asignarle un ID.
    await _cuentaBD.insertarCuenta(cuenta);
    // Se asume que la cuenta ya tiene el ID después de la inserción o se re-consulta.
    // Para simplificar, la añadimos directamente.
    _cuentas.add(cuenta); 
    notifyListeners();
  }

  /// Comentario: Actualiza una cuenta existente en la base de datos y en la lista local.
  Future<void> actualizarCuenta(Cuenta cuenta) async {
    await _cuentaBD.actualizarCuenta(cuenta);
    // Reemplaza la cuenta antigua con la nueva en la lista local.
    final index = _cuentas.indexWhere((c) => c.idCuenta == cuenta.idCuenta);
    if (index != -1) {
      _cuentas[index] = cuenta;
      notifyListeners();
    }
  }

  /// Comentario: Elimina una cuenta de la BD y de la lista local.
  Future<void> eliminarCuenta(String idCuenta) async {
    await _cuentaBD.eliminarCuenta(idCuenta);
    _cuentas.removeWhere((c) => c.idCuenta == idCuenta);
    notifyListeners();
  }

  // Comentario: Método auxiliar para obtener una cuenta por ID
  Cuenta? obtenerCuentaPorId(String idCuenta) {
    try {
      return _cuentas.firstWhere((c) => c.idCuenta == idCuenta);
    } catch (e) {
      return null;
    }
  }
}