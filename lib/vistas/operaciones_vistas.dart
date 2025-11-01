// Archivo: lib/vistas/operaciones_vistas.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Importa los modelos y la lógica necesarios
import '../modelos/operaciones_modelo.dart';
import '../modelos/categorias_modelo.dart';
import '../modelos/cuentas_modelo.dart';
import '../logica/operaciones_logica.dart';
import '../logica/categorias_logica.dart';
import '../logica/cuentas_logica.dart';


// -------------------------------------------------------------------------
// VISTA PRINCIPAL: Lista de operaciones para una cuenta específica
// -------------------------------------------------------------------------
class OperacionesListaView extends StatelessWidget {
  final String cuentaId;

  const OperacionesListaView({
    super.key,
    required this.cuentaId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OperacionesGestion>(
      builder: (context, operacionesGestion, child) {
        final operacionesFiltradas = operacionesGestion.operaciones
            .where((op) => op.idCuenta == cuentaId || op.idCuentaDestino == cuentaId)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Operaciones'),
            centerTitle: true,
          ),
          body: operacionesGestion.estaCargando
              ? const Center(child: CircularProgressIndicator())
              : operacionesFiltradas.isEmpty
                  ? const Center(child: Text('No hay operaciones registradas.'))
                  : ListView.builder(
                      itemCount: operacionesFiltradas.length,
                      itemBuilder: (context, index) {
                        final operacion = operacionesFiltradas[index];
                        return OperacionItem(operacion: operacion);
                      },
                    ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => OperacionFormDialog(
                  cuentaId: cuentaId,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------------------
// WIDGET ITEM: Representa una sola operación en la lista (VERSIÓN PÚBLICA)
// -------------------------------------------------------------------------
class OperacionItem extends StatelessWidget {
  final Operacion operacion;

  const OperacionItem({required this.operacion});

  @override
  Widget build(BuildContext context) {
    final categoriaGestion = Provider.of<CategoriaGestion>(context);
    final categoria = categoriaGestion.buscarCategoriaPorId(operacion.idCategoria);
    
    final fechaFormateada = DateFormat('dd/MM/yyyy').format(operacion.fecha);
    
    Color? colorAvatar = Colors.grey;
    if (categoria != null) {
      colorAvatar = Color(int.parse(categoria.color.replaceAll('#', '0xff')));
    }

    IconData icono = Icons.sync_alt;
    Color colorMonto = Colors.black;

    switch(operacion.tipo){
      case TipoOperacion.ingreso:
        icono = Icons.add;
        colorMonto = Colors.green;
        break;
      case TipoOperacion.gasto:
        icono = Icons.remove;
        colorMonto = Colors.red;
        break;
      case TipoOperacion.transferencia:
        icono = Icons.swap_horiz;
        colorMonto = Colors.blueGrey;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorAvatar,
        child: Icon(icono, color: Colors.white),
      ),
      title: Text(operacion.descripcion),
      subtitle: Text('${categoria?.nombre ?? 'Sin Categoría'} - $fechaFormateada'),
      trailing: Text(
        '${operacion.monto.toStringAsFixed(2)}€',
        style: TextStyle(
          color: colorMonto,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => OperacionFormDialog(
            cuentaId: operacion.idCuenta,
            operacion: operacion,
          ),
        );
      },
      onLongPress: () {
        _mostrarDialogoConfirmacionEliminar(context, operacion);
      },
    );
  }
  
  void _mostrarDialogoConfirmacionEliminar(BuildContext context, Operacion operacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar operación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta operación?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () {
              Provider.of<OperacionesGestion>(context, listen: false)
                  .eliminarOperacion(operacion.idOperacion);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// DIALOGO: Formulario para añadir o editar una operación
// -------------------------------------------------------------------------
class OperacionFormDialog extends StatefulWidget {
  final String cuentaId;
  final Operacion? operacion;

  const OperacionFormDialog({
    super.key,
    required this.cuentaId,
    this.operacion,
  });

  @override
  State<OperacionFormDialog> createState() => _OperacionFormDialogState();
}

class _OperacionFormDialogState extends State<OperacionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  late TipoOperacion _tipo;
  late DateTime _fecha;
  late String _idCategoria;
  String? _idCuentaDestino;
  
  @override
  void initState() {
    super.initState();
    if (widget.operacion != null) {
      _tipo = widget.operacion!.tipo;
      _montoController.text = widget.operacion!.monto.toStringAsFixed(2);
      _descripcionController.text = widget.operacion!.descripcion;
      _fecha = widget.operacion!.fecha;
      _idCategoria = widget.operacion!.idCategoria;
      _idCuentaDestino = widget.operacion!.idCuentaDestino;
    } else {
      _tipo = TipoOperacion.gasto;
      _fecha = DateTime.now();
      _idCategoria = ''; 
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardarOperacion(OperacionesGestion operacionesGestion) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final operacion = Operacion(
        idOperacion: widget.operacion?.idOperacion,
        tipo: _tipo,
        monto: double.parse(_montoController.text),
        descripcion: _descripcionController.text,
        fecha: _fecha,
        idCuenta: widget.cuentaId,
        idCategoria: _idCategoria,
        idCuentaDestino: _tipo == TipoOperacion.transferencia ? _idCuentaDestino : null,
      );
      
      if (widget.operacion == null) {
        operacionesGestion.agregarOperacion(operacion);
      } else {
        operacionesGestion.actualizarOperacion(operacion);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final operacionesGestion = Provider.of<OperacionesGestion>(context, listen: false);
    final categoriaGestion = Provider.of<CategoriaGestion>(context);
    final cuentasGestion = Provider.of<CuentaGestion>(context);
    final categorias = categoriaGestion.categorias;
    final cuentas = cuentasGestion.cuentas;
    final esEdicion = widget.operacion != null;
    
    return AlertDialog(
      title: Text(esEdicion ? 'Editar Operación' : 'Añadir Operación'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Selector de Tipo de Operación
              DropdownButtonFormField<TipoOperacion>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: TipoOperacion.values.map((tipo) {
                  return DropdownMenuItem<TipoOperacion>(
                    value: tipo,
                    child: Text(tipo.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _tipo = value!;
                  _idCategoria = '';
                }),
              ),
              // Campo para el monto
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              // Campo para la descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una descripción';
                  }
                  return null;
                },
              ),
              // Selector de categoría (filtrado por tipo de operación)
              DropdownButtonFormField<String>(
                value: _idCategoria.isNotEmpty ? _idCategoria : null,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categorias
                    .where((c) => c.tiposAplicables.contains(TipoCategoria.values[_tipo.index]) || c.tiposAplicables.contains(TipoCategoria.todos))
                    .map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria.idCategoria,
                        child: Text(categoria.nombre),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _idCategoria = value!),
                validator: (value) {
                  if (value == null) {
                    return 'Seleccione una categoría';
                  }
                  return null;
                },
              ),
              // Selector de cuenta destino (solo para transferencias)
              if (_tipo == TipoOperacion.transferencia)
                DropdownButtonFormField<String>(
                  value: _idCuentaDestino,
                  decoration: const InputDecoration(labelText: 'Cuenta Destino'),
                  items: cuentas
                      .where((cuenta) => cuenta.idCuenta != widget.cuentaId) // Evita la cuenta origen
                      .map((cuenta) {
                        return DropdownMenuItem<String>(
                          value: cuenta.idCuenta,
                          child: Text(cuenta.nombre),
                        );
                      }).toList(),
                  onChanged: (value) => setState(() => _idCuentaDestino = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Seleccione una cuenta destino';
                    }
                    return null;
                  },
                ),
              // Selector de fecha
              ListTile(
                title: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fecha)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final seleccion = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (seleccion != null) {
                    setState(() => _fecha = seleccion);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(esEdicion ? 'Guardar' : 'Añadir'),
          onPressed: () => _guardarOperacion(operacionesGestion),
        ),
      ],
    );
  }
}
