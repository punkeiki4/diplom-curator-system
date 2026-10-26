import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

const _roles = [
  {'id': 1, 'name': 'Admin'},
  {'id': 2, 'name': 'ViceDean'},
  {'id': 3, 'name': 'Curator'},
  {'id': 4, 'name': 'Student'},
];

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List _users = [];
  List _groups = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final [usersRes, groupsRes] = await Future.wait([
        ApiClient.dio.get('/users'),
        ApiClient.dio.get('/groups'),
      ]);
      setState(() {
        _users = usersRes.data as List;
        _groups = groupsRes.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    int selectedRoleId = 4;
    int? selectedGroupId;
    bool sending = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Новый пользователь'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'ФИО *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите ФИО' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Введите email';
                      if (!v.contains('@')) return 'Некорректный email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'Пароль *', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Введите пароль';
                      if (v.length < 6) return 'Минимум 6 символов';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedRoleId,
                    decoration: const InputDecoration(labelText: 'Роль', border: OutlineInputBorder()),
                    items: _roles.map((r) => DropdownMenuItem<int>(
                      value: r['id'] as int,
                      child: Text(r['name'] as String),
                    )).toList(),
                    onChanged: (v) => setS(() => selectedRoleId = v ?? 4),
                  ),
                  if (selectedRoleId == 4) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedGroupId,
                      decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('— без группы —')),
                        ..._groups.map((g) => DropdownMenuItem<int>(
                          value: g['id'] as int,
                          child: Text(g['name'] ?? '—'),
                        )),
                      ],
                      onChanged: (v) => setS(() => selectedGroupId = v),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: sending ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setS(() => sending = true);
                try {
                  await ApiClient.dio.post('/users', data: {
                    'fullName': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'password': passCtrl.text,
                    'roleId': selectedRoleId,
                    if (selectedGroupId != null) 'groupId': selectedGroupId,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пользователь создан'), backgroundColor: Colors.green),
                    );
                  }
                } catch (_) {
                  setS(() => sending = false);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Ошибка создания'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: sending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(dynamic user) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user['fullName'] ?? '');
    final emailCtrl = TextEditingController(text: user['email'] ?? '');
    int selectedRoleId = user['roleId'] as int? ?? 4;
    int? selectedGroupId = user['groupId'] as int?;
    bool sending = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Редактировать пользователя'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'ФИО *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите ФИО' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Введите email';
                      if (!v.contains('@')) return 'Некорректный email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedRoleId,
                    decoration: const InputDecoration(labelText: 'Роль', border: OutlineInputBorder()),
                    items: _roles.map((r) => DropdownMenuItem<int>(
                      value: r['id'] as int,
                      child: Text(r['name'] as String),
                    )).toList(),
                    onChanged: (v) => setS(() => selectedRoleId = v ?? selectedRoleId),
                  ),
                  if (selectedRoleId == 4) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedGroupId,
                      decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('— без группы —')),
                        ..._groups.map((g) => DropdownMenuItem<int>(
                          value: g['id'] as int,
                          child: Text(g['name'] ?? '—'),
                        )),
                      ],
                      onChanged: (v) => setS(() => selectedGroupId = v),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: sending ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setS(() => sending = true);
                try {
                  await ApiClient.dio.put('/users/${user['id']}', data: {
                    'fullName': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'roleId': selectedRoleId,
                    'groupId': selectedRoleId == 4 ? (selectedGroupId ?? 0) : null,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Изменения сохранены'), backgroundColor: Colors.green),
                    );
                  }
                } catch (_) {
                  setS(() => sending = false);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Ошибка сохранения'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: sending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'vicedean': return Colors.purple;
      case 'curator': return Colors.teal;
      default: return Colors.blue;
    }
  }

  String _roleLabel(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin': return 'Админ';
      case 'vicedean': return 'ЗамДекана';
      case 'curator': return 'Куратор';
      default: return 'Студент';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _users.where((u) {
      final name = (u['fullName'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return name.contains(_search.toLowerCase()) || email.contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Добавить'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск пользователя...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Пользователей не найдено', style: TextStyle(color: Colors.grey)))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final u = filtered[i];
                        final role = u['roleName']?.toString() ?? '';
                        final groupName = u['groupName'] as String?;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _roleColor(role),
                              child: Text(
                                (u['fullName'] ?? '?').toString().substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(u['fullName'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u['email'] ?? ''),
                                if (groupName != null)
                                  Text('Группа: $groupName', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _roleColor(role).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(_roleLabel(role),
                                      style: TextStyle(color: _roleColor(role), fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                  onPressed: () => _showEditDialog(u),
                                  tooltip: 'Редактировать',
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                ),
                              ],
                            ),
                            isThreeLine: groupName != null,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
