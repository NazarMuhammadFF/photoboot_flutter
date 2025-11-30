import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/grid_config.dart';

class GridEditorScreen extends StatefulWidget {
  final GridConfig? grid;
  final Function(GridConfig) onSave;

  const GridEditorScreen({super.key, this.grid, required this.onSave});

  @override
  State<GridEditorScreen> createState() => _GridEditorScreenState();
}

class _GridEditorScreenState extends State<GridEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  List<GridSlot> _slots = [];
  GridSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.grid?.name ?? '');
    _widthController = TextEditingController(
      text: widget.grid?.canvasWidth.toString() ?? '1200',
    );
    _heightController = TextEditingController(
      text: widget.grid?.canvasHeight.toString() ?? '1800',
    );

    if (widget.grid != null) {
      _slots = List.from(widget.grid!.slots);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _addSlot() {
    setState(() {
      final newId = _slots.isEmpty
          ? 1
          : _slots.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      _slots.add(GridSlot(id: newId, x: 50, y: 50, width: 300, height: 300));
    });
  }

  void _updateSlot(GridSlot slot) {
    setState(() {
      final index = _slots.indexWhere((s) => s.id == slot.id);
      if (index != -1) {
        _slots[index] = slot;
      }
    });
  }

  void _removeSelectedSlot() {
    if (_selectedSlot != null) {
      setState(() {
        _slots.removeWhere((s) => s.id == _selectedSlot!.id);
        _selectedSlot = null;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newGrid = GridConfig(
        id: widget.grid?.id ?? const Uuid().v4(),
        name: _nameController.text,
        canvasWidth: double.parse(_widthController.text),
        canvasHeight: double.parse(_heightController.text),
        slots: _slots,
      );
      widget.onSave(newGrid);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grid == null ? 'Create Grid' : 'Edit Grid'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Row(
        children: [
          // Left Panel: Properties
          Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    'Grid Properties',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Grid Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _widthController,
                          decoration: const InputDecoration(
                            labelText: 'Width (px)',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Height (px)',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Slots',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: _addSlot,
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  if (_selectedSlot != null) ...[
                    const Divider(),
                    Text(
                      'Selected Slot #${_selectedSlot!.id}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    _SlotPropertyEditor(
                      slot: _selectedSlot!,
                      onUpdate: _updateSlot,
                      onDelete: _removeSelectedSlot,
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Select a slot on the canvas to edit properties',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Right Panel: Canvas Visualizer
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final canvasW =
                        double.tryParse(_widthController.text) ?? 1200;
                    final canvasH =
                        double.tryParse(_heightController.text) ?? 1800;

                    // Calculate scale to fit
                    final scaleX = (constraints.maxWidth - 40) / canvasW;
                    final scaleY = (constraints.maxHeight - 40) / canvasH;
                    final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(
                      0.1,
                      1.0,
                    );

                    return Container(
                      width: canvasW * scale,
                      height: canvasH * scale,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: _slots.map((slot) {
                          final isSelected = _selectedSlot?.id == slot.id;
                          return Positioned(
                            left: slot.x * scale,
                            top: slot.y * scale,
                            width: slot.width * scale,
                            height: slot.height * scale,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSlot = slot;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.3),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.blue.withOpacity(0.5),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '#${slot.id}',
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotPropertyEditor extends StatelessWidget {
  final GridSlot slot;
  final Function(GridSlot) onUpdate;
  final VoidCallback onDelete;

  const _SlotPropertyEditor({
    required this.slot,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _NumberInput(
                label: 'X',
                value: slot.x,
                onChanged: (val) => onUpdate(
                  GridSlot(
                    id: slot.id,
                    x: val,
                    y: slot.y,
                    width: slot.width,
                    height: slot.height,
                    rotation: slot.rotation,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberInput(
                label: 'Y',
                value: slot.y,
                onChanged: (val) => onUpdate(
                  GridSlot(
                    id: slot.id,
                    x: slot.x,
                    y: val,
                    width: slot.width,
                    height: slot.height,
                    rotation: slot.rotation,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _NumberInput(
                label: 'W',
                value: slot.width,
                onChanged: (val) => onUpdate(
                  GridSlot(
                    id: slot.id,
                    x: slot.x,
                    y: slot.y,
                    width: val,
                    height: slot.height,
                    rotation: slot.rotation,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberInput(
                label: 'H',
                value: slot.height,
                onChanged: (val) => onUpdate(
                  GridSlot(
                    id: slot.id,
                    x: slot.x,
                    y: slot.y,
                    width: slot.width,
                    height: val,
                    rotation: slot.rotation,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            label: const Text('Remove Slot'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberInput extends StatelessWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const _NumberInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.toString(),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (val) {
        if (val.isNotEmpty) {
          onChanged(double.tryParse(val) ?? value);
        }
      },
    );
  }
}
