import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class ViceDeanDebtsScreen extends StatefulWidget {
  const ViceDeanDebtsScreen({super.key});

  @override
  State<ViceDeanDebtsScreen> createState() => _ViceDeanDebtsScreenState();
}

class _ViceDeanDebtsScreenState extends State<ViceDeanDebtsScreen> {
  List _debts = [];
  List<dynamic> _groups = [];
  bool _loading = true;
  String _search = '';
  int? _selectedGroupId; // null = все группы

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient.dio.get('/academicdebts'),
        ApiClient.dio.get('/groups'),
      ]);
      setState(() {
        _debts  = results[0].data as List;
        _groups = results[1].data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _eliminate(int id) async {
    try {
      await ApiClient.dio.put('/academicdebts/$id/eliminate');
      await _loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Задолженность устранена'), backgroundColor: Colors.green),
        );
      }
    } catch (_) {}
  }

  List get _filtered {
    return _debts.where((d) {
      final name = (d['studentName'] ?? '').toString().toLowerCase();
      final matchSearch = name.contains(_search.toLowerCase());
      final matchGroup = _selectedGroupId == null || d['groupId'] == _selectedGroupId;
      return matchSearch && matchGroup;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _filtered;
    final active = filtered.where((d) => d['isEliminated'] != true).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Статистика
              Row(
                children: [
                  _Stat('Всего', '${filtered.length}', Colors.blue),
                  const SizedBox(width: 12),
                  _Stat('Активных', '$active', Colors.red),
                  const SizedBox(width: 12),
                  _Stat('Устранено', '${filtered.length - active}', Colors.green),
                ],
              ),
              const SizedBox(height: 10),
              // Фильтр по группам
              DropdownButtonFormField<int?>(
                value: _selectedGroupId,
                decoration: InputDecoration(
                  labelText: 'Группа',
                  prefixIcon: const Icon(Icons.group),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Все группы'),
                  ),
                  ..._groups.map((g) => DropdownMenuItem<int?>(
                    value: g['id'] as int?,
                    child: Text(g['name'] ?? 'Группа ${g['id']}'),
                  )),
                ],
                onChanged: (v) => setState(() => _selectedGroupId = v),
              ),
              const SizedBox(height: 10),
              // Поиск по студенту
              TextField(
                decoration: InputDecoration(
                  hintText: 'Поиск студента...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      _selectedGroupId != null ? 'В этой группе задолженностей нет' : 'Задолженностей нет',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final d = filtered[i];
                      final isEliminated = d['isEliminated'] == true;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isEliminated ? Colors.green : Colors.red,
                            child: Icon(
                              isEliminated ? Icons.check : Icons.warning,
                              color: Colors.white, size: 18,
                            ),
                          ),
                          title: Text(
                            d['studentName'] ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${d['subject'] ?? ''} · ${d['debtType'] ?? ''}'),
                              if (d['groupName'] != null)
                                Text(
                                  'Группа: ${d['groupName']}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                            ],
                          ),
                          isThreeLine: d['groupName'] != null,
                          trailing: isEliminated
                              ? const Text('Устранена', style: TextStyle(color: Colors.green, fontSize: 12))
                              : TextButton(
                                  onPressed: () => _eliminate(d['id'] as int),
                                  child: const Text('Устранить', style: TextStyle(color: Colors.red)),
                                ),
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

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
