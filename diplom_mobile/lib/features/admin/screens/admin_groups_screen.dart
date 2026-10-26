import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class AdminGroupsScreen extends StatefulWidget {
  const AdminGroupsScreen({super.key});

  @override
  State<AdminGroupsScreen> createState() => _AdminGroupsScreenState();
}

class _AdminGroupsScreenState extends State<AdminGroupsScreen> {
  List _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await ApiClient.dio.get('/groups');
      setState(() {
        _groups = r.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _showCreateDialog() async {
    final nameCtrl = TextEditingController();
    final yearCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новая группа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название группы')),
            const SizedBox(height: 8),
            TextField(
              controller: yearCtrl,
              decoration: const InputDecoration(labelText: 'Год набора'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiClient.dio.post('/groups', data: {
                  'name': nameCtrl.text,
                  'year': int.tryParse(yearCtrl.text) ?? DateTime.now().year,
                });
                if (context.mounted) Navigator.pop(context);
                await _load();
              } catch (_) {}
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _showCreateDialog, child: const Icon(Icons.group_add)),
      body: _groups.isEmpty
          ? const Center(child: Text('Групп нет'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _groups.length,
                itemBuilder: (_, i) {
                  final g = _groups[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF1565C0),
                        child: Icon(Icons.groups, color: Colors.white, size: 22),
                      ),
                      title: Text(g['name'] ?? '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Год набора: ${g['year'] ?? '—'} | Студентов: ${g['studentCount'] ?? 0}'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
