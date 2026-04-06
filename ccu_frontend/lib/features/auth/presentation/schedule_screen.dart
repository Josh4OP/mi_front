import 'package:flutter/material.dart';

class ScheduleEntry {
  final String id;
  String subject;
  int dayOfWeek;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String classroom;
  String professor;

  ScheduleEntry({
    required this.id,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.classroom = '',
    this.professor = '',
  });

  bool get isPassedToday {
    final now = DateTime.now();
    if (now.weekday != dayOfWeek) return false;
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    return nowMinutes > startMinutes;
  }

  String formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  final List<ScheduleEntry> _entries = [];
  DateTime? _semesterEnd;

  late final TabController _tabController;

  static const List<String> _dayNames = [
    'Lunes', 'Martes', 'Miércoles',
    'Jueves', 'Viernes', 'Sábado',
  ];

  @override
  void initState() {
    super.initState();
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 5);
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: todayIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ScheduleEntry> _entriesForDay(int dayOfWeek) {
    final list = _entries.where((e) => e.dayOfWeek == dayOfWeek).toList();
    list.sort((a, b) {
      final aMin = a.startTime.hour * 60 + a.startTime.minute;
      final bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });
    return list;
  }

  void _openForm({ScheduleEntry? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ScheduleForm(
        existing: existing,
        initialDay: _tabController.index + 1,
        semesterEnd: _semesterEnd,
        onSave: (entry, semEnd) {
          setState(() {
            if (semEnd != null) _semesterEnd = semEnd;
            if (existing != null) {
              final i = _entries.indexWhere((e) => e.id == existing.id);
              if (i != -1) _entries[i] = entry;
            } else {
              _entries.add(entry);
            }
          });
        },
      ),
    );
  }

