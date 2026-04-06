import 'package:flutter/material.dart';

class CalculationsScreen extends StatelessWidget {
  const CalculationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(
          top: 16, left: 16, right: 16, bottom: 90),
      children: [
        Text(
          "Calculadoras",
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          "Herramientas para tu rendimiento académico",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 20),

        const _NotaCorteCard(),
        const SizedBox(height: 12),
        const _DefinitivaCorteCard(),
        const SizedBox(height: 12),
        const _DefinitivaMateriaCard(),
        const SizedBox(height: 12),
        const _NotaAprobatoriaCard(),
        const SizedBox(height: 12),
        const _NotaMetaCard(),
        const SizedBox(height: 12),
        const _PPACard(),
      ],
    );
  }
}

class _CalcCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Widget content;

  const _CalcCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.content,
  });

  @override
  State<_CalcCard> createState() => _CalcCardState();
}

class _CalcCardState extends State<_CalcCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: widget.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: widget.content,
            ),
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _ResultBox({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontSize: 12, color: c)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, color: c),
          ),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData? icon;

  const _NumField({required this.ctrl, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }
}

Color _colorForGrade(double g) {
  if (g >= 4.0) return Colors.green.shade500;
  if (g >= 3.0) return Colors.orange.shade500;
  return Colors.red.shade400;
}

Color _colorForNeeded(double n) {
  if (n >= 4.5) return Colors.red.shade400;
  if (n >= 3.5) return Colors.orange.shade500;
  return Colors.green.shade500;
}

class _NotaCorteCard extends StatefulWidget {
  const _NotaCorteCard();

  @override
  State<_NotaCorteCard> createState() => _NotaCorteCardState();
}

class _NotaCorteCardState extends State<_NotaCorteCard> {
  final List<TextEditingController> _notaCtrls = [TextEditingController()];
  final List<TextEditingController> _pesoCtrls = [TextEditingController()];
  String _result = '';
  Color? _resultColor;

  void _addRow() {
    setState(() {
      _notaCtrls.add(TextEditingController());
      _pesoCtrls.add(TextEditingController());
    });
  }

  void _removeRow(int i) {
    if (_notaCtrls.length == 1) return;
    setState(() {
      _notaCtrls[i].dispose();
      _pesoCtrls[i].dispose();
      _notaCtrls.removeAt(i);
      _pesoCtrls.removeAt(i);
    });
  }

  void _calculate() {
    double total = 0;
    double pesoTotal = 0;
    for (int i = 0; i < _notaCtrls.length; i++) {
      final nota = double.tryParse(_notaCtrls[i].text);
      final peso = double.tryParse(_pesoCtrls[i].text);
      if (nota == null || peso == null) {
        setState(() {
          _result = 'Completa todos los campos';
          _resultColor = Colors.orange.shade500;
        });
        return;
      }
      if (nota < 0 || nota > 5) {
        setState(() {
          _result = 'Las notas deben estar entre 0.0 y 5.0';
          _resultColor = Colors.red.shade400;
        });
        return;
      }
      total += nota * (peso / 100);
      pesoTotal += peso;
    }
    if ((pesoTotal - 100).abs() > 0.01) {
      setState(() {
        _result =
            'Los pesos deben sumar 100% (actual: ${pesoTotal.toStringAsFixed(1)}%)';
        _resultColor = Colors.orange.shade500;
      });
      return;
    }
    setState(() {
      _result = total.toStringAsFixed(2);
      _resultColor = _colorForGrade(total);
    });
  }

