import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class ViceDeanReportsScreen extends StatefulWidget {
  const ViceDeanReportsScreen({super.key});

  @override
  State<ViceDeanReportsScreen> createState() => _ViceDeanReportsScreenState();
}

class _ViceDeanReportsScreenState extends State<ViceDeanReportsScreen> {
  List _reports = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiClient.dio.get('/curatorreports');
      setState(() {
        _reports = r.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _review(int id, bool approve) async {
    try {
      await ApiClient.dio.put('/curatorreports/$id/review', data: {
        'isApproved': approve,
        'reviewComment': approve ? null : 'Требует доработки',
      });
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Отчёт утверждён' : 'Отчёт возвращён на доработку'),
            backgroundColor: approve ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при проверке отчёта'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List get _filtered {
    if (_filter == 'all') return _reports;
    if (_filter == 'pending') return _reports.where((r) => r['isReviewed'] != true && r['reviewStatus'] != 'Возвращён').toList();
    if (_filter == 'approved') return _reports.where((r) => r['isReviewed'] == true).toList();
    if (_filter == 'returned') return _reports.where((r) => r['reviewStatus'] == 'Возвращён').toList();
    return _reports;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final pending = _reports.where((r) => r['isReviewed'] != true && r['reviewStatus'] != 'Возвращён').length;

    return Column(
      children: [
        if (pending > 0)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.pending_actions, color: Colors.orange),
              const SizedBox(width: 8),
              Text('$pending отчётов ожидают проверки', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Все')),
                ButtonSegment(value: 'pending', label: Text('На проверке')),
                ButtonSegment(value: 'approved', label: Text('Принятые')),
                ButtonSegment(value: 'returned', label: Text('Возвращённые')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('Отчётов нет', style: TextStyle(color: Colors.grey, fontSize: 16)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final r = _filtered[i];
                      final isReviewed = r['isReviewed'] == true;
                      final isReturned = r['reviewStatus'] == 'Возвращён';
                      final statusColor = isReviewed ? Colors.green : isReturned ? Colors.red : Colors.orange;
                      final statusLabel = isReviewed ? 'Принят' : isReturned ? 'Возвращён' : 'На проверке';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.15),
                            child: Icon(
                              isReviewed ? Icons.done_all : isReturned ? Icons.redo : Icons.pending,
                              color: statusColor,
                            ),
                          ),
                          title: Text(r['title'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Куратор: ${r['curatorName'] ?? '—'} · ${r['submittedAtStr'] ?? ''}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['content'] ?? r['reportText'] ?? '—'),
                                  if (r['reviewComment'] != null) ...[
                                    const Divider(),
                                    Row(children: [
                                      const Icon(Icons.comment, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(r['reviewComment'], style: const TextStyle(color: Colors.grey, fontSize: 13))),
                                    ]),
                                  ],
                                  if (!isReviewed && !isReturned) ...[
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _review(r['id'] as int, false),
                                          icon: const Icon(Icons.redo, size: 16),
                                          label: const Text('Вернуть'),
                                          style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _review(r['id'] as int, true),
                                          icon: const Icon(Icons.check, size: 16),
                                          label: const Text('Принять'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        ),
                                      ),
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
        ),
      ],
    );
  }
}
