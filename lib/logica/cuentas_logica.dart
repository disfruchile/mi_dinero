// Archivo: lib/logica/cuentas_logica.dart
// Contiene la lógica de negocio y gestión de estado (Provider) para las Cuentas.

import 'package:flutter/material.dart';
import '../modelos/cuentas_modelo.dart';
// Se asume que tienes una clase CuentaBD importada en otro archivo que funciona como DAO.

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
    CuentaGestion(this._cuentaBD);

    // ⭐️ MÉTODO AGREGADO: Carga todas las cuentas desde la base de datos a la memoria.
    Future<void> cargarCuentas() async {
        _cuentas = await _cuentaBD.consultarCuentas();
        _isInitialized = true;
        notifyListeners();
    }

    /// Comentario: Añade una nueva cuenta a la BD y a la lista local.
    Future<void> agregarCuenta(Cuenta cuenta) async {
        await _cuentaBD.insertarCuenta(cuenta);
        _cuentas.add(cuenta);
        notifyListeners();
    }

    /// Comentario: Actualiza una cuenta existente en la base de datos y en la lista local.
    Future<void> actualizarCuenta(Cuenta cuenta) async {
        await _cuentaBD.actualizarCuenta(cuenta);
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

    /// Comentario: Ajusta el saldo de una cuenta por el monto de una operación.
    Future<void> ajustarSaldo(String idCuenta, double monto) async {
        final cuentaAjustar = obtenerCuentaPorId(idCuenta);

        if (cuentaAjustar == null) {
            debugPrint('Error: Cuenta con ID $idCuenta no encontrada para ajustar saldo.');
            return;
        }

        final double nuevoSaldo = cuentaAjustar.saldoActual + monto;

        final cuentaActualizada = Cuenta(
            idCuenta: cuentaAjustar.idCuenta,
            nombre: cuentaAjustar.nombre,
            tipo: cuentaAjustar.tipo,
            saldoInicial: cuentaAjustar.saldoInicial,
            saldoActual: nuevoSaldo,
            color: cuentaAjustar.color,
        );

        await actualizarCuenta(cuentaActualizada);
    }
}
