import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  List<dynamic> _records = [];
  bool _loading = true;
  String? _error;
  late int _month;
  late int _year;

  static const _monthNames = [
    '', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
  ];

  @override
  void initState() {
    super.initState();
    _month = 9;
    _year = 2025;
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiClient.dio.get('/attendances/my');
      setState(() { _records = r.data as List; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Ошибка загрузки'; _loading = false; });
    }
  }

  List<dynamic> get _filtered => _records.where((r) {
    if (r['lessonDate'] == null) return false;
    try {
      final dt = DateTime.parse(r['lessonDate'].toString());
      return dt.month == _month && dt.year == _year;
    } catch (_) { return false; }
  }).toList();

  // Группировка по предметам
  Map<String, _SubjectStats> get _bySubject {
    final map = <String, _SubjectStats>{};
    for (final r in _filtered) {
      final subj = r['subject'] ?? 'Предмет';
      final isPresent = r['isPresent'] == true;
      map.putIfAbsent(subj, () => _SubjectStats(subj));
      if (isPresent) map[subj]!.present++;
      else map[subj]!.absent++;
    }
    return map;
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) { _month = 12; _year--; }
      else { _month--; }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) { _month = 1; _year++; }
      else { _month++; }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final present = filtered.where((r) => r['isPresent'] == true).length;
    final total = filtered.length;
    final absent = total - present;
    final pct = total > 0 ? (present / total * 100) : 0.0;
    final pctColor = pct >= 80 ? Colors.green : pct >= 60 ? Colors.orange : Colors.red;
    final subjects = _bySubject;

    return Column(
      children: [
        // Переключатель месяца
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
            Expanded(
              child: Text(
                '${_monthNames[_month]} $_year',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
          ]),
        ),

        // Общая статистика за месяц
        if (!_loading && _error == null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _StatBox('Всего', '$total', Colors.white),
                _StatBox('Присутствовал', '$present', Colors.greenAccent),
                _StatBox('Пропустил', '$absent', Colors.redAccent),
                _StatBox('Процент', '${pct.toStringAsFixed(0)}%', Colors.amberAccent),
              ]),
              if (total > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: present / total,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                    minHeight: 8,
                  ),
                ),
              ],
            ]),
          ),

        const SizedBox(height: 8),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      TextButton(onPressed: _load, child: const Text('Повторить')),
                    ]))
                  : filtered.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 80),
                          Center(child: Column(children: [
                            const Icon(Icons.calendar_today, size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('Нет данных за этот месяц',
                              style: TextStyle(color: Colors.grey, fontSize: 15)),
                          ])),
                        ])
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            children: [
                              // По предметам
                              const Text('По предметам',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 8),
                              ...subjects.values.map((s) {
                                final tot = s.present + s.absent;
                                final p = tot > 0 ? s.present / tot : 0.0;
                                final col = p >= 0.8 ? Colors.green : p >= 0.6 ? Colors.orange : Colors.red;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Expanded(child: Text(s.subject,
                                          style: const TextStyle(fontWeight: FontWeight.w600))),
                                        Text('${(p * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(color: col, fontWeight: FontWeight.bold)),
                                      ]),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: p,
                                          backgroundColor: Colors.red.withOpacity(0.15),
                                          valueColor: AlwaysStoppedAnimation(col),
                                          minHeight: 5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${s.present} из $tot занятий',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ]),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              // Детальный список
                              const Text('Детальная история',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 8),
                              ...filtered.map((r) {
                                final isPresent = r['isPresent'] == true;
                                String dateStr = '';
                                if (r['lessonDate'] != null) {
                                  try {
                                    final dt = DateTime.parse(r['lessonDate'].toString());
                                    dateStr = '${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}';
                                  } catch (_) {}
                                }
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: ListTile(
                                    dense: true,
                                    leading: Icon(
                                      isPresent ? Icons.check_circle : Icons.cancel,
                                      color: isPresent ? Colors.green : Colors.red,
                                      size: 22,
                                    ),
                                    title: Text(r['subject'] ?? '—',
                                      style: const TextStyle(fontSize: 14)),
                                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text(dateStr,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(width: 8),
                                      Text(
                                        isPresent ? 'Присутствовал' : 'Отсутствовал',
                                        style: TextStyle(
                                          color: isPresent ? Colors.green : Colors.red,
                                          fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ]),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
        ),
      ],
    );
  }
}

class _SubjectStats {
  final String subject;
  int present = 0;
  int absent = 0;
  _SubjectStats(this.subject);
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.85))),
  ]);
}
