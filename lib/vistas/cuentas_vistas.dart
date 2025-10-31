// Archivo: lib/vistas/cuentas_vistas.dart
// Contiene la interfaz de usuario para listar, crear, editar y eliminar Cuentas.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Importaciones de modelos y lógica de cuentas
import '../modelos/cuentas_modelo.dart';
import '../logica/cuentas_logica.dart';

/// Comentario: Función auxiliar para convertir String HEX a objeto Color.
/// Es esencial para manejar los colores de cuenta guardados en la BD.
Color _hexToColor(String hexColor) {
  // Manejamos el formato: #RRGGBB a 0xFFRRGGBB
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor"; // **Uso de interpolación**
  }
  // Se usa int.parse con radix 16 para convertir el String hexadecimal a entero.
  return Color(int.parse(hexColor, radix: 16));
}


/// Comentario: Vista principal para la gestión y listado de cuentas.
class VistaGestionCuentas extends StatelessWidget {
  const VistaGestionCuentas({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar el estado de CuentaGestion
    final cuentaGestion = Provider.of<CuentaGestion>(context);
    final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

    // Mapear cuentas por tipo para mostrar en secciones separadas.
    final List<Cuenta> efectivoCuentas = cuentaGestion.cuentas
        .where((c) => c.tipo == TipoCuenta.efectivo)
        .toList();
    final List<Cuenta> transferenciaCuentas = cuentaGestion.cuentas
        .where((c) => c.tipo == TipoCuenta.transferencia)
        .toList();

    return Scaffold(
      // Se utiliza AppBar de Material Design.
      appBar: AppBar( 
        title: const Text('Gestión de Cuentas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Sección de Cuentas de Efectivo
            _buildSeccionTitulo('💰 Cuentas de Efectivo', efectivoCuentas.isEmpty),
            if (efectivoCuentas.isEmpty)
              _buildPlaceholder('Aún no tienes cuentas de efectivo.'),
            ...efectivoCuentas.map((cuenta) => _buildCuentaCard(context, cuenta, formatter)),
            
            const SizedBox(height: 30),

            // 2. Sección de Cuentas de Transferencia
            _buildSeccionTitulo('🏦 Cuentas de Transferencia', transferenciaCuentas.isEmpty),
            if (transferenciaCuentas.isEmpty)
              _buildPlaceholder('Aún no tienes cuentas de transferencia.'),
            ...transferenciaCuentas.map((cuenta) => _buildCuentaCard(context, cuenta, formatter)),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarVentanaCrearCuenta(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir Cuenta'),
      ),
    );
  }

  /// Comentario: Widget auxiliar para el título de la sección.
  Widget _buildSeccionTitulo(String titulo, bool esVacio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: esVacio ? Colors.grey : Colors.indigo.shade700,
        ),
      ),
    );
  }

  /// Comentario: Widget auxiliar para el mensaje de placeholder.
  Widget _buildPlaceholder(String mensaje) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        mensaje,
        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      ),
    );
  }

  /// Comentario: Widget para mostrar cada cuenta como una tarjeta.
  Widget _buildCuentaCard(BuildContext context, Cuenta cuenta, NumberFormat formatter) {
    final Color colorPrimario = _hexToColor(cuenta.color);
    
    // Convertimos la opacidad 0.5 a valor alfa (127/255) para evitar warning de withOpacity
    final int alphaValue = (0.5 * 255).round();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _mostrarVentanaEditarCuenta(context, cuenta),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorPrimario.withAlpha(alphaValue), width: 1), 
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de la cuenta (Efectivo o Transferencia)
              Icon(
                cuenta.tipo == TipoCuenta.efectivo ? Icons.money : Icons.account_balance,
                color: colorPrimario,
                size: 30,
              ),
              const SizedBox(width: 15),
              // Nombre y tipo de la cuenta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cuenta.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      cuenta.tipo == TipoCuenta.efectivo ? 'Efectivo' : 'Transferencia',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Saldo Actual
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatter.format(cuenta.saldoActual),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cuenta.saldoActual >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  const Text(
                    'Saldo Actual',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }


  /// Comentario: Muestra la ventana de diálogo para crear una nueva cuenta.
  void _mostrarVentanaCrearCuenta(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _FormularioCuenta(
            accion: AccionCuenta.crear,
          ),
        ),
      ),
    );
  }

  /// Comentario: Muestra la ventana de diálogo para editar una cuenta existente.
  void _mostrarVentanaEditarCuenta(BuildContext context, Cuenta cuenta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _FormularioCuenta(
            accion: AccionCuenta.editar,
            cuentaInicial: cuenta,
          ),
        ),
      ),
    );
  }
}

/// Comentario: Enum para definir la acción del formulario.
enum AccionCuenta { crear, editar }

/// Comentario: Formulario stateful para crear o editar una cuenta.
class _FormularioCuenta extends StatefulWidget {
  final AccionCuenta accion;
  final Cuenta? cuentaInicial;

  const _FormularioCuenta({
    required this.accion,
    this.cuentaInicial,
  });

  @override
  State<_FormularioCuenta> createState() => _FormularioCuentaState();
}