  @override
  void dispose() {
    for (final c in [..._notaCtrls, ..._pesoCtrls]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CalcCard(
      icon: Icons.bar_chart_outlined,
      title: "Nota de corte",
      subtitle: "Suma ponderada de actividades",
      gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      content: Column(
        children: [
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Text("Nota",
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Text("Peso %",
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_notaCtrls.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: _NumField(ctrl: _notaCtrls[i], label: 'Ej: 3.8')),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 4,
                      child: _NumField(ctrl: _pesoCtrls[i], label: 'Ej: 30')),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: _notaCtrls.length > 1
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        size: 20),
                    onPressed: () => _removeRow(i),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Agregar actividad"),
          ),
          const SizedBox(height: 8),
          _CalcButton(onPressed: _calculate),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResultBox(
                label: "Nota del corte",
                value: _result,
                color: _resultColor),
          ],
        ],
      ),
    );
  }
}

class _DefinitivaCorteCard extends StatefulWidget {
  const _DefinitivaCorteCard();

  @override
  State<_DefinitivaCorteCard> createState() => _DefinitivaCorteCardState();
}

class _DefinitivaCorteCardState extends State<_DefinitivaCorteCard> {
  final List<TextEditingController> _notaCtrls = [TextEditingController()];
  final List<TextEditingController> _creditCtrls = [TextEditingController()];
  String _result = '';
  Color? _resultColor;

  void _addRow() {
    setState(() {
      _notaCtrls.add(TextEditingController());
      _creditCtrls.add(TextEditingController());
    });
  }

  void _removeRow(int i) {
    if (_notaCtrls.length == 1) return;
    setState(() {
      _notaCtrls[i].dispose();
      _creditCtrls[i].dispose();
      _notaCtrls.removeAt(i);
      _creditCtrls.removeAt(i);
    });
  }

  void _calculate() {
    double sumaNC = 0;
    double sumaC = 0;
    for (int i = 0; i < _notaCtrls.length; i++) {
      final nota = double.tryParse(_notaCtrls[i].text);
      final cred = double.tryParse(_creditCtrls[i].text);
      if (nota == null || cred == null) {
        setState(() {
          _result = 'Completa todos los campos';
          _resultColor = Colors.orange.shade500;
        });
        return;
      }
      if (nota < 0 || nota > 5) {
        setState(() {
          _result = 'Las notas deben estar entre 0.0 y 5.0';
          _resultColor = Colors.red.shade400;
        });
        return;
      }
      if (cred <= 0) {
        setState(() {
          _result = 'Los créditos deben ser mayores a 0';
          _resultColor = Colors.red.shade400;
        });
        return;
      }
      sumaNC += nota * cred;
      sumaC += cred;
    }
    final def = sumaNC / sumaC;
    setState(() {
      _result = def.toStringAsFixed(2);
      _resultColor = _colorForGrade(def);
    });
  }

  @override
  void dispose() {
    for (final c in [..._notaCtrls, ..._creditCtrls]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CalcCard(
      icon: Icons.summarize_outlined,
      title: "Definitiva de corte",
      subtitle: "Promedio ponderado por créditos",
      gradient: const [Color(0xFF9333EA), Color(0xFFA855F7)],
      content: Column(
        children: [
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Text("Nota",
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Text("Créditos",
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_notaCtrls.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: _NumField(ctrl: _notaCtrls[i], label: 'Ej: 3.8')),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 4,
                      child:
                          _NumField(ctrl: _creditCtrls[i], label: 'Ej: 3')),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: _notaCtrls.length > 1
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        size: 20),
                    onPressed: () => _removeRow(i),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Agregar materia"),
          ),
          const SizedBox(height: 8),
          _CalcButton(onPressed: _calculate),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResultBox(
                label: "Definitiva del corte",
                value: _result,
                color: _resultColor),
          ],
        ],
      ),
    );
  }
}

class _DefinitivaMateriaCard extends StatefulWidget {
  const _DefinitivaMateriaCard();

  @override
  State<_DefinitivaMateriaCard> createState() =>
      _DefinitivaMateriaCardState();
}

class _DefinitivaMateriaCardState extends State<_DefinitivaMateriaCard> {
  final List<TextEditingController> _notaCtrls = [TextEditingController()];
  final List<TextEditingController> _pesoCtrls = [TextEditingController()];
  String _result = '';
  Color? _resultColor;

  void _addRow() {
    setState(() {
      _notaCtrls.add(TextEditingController());
      _pesoCtrls.add(TextEditingController());
    });
  }

  void _removeRow(int i) {
    if (_notaCtrls.length == 1) return;
    setState(() {
      _notaCtrls[i].dispose();
      _pesoCtrls[i].dispose();
      _notaCtrls.removeAt(i);
      _pesoCtrls.removeAt(i);
    });
  }

  void _calculate() {
    double total = 0;
    double pesoTotal = 0;
    for (int i = 0; i < _notaCtrls.length; i++) {
      final nota = double.tryParse(_notaCtrls[i].text);
      final peso = double.tryParse(_pesoCtrls[i].text);
      if (nota == null || peso == null) {
        setState(() {
          _result = 'Completa todos los campos';
          _resultColor = Colors.orange.shade500;
        });
        return;
      }
      if (nota < 0 || nota > 5) {
        setState(() {
          _result = 'Las notas deben estar entre 0.0 y 5.0';
          _resultColor = Colors.red.shade400;
        });
        return;
      }
      total += nota * (peso / 100);
      pesoTotal += peso;
    }
    if ((pesoTotal - 100).abs() > 0.01) {
      setState(() {
        _result =
            'Los porcentajes deben sumar 100% (actual: ${pesoTotal.toStringAsFixed(1)}%)';
        _resultColor = Colors.orange.shade500;
      });
      return;
    }
    setState(() {
      _result = total.toStringAsFixed(2);
      _resultColor = _colorForGrade(total);
    });
  }

  @override
  void dispose() {
    for (final c in [..._notaCtrls, ..._pesoCtrls]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CalcCard(
      icon: Icons.book_outlined,
      title: "Definitiva de materia",
      subtitle: "Nota final desde los cortes por porcentaje",
      gradient: const [Color(0xFF0284C7), Color(0xFF0EA5E9)],
      content: Column(
        children: [
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Text("Nota corte",
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Text("Peso %",
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_notaCtrls.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: _NumField(ctrl: _notaCtrls[i], label: 'Ej: 3.8')),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 4,
                      child: _NumField(ctrl: _pesoCtrls[i], label: 'Ej: 30')),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: _notaCtrls.length > 1
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        size: 20),
                    onPressed: () => _removeRow(i),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Agregar corte"),
          ),
          const SizedBox(height: 8),
          _CalcButton(onPressed: _calculate),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResultBox(
                label: "Definitiva de la materia",
                value: _result,
                color: _resultColor),
          ],
        ],
      ),
    );
  }
}

class _NotaAprobatoriaCard extends StatefulWidget {
  const _NotaAprobatoriaCard();

  @override
  State<_NotaAprobatoriaCard> createState() => _NotaAprobatoriaCardState();
}

class _NotaAprobatoriaCardState extends State<_NotaAprobatoriaCard> {
  final _n1Ctrl = TextEditingController();
  final _p1Ctrl = TextEditingController();
  final _n2Ctrl = TextEditingController();
  final _p2Ctrl = TextEditingController();
  final _pRestCtrl = TextEditingController();
  String _result = '';
  Color? _resultColor;

  @override
  void dispose() {
    _n1Ctrl.dispose();
    _p1Ctrl.dispose();
    _n2Ctrl.dispose();
    _p2Ctrl.dispose();
    _pRestCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final n1 = double.tryParse(_n1Ctrl.text);
    final p1 = double.tryParse(_p1Ctrl.text);
    final n2 = double.tryParse(_n2Ctrl.text);
    final p2 = double.tryParse(_p2Ctrl.text);
    final pRest = double.tryParse(_pRestCtrl.text);

    if (n1 == null || p1 == null || n2 == null ||
        p2 == null || pRest == null) {
      setState(() {
        _result = 'Completa todos los campos';
        _resultColor = Colors.orange.shade500;
      });
      return;
    }

    final needed =
        (3.0 - n1 * (p1 / 100) - n2 * (p2 / 100)) / (pRest / 100);

    if (needed <= 0) {
      setState(() {
        _result = 'Ya tienes el mínimo garantizado';
        _resultColor = Colors.green.shade500;
      });
      return;
    }
    if (needed > 5.0) {
      setState(() {
        _result = 'No es posible aprobar con 5.0';
        _resultColor = Colors.red.shade400;
      });
      return;
    }
    setState(() {
      _result = needed.toStringAsFixed(2);
      _resultColor = _colorForNeeded(needed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CalcCard(
      icon: Icons.trending_up_outlined,
      title: "Mínimo para aprobar",
      subtitle: "¿Qué necesito en el corte final para pasar?",
      gradient: const [Color(0xFF059669), Color(0xFF10B981)],
      content: Column(
        children: [
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                  child: _NumField(ctrl: _n1Ctrl, label: 'Nota corte 1')),
              const SizedBox(width: 10),
              Expanded(child: _NumField(ctrl: _p1Ctrl, label: '% corte 1')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _NumField(ctrl: _n2Ctrl, label: 'Nota corte 2')),
              const SizedBox(width: 10),
              Expanded(child: _NumField(ctrl: _p2Ctrl, label: '% corte 2')),
            ],
          ),
          const SizedBox(height: 10),
          _NumField(ctrl: _pRestCtrl, label: '% restante (corte final)'),
          const SizedBox(height: 16),
          _CalcButton(onPressed: _calculate),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResultBox(
                label: "Nota mínima en corte final",
                value: _result,
                color: _resultColor),
          ],
        ],
      ),
    );
  }
}

class _NotaMetaCard extends StatefulWidget {
  const _NotaMetaCard();

  @override
  State<_NotaMetaCard> createState() => _NotaMetaCardState();
}

class _NotaMetaCardState extends State<_NotaMetaCard> {
  final _metaCtrl = TextEditingController();
  final _n1Ctrl = TextEditingController();
  final _p1Ctrl = TextEditingController();
  final _n2Ctrl = TextEditingController();
  final _p2Ctrl = TextEditingController();
  final _pRestCtrl = TextEditingController();
  String _result = '';
  Color? _resultColor;

  @override
  void dispose() {
    _metaCtrl.dispose();
    _n1Ctrl.dispose();
    _p1Ctrl.dispose();
    _n2Ctrl.dispose();
    _p2Ctrl.dispose();
    _pRestCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final meta = double.tryParse(_metaCtrl.text);
    final n1 = double.tryParse(_n1Ctrl.text);
    final p1 = double.tryParse(_p1Ctrl.text);
    final n2 = double.tryParse(_n2Ctrl.text);
    final p2 = double.tryParse(_p2Ctrl.text);
    final pRest = double.tryParse(_pRestCtrl.text);

    if (meta == null || n1 == null || p1 == null ||
        n2 == null || p2 == null || pRest == null) {
      setState(() {
        _result = 'Completa todos los campos';
        _resultColor = Colors.orange.shade500;
      });
      return;
    }
    if (meta < 0 || meta > 5) {
      setState(() {
        _result = 'La meta debe estar entre 0.0 y 5.0';
        _resultColor = Colors.red.shade400;
      });
      return;
    }

    final needed =
        (meta - n1 * (p1 / 100) - n2 * (p2 / 100)) / (pRest / 100);

    if (needed <= 0) {
      setState(() {
        _result = 'Ya tienes la meta garantizada';
        _resultColor = Colors.green.shade500;
      });
      return;
    }
    if (needed > 5.0) {
      setState(() {
        _result =
            'No es posible alcanzar ${meta.toStringAsFixed(2)} con 5.0';
        _resultColor = Colors.red.shade400;
      });
      return;
    }
    setState(() {
      _result = needed.toStringAsFixed(2);
      _resultColor = _colorForNeeded(needed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CalcCard(
      icon: Icons.flag_outlined,
      title: "Nota para mi meta",
      subtitle: "¿Qué necesito en el corte final para llegar a X?",
      gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
      content: Column(
        children: [
          const Divider(height: 20),
          _NumField(
            ctrl: _metaCtrl,
            label: 'Meta deseada (0.0 – 5.0)',
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _NumField(ctrl: _n1Ctrl, label: 'Nota corte 1')),
              const SizedBox(width: 10),
              Expanded(child: _NumField(ctrl: _p1Ctrl, label: '% corte 1')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _NumField(ctrl: _n2Ctrl, label: 'Nota corte 2')),
              const SizedBox(width: 10),
              Expanded(child: _NumField(ctrl: _p2Ctrl, label: '% corte 2')),
            ],
          ),
          const SizedBox(height: 10),
          _NumField(ctrl: _pRestCtrl, label: '% restante (corte final)'),
          const SizedBox(height: 16),
          _CalcButton(onPressed: _calculate),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResultBox(
                label: "Nota necesaria en corte final",
                value: _result,
                color: _resultColor),
          ],
        ],
      ),
    );
  }
}

