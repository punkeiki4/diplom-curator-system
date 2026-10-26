import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  List _grades = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final r = await ApiClient.dio.get('/grades/my');
      setState(() {
        _grades = r.data as List;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить оценки';
        _loading = false;
      });
    }
  }

  Color _gradeColor(int? grade) {
    if (grade == null) return Colors.grey;
    if (grade >= 5) return Colors.green;
    if (grade >= 4) return Colors.blue;
    if (grade >= 3) return Colors.orange;
    return Colors.red;
  }

  String _gradeLabel(int? grade) {
    if (grade == null) return '—';
    if (grade == 5) return 'Отлично';
    if (grade == 4) return 'Хорошо';
    if (grade == 3) return 'Удовл.';
    return 'Неуд.';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text(_error, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _load, child: const Text('Повторить')),
      ]),
    );
    if (_grades.isEmpty) return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.grade, size: 64, color: Colors.grey),
        SizedBox(height: 12),
        Text('Оценок нет', style: TextStyle(color: Colors.grey, fontSize: 16)),
      ]),
    );

    // Средний балл
    final vals = _grades.where((g) => g['value'] != null).map((g) => g['value'] as int).toList();
    final avg = vals.isEmpty ? 0.0 : vals.reduce((a, b) => a + b) / vals.length;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem('Всего', '${_grades.length}', Colors.blue),
              _StatItem('Средний балл', avg.toStringAsFixed(1), avg >= 4 ? Colors.green : avg >= 3 ? Colors.orange : Colors.red),
              _StatItem('Отличных', '${vals.where((v) => v == 5).length}', Colors.green),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _grades.length,
              itemBuilder: (_, i) {
                final g = _grades[i];
                final value = g['value'] as int?;
                final dateStr = g['dateStr'] ?? '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _gradeColor(value),
                      child: Text('${value ?? '—'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(g['subject'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_gradeLabel(value)),
                    trailing: Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
