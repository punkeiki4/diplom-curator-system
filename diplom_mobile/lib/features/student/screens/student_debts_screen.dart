import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class StudentDebtsScreen extends StatefulWidget {
  const StudentDebtsScreen({super.key});

  @override
  State<StudentDebtsScreen> createState() => _StudentDebtsScreenState();
}

class _StudentDebtsScreenState extends State<StudentDebtsScreen> {
  List _debts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiClient.dio.get('/academicdebts/my');
      setState(() {
        _debts = r.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Задолженности')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _debts.isEmpty
              ? const Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle, size: 72, color: Colors.green),
                    SizedBox(height: 16),
                    Text('Задолженностей нет!', style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Отличная успеваемость', style: TextStyle(color: Colors.grey)),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          _Stat('Всего', '${_debts.length}', Colors.blue),
                          _Stat('Активных', '${_debts.where((d) => d['isEliminated'] != true).length}', Colors.red),
                          _Stat('Погашено', '${_debts.where((d) => d['isEliminated'] == true).length}', Colors.green),
                        ]),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _debts.length,
                          itemBuilder: (_, i) {
                            final d = _debts[i];
                            final isEliminated = d['isEliminated'] == true;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isEliminated ? Colors.green : Colors.red,
                                  child: Icon(isEliminated ? Icons.check : Icons.warning, color: Colors.white, size: 20),
                                ),
                                title: Text(d['subject'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(d['debtType'] ?? ''),
                                    if (d['deadlineStr'] != null)
                                      Text('Срок: ${d['deadlineStr']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isEliminated ? Colors.green : Colors.red).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isEliminated ? 'Погашена' : 'Активна',
                                    style: TextStyle(color: isEliminated ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
