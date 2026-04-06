import 'package:flutter/material.dart';

class GradeActivity {
  final String id;
  String name;
  double grade;
  double weight;

  GradeActivity({
    required this.id,
    required this.name,
    required this.grade,
    required this.weight,
  });
}

class Cut {
  final String id;
  String name;
  double weight;
  List<GradeActivity> activities;

  Cut({
    required this.id,
    required this.name,
    required this.weight,
    List<GradeActivity>? activities,
  }) : activities = activities ?? [];

  double get grade {
    if (activities.isEmpty) return 0.0;
    return activities.fold(
        0.0, (sum, a) => sum + a.grade * (a.weight / 100));
  }

  double get usedWeight =>
      activities.fold(0.0, (sum, a) => sum + a.weight);
}

class Subject {
  final String id;
  String name;
  List<Cut> cuts;

  Subject({
    required this.id,
    required this.name,
    List<Cut>? cuts,
  }) : cuts = cuts ??
            [
              Cut(id: '1', name: 'Corte 1', weight: 30),
              Cut(id: '2', name: 'Corte 2', weight: 35),
              Cut(id: '3', name: 'Corte 3', weight: 35),
            ];

  double get finalGrade =>
      cuts.fold(0.0, (sum, c) => sum + c.grade * (c.weight / 100));

  double get totalCutWeight =>
      cuts.fold(0.0, (sum, c) => sum + c.weight);

  bool get isPassing => finalGrade >= 3.0;
}

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final List<Subject> _subjects = [];

  void _openAddSubject({Subject? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SubjectForm(
        existing: existing,
        onSave: (subject) {
          setState(() {
            if (existing != null) {
              final i =
                  _subjects.indexWhere((s) => s.id == existing.id);
              if (i != -1) _subjects[i] = subject;
            } else {
              _subjects.add(subject);
            }
          });
        },
      ),
    );
  }

  void _deleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar materia'),
        content: Text('¿Eliminar "${subject.name}" y todas sus notas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() =>
                  _subjects.removeWhere((s) => s.id == subject.id));
              Navigator.pop(context);
            },
            child: Text('Eliminar',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _openDetail(Subject subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubjectDetailPage(
          subject: subject,
          onChanged: () => setState(() {}),
        ),
      ),
    );
  }

  Color _gradeColor(double grade, ColorScheme cs) {
    if (grade >= 4.0) return Colors.green.shade500;
    if (grade >= 3.0) return Colors.orange.shade500;
    return cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calculate_outlined,
                      size: 72,
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Sin materias registradas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(
                  top: 16, left: 16, right: 16, bottom: 90),
              itemCount: _subjects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final s = _subjects[i];
                final grade = s.finalGrade;
                final color = _gradeColor(grade, theme.colorScheme);

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    onTap: () => _openDetail(s),
                    title: Text(
                      s.name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${s.cuts.length} cortes · '
                      '${s.cuts.where((c) => c.activities.isNotEmpty).length} con notas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              grade.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            Text(
                              s.isPassing ? 'Aprobando' : 'En riesgo',
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _openAddSubject(existing: s);
                            if (v == 'delete') _deleteSubject(s);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Editar nombre')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Eliminar')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSubject(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva materia'),
      ),
    );
  }
}

class _SubjectForm extends StatefulWidget {
  final Subject? existing;
  final void Function(Subject) onSave;

  const _SubjectForm({this.existing, required this.onSave});

  @override
  State<_SubjectForm> createState() => _SubjectFormState();
}

class _SubjectFormState extends State<_SubjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  final _w1Ctrl = TextEditingController();
  final _w2Ctrl = TextEditingController();
  final _w3Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _w1Ctrl.text = (e?.cuts[0].weight ?? 30).toStringAsFixed(0);
    _w2Ctrl.text = (e?.cuts[1].weight ?? 35).toStringAsFixed(0);
    _w3Ctrl.text = (e?.cuts[2].weight ?? 35).toStringAsFixed(0);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _w1Ctrl.dispose();
    _w2Ctrl.dispose();
    _w3Ctrl.dispose();
    super.dispose();
  }

  bool get _weightsValid {
    final w1 = double.tryParse(_w1Ctrl.text) ?? 0;
    final w2 = double.tryParse(_w2Ctrl.text) ?? 0;
    final w3 = double.tryParse(_w3Ctrl.text) ?? 0;
    return (w1 + w2 + w3) == 100;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_weightsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Los pesos de los cortes deben sumar 100%')),
      );
      return;
    }

    final e = widget.existing;
    final subject = Subject(
      id: e?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      cuts: [
        Cut(
          id: e?.cuts[0].id ?? '1',
          name: 'Corte 1',
          weight: double.parse(_w1Ctrl.text),
          activities: e?.cuts[0].activities,
        ),
        Cut(
          id: e?.cuts[1].id ?? '2',
          name: 'Corte 2',
          weight: double.parse(_w2Ctrl.text),
          activities: e?.cuts[1].activities,
        ),
        Cut(
          id: e?.cuts[2].id ?? '3',
          name: 'Corte 3',
          weight: double.parse(_w3Ctrl.text),
          activities: e?.cuts[2].activities,
        ),
      ],
    );

    widget.onSave(subject);
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
                  color:
                      theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              isEdit ? 'Editar materia' : 'Nueva materia',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre de la materia *',
                prefixIcon: const Icon(Icons.book_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
            ),
            const SizedBox(height: 16),

            Text(
              'Pesos de cortes (deben sumar 100%)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _WeightField(ctrl: _w1Ctrl, label: 'Corte 1 %')),
                const SizedBox(width: 10),
                Expanded(child: _WeightField(ctrl: _w2Ctrl, label: 'Corte 2 %')),
                const SizedBox(width: 10),
                Expanded(child: _WeightField(ctrl: _w3Ctrl, label: 'Corte 3 %')),
              ],
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
                  isEdit ? 'Guardar cambios' : 'Agregar materia',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  const _WeightField({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
      validator: (v) {
        final n = double.tryParse(v ?? '');
        if (n == null || n <= 0 || n > 100) return 'Inválido';
        return null;
      },
    );
  }
}

