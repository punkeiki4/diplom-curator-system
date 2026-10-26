import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CuratorEventsScreen extends StatefulWidget {
  const CuratorEventsScreen({super.key});

  @override
  State<CuratorEventsScreen> createState() => _CuratorEventsScreenState();
}

class _CuratorEventsScreenState extends State<CuratorEventsScreen> with SingleTickerProviderStateMixin {
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
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiClient.dio.get('/events/my');
      setState(() { _all = r.data as List; _loading = false; });
    } on DioException catch (e) {
      setState(() { _error = 'Ошибка: ${e.response?.statusCode ?? 'нет соединения'}'; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Нет соединения'; _loading = false; });
    }
  }

  List<dynamic> get _planned => _all.where((e) => (e['eventType'] ?? '') != 'Внеплановое').toList();
  List<dynamic> get _unplanned => _all.where((e) => (e['eventType'] ?? '') == 'Внеплановое').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(_error!),
                        TextButton(onPressed: _load, child: const Text('Повторить')),
                      ]))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _EventList(events: _planned, onRefresh: _load),
                            _EventList(events: _unplanned, emptyText: 'Внеплановых мероприятий нет', onRefresh: _load),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUnplannedDialog,
        icon: const Icon(Icons.notification_important),
        label: const Text('Внеплановое'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _showCreateUnplannedDialog() => _showCreateDialog(forceUnplanned: true);

  Future<void> _showCreateDialog({bool forceUnplanned = false}) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    String eventType = forceUnplanned ? 'Внеплановое' : 'Плановое';
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
          title: Text(forceUnplanned ? 'Внеплановое мероприятие' : 'Новое мероприятие'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (forceUnplanned)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [
                    Icon(Icons.notifications_active, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('Студенты получат уведомление', style: TextStyle(fontSize: 12, color: Colors.orange))),
                  ]),
                ),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Название *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 10),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Место проведения', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(eventDate == null ? 'Дата *' : '${eventDate!.day.toString().padLeft(2,'0')}.${eventDate!.month.toString().padLeft(2,'0')}.${eventDate!.year}'),
                    onPressed: () async {
                      final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) setS(() => eventDate = d);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(eventTime == null ? 'Время' : eventTime!.format(ctx)),
                    onPressed: () async {
                      final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                      if (t != null) setS(() => eventTime = t);
                    },
                  ),
                ),
              ]),
              if (groups.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int?>(
                  value: selectedGroupId,
                  decoration: const InputDecoration(labelText: 'Группа (пусто = все)', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Все группы')),
                    ...groups.map((g) => DropdownMenuItem<int>(value: g['id'] as int, child: Text(g['name'] ?? ''))),
                  ],
                  onChanged: (v) => setS(() => selectedGroupId = v),
                ),
              ],
              if (eventType == 'Внеплановое')
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [
                    Icon(Icons.notifications_active, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('Студенты получат уведомление о мероприятии', style: TextStyle(fontSize: 12, color: Colors.orange))),
                  ]),
                ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || eventDate == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Заполните название и дату')));
                  return;
                }
                final dt = eventTime == null
                    ? DateTime(eventDate!.year, eventDate!.month, eventDate!.day, 9, 0)
                    : DateTime(eventDate!.year, eventDate!.month, eventDate!.day, eventTime!.hour, eventTime!.minute);
                Navigator.pop(ctx);
                await _createEvent({
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  'location': locCtrl.text.trim().isEmpty ? null : locCtrl.text.trim(),
                  'eventType': eventType,
                  'eventDate': dt.toIso8601String(),
                  'groupId': selectedGroupId,
                });
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createEvent(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post('/events', data: data);
      _load();
      if (mounted) {
        final isUnplanned = data['eventType'] == 'Внеплановое';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isUnplanned ? 'Мероприятие создано, студенты уведомлены' : 'Мероприятие создано'),
          backgroundColor: isUnplanned ? Colors.orange : Colors.green,
        ));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка'), backgroundColor: Colors.red));
    }
  }
}

class _EventList extends StatefulWidget {
  final List<dynamic> events;
  final String emptyText;
  final VoidCallback onRefresh;

  const _EventList({
    required this.events,
    this.emptyText = 'Плановых мероприятий нет',
    required this.onRefresh,
  });

  @override
  State<_EventList> createState() => _EventListState();
}

class _EventListState extends State<_EventList> {
  final Set<int> _notifying = {};

  Future<void> _notify(BuildContext ctx, int eventId) async {
    setState(() => _notifying.add(eventId));
    try {
      await ApiClient.dio.post('/events/$eventId/notify');
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text('Уведомления отправлены студентам'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (_) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text('Ошибка отправки уведомлений'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _notifying.remove(eventId));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 80),
        Center(child: Column(children: [
          const Icon(Icons.event_busy, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(widget.emptyText, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ])),
      ]);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.events.length,
      itemBuilder: (ctx, i) {
        final e = widget.events[i];
        final isUnplanned = (e['eventType'] ?? '') == 'Внеплановое';
        final color = isUnplanned ? Colors.orange : Colors.blue;
        final isUpcoming = e['isUpcoming'] == true;
        final eventId = e['id'] as int;
        final isSending = _notifying.contains(eventId);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(isUnplanned ? Icons.notification_important : Icons.event, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(e['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                if (isUpcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Предстоит', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
              ]),
              if (e['description'] != null) ...[
                const SizedBox(height: 6),
                Text(e['description'], style: const TextStyle(color: Colors.black87, fontSize: 13)),
              ],
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(e['eventDateStr'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (e['location'] != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.place, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(e['location'], style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
                ],
              ]),
              if (e['groupName'] != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.group, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(e['groupName'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ]),
              ],
              const SizedBox(height: 10),
              // Кнопка уведомить студентов
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: isSending
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, size: 16),
                  label: Text(isSending ? 'Отправка...' : 'Уведомить студентов'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: isSending ? null : () => _notify(context, eventId),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
