import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/level_system.dart';
import '../providers/quest_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';
import '../widgets/pixel_avatar.dart';
import 'habit_form_screen.dart';

/// Pantalla principal: avatar, barra de XP/nivel y lista de hábitos.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.onCrearHabito});

  final VoidCallback onCrearHabito;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _xpFlotante;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _completar(String id, int xp, String nombre) {
    final ok = ref.read(questProvider.notifier).completarHabito(id);
    if (!ok) return;
    _timer?.cancel();
    setState(() => _xpFlotante = '+$xp XP · $nombre');
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _xpFlotante = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questProvider);
    final rango = state.rango;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    PixelAvatar(rango: rango, size: 96),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Nivel ${state.nivel}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.violet.withValues(
                                    alpha: 0.25,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  rango.nombre,
                                  style: const TextStyle(
                                    color: Color(0xFFC4B5FD),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rango.descripcion,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: state.progresoNivel,
                            ),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, progreso, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progreso,
                                      minHeight: 10,
                                      backgroundColor: const Color(
                                        0xFF232839,
                                      ),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            AppTheme.amber,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${state.xpEnNivel} / ${state.xpNecesarioNivel} XP para el nivel ${state.nivel + 1} · Total: ${state.totalXp} XP',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatMini(
                  label: 'Hoy',
                  value:
                      '${state.habitosCompletadosHoy}/${state.habits.length}',
                ),
                const SizedBox(width: 8),
                _StatMini(
                  label: 'Mejor racha',
                  value: '${state.mejorRacha} días',
                ),
                const SizedBox(width: 8),
                _StatMini(
                  label: 'Misiones',
                  value: '${state.totalCompletados}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Misiones de hoy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Completa un hábito para ganar XP y mantener tu racha.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (state.habits.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Aún no tienes hábitos. Toca + para crear tu primera misión.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...state.habits.map(
                (habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HabitCard(
                    habit: habit,
                    onComplete: () =>
                        _completar(habit.id, habit.xpPorCompletar, habit.nombre),
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HabitFormScreen(habit: habit),
                        ),
                      );
                    },
                    onDelete: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar hábito'),
                          content: Text(
                            '¿Eliminar "${habit.nombre}"? Su progreso se perderá.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      if (confirmar == true) {
                        ref
                            .read(questProvider.notifier)
                            .eliminarHabito(habit.id);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
        if (_xpFlotante != null)
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, valor, child) {
                  return Opacity(
                    opacity: 1 - (valor * 0.3),
                    child: Transform.translate(
                      offset: Offset(0, -20 * valor),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.amber,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _xpFlotante!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
