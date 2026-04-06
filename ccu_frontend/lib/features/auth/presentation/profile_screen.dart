import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/data/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? initialProfilePic;

  const ProfileScreen({
    super.key,
    this.userName = "Estudiante",
    this.userEmail = "",
    this.initialProfilePic,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _email;
  String? _profilePicUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.userName;
    _email = widget.userEmail;
    _profilePicUrl = widget.initialProfilePic;
  }

  String get _initial =>
      _name.isNotEmpty ? _name.trim()[0].toUpperCase() : '?';

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final result = await AuthService.uploadProfilePic(_email, pickedFile.path);
      setState(() => _isUploading = false);

      if (mounted) {
        if (result['success']) {
          setState(() => _profilePicUrl = result['profile_pic_url']);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto actualizada'), behavior: SnackBarBehavior.floating),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  void _openEditName() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditNameForm(
        currentName: _name,
        onSave: (newName) {
          setState(() => _name = newName);
        },
      ),
    );
  }

  void _openChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ChangePasswordForm(userEmail: _email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullImageUrl = _profilePicUrl != null 
        ? "${AuthService.baseUrl}$_profilePicUrl?v=${DateTime.now().millisecondsSinceEpoch}" 
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                backgroundImage: fullImageUrl != null ? NetworkImage(fullImageUrl) : null,
                child: _isUploading 
                    ? const CircularProgressIndicator() 
                    : (fullImageUrl == null 
                        ? Text(_initial, style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: theme.colorScheme.primary))
                        : null),
              ),
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(_email.isNotEmpty ? _email : 'Sin correo registrado', 
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: 32),
          _SectionLabel(label: 'Información personal'),
          const SizedBox(height: 10),
          _InfoTile(
            icon: Icons.person_outline,
            label: 'Nombre',
            value: _name,
            onTap: _openEditName,
            actionIcon: Icons.edit_outlined,
          ),
          _InfoTile(
            icon: Icons.email_outlined,
            label: 'Correo institucional',
            value: _email.isNotEmpty ? _email : '—',
            onTap: null,
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Seguridad'),
          const SizedBox(height: 10),
          _InfoTile(
            icon: Icons.lock_outline,
            label: 'Contraseña',
            value: '••••••••',
            onTap: _openChangePassword,
            actionIcon: Icons.chevron_right,
          ),
          const SizedBox(height: 32),
          Text('CCU Mobile · v1.0.0', style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.35))),
          const SizedBox(height: 8),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          letterSpacing: 1.0,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData? actionIcon;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        subtitle: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        trailing: onTap != null ? Icon(actionIcon ?? Icons.edit_outlined, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)) : null,
        onTap: onTap,
      ),
    );
  }
}

class _EditNameForm extends StatefulWidget {
  final String currentName;
  final void Function(String) onSave;

  const _EditNameForm({required this.currentName, required this.onSave});

  @override
  State<_EditNameForm> createState() => _EditNameFormState();
}

class _EditNameFormState extends State<_EditNameForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_nameCtrl.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
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
                decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Editar nombre', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre completo *',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre no puede estar vacío' : null,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Guardar nombre', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  final String userEmail;
  const _ChangePasswordForm({required this.userEmail});

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await AuthService.changePassword(widget.userEmail, _currentCtrl.text, _newCtrl.text);
    
    setState(() => _loading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Error inesperado'), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
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
                decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
              ),
            ),

            Text('Cambiar contraseña', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            
            const SizedBox(height: 20),

            TextFormField(
              controller: _currentCtrl,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Contraseña actual *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _newCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña *',
                prefixIcon: const Icon(Icons.lock_open_outlined),
                suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña *',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) => (v != _newCtrl.text) ? 'Las contraseñas no coinciden' : null,
            ),
            
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Cambiar contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}