import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class StudentRequestsScreen extends StatefulWidget {
  const StudentRequestsScreen({super.key});

  @override
  State<StudentRequestsScreen> createState() => _StudentRequestsScreenState();
}

class _StudentRequestsScreenState extends State<StudentRequestsScreen> {
  List _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiClient.dio.get('/requests/my');
      setState(() {
        _requests = r.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _createRequest() async {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool sending = false;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Новая заявка'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Тема заявки *', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Укажите тему заявки';
                    if (v.trim().length < 5) return 'Минимум 5 символов';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Описание *', border: OutlineInputBorder()),
                  maxLines: 4,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Укажите описание';
                    if (v.trim().length < 10) return 'Минимум 10 символов';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: sending ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setS(() => sending = true);
                try {
                  await ApiClient.dio.post('/requests', data: {
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Заявка отправлена'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  setS(() => sending = false);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Ошибка отправки заявки'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s == 'одобрено' || s == 'approved') return Colors.green;
    if (s == 'отклонено' || s == 'rejected') return Colors.red;
    return Colors.orange;
  }

  String _statusText(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s == 'одобрено' || s == 'approved') return 'Одобрено';
    if (s == 'отклонено' || s == 'rejected') return 'Отклонено';
    if (s == 'на согласовании') return 'На согласовании';
    return 'В обработке';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заявки')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRequest,
        icon: const Icon(Icons.add),
        label: const Text('Новая заявка'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Заявок нет', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (_, i) {
                      final req = _requests[i];
                      final status = req['status'] as String?;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          title: Text(req['requestType'] ?? req['title'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(_statusText(status), style: TextStyle(color: _statusColor(status))),
                          trailing: _StatusChip(status),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req['description'] ?? ''),
                                  if (req['reviewComment'] != null) ...[
                                    const Divider(),
                                    Row(children: [
                                      const Icon(Icons.comment, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(req['reviewComment'], style: const TextStyle(color: Colors.grey, fontSize: 13))),
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

class _StatusChip extends StatelessWidget {
  final String? status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final s = status?.toLowerCase() ?? '';
    Color color;
    if (s == 'одобрено' || s == 'approved') {
      color = Colors.green;
    } else if (s == 'отклонено' || s == 'rejected') {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Icon(s == 'одобрено' || s == 'approved' ? Icons.check_circle : s == 'отклонено' || s == 'rejected' ? Icons.cancel : Icons.hourglass_empty, color: color, size: 18),
    );
  }
}
