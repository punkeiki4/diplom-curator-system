import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class ViceDeanEventsScreen extends StatefulWidget {
  const ViceDeanEventsScreen({super.key});

  @override
  State<ViceDeanEventsScreen> createState() => _ViceDeanEventsScreenState();
}

class _ViceDeanEventsScreenState extends State<ViceDeanEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<dynamic> _all = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await ApiClient.dio.get('/events');
      setState(() {
        _all = r.data as List;
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = 'Ошибка: ${e.response?.statusCode ?? 'нет соединения'}';
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Нет соединения';
        _loading = false;
      });
    }
  }

  List<dynamic> get _planned =>
      _all.where((e) => (e['eventType'] ?? '') != 'Внеплановое').toList();
  List<dynamic> get _unplanned =>
      _all.where((e) => (e['eventType'] ?? '') == 'Внеплановое').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'unplanned_fab',
            onPressed: _showCreateUnplannedDialog,
            icon: const Icon(Icons.notification_important),
            label: const Text('Внеплановое'),
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'planned_fab',
            onPressed: _showCreatePlannedDialog,
            icon: const Icon(Icons.event_available),
            label: const Text('Плановое'),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabs,
              tabs: [
                Tab(text: 'Плановые (${_planned.length})'),
                Tab(text: 'Внеплановые (${_unplanned.length})'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(_error!),
                            TextButton(
                                onPressed: _load,
                                child: const Text('Повторить')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _buildEventList(
                                _planned, 'Плановых мероприятий нет'),
                            _buildEventList(
                                _unplanned, 'Внеплановых мероприятий нет'),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ─── Создание планового мероприятия ───────────────────────────────────────

  Future<void> _showCreatePlannedDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    DateTime? eventDate;
    TimeOfDay? eventTime;

    List<dynamic> groups = [];
    int? selectedGroupId;
    try {
      final r = await ApiClient.dio.get('/groups');
      groups = r.data as List;
    } catch (_) {}

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Новое плановое мероприятие'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.event, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Плановое мероприятие будет видно всем кураторам',
                          style: TextStyle(fontSize: 12, color: Colors.blue))),
                ]),
              ),
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Название *',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Описание', border: OutlineInputBorder()),
                  maxLines: 2),
              const SizedBox(height: 10),
              TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Место проведения',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(eventDate == null
                        ? 'Дата *'
                        : '${eventDate!.day.toString().padLeft(2, '0')}.${eventDate!.month.toString().padLeft(2, '0')}.${eventDate!.year}'),
                    onPressed: () async {
                      final d = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030));
                      if (d != null) setS(() => eventDate = d);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(
                        eventTime == null ? 'Время' : eventTime!.format(ctx)),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: ctx, initialTime: TimeOfDay.now());
                      if (t != null) setS(() => eventTime = t);
                    },
                  ),
                ),
              ]),
              if (groups.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int?>(
                  value: selectedGroupId,
                  decoration: const InputDecoration(
                      labelText: 'Группа (пусто = все)',
                      border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Все группы')),
                    ...groups.map((g) => DropdownMenuItem<int>(
                        value: g['id'] as int,
                        child: Text(g['name'] ?? ''))),
                  ],
                  onChanged: (v) => setS(() => selectedGroupId = v),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || eventDate == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Заполните название и дату')));
                  return;
                }
                final dt = eventTime == null
                    ? DateTime(eventDate!.year, eventDate!.month,
                        eventDate!.day, 9, 0)
                    : DateTime(
                        eventDate!.year,
                        eventDate!.month,
                        eventDate!.day,
                        eventTime!.hour,
                        eventTime!.minute);
                Navigator.pop(ctx);
                try {
                  await ApiClient.dio.post('/events', data: {
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                    'location': locCtrl.text.trim().isEmpty
                        ? null
                        : locCtrl.text.trim(),
                    'eventType': 'Плановое',
                    'eventDate': dt.toIso8601String(),
                    'groupId': selectedGroupId,
                  });
                  _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Мероприятие создано'),
                        backgroundColor: Colors.green));
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Ошибка'),
                        backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Создание внепланового мероприятия с назначением куратора ─────────────

  Future<void> _showCreateUnplannedDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    DateTime? eventDate;
    TimeOfDay? eventTime;

    List<dynamic> groups = [];
    int? selectedGroupId;
    List<dynamic> curators = [];
    int? selectedCuratorId;

    try {
      final r = await ApiClient.dio.get('/groups');
      groups = r.data as List;
    } catch (_) {}

    try {
      final r = await ApiClient.dio.get('/users/curators');
      curators = r.data as List;
    } catch (_) {}

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Внеплановое мероприятие'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(children: [
                  Icon(Icons.notification_important,
                      color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Будет назначено выбранному куратору, студенты получат уведомление',
                          style:
                              TextStyle(fontSize: 12, color: Colors.orange))),
                ]),
              ),
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Название *',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Описание', border: OutlineInputBorder()),
                  maxLines: 2),
              const SizedBox(height: 10),
              TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Место проведения',
                      border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(eventDate == null
                        ? 'Дата *'
                        : '${eventDate!.day.toString().padLeft(2, '0')}.${eventDate!.month.toString().padLeft(2, '0')}.${eventDate!.year}'),
                    onPressed: () async {
                      final d = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030));
                      if (d != null) setS(() => eventDate = d);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(
                        eventTime == null ? 'Время' : eventTime!.format(ctx)),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: ctx, initialTime: TimeOfDay.now());
                      if (t != null) setS(() => eventTime = t);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              if (curators.isNotEmpty)
                DropdownButtonFormField<int?>(
                  value: selectedCuratorId,
                  decoration: const InputDecoration(
                      labelText: 'Куратор *',
                      border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Выберите куратора')),
                    ...curators.map((c) => DropdownMenuItem<int>(
                        value: c['id'] as int,
                        child: Text(c['fullName'] ?? ''))),
                  ],
                  onChanged: (v) => setS(() => selectedCuratorId = v),
                )
              else
                const Text('Кураторы не найдены',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              if (groups.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int?>(
                  value: selectedGroupId,
                  decoration: const InputDecoration(
                      labelText: 'Группа (пусто = все)',
                      border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Все группы')),
                    ...groups.map((g) => DropdownMenuItem<int>(
                        value: g['id'] as int,
                        child: Text(g['name'] ?? ''))),
                  ],
                  onChanged: (v) => setS(() => selectedGroupId = v),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || eventDate == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Заполните название и дату')));
                  return;
                }
                if (selectedCuratorId == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Выберите куратора')));
                  return;
                }
                final dt = eventTime == null
                    ? DateTime(eventDate!.year, eventDate!.month,
                        eventDate!.day, 9, 0)
                    : DateTime(
                        eventDate!.year,
                        eventDate!.month,
                        eventDate!.day,
                        eventTime!.hour,
                        eventTime!.minute);
                Navigator.pop(ctx);
                try {
                  await ApiClient.dio.post('/events', data: {
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                    'location': locCtrl.text.trim().isEmpty
                        ? null
                        : locCtrl.text.trim(),
                    'eventType': 'Внеплановое',
                    'eventDate': dt.toIso8601String(),
                    'groupId': selectedGroupId,
                    'assignedCuratorId': selectedCuratorId,
                  });
                  _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Мероприятие создано, куратор уведомлён'),
                        backgroundColor: Colors.orange));
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Ошибка'),
                        backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text('Создать',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Список мероприятий ───────────────────────────────────────────────────

  Widget _buildEventList(List<dynamic> events, String emptyText) {
    if (events.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 80),
        Center(
            child: Column(children: [
          const Icon(Icons.event_busy, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(emptyText,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ])),
      ]);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (ctx, i) {
        final e = events[i];
        final isUnplanned = (e['eventType'] ?? '') == 'Внеплановое';
        final color = isUnplanned ? Colors.orange : Colors.blue;
        final isUpcoming = e['isUpcoming'] == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(
                    isUnplanned
                        ? Icons.notification_important
                        : Icons.event,
                    color: color,
                    size: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(e['title'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15))),
                if (isUpcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Предстоит',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
              if (e['description'] != null) ...[
                const SizedBox(height: 6),
                Text(e['description'],
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 13)),
              ],
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(e['eventDateStr'] ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (e['location'] != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.place, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(e['location'],
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis)),
                ],
              ]),
              if (e['groupName'] != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.group, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(e['groupName'],
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ]),
              ],
              if (e['assignedCuratorName'] != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person_pin,
                      size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('Куратор: ${e['assignedCuratorName']}',
                      style: const TextStyle(
                          color: Colors.orange, fontSize: 12)),
                ]),
              ],
              if (e['creatorName'] != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Создал: ${e['creatorName']}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ]),
              ],
            ]),
          ),
        );
      },
    );
  }
}
