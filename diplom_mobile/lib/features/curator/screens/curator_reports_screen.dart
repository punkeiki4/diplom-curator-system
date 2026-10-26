import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CuratorReportsScreen extends StatefulWidget {
  const CuratorReportsScreen({super.key});

  @override
  State<CuratorReportsScreen> createState() => _CuratorReportsScreenState();
}

class _CuratorReportsScreenState extends State<CuratorReportsScreen> {
  List _reports = [];
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
      final [reportsRes, tasksRes] = await Future.wait([
        ApiClient.dio.get('/curatorreports/my'),
        ApiClient.dio.get('/tasks/my'),
      ]);
      setState(() {
        _reports = reportsRes.data as List;
        _tasks = tasksRes.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _createReport() async {
    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет заданий для отчёта'), backgroundColor: Colors.orange),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final textCtrl = TextEditingController();
    int? selectedTaskId = _tasks.first['id'] as int?;
    bool sending = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Новый отчёт'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedTaskId,
                    decoration: const InputDecoration(labelText: 'Задание *', border: OutlineInputBorder()),
                    items: _tasks.map((t) => DropdownMenuItem<int>(
                      value: t['id'] as int,
                      child: Text(t['title'] ?? '—', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setS(() => selectedTaskId = v),
                    validator: (v) => v == null ? 'Выберите задание' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: textCtrl,
                    decoration: const InputDecoration(labelText: 'Текст отчёта *', border: OutlineInputBorder()),
                    maxLines: 5,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Введите текст отчёта';
                      if (v.trim().length < 20) return 'Минимум 20 символов';
                      return null;
                    },
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
                  await ApiClient.dio.post('/curatorreports', data: {
                    'taskId': selectedTaskId,
                    'reportText': textCtrl.text.trim(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Отчёт отправлен'), backgroundColor: Colors.green),
                    );
                  }
                } catch (_) {
                  setS(() => sending = false);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Ошибка отправки отчёта'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: sending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createReport,
        icon: const Icon(Icons.add),
        label: const Text('Новый отчёт'),
      ),
      body: _reports.isEmpty
          ? const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.summarize, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Отчётов нет', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ]),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                itemBuilder: (_, i) {
                  final r = _reports[i];
                  final isReviewed = r['isReviewed'] == true;
                  final reviewStatus = r['reviewStatus'] as String? ?? '';
                  Color statusColor = isReviewed ? Colors.green : Colors.orange;
                  if (reviewStatus == 'Возвращён') statusColor = Colors.red;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor,
                        child: Icon(
                          isReviewed ? Icons.done_all : reviewStatus == 'Возвращён' ? Icons.redo : Icons.pending,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(r['title'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(r['submittedAtStr'] ?? '', style: const TextStyle(fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reviewStatus.isEmpty ? 'На проверке' : reviewStatus,
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['content'] ?? r['reportText'] ?? '—'),
                              if (r['reviewComment'] != null) ...[
                                const Divider(),
                                Row(children: [
                                  const Icon(Icons.comment, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(r['reviewComment'], style: const TextStyle(color: Colors.grey, fontSize: 13))),
                                ]),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