class _FormularioCuentaState extends State<_FormularioCuenta> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late TipoCuenta _tipo;
  late double _saldoInicial;
  late String _color;
  bool _puedeEliminar = false; // Solo true en modo editar si no tiene transacciones

  // Lista de colores predefinidos (HEX) para seleccionar.
  final List<String> _coloresPredeterminados = [
    '#3CB371', // MediumSeaGreen (Efectivo)
    '#1E90FF', // DodgerBlue (Transferencia)
    '#FF6347', // Tomato
    '#FFD700', // Gold
    '#9400D3', // DarkViolet
  ];

  @override
  void initState() {
    super.initState();
    final isCrear = widget.accion == AccionCuenta.crear;
    
    // Inicialización de campos con valores por defecto o valores iniciales
    _nombre = widget.cuentaInicial?.nombre ?? '';
    _tipo = widget.cuentaInicial?.tipo ?? TipoCuenta.efectivo;
    _saldoInicial = widget.cuentaInicial?.saldoInicial ?? 0.0; 
    _color = widget.cuentaInicial?.color ?? _coloresPredeterminados[0];
    
    // En modo editar, verificamos si se puede eliminar
    if (!isCrear) {
      _puedeEliminar = true; 
    }
  }

  /// Comentario: Maneja el guardado o actualización de la cuenta.
  void _guardarCuenta() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final cuentaGestion = Provider.of<CuentaGestion>(context, listen: false);
    
    if (widget.accion == AccionCuenta.crear) {
      // Creación de nueva cuenta
      final nuevaCuenta = Cuenta.nueva(
        nombre: _nombre, 
        tipo: _tipo,
        saldoInicial: _saldoInicial,
        color: _color,
      );
      cuentaGestion.agregarCuenta(nuevaCuenta);
      
    } else {
      // Edición de cuenta existente
      final cuentaActualizada = Cuenta(
        idCuenta: widget.cuentaInicial!.idCuenta,
        nombre: _nombre,
        tipo: _tipo,
        saldoInicial: _saldoInicial,
        // Al editar, el saldo actual se mantiene, solo se actualizan los datos básicos.
        saldoActual: widget.cuentaInicial!.saldoActual, 
        color: _color,
      );
      cuentaGestion.actualizarCuenta(cuentaActualizada); 
    }

    // Se asume que el widget está montado al final de la función síncrona.
    Navigator.of(context).pop(); // Cerrar el formulario
  }

  /// Comentario: Maneja la eliminación de la cuenta (solo en modo editar).
  void _eliminarCuenta() async {
    if (!mounted) return;
    
    final bool? confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: const Text('¿Estás seguro de que quieres eliminar esta cuenta? Todas las transacciones asociadas serán eliminadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (!mounted) return; 

    if (confirmar == true) {
      final cuentaGestion = Provider.of<CuentaGestion>(context, listen: false);
      // Lógica de eliminación.
      cuentaGestion.eliminarCuenta(widget.cuentaInicial!.idCuenta);
      
      // Solo hacemos un pop para cerrar el ModalBottomSheet y volver al listado.
      if (!mounted) return;
      Navigator.of(context).pop(); 
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            widget.accion == AccionCuenta.crear ? 'Añadir Nueva Cuenta' : 'Editar Cuenta',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Campo de Nombre
          TextFormField(
            initialValue: _nombre,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Cuenta',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.wallet_travel),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, introduce un nombre.';
              }
              return null;
            },
            onSaved: (value) => _nombre = value!,
          ),
          const SizedBox(height: 15),

          // Selector de Tipo de Cuenta (Efectivo / Transferencia)
          DropdownButtonFormField<TipoCuenta>(
            value: _tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo de Fondo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: const [
              DropdownMenuItem(
                value: TipoCuenta.efectivo,
                child: Text('Efectivo (Billetera, Monedero)'),
              ),
              DropdownMenuItem(
                value: TipoCuenta.transferencia,
                child: Text('Transferencia (Banco, Tarjeta, Virtual)'),
              ),
            ],
            onChanged: (TipoCuenta? newValue) {
              setState(() {
                _tipo = newValue!;
                // Al cambiar el tipo, se asigna un color por defecto (si no se ha seleccionado uno)
                if (!_coloresPredeterminados.contains(_color)) {
                    _color = _tipo == TipoCuenta.efectivo 
                        ? _coloresPredeterminados[0] 
                        : _coloresPredeterminados[1];
                }
              });
            },
            onSaved: (newValue) => _tipo = newValue!,
          ),
          const SizedBox(height: 15),

          // Campo de Saldo Inicial (solo visible y editable al crear)
          if (widget.accion == AccionCuenta.crear)
            TextFormField(
              initialValue: _saldoInicial.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Saldo Inicial (Solo al crear)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Introduce un monto.';
                if (double.tryParse(value) == null) return 'Introduce un número válido.';
                return null;
              },
              onSaved: (value) => _saldoInicial = double.parse(value!),
            ),
          
          // Texto informativo para el modo Edición
          if (widget.accion == AccionCuenta.editar)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                'Saldo Actual: ${NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 2).format(widget.cuentaInicial!.saldoActual)}',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w500,
                  color: widget.cuentaInicial!.saldoActual >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
          const SizedBox(height: 15),

          // Selector de Color
          Text('Color de la Cuenta:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _coloresPredeterminados.length,
              itemBuilder: (context, index) {
                final hexColor = _coloresPredeterminados[index];
                final color = _hexToColor(hexColor);
                final isSelected = _color == hexColor;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _color = hexColor;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),

          // Botones de Acción (Guardar y Opcional: Eliminar)
          Row(
            children: [
              // Botón de Eliminar (solo en modo editar y si se puede)
              if (widget.accion == AccionCuenta.editar && _puedeEliminar)
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red, size: 30),
                  tooltip: 'Eliminar Cuenta',
                  onPressed: _eliminarCuenta,
                ),
              
              const Spacer(),
              
              // Botón de Cancelar
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 10),
              // Botón de Guardar/Actualizar
              ElevatedButton(
                onPressed: _guardarCuenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                ),
                child: Text(widget.accion == AccionCuenta.crear ? 'Guardar Cuenta' : 'Actualizar Cuenta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}