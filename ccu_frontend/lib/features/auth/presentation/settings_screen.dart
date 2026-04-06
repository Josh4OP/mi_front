import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SettingsScreen({super.key, required this.onToggleTheme});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _reminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configuración",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [

          _SectionLabel(label: "Apariencia"),
          const SizedBox(height: 8),

          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              title: const Text(
                "Modo oscuro",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isDark ? "Tema oscuro activo" : "Tema claro activo",
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              value: isDark,
              onChanged: (_) => widget.onToggleTheme(),
            ),
          ),

          const SizedBox(height: 24),

          _SectionLabel(label: "Notificaciones"),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    "Notificaciones generales",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Avisos de tareas y eventos",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (v) =>
                      setState(() => _notificationsEnabled = v),
                ),

                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),

                SwitchListTile(
                  secondary: Icon(
                    Icons.alarm_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text(
                    "Recordatorios de estudio",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Avisos antes de evaluaciones",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  value: _reminderEnabled,
                  onChanged: _notificationsEnabled
                      ? (v) => setState(() => _reminderEnabled = v)
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _SectionLabel(label: "Acerca de"),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.info_outline,
                  label: "Versión",
                  value: "1.0.0",
                ),

                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),

                _InfoRow(
                  icon: Icons.school_outlined,
                  label: "Institución",
                  value: "Universidad Tecnológica de Bolívar",
                ),

              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            "CCU Mobile · v1.0.0",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        letterSpacing: 1.0,
        fontSize: 12,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}