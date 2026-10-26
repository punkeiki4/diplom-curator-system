import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class CuratorNotificationsScreen extends StatefulWidget {
  const CuratorNotificationsScreen({super.key});

  @override
  State<CuratorNotificationsScreen> createState() => _CuratorNotificationsScreenState();
}

class _CuratorNotificationsScreenState extends State<CuratorNotificationsScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Уведомлений нет'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      final isRead = n['isRead'] == true;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: isRead ? null : const Color(0xFFE8F5E9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isRead ? Colors.grey.shade300 : Colors.green,
                            child: Icon(Icons.notifications, color: isRead ? Colors.grey : Colors.white, size: 20),
                          ),
                          title: Text(n['title'] ?? '—', style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(n['message'] ?? ''),
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
                ),
    );
  }
}