  void _deleteEntry(ScheduleEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar clase'),
        content: Text(
            '¿Eliminar "${entry.subject}" de todos los ${_dayNames[entry.dayOfWeek - 1]}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _entries.removeWhere((e) => e.id == entry.id));
              Navigator.pop(context);
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 5);

    return Scaffold(
      body: Column(
        children: [
          // Info de fin de semestre
          if (_semesterEnd != null)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Icon(Icons.event_outlined,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Fin de semestre: ${_semesterEnd!.day.toString().padLeft(2, '0')}/'
                    '${_semesterEnd!.month.toString().padLeft(2, '0')}/'
                    '${_semesterEnd!.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _semesterEnd!,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _semesterEnd = picked);
                      }
                    },
                    child: Text(
                      'Cambiar',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tabs de días
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: List.generate(6, (i) {
              final isToday = i == todayIndex;
              return Tab(
                child: Text(
                  _dayNames[i].substring(0, 3),
                  style: TextStyle(
                    fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              );
            }),
          ),

          // Contenido de cada día
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(6, (i) {
                final dayEntries = _entriesForDay(i + 1);
                final isToday = i == todayIndex;

                if (dayEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sin clases',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                      top: 16, left: 16, right: 16, bottom: 90),
                  itemCount: dayEntries.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, j) {
                    final entry = dayEntries[j];
                    final passed = isToday && entry.isPassedToday;

                    return _ScheduleTile(
                      entry: entry,
                      passed: passed,
                      onEdit: () => _openForm(existing: entry),
                      onDelete: () => _deleteEntry(entry),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar clase'),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final ScheduleEntry entry;
  final bool passed;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleTile({
    required this.entry,
    required this.passed,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: passed
                ? theme.colorScheme.outline.withValues(alpha: 0.4)
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          entry.subject,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: passed ? TextDecoration.lineThrough : null,
            color: passed
                ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    size: 13,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: passed ? 0.3 : 0.55)),
                const SizedBox(width: 4),
                Text(
                  '${entry.formatTime(entry.startTime)} – ${entry.formatTime(entry.endTime)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    decoration:
                        passed ? TextDecoration.lineThrough : null,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: passed ? 0.3 : 0.55),
                  ),
                ),
                if (passed) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Finalizada',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            if (entry.classroom.isNotEmpty || entry.professor.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  [
                    if (entry.classroom.isNotEmpty) entry.classroom,
                    if (entry.professor.isNotEmpty) entry.professor,
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: passed ? 0.3 : 0.45),
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(
                value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}

class _ScheduleForm extends StatefulWidget {
  final ScheduleEntry? existing;
  final int initialDay;
  final DateTime? semesterEnd;
  final void Function(ScheduleEntry, DateTime?) onSave;

  const _ScheduleForm({
    this.existing,
    required this.initialDay,
    required this.semesterEnd,
    required this.onSave,
  });

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _classroomCtrl;
  late final TextEditingController _professorCtrl;

  late int _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _semesterEnd;

  static const List<String> _dayNames = [
    'Lunes', 'Martes', 'Miércoles',
    'Jueves', 'Viernes', 'Sábado',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _subjectCtrl = TextEditingController(text: e?.subject ?? '');
    _classroomCtrl = TextEditingController(text: e?.classroom ?? '');
    _professorCtrl = TextEditingController(text: e?.professor ?? '');
    _selectedDay = e?.dayOfWeek ?? widget.initialDay;
    _startTime = e?.startTime;
    _endTime = e?.endTime;
    _semesterEnd = widget.semesterEnd;
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _classroomCtrl.dispose();
    _professorCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 7, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 8, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _pickSemesterEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _semesterEnd ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _semesterEnd = picked);
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la hora de inicio'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la hora de fin'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final startMin = _startTime!.hour * 60 + _startTime!.minute;
    final endMin = _endTime!.hour * 60 + _endTime!.minute;

    if (endMin <= startMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de fin debe ser mayor a la de inicio'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_semesterEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Define la fecha de fin de semestre'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final entry = ScheduleEntry(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      subject: _subjectCtrl.text.trim(),
      dayOfWeek: _selectedDay,
      startTime: _startTime!,
      endTime: _endTime!,
      classroom: _classroomCtrl.text.trim(),
      professor: _professorCtrl.text.trim(),
    );

    widget.onSave(entry, _semesterEnd);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                isEdit ? 'Editar clase' : 'Nueva clase',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Se repetirá semanalmente hasta fin de semestre',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _subjectCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Materia *',
                  prefixIcon: const Icon(Icons.book_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'El nombre es obligatorio'
                        : null,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration: InputDecoration(
                  labelText: 'Día de la semana *',
                  prefixIcon: const Icon(Icons.today_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                items: List.generate(
                  6,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(_dayNames[i]),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedDay = v);
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(isStart: true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora inicio *',
                          prefixIcon:
                              const Icon(Icons.access_time_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _startTime != null
                              ? _formatTime(_startTime!)
                              : 'Seleccionar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _startTime != null
                                ? null
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(isStart: false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora fin *',
                          prefixIcon:
                              const Icon(Icons.access_time_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _endTime != null
                              ? _formatTime(_endTime!)
                              : 'Seleccionar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _endTime != null
                                ? null
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _classroomCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Salón (opcional)',
                  prefixIcon: const Icon(Icons.room_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _professorCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Profesor (opcional)',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: _pickSemesterEnd,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fin de semestre *',
                    prefixIcon:
                        const Icon(Icons.calendar_month_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    suffixIcon: const Icon(Icons.edit_calendar_outlined,
                        size: 18),
                  ),
                  child: Text(
                    _semesterEnd != null
                        ? '${_semesterEnd!.day.toString().padLeft(2, '0')}/'
                            '${_semesterEnd!.month.toString().padLeft(2, '0')}/'
                            '${_semesterEnd!.year}'
                        : 'Seleccionar fecha',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _semesterEnd != null
                          ? null
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isEdit ? 'Guardar cambios' : 'Agregar clase',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}