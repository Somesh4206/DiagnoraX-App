import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class _Reminder {
  final String id;
  String medicineName;
  String dosage;
  String time;
  bool isActive;

  _Reminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.time,
    this.isActive = true,
  });
}

class RemindersScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const RemindersScreen({super.key, required this.user});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<_Reminder> _reminders = [
    _Reminder(
      id: '1',
      medicineName: 'Paracetamol',
      dosage: '500mg',
      time: '08:00',
      isActive: true,
    ),
  ];

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    String selectedTime = '09:00';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Medication',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  NeonTextField(
                    hint: 'e.g., Paracetamol',
                    label: 'Medicine Name',
                    controller: nameCtrl,
                  ),
                  const SizedBox(height: 16),
                  NeonTextField(
                    hint: 'e.g., 500mg',
                    label: 'Dosage',
                    controller: dosageCtrl,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TIME',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final parts = selectedTime.split(':');
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay(
                          hour: int.parse(parts[0]),
                          minute: int.parse(parts[1]),
                        ),
                        builder: (_, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppTheme.neonGreen,
                              onPrimary: Colors.black,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setSheetState(() {
                          selectedTime =
                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.neonGreenBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: AppTheme.neonGreen, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            selectedTime,
                            style: const TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeonButton(
                    label: 'Save Reminder',
                    icon: Icons.save_outlined,
                    fullWidth: true,
                    onTap: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _reminders.add(_Reminder(
                          id: const Uuid().v4(),
                          medicineName: nameCtrl.text.trim(),
                          dosage: dosageCtrl.text.trim(),
                          time: selectedTime,
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Medicine Reminders'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _reminders.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.notifications_outlined,
                message:
                    'No active reminders.\nTap + Add to get started!',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final rem = _reminders[i];
                return _ReminderCard(
                  reminder: rem,
                  onToggle: () {
                    setState(() => rem.isActive = !rem.isActive);
                  },
                  onDelete: () {
                    setState(() => _reminders.removeAt(i));
                  },
                );
              },
            ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final _Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: reminder.isActive ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: GlassCard(
        highlight: reminder.isActive,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: reminder.isActive
                        ? AppTheme.neonGreenDim
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: reminder.isActive
                        ? AppTheme.neonGreen
                        : AppTheme.textMuted,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.medicineName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reminder.dosage.isNotEmpty
                            ? reminder.dosage
                            : 'No dosage set',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    reminder.isActive
                        ? Icons.check_circle_rounded
                        : Icons.cancel_outlined,
                    color: reminder.isActive
                        ? AppTheme.neonGreen
                        : AppTheme.textMuted,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time,
                    color: AppTheme.neonGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  reminder.time,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                // Day chips
                Row(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map(
                        (d) => Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: reminder.isActive
                                ? AppTheme.neonGreenDim
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: reminder.isActive
                                    ? AppTheme.neonGreen
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
