import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../providers/quest_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_helpers.dart';

const _xpOpciones = [10, 20, 30, 50];

/// Formulario para crear o editar un hábito.
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habit});

  /// Si es null, se crea un hábito nuevo; si no, se edita este.
  final Habit? habit;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late String _icono;
  late Color _color;
  late int _xp;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nombreController = TextEditingController(text: h?.nombre ?? '');
    _icono = h?.icono ?? 'book';
    _color = h != null ? Color(h.color) : habitColors.first;
    _xp = h?.xpPorCompletar ?? 20;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(questProvider.notifier);
    final existente = widget.habit;
    if (existente == null) {
      notifier.agregarHabito(
        Habit(
          id: notifier.nuevoId(),
          nombre: _nombreController.text.trim(),
          icono: _icono,
          color: _color.toARGB32(),
          xpPorCompletar: _xp,
        ),
      );
    } else {
      notifier.editarHabito(
        existente.copyWith(
          nombre: _nombreController.text.trim(),
          icono: _icono,
          color: _color.toARGB32(),
          xpPorCompletar: _xp,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.habit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar hábito' : 'Nueva misión'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                hintText: 'p. ej. Leer 20 min',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe un nombre para el hábito.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Icono',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: habitIcons.entries.map((entry) {
                final seleccionado = entry.key == _icono;
                return GestureDetector(
                  onTap: () => setState(() => _icono = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? AppTheme.amber.withValues(alpha: 0.2)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: seleccionado
                            ? AppTheme.amber
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      entry.value,
                      color: seleccionado
                          ? AppTheme.amber
                          : AppTheme.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Color',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: habitColors.map((color) {
                final seleccionado = color.toARGB32() == _color.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: seleccionado
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: seleccionado
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'XP por completar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _xpOpciones.map((xp) {
                final seleccionado = xp == _xp;
                return ChoiceChip(
                  label: Text('+$xp XP'),
                  selected: seleccionado,
                  selectedColor: AppTheme.amber,
                  labelStyle: TextStyle(
                    color: seleccionado ? Colors.black : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _xp = xp),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _guardar,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.amber,
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  esEdicion ? 'Guardar cambios' : 'Crear misión',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