class _PPACard extends StatefulWidget {
  const _PPACard();

  @override
  State<_PPACard> createState() => _PPACardState();
}

class _PPACardState extends State<_PPACard> {
  final List<TextEditingController> _notaCtrls = [TextEditingController()];
  final List<TextEditingController> _creditCtrls = [TextEditingController()];
  String _result = '';
  Color? _resultColor;

  void _addRow() {
    setState(() {
      _notaCtrls.add(TextEditingController());
      _creditCtrls.add(TextEditingController());
    });
  }

  void _removeRow(int i) {
    if (_notaCtrls.length == 1) return;
    setState(() {
      _notaCtrls[i].dispose();
      _creditCtrls[i].dispose();
      _notaCtrls.removeAt(i);
      _creditCtrls.removeAt(i);
    });
  }

  void _calculate() {
    double sumaNC = 0;
    double sumaC = 0;
    for (int i = 0; i < _notaCtrls.length; i++) {
      final nota = double.tryParse(_notaCtrls[i].text);
      final cred = double.tryParse(_creditCtrls[i].text);
      if (nota == null || cred == null) {
        setState(() {
          _result = 'Completa todos los campos';
          _resultColor = Colors.orange.shade500;
        });
        return;
      }
      if (nota < 0 || nota > 5) {
        setState(() {
          _result = 'Las notas deben estar entre 0.0 y 5.0';
          _resultColor = Colors.red.shade400;
        });
        return;
      }
      if (cred <= 0) {
        setState(() {
          _result = 'Los créditos deben ser mayores a 0';
          _resultColor = Colors.red.shade400;
        });
        return;
      }
      sumaNC += nota * cred;
      sumaC += cred;
    }
    final ppa = sumaNC / sumaC;
    setState(() {
      _result = ppa.toStringAsFixed(2);
      _resultColor = _colorForGrade(ppa);
    });
  }

  @override
  void dispose() {
    for (final c in [..._notaCtrls, ..._creditCtrls]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CalcCard(
      icon: Icons.school_outlined,
      title: "PPA",
      subtitle: "Promedio Ponderado Acumulado por créditos",
      gradient: const [Color(0xFF0891B2), Color(0xFF06B6D4)],
      content: Column(
        children: [
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Text("Nota final",
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Text("Créditos",
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5))),
              ),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_notaCtrls.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: _NumField(ctrl: _notaCtrls[i], label: 'Ej: 3.8')),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 4,
                      child:
                          _NumField(ctrl: _creditCtrls[i], label: 'Ej: 3')),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: _notaCtrls.length > 1
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        size: 20),
                    onPressed: () => _removeRow(i),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Agregar materia"),
          ),
          const SizedBox(height: 8),
          _CalcButton(onPressed: _calculate),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ResultBox(label: "PPA", value: _result, color: _resultColor),
          ],
        ],
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CalcButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text("Calcular",
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}