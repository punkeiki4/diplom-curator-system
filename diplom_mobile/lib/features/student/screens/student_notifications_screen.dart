import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  List _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await ApiClient.dio.get('/notifications/my');
      setState(() {
        _notifications = r.data as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: _notifications.isEmpty
          ? const Center(child: Text('Уведомлений нет'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (_, i) {
                final n = _notifications[i];
                final isRead = n['isRead'] == true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: isRead ? null : const Color(0xFFE3F2FD),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isRead ? Colors.grey.shade300 : const Color(0xFF1565C0),
                      child: Icon(
                        Icons.notifications,
                        color: isRead ? Colors.grey : Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n['title'] ?? '—',
                      style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Text(n['message'] ?? ''),
                    trailing: Text(
                      n['createdAt'] != null ? _formatDate(n['createdAt']) : '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    onTap: () async {
                      if (!isRead) {
                        try {
                          await ApiClient.dio.put('/notifications/${n['id']}/read');
                          await _load();
                        } catch (_) {}
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
