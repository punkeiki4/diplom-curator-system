import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  List<dynamic> _schedule = [];
  bool _loading = true;
  String _error = '';

  late DateTime _weekStart; // понедельник текущей недели
  DateTime? _selectedDay;

  static const _dayNames = ['', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const _monthNames = [
    '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
  ];

  // Цвета предметов — генерируем по хэшу названия
  static const _subjectColors = [
    Color(0xFF1565C0), Color(0xFF6A1B9A), Color(0xFF00838F),
    Color(0xFF2E7D32), Color(0xFFE65100), Color(0xFFC62828),
    Color(0xFF4527A0), Color(0xFF00695C), Color(0xFF558B2F),
  ];

  Color _colorForSubject(String? subject) {
    if (subject == null) return _subjectColors[0];
    return _subjectColors[subject.hashCode.abs() % _subjectColors.length];
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _selectedDay = DateTime(now.year, now.month, now.day);
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final r = await ApiClient.dio.get('/schedules/my');
      setState(() { _schedule = r.data as List; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Не удалось загрузить расписание'; _loading = false; });
    }
  }

  // Занятия выбранной недели
  List<dynamic> get _weekSchedule {
    final weekEnd = _weekStart.add(const Duration(days: 7));
    return _schedule.where((item) {
      if (item['lessonDate'] == null) return false;
      try {
        final dt = DateTime.parse(item['lessonDate'].toString());
        final d = DateTime(dt.year, dt.month, dt.day);
        return !d.isBefore(_weekStart) && d.isBefore(weekEnd);
      } catch (_) { return false; }
    }).toList();
  }

  // Занятия выбранного дня
  List<dynamic> _dayLessons(DateTime day) {
    return _weekSchedule.where((item) {
      try {
        final dt = DateTime.parse(item['lessonDate'].toString());
        return dt.year == day.year && dt.month == day.month && dt.day == day.day;
      } catch (_) { return false; }
    }).toList()
      ..sort((a, b) {
        try {
          return DateTime.parse(a['lessonDate'].toString())
              .compareTo(DateTime.parse(b['lessonDate'].toString()));
        } catch (_) { return 0; }
      });
  }

  int _lessonsCount(DateTime day) => _dayLessons(day).length;

  void _prevWeek() => setState(() {
    _weekStart = _weekStart.subtract(const Duration(days: 7));
    _selectedDay = _weekStart;
  });

  void _nextWeek() => setState(() {
    _weekStart = _weekStart.add(const Duration(days: 7));
    _selectedDay = _weekStart;
  });

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _weekStart = now.subtract(Duration(days: now.weekday - 1));
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final weekEnd = _weekStart.add(const Duration(days: 6));

    return Column(
      children: [
        // ── Шапка с навигацией по неделям ──────────────────────────────
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Строка: < Неделя > [Сегодня]
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _prevWeek,
                  ),
                  Expanded(
                    child: Text(
                      '${_weekStart.day} ${_monthNames[_weekStart.month]} — ${weekEnd.day} ${_monthNames[weekEnd.month]} ${weekEnd.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextWeek,
                  ),
                  TextButton(
                    onPressed: _goToday,
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: const Text('Сегодня'),
                  ),
                ]),
              ),
              // Дни недели (Пн–Вс)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                child: Row(
                  children: List.generate(7, (i) {
                    final day = _weekStart.add(Duration(days: i));
                    final dayOnly = DateTime(day.year, day.month, day.day);
                    final isSelected = _selectedDay != null &&
                        _selectedDay!.year == dayOnly.year &&
                        _selectedDay!.month == dayOnly.month &&
                        _selectedDay!.day == dayOnly.day;
                    final isToday = dayOnly == todayOnly;
                    final count = _lessonsCount(dayOnly);
                    final isWeekend = i >= 5;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDay = dayOnly),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : isToday
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isToday && !isSelected
                                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
                                : null,
                          ),
                          child: Column(children: [
                            Text(
                              _dayNames[i + 1],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : isWeekend
                                        ? Colors.red.shade400
                                        : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isWeekend
                                        ? Colors.red.shade400
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Точки — количество занятий
                            count > 0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      count.clamp(0, 4),
                                      (_) => Container(
                                        width: 4, height: 4,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? Colors.white70
                                              : Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(height: 4),
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // ── Список занятий дня ──────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Повторить')),
                    ]))
                  : _selectedDay == null
                      ? const Center(child: Text('Выберите день'))
                      : _buildDayView(_selectedDay!),
        ),
      ],
    );
  }

  Widget _buildDayView(DateTime day) {
    final lessons = _dayLessons(day);
    final today = DateTime.now();
    final isToday = day.year == today.year && day.month == today.month && day.day == today.day;

    if (lessons.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(children: [
          const SizedBox(height: 60),
          Center(child: Column(children: [
            Icon(
              isToday ? Icons.celebration_outlined : Icons.event_available,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isToday ? 'Сегодня занятий нет 🎉' : 'Занятий нет',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ])),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: lessons.length,
        itemBuilder: (_, i) {
          final item = lessons[i];
          final subject = item['subject'] as String? ?? '—';
          final color = _colorForSubject(subject);

          String timeStr = '';
          try {
            final dt = DateTime.parse(item['lessonDate'].toString());
            timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          } catch (_) {}

          // Определяем — идёт ли занятие сейчас (±45 мин)
          bool isNow = false;
          try {
            final dt = DateTime.parse(item['lessonDate'].toString());
            final diff = today.difference(dt).inMinutes;
            isNow = isToday && diff >= 0 && diff < 90;
          } catch (_) {}

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Время + номер занятия
                SizedBox(
                  width: 44,
                  child: Column(
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isNow ? color : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isNow ? color : Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isNow ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      // Линия между занятиями
                      if (i < lessons.length - 1)
                        Container(
                          width: 2,
                          height: 30,
                          margin: const EdgeInsets.only(top: 6),
                          color: Colors.grey.shade200,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Карточка занятия
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isNow
                          ? color.withOpacity(0.08)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isNow ? color.withOpacity(0.4) : Colors.grey.withOpacity(0.15),
                        width: isNow ? 1.5 : 1,
                      ),
                      boxShadow: isNow
                          ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
                          : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        // Цветная полоска слева
                        Container(
                          width: 4, height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isNow ? color : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.group_outlined, size: 13, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  item['groupName'] ?? '—',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ]),
                            ],
                          ),
                        ),
                        if (isNow)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Сейчас', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