class _SubjectDetailPage extends StatefulWidget {
  final Subject subject;
  final VoidCallback onChanged;

  const _SubjectDetailPage(
      {required this.subject, required this.onChanged});

  @override
  State<_SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<_SubjectDetailPage> {
  // ELIMINADO: _rebuild() no se usaba en ningún lugar

  void _openAddActivity(Cut cut) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ActivityForm(
        cut: cut,
        onSave: (activity) {
          setState(() => cut.activities.add(activity));
          widget.onChanged();
        },
      ),
    );
  }

  void _editActivity(Cut cut, GradeActivity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ActivityForm(
        cut: cut,
        existing: activity,
        onSave: (updated) {
          setState(() {
            final i =
                cut.activities.indexWhere((a) => a.id == activity.id);
            if (i != -1) cut.activities[i] = updated;
          });
          widget.onChanged();
        },
      ),
    );
  }

  void _deleteActivity(Cut cut, GradeActivity activity) {
    setState(() =>
        cut.activities.removeWhere((a) => a.id == activity.id));
    widget.onChanged();
  }

  void _openGoalCalculator() {
    showDialog(
      context: context,
      builder: (_) => _GoalCalculatorDialog(subject: widget.subject),
    );
  }

  Color _gradeColor(double grade) {
    if (grade >= 4.0) return Colors.green.shade500;
    if (grade >= 3.0) return Colors.orange.shade500;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Calcular meta',
            onPressed: _openGoalCalculator,
          ),
        ],
      ),

      body: ListView(
        padding:
            const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
        children: [
          _FinalGradeCard(subject: subject),
          const SizedBox(height: 20),

          ...subject.cuts.map((cut) => _CutSection(
                cut: cut,
                gradeColor: _gradeColor,
                onAddActivity: () => _openAddActivity(cut),
                onEditActivity: (a) => _editActivity(cut, a),
                onDeleteActivity: (a) => _deleteActivity(cut, a),
              )),
        ],
      ),
    );
  }
}

class _FinalGradeCard extends StatelessWidget {
  final Subject subject;
  const _FinalGradeCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grade = subject.finalGrade;
    final isPassing = subject.isPassing;

    final List<Color> gradient = isPassing
        ? [const Color(0xFF059669), const Color(0xFF10B981)]
        : [const Color(0xFFDC2626), const Color(0xFFEF4444)];

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Definitiva estimada',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    grade.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    isPassing ? '✓ Aprobando' : '✗ En riesgo',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: subject.cuts.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${c.name}: ${c.grade.toStringAsFixed(2)} (${c.weight.toStringAsFixed(0)}%)',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CutSection extends StatelessWidget {
  final Cut cut;
  final Color Function(double) gradeColor;
  final VoidCallback onAddActivity;
  final void Function(GradeActivity) onEditActivity;
  final void Function(GradeActivity) onDeleteActivity;

  const _CutSection({
    required this.cut,
    required this.gradeColor,
    required this.onAddActivity,
    required this.onEditActivity,
    required this.onDeleteActivity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = 100 - cut.usedWeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cut.name}  ·  ${cut.weight.toStringAsFixed(0)}% del total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Nota del corte: ${cut.grade.toStringAsFixed(2)}  '
                    '·  Peso usado: ${cut.usedWeight.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: remaining > 0 ? onAddActivity : null,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
            ),
          ],
        ),

        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: cut.usedWeight / 100,
            minHeight: 6,
            backgroundColor:
                theme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              cut.usedWeight > 100
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ),

        if (remaining <= 0 && cut.activities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Peso completo (100%)',
              style: TextStyle(
                  fontSize: 11, color: theme.colorScheme.primary),
            ),
          ),

        const SizedBox(height: 8),

        if (cut.activities.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Sin actividades aún',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          )
        else
          ...cut.activities.map((a) => _ActivityTile(
                activity: a,
                gradeColor: gradeColor(a.grade),
                onEdit: () => onEditActivity(a),
                onDelete: () => onDeleteActivity(a),
              )),

        const Divider(height: 28),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final GradeActivity activity;
  final Color gradeColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityTile({
    required this.activity,
    required this.gradeColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title: Text(
          activity.name,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Peso: ${activity.weight.toStringAsFixed(0)}%',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              activity.grade.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: gradeColor,
              ),
            ),
            PopupMenuButton<String>(
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
          ],
        ),
      ),
    );
  }
}

