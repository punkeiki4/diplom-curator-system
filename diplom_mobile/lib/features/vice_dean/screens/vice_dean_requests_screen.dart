import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class ViceDeanRequestsScreen extends StatefulWidget {
  const ViceDeanRequestsScreen({super.key});

  @override
  State<ViceDeanRequestsScreen> createState() => _ViceDeanRequestsScreenState();
}

class _ViceDeanRequestsScreenState extends State<ViceDeanRequestsScreen> {
  List _requests = [];
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
      final r = await ApiClient.dio.get('/requests');
      setState(() {
        _requests = r.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _review(int id, String action) async {
    try {
      await ApiClient.dio.put('/requests/$id/review', data: {'status': action});
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'approved' ? 'Заявка одобрена' : 'Заявка отклонена'),
            backgroundColor: action == 'approved' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при обработке заявки'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _normalizedStatus(dynamic req) {
    final sn = req['statusNormalized'] as String?;
    if (sn != null) return sn;
    final s = req['status']?.toString().toLowerCase() ?? '';
    if (s.contains('одобр')) return 'approved';
    if (s.contains('откл')) return 'rejected';
    return 'pending';
  }

  List get _filtered {
    if (_filter == 'all') return _requests;
    return _requests.where((r) => _normalizedStatus(r) == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final pendingCount = _requests.where((r) => _normalizedStatus(r) == 'pending').length;

    return Column(
      children: [
        if (pendingCount > 0)
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
              Text('$pendingCount заявок ожидают рассмотрения',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Все')),
                ButtonSegment(value: 'pending', label: Text('Ожидают')),
                ButtonSegment(value: 'approved', label: Text('Одобрены')),
                ButtonSegment(value: 'rejected', label: Text('Откл.')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
                  child: Text('Заявок нет', style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final req = _filtered[i];
                      final ns = _normalizedStatus(req);
                      final isPending = ns == 'pending';
                      final statusColor = ns == 'approved'
                          ? Colors.green
                          : ns == 'rejected'
                              ? Colors.red
                              : Colors.orange;
                      final statusLabel = ns == 'approved'
                          ? 'Одобрена'
                          : ns == 'rejected'
                              ? 'Отклонена'
                              : 'Ожидает';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.15),
                            child: Icon(
                              ns == 'approved'
                                  ? Icons.check_circle
                                  : ns == 'rejected'
                                      ? Icons.cancel
                                      : Icons.hourglass_empty,
                              color: statusColor,
                            ),
                          ),
                          title: Text(req['requestType'] ?? req['title'] ?? '—',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${req['studentName'] ?? '—'}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(statusLabel,
                                style: TextStyle(
                                    color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((req['description'] as String?)?.isNotEmpty == true)
                                    Text(req['description']),
                                  if (req['reviewComment'] != null) ...[
                                    const Divider(),
                                    Row(children: [
                                      const Icon(Icons.comment, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(req['reviewComment'],
                                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ),
                                    ]),
                                  ],
                                  if (isPending) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _review(req['id'] as int, 'rejected'),
                                            icon: const Icon(Icons.cancel, size: 16),
                                            label: const Text('Отклонить'),
                                            style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _review(req['id'] as int, 'approved'),
                                            icon: const Icon(Icons.check, size: 16),
                                            label: const Text('Одобрить'),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                          ),
                                        ),
                                      ],
                                    ),
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
