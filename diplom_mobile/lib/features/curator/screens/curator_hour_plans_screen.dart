import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CuratorHourPlansScreen extends StatefulWidget {
  const CuratorHourPlansScreen({super.key});

  @override
  State<CuratorHourPlansScreen> createState() => _CuratorHourPlansScreenState();
}

class _CuratorHourPlansScreenState extends State<CuratorHourPlansScreen> {
  List<dynamic> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiClient.dio.get('/curatorhourplans/my');
      setState(() { _plans = r.data as List; _loading = false; });
    } on DioException catch (e) {
      setState(() { _error = 'Ошибка: ${e.response?.statusCode ?? 'нет соединения'}'; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Нет соединения с сервером'; _loading = false; });
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Проведён': return Colors.green;
      case 'Отменён': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Проведён': return Icons.check_circle;
      case 'Отменён': return Icons.cancel;
      default: return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    TextButton(onPressed: _load, child: const Text('Повторить')),
                  ]))
                : _plans.isEmpty
                    ? ListView(children: const [
                        SizedBox(height: 120),
                        Center(child: Column(children: [
                          Icon(Icons.event_note_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Планов кураторских часов нет', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Нажмите + чтобы добавить', style: TextStyle(color: Colors.grey)),
                        ])),
                      ])
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _plans.length,
                        itemBuilder: (ctx, i) {
                          final p = _plans[i];
                          final status = p['status'] ?? 'Запланировано';
                          final color = _statusColor(status);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(_statusIcon(status), color: color, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                                      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ),
                                  ]),
                                  if (p['topic'] != null) ...[
                                    const SizedBox(height: 6),
                                    Text('Тема: ${p['topic']}', style: const TextStyle(color: Colors.black87)),
                                  ],
                                  if (p['description'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(p['description'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(p['plannedDateStr'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                    if (p['groupName'] != null) ...[
                                      const SizedBox(width: 12),
                                      const Icon(Icons.group, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(p['groupName'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                    ],
                                  ]),
                                  if (p['notes'] != null) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                                      child: Text('Заметка: ${p['notes']}', style: const TextStyle(fontSize: 12, color: Colors.brown)),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Изменить'),
                                      onPressed: () => _showEditDialog(p),
                                    ),
                                    const SizedBox(width: 4),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                      label: const Text('Удалить', style: TextStyle(color: Colors.red)),
                                      onPressed: () => _deletePlan(p['id'] as int),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Новый план'),
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final titleCtrl = TextEditingController();
    final topicCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? plannedDate;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Новый план кураторского часа'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Название *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: topicCtrl, decoration: const InputDecoration(labelText: 'Тема', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(plannedDate == null ? 'Выбрать дату *' : '${plannedDate!.day.toString().padLeft(2,'0')}.${plannedDate!.month.toString().padLeft(2,'0')}.${plannedDate!.year}'),
                onPressed: () async {
                  final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (d != null) setS(() => plannedDate = d);
                },
              ),
              const SizedBox(height: 10),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Заметки', border: OutlineInputBorder())),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || plannedDate == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Заполните название и дату')));
                  return;
                }
                Navigator.pop(ctx);
                await _createPlan({
                  'title': titleCtrl.text.trim(),
                  'topic': topicCtrl.text.trim().isEmpty ? null : topicCtrl.text.trim(),
                  'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  'plannedDate': plannedDate!.toIso8601String(),
                  'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                });
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(dynamic plan) async {
    final titleCtrl = TextEditingController(text: plan['title']);
    final topicCtrl = TextEditingController(text: plan['topic'] ?? '');
    final descCtrl = TextEditingController(text: plan['description'] ?? '');
    final notesCtrl = TextEditingController(text: plan['notes'] ?? '');
    String status = plan['status'] ?? 'Запланировано';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Редактировать план'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: topicCtrl, decoration: const InputDecoration(labelText: 'Тема', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Статус', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Запланировано', child: Text('Запланировано')),
                  DropdownMenuItem(value: 'Проведён', child: Text('Проведён')),
                  DropdownMenuItem(value: 'Отменён', child: Text('Отменён')),
                ],
                onChanged: (v) => setS(() => status = v ?? status),
              ),
              const SizedBox(height: 10),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Заметки', border: OutlineInputBorder())),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _updatePlan(plan['id'] as int, {
                  'title': titleCtrl.text.trim(),
                  'topic': topicCtrl.text.trim().isEmpty ? null : topicCtrl.text.trim(),
                  'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  'status': status,
                  'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                });
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlan(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post('/curatorhourplans', data: data);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('План создан'), backgroundColor: Colors.green));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка при создании'), backgroundColor: Colors.red));
    }
  }

  Future<void> _updatePlan(int id, Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.put('/curatorhourplans/$id', data: data);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Обновлено'), backgroundColor: Colors.green));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка при обновлении'), backgroundColor: Colors.red));
    }
  }

  Future<void> _deletePlan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить план?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ApiClient.dio.delete('/curatorhourplans/$id');
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Удалено')));
    } catch (_) {}
  }
}
