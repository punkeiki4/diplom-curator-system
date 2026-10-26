import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CuratorStudentsScreen extends StatefulWidget {
  const CuratorStudentsScreen({super.key});

  @override
  State<CuratorStudentsScreen> createState() => _CuratorStudentsScreenState();
}

class _CuratorStudentsScreenState extends State<CuratorStudentsScreen> {
  List _students = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await ApiClient.dio.get('/students/my-group');
      setState(() { _students = r.data as List; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _students.where((s) {
      final name = (s['fullName'] ?? '').toString().toLowerCase();
      return name.contains(_search.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Поиск студента...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Студентов не найдено'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          onTap: () => _showStudentDetail(context, s),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1565C0),
                            child: Text(
                              (s['fullName'] ?? '?').toString().substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(s['fullName'] ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(s['email'] ?? ''),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showStudentDetail(BuildContext context, dynamic student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StudentDetailSheet(student: student),
    );
  }
}

class _StudentDetailSheet extends StatefulWidget {
  final dynamic student;
  const _StudentDetailSheet({required this.student});

  @override
  State<_StudentDetailSheet> createState() => _StudentDetailSheetState();
}

class _StudentDetailSheetState extends State<_StudentDetailSheet> {
  List<dynamic> _contacts = [];
  List<dynamic> _attendance = [];
  bool _loadingContacts = true;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadStats();
  }

  Future<void> _loadContacts() async {
    try {
      final r = await ApiClient.dio.get('/parentcontacts/student/${widget.student['id']}');
      setState(() { _contacts = r.data as List; _loadingContacts = false; });
    } catch (_) {
      setState(() => _loadingContacts = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final r = await ApiClient.dio.get('/attendances/student/${widget.student['id']}');
      setState(() { _attendance = r.data as List; _loadingStats = false; });
    } catch (_) {
      setState(() => _loadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final present = _attendance.where((a) => a['isPresent'] == true).length;
    final total = _attendance.length;
    final pct = total > 0 ? (present / total * 100) : 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // Ручка
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // Шапка студента
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Text(
                        (s['fullName'] ?? '?').toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s['fullName'] ?? '—',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(s['email'] ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      if (s['groupName'] != null)
                        Text('Группа: ${s['groupName']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ])),
                  ]),
                ),

                const SizedBox(height: 16),

                // Статистика посещаемости
                const Text('Посещаемость (всего)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                _loadingStats
                    ? const Center(child: CircularProgressIndicator())
                    : Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                              _InfoChip('Занятий', '$total', Colors.blue),
                              _InfoChip('Присутствовал', '$present', Colors.green),
                              _InfoChip('Пропустил', '${total - present}', Colors.red),
                            ]),
                            if (total > 0) ...[
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: present / total,
                                      backgroundColor: Colors.red.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation(
                                        pct >= 80 ? Colors.green : pct >= 60 ? Colors.orange : Colors.red),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: pct >= 80 ? Colors.green : pct >= 60 ? Colors.orange : Colors.red)),
                              ]),
                            ],
                          ]),
                        ),
                      ),

                const SizedBox(height: 16),

                // Контакты родителей
                Row(children: [
                  const Text('Контакты родителей',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Добавить'),
                    onPressed: () => _showAddContactDialog(context),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ]),
                const SizedBox(height: 8),

                _loadingContacts
                    ? const Center(child: CircularProgressIndicator())
                    : _contacts.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: const Row(children: [
                              Icon(Icons.contact_phone_outlined, color: Colors.grey),
                              SizedBox(width: 10),
                              Text('Контакты родителей не добавлены',
                                style: TextStyle(color: Colors.grey)),
                            ]),
                          )
                        : Column(
                            children: _contacts.map((c) => _ContactCard(
                              contact: c,
                              onAddConversation: () => _showAddConversationDialog(context, c['id'] as int),
                              onDelete: () => _deleteContact(c['id'] as int),
                            )).toList(),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddContactDialog(BuildContext context) async {
    final parentNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить контакт родителя'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: parentNameCtrl,
            decoration: const InputDecoration(labelText: 'ФИО родителя *', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: phoneCtrl,
            decoration: const InputDecoration(labelText: 'Телефон *', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          TextField(controller: relationCtrl,
            decoration: const InputDecoration(labelText: 'Степень родства', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              if (parentNameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await ApiClient.dio.post('/parentcontacts', data: {
                'studentId': widget.student['id'],
                'parentName': parentNameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'relation': relationCtrl.text.trim().isEmpty ? null : relationCtrl.text.trim(),
              });
              _loadContacts();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddConversationDialog(BuildContext context, int contactId) async {
    final notesCtrl = TextEditingController();
    DateTime convDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Запись о разговоре'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text('${convDate.day.toString().padLeft(2,'0')}.${convDate.month.toString().padLeft(2,'0')}.${convDate.year}'),
              onPressed: () async {
                final d = await showDatePicker(context: ctx,
                  initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (d != null) setS(() => convDate = d);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Содержание разговора *',
                border: OutlineInputBorder(),
                hintText: 'О чём был разговор...',
              ),
              maxLines: 3,
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (notesCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await ApiClient.dio.post('/parentcontacts/conversations', data: {
                  'parentContactId': contactId,
                  'conversationDate': convDate.toIso8601String(),
                  'notes': notesCtrl.text.trim(),
                });
                _loadContacts();
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteContact(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить контакт?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ApiClient.dio.delete('/parentcontacts/$id');
    _loadContacts();
  }
}

class _ContactCard extends StatefulWidget {
  final dynamic contact;
  final VoidCallback onAddConversation;
  final VoidCallback onDelete;
  const _ContactCard({required this.contact, required this.onAddConversation, required this.onDelete});

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    final convs = (c['conversations'] as List?)?.cast<dynamic>() ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.contact_phone, color: Colors.teal, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c['parentName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(c['phone'] ?? '', style: const TextStyle(color: Colors.blue, fontSize: 13)),
              if (c['relation'] != null)
                Text(c['relation'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ])),
            IconButton(
              icon: const Icon(Icons.add_comment, size: 18, color: Colors.green),
              tooltip: 'Добавить запись о разговоре',
              onPressed: widget.onAddConversation,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              tooltip: 'Удалить контакт',
              onPressed: widget.onDelete,
            ),
          ]),
          if (convs.isNotEmpty) ...[
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(children: [
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    _expanded ? 'Скрыть разговоры' : 'Разговоров: ${convs.length} (последний: ${c['lastConversationDateStr'] ?? ''})',
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ]),
              ),
            ),
            if (_expanded)
              ...convs.map((conv) => Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(_fmtDate(conv['conversationDate']),
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ]),
                  const SizedBox(height: 3),
                  Text(conv['notes'] ?? '', style: const TextStyle(fontSize: 13)),
                ]),
              )),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.chat_bubble_outline, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                const Text('Разговоров нет', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
        ]),
      ),
    );
  }

  String _fmtDate(dynamic d) {
    if (d == null) return '';
    try {
      final dt = DateTime.parse(d.toString());
      return '${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year}';
    } catch (_) { return ''; }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}
