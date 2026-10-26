import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CuratorTasksScreen extends StatefulWidget {
  const CuratorTasksScreen({super.key});

  @override
  State<CuratorTasksScreen> createState() => _CuratorTasksScreenState();
}

class _CuratorTasksScreenState extends State<CuratorTasksScreen> {
  List _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiClient.dio.get('/tasks/my');
      setState(() {
        _tasks = r.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await ApiClient.dio.put('/tasks/$id', data: {'status': status});
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Статус обновлён: $status'), backgroundColor: Colors.green),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось обновить статус'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Выполнено': return Colors.green;
      case 'В работе': return Colors.blue;
      default: return Colors.orange;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'Выполнено': return 'Выполнено';
      case 'В работе': return 'В работе';
      default: return 'Новое';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return _tasks.isEmpty
        ? const Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.task_alt, size: 64, color: Colors.grey),
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
                final deadline = t['deadline'] != null
                    ? _formatDate(t['deadline'].toString())
                    : null;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    title: Text(t['title'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: deadline != null ? Text('Срок: $deadline', style: const TextStyle(fontSize: 12)) : null,
                    trailing: Chip(
                      label: Text(_statusLabel(status), style: const TextStyle(color: Colors.white, fontSize: 11)),
                      backgroundColor: _statusColor(status),
                      padding: EdgeInsets.zero,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['description'] ?? '—'),
                            if (t['priority'] != null) ...[
                              const SizedBox(height: 8),
                              Text('Приоритет: ${t['priority']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                            const SizedBox(height: 12),
                            if (status != 'Выполнено')
                              Row(children: [
                                if (status != 'В работе')
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _updateStatus(t['id'] as int, 'В работе'),
                                      icon: const Icon(Icons.play_arrow, size: 16),
                                      label: const Text('Взять в работу'),
                                    ),
                                  ),
                                if (status != 'В работе') const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateStatus(t['id'] as int, 'Выполнено'),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Выполнено'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  ),
                                ),
                              ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
