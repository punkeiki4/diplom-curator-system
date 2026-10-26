import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CuratorAttendanceScreen extends StatefulWidget {
  const CuratorAttendanceScreen({super.key});

  @override
  State<CuratorAttendanceScreen> createState() => _CuratorAttendanceScreenState();
}

class _CuratorAttendanceScreenState extends State<CuratorAttendanceScreen> {
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
      final r = await ApiClient.dio.get(
        '/attendances/my-group',
        queryParameters: {'month': _month, 'year': _year},
      );
      setState(() { _records = r.data as List; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Ошибка загрузки данных'; _loading = false; });
    }
  }

  
  Map<String, _StudentStats> get _statsByStudent {
    final map = <String, _StudentStats>{};
    for (final r in _records) {
      final name = r['studentName'] ?? 'Студент';
      final isPresent = r['isPresent'] == true;
      map.putIfAbsent(name, () => _StudentStats(name));
      if (isPresent) {
        map[name]!.present++;
      } else {
        map[name]!.absent++;
      }
    }
    return map;
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) { _month = 12; _year--; }
      else { _month--; }
    });
    _load();
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) { _month = 1; _year++; }
      else { _month++; }
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _statsByStudent;
    final students = stats.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    
    final totalPresent = students.fold(0, (s, e) => s + e.present);
    final totalAbsent = students.fold(0, (s, e) => s + e.absent);
    final totalLessons = totalPresent + totalAbsent;
    final avgPercent = totalLessons > 0
        ? (totalPresent / totalLessons * 100).toStringAsFixed(1)
        : '—';

    return Column(
      children: [
        
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

         
        if (!_loading && _error == null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade400],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _SummaryItem('Студентов', '${students.length}', Colors.white),
              _SummaryItem('Посещений', '$totalPresent', Colors.white),
              _SummaryItem('Пропусков', '$totalAbsent', Colors.white),
              _SummaryItem('Ср. %', '$avgPercent%', Colors.white),
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
                  : students.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 80),
                          Center(child: Column(children: [
                            const Icon(Icons.event_busy, size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text('Нет данных за ${_monthNames[_month].toLowerCase()} $_year',
                              style: const TextStyle(color: Colors.grey, fontSize: 15)),
                          ])),
                        ])
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: students.length,
                            itemBuilder: (_, i) {
                              final s = students[i];
                              final total = s.present + s.absent;
                              final pct = total > 0 ? (s.present / total * 100) : 0.0;
                              final color = pct >= 80
                                  ? Colors.green
                                  : pct >= 60 ? Colors.orange : Colors.red;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: color.withOpacity(0.15),
                                          child: Text(
                                            s.name.substring(0, 1),
                                            style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(s.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text('${pct.toStringAsFixed(0)}%',
                                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                                        ),
                                      ]),
                                      const SizedBox(height: 10),
                                    
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: total > 0 ? s.present / total : 0,
                                          backgroundColor: Colors.red.withOpacity(0.15),
                                          valueColor: AlwaysStoppedAnimation(color),
                                          minHeight: 6,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        _MiniStat(Icons.check_circle, '${s.present}', Colors.green, 'присут.'),
                                        const SizedBox(width: 16),
                                        _MiniStat(Icons.cancel, '${s.absent}', Colors.red, 'пропуск'),
                                        const SizedBox(width: 16),
                                        _MiniStat(Icons.calendar_today, '$total', Colors.blue, 'всего зан.'),
                                      ]),
                                    ],
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

class _StudentStats {
  final String name;
  int present = 0;
  int absent = 0;
  _StudentStats(this.name);
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
  ]);
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final String label;
  const _MiniStat(this.icon, this.value, this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 3),
    Text('$value ', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
  ]);
}
