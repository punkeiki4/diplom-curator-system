import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CuratorParentContactsScreen extends StatefulWidget {
  const CuratorParentContactsScreen({super.key});

  @override
  State<CuratorParentContactsScreen> createState() => _CuratorParentContactsScreenState();
}

class _CuratorParentContactsScreenState extends State<CuratorParentContactsScreen> {
  List<dynamic> _contacts = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiClient.dio.get('/parentcontacts/my-group');
      setState(() { _contacts = r.data as List; _loading = false; });
    } on DioException catch (e) {
      setState(() { _error = 'Ошибка: ${e.response?.statusCode ?? 'нет соединения'}'; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Нет соединения'; _loading = false; });
    }
  }

  List<dynamic> get _filtered {
    if (_search.isEmpty) return _contacts;
    final q = _search.toLowerCase();
    return _contacts.where((c) =>
      (c['studentName'] ?? '').toLowerCase().contains(q) ||
      (c['parentName'] ?? '').toLowerCase().contains(q) ||
      (c['phone'] ?? '').contains(q)
    ).toList();
  }

  Map<String, List<dynamic>> get _byStudent {
    final map = <String, List<dynamic>>{};
    for (final c in _filtered) {
      final name = c['studentName'] ?? 'Студент ${c['studentId']}';
      map.putIfAbsent(name, () => []).add(c);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Контакты родителей')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск по студенту, родителю, телефону...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (v) => setState(() => _search = v),
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
                        child: _contacts.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 100),
                                Center(child: Column(children: [
                                  Icon(Icons.contact_phone_outlined, size: 64, color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text('Контактов родителей нет', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text('Нажмите + чтобы добавить', style: TextStyle(color: Colors.grey)),
                                ])),
                              ])
                            : _buildList(),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Добавить контакт'),
      ),
    );
  }

  Widget _buildList() {
    final grouped = _byStudent;
    final students = grouped.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      itemCount: students.length,
      itemBuilder: (ctx, i) {
        final studentName = students[i];
        final contacts = grouped[studentName]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(children: [
                  const CircleAvatar(radius: 18, backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white, size: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                  IconButton(
                    icon: const Icon(Icons.add_call, color: Colors.blue),
                    tooltip: 'Добавить контакт для студента',
                    onPressed: () => _showAddContactDialog(studentId: contacts.first['studentId'] as int),
                  ),
                ]),
              ),
              ...contacts.map((contact) => _ContactTile(
                contact: contact,
                onEdit: () => _showEditContactDialog(contact),
                onDelete: () => _deleteContact(contact['id'] as int),
                onAddConversation: () => _showAddConversationDialog(
                  contact['id'] as int,
                  parentName: contact['parentName'] as String?,
                  studentName: studentName,
                ),
                onDeleteConversation: (cid) => _deleteConversation(cid),
              )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddContactDialog({int? studentId}) async {
    List<dynamic> students = [];
    int? selectedStudentId = studentId;
    try {
      final r = await ApiClient.dio.get('/students/my-group');
      students = r.data as List;
    } catch (_) {}

    if (!mounted) return;

    final parentNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Добавить контакт родителя'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (studentId == null && students.isNotEmpty)
                DropdownButtonFormField<int?>(
                  value: selectedStudentId,
                  decoration: const InputDecoration(labelText: 'Студент *', border: OutlineInputBorder()),
                  items: students.map((s) => DropdownMenuItem<int>(
                    value: s['id'] as int,
                    child: Text(s['fullName'] ?? 'Студент'),
                  )).toList(),
                  onChanged: (v) => setS(() => selectedStudentId = v),
                ),
              const SizedBox(height: 10),
              TextField(controller: parentNameCtrl, decoration: const InputDecoration(labelText: 'ФИО родителя *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Телефон *', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              TextField(controller: relationCtrl, decoration: const InputDecoration(labelText: 'Степень родства (мать/отец/...)', border: OutlineInputBorder())),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (selectedStudentId == null || parentNameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Заполните обязательные поля')));
                  return;
                }
                Navigator.pop(ctx);
                await _createContact({
                  'studentId': selectedStudentId,
                  'parentName': parentNameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'relation': relationCtrl.text.trim().isEmpty ? null : relationCtrl.text.trim(),
                });
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditContactDialog(dynamic contact) async {
    final parentNameCtrl = TextEditingController(text: contact['parentName']);
    final phoneCtrl = TextEditingController(text: contact['phone']);
    final relationCtrl = TextEditingController(text: contact['relation'] ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редактировать контакт'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: parentNameCtrl, decoration: const InputDecoration(labelText: 'ФИО родителя', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Телефон', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            TextField(controller: relationCtrl, decoration: const InputDecoration(labelText: 'Степень родства', border: OutlineInputBorder())),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _updateContact(contact['id'] as int, {
                'parentName': parentNameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'relation': relationCtrl.text.trim().isEmpty ? null : relationCtrl.text.trim(),
              });
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddConversationDialog(int contactId, {String? parentName, String? studentName}) async {
    final notesCtrl = TextEditingController();
    DateTime? convDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Запись о разговоре с родителями'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(convDate == null ? 'Дата разговора *' : '${convDate!.day.toString().padLeft(2,'0')}.${convDate!.month.toString().padLeft(2,'0')}.${convDate!.year}'),
                onPressed: () async {
                  final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (d != null) setS(() => convDate = d);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Содержание разговора *',
                  border: OutlineInputBorder(),
                  hintText: 'Опишите о чём был разговор...',
                ),
                maxLines: 4,
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                if (notesCtrl.text.trim().isEmpty || convDate == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
                  return;
                }
                Navigator.pop(ctx);
                await _addConversation(
                  {
                    'parentContactId': contactId,
                    'conversationDate': convDate!.toIso8601String(),
                    'notes': notesCtrl.text.trim(),
                  },
                  parentName: parentName,
                  studentName: studentName,
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createContact(Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.post('/parentcontacts', data: data);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Контакт добавлен'), backgroundColor: Colors.green));
    } catch (_) {}
  }

  Future<void> _updateContact(int id, Map<String, dynamic> data) async {
    try {
      await ApiClient.dio.put('/parentcontacts/$id', data: data);
      _load();
    } catch (_) {}
  }

  Future<void> _deleteContact(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить контакт?'),
        content: const Text('Будут удалены все записи о разговорах с этим родителем.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiClient.dio.delete('/parentcontacts/$id');
      _load();
    } catch (_) {}
  }

  Future<void> _addConversation(Map<String, dynamic> data, {String? parentName, String? studentName}) async {
    try {
      await ApiClient.dio.post('/parentcontacts/conversations', data: data);

      // Автоматически создаём отчёт для замдекана
      try {
        final title = 'Разговор с родителем: ${parentName ?? 'родитель'}'
            '${studentName != null ? ' (студент: $studentName)' : ''}';
        await ApiClient.dio.post('/curatorreports', data: {
          'customTitle': title,
          'reportText': data['notes'],
        });
      } catch (_) {}

      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись добавлена и отчёт направлен замдекану'), backgroundColor: Colors.green),
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при сохранении'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteConversation(int id) async {
    try {
      await ApiClient.dio.delete('/parentcontacts/conversations/$id');
      _load();
    } catch (_) {}
  }
}

class _ContactTile extends StatefulWidget {
  final dynamic contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddConversation;
  final Function(int) onDeleteConversation;

  const _ContactTile({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onAddConversation,
    required this.onDeleteConversation,
  });

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    final conversations = (c['conversations'] as List?)?.cast<dynamic>() ?? [];

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.contact_phone, color: Colors.teal, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['parentName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(c['phone'] ?? '', style: const TextStyle(color: Colors.blue, fontSize: 13)),
                  if (c['relation'] != null)
                    Text(c['relation'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: widget.onEdit, tooltip: 'Редактировать'),
                IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: widget.onDelete, tooltip: 'Удалить'),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Разговоров: ${conversations.length}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (conversations.isNotEmpty && c['lastConversationDateStr'] != null) ...[
                  const SizedBox(width: 8),
                  Text('• последний: ${c['lastConversationDateStr']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add_comment, size: 14),
                  label: const Text('Запись', style: TextStyle(fontSize: 12)),
                  onPressed: widget.onAddConversation,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2)),
                ),
              ]),
              if (conversations.isNotEmpty) ...[
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(_expanded ? 'Скрыть записи' : 'Показать записи (${conversations.length})', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                    ]),
                  ),
                ),
                if (_expanded)
                  ...conversations.map((conv) => Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(_formatDate(conv['conversationDate']), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          if (conv['curatorName'] != null) ...[
                            const SizedBox(width: 8),
                            Text('(${conv['curatorName']})', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ]),
                        const SizedBox(height: 4),
                        Text(conv['notes'] ?? '', style: const TextStyle(fontSize: 13)),
                      ])),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        onPressed: () => widget.onDeleteConversation(conv['id'] as int),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Удалить запись',
                      ),
                    ]),
                  )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr.toString());
      return '${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year}';
    } catch (_) {
      return dateStr.toString().substring(0, 10);
    }
  }
}