class _ActivityForm extends StatefulWidget {
  final Cut cut;
  final GradeActivity? existing;
  final void Function(GradeActivity) onSave;

  const _ActivityForm(
      {required this.cut, this.existing, required this.onSave});

  @override
  State<_ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<_ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _gradeCtrl =
        TextEditingController(text: e != null ? e.grade.toString() : '');
    _weightCtrl = TextEditingController(
        text: e != null ? e.weight.toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gradeCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  double get _availableWeight {
    final used = widget.cut.usedWeight;
    final existing = widget.existing?.weight ?? 0;
    return 100 - used + existing;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final activity = GradeActivity(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      grade: double.parse(_gradeCtrl.text),
      weight: double.parse(_weightCtrl.text),
    );

    widget.onSave(activity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;
    final available = _availableWeight;

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
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
                  color:
                      theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              isEdit ? 'Editar actividad' : 'Nueva actividad — ${widget.cut.name}',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Peso disponible: ${available.toStringAsFixed(0)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nombre de la actividad *',
                prefixIcon: const Icon(Icons.assignment_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gradeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Nota (0.0 – 5.0) *',
                      prefixIcon: const Icon(Icons.grade_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null) return 'Nota inválida';
                      if (n < 0 || n > 5) return 'Entre 0 y 5';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Peso % *',
                      prefixIcon: const Icon(Icons.percent),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Inválido';
                      if (n > available + 0.01) {
                        return 'Máx ${available.toStringAsFixed(0)}%';
                      }
                      return null;
                    },
                  ),
                ),
              ],
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
                  isEdit ? 'Guardar cambios' : 'Agregar actividad',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCalculatorDialog extends StatefulWidget {
  final Subject subject;
  const _GoalCalculatorDialog({required this.subject});

  @override
  State<_GoalCalculatorDialog> createState() =>
      _GoalCalculatorDialogState();
}

class _GoalCalculatorDialogState extends State<_GoalCalculatorDialog> {
  final _goalCtrl = TextEditingController(text: '3.5');
  int _targetCutIndex = 2;
  String _result = '';

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final goal = double.tryParse(_goalCtrl.text);
    if (goal == null || goal < 0 || goal > 5) {
      setState(() => _result = 'Ingresa una meta válida (0.0 – 5.0)');
      return;
    }

    final subject = widget.subject;
    final targetCut = subject.cuts[_targetCutIndex];

    double accumulated = 0;
    for (int i = 0; i < subject.cuts.length; i++) {
      if (i != _targetCutIndex) {
        accumulated +=
            subject.cuts[i].grade * (subject.cuts[i].weight / 100);
      }
    }

    final needed =
        (goal - accumulated) / (targetCut.weight / 100);

    setState(() {
      if (needed > 5.0) {
        _result =
            'No es posible alcanzar ${goal.toStringAsFixed(2)} en ${targetCut.name}.\n'
            'La nota máxima posible con 5.0 sería '
            '${(accumulated + 5.0 * targetCut.weight / 100).toStringAsFixed(2)}.';
      } else if (needed < 0) {
        _result =
            'Ya tienes garantizada la meta ${goal.toStringAsFixed(2)} '
            'sin importar la nota del ${targetCut.name}.';
      } else {
        _result =
            'Necesitas sacar mínimo\n${needed.toStringAsFixed(2)}\nen ${targetCut.name}.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = widget.subject;

    return AlertDialog(
      title: const Text('Calcular meta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materia: ${subject.name}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _goalCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Meta de nota final (0.0 – 5.0)',
                prefixIcon: const Icon(Icons.flag_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),

            // CORREGIDO: value → initialValue
            DropdownButtonFormField<int>(
              initialValue: _targetCutIndex,
              decoration: InputDecoration(
                labelText: '¿Para qué corte calcular?',
                prefixIcon: const Icon(Icons.calculate_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              items: List.generate(
                subject.cuts.length,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(subject.cuts[i].name),
                ),
              ),
              onChanged: (v) {
                if (v != null) setState(() => _targetCutIndex = v);
              },
            ),
            const SizedBox(height: 20),

            if (_result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _result,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
          onPressed: _calculate,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Calcular'),
        ),
      ],
    );
  }
}