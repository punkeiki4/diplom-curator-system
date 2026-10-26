import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class ViceDeanTasksScreen extends StatefulWidget {
  const ViceDeanTasksScreen({super.key});

  @override
  State<ViceDeanTasksScreen> createState() => _ViceDeanTasksScreenState();
}

class _ViceDeanTasksScreenState extends State<ViceDeanTasksScreen> {
  List _tasks = [];
  List _curators = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final [tasksRes, curatorsRes] = await Future.wait([
        ApiClient.dio.get('/tasks'),
        ApiClient.dio.get('/users/curators'),
      ]);
      setState(() {
        _tasks = tasksRes.data as List;
        _curators = curatorsRes.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _createTask() async {
    if (_curators.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет доступных кураторов'), backgroundColor: Colors.orange),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int? selectedCuratorId = _curators.first['id'] as int?;
    String priority = 'Средний';
    bool sending = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Новое задание куратору'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedCuratorId,
                    decoration: const InputDecoration(labelText: 'Куратор *', border: OutlineInputBorder()),
                    items: _curators.map((c) => DropdownMenuItem<int>(
                      value: c['id'] as int,
                      child: Text(c['fullName'] ?? '—', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setS(() => selectedCuratorId = v),
                    validator: (v) => v == null ? 'Выберите куратора' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Название *', border: OutlineInputBorder()),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Введите название';
                      if (v.trim().length < 3) return 'Минимум 3 символа';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Описание *', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Введите описание';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Приоритет', border: OutlineInputBorder()),
                    items: ['Высокий', 'Средний', 'Низкий'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) => setS(() => priority = v ?? 'Средний'),
                  ),
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
                  await ApiClient.dio.post('/tasks', data: {
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'assignedTo': selectedCuratorId,
                    'priority': priority,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Задание создано'), backgroundColor: Colors.green),
                    );
                  }
                } catch (_) {
                  setS(() => sending = false);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Ошибка создания задания'), backgroundColor: Colors.red),
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

  Color _statusColor(String? status) {
    switch (status) {
      case 'Выполнено': return Colors.green;
      case 'В работе': return Colors.blue;
      default: return Colors.orange;
    }
  }

  Color _priorityColor(String? p) {
    switch (p) {
      case 'Высокий': return Colors.red;
      case 'Низкий': return Colors.grey;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        icon: const Icon(Icons.add),
        label: const Text('Создать задание'),
      ),
      body: _tasks.isEmpty
          ? const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.task, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Заданий нет', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ]),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tasks.length,
                itemBuilder: (_, i) {
                  final t = _tasks[i];
                  final status = t['status'] as String?;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _statusColor(status).withOpacity(0.15),
                        child: Icon(
                          status == 'Выполнено' ? Icons.check_circle : status == 'В работе' ? Icons.play_circle : Icons.circle_outlined,
                          color: _statusColor(status),
                        ),
                      ),
                      title: Text(t['title'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Куратор: ${t['assignedToName'] ?? '—'}'),
                          if (t['priority'] != null)
                            Text('Приоритет: ${t['priority']}', style: TextStyle(fontSize: 11, color: _priorityColor(t['priority']))),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(status ?? 'Новое', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        backgroundColor: _statusColor(status),
                        padding: EdgeInsets.zero,
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
