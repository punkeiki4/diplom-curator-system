import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/api/api_client.dart';
import 'student_schedule_screen.dart';
import 'student_attendance_screen.dart';
import 'student_requests_screen.dart';
import 'student_notifications_screen.dart';
import 'student_debts_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _StudentDashboard(),
    StudentScheduleScreen(),
    StudentAttendanceScreen(),
    StudentNotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Студент'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Расписание'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Посещ.'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Уведомл.'),
        ],
      ),
    );
  }
}

class _StudentDashboard extends StatefulWidget {
  const _StudentDashboard();

  @override
  State<_StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<_StudentDashboard> {
  List<dynamic> _events = [];
  bool _eventsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final r = await ApiClient.dio.get('/events/my');
      final all = r.data as List;
      // Show only upcoming events (next 30 days), max 5
      final now = DateTime.now();
      final upcoming = all.where((e) {
        try {
          final dt = DateTime.parse(e['eventDate'].toString());
          return dt.isAfter(now) && dt.isBefore(now.add(const Duration(days: 30)));
        } catch (_) {
          return false;
        }
      }).take(5).toList();
      if (mounted) setState(() { _events = upcoming; _eventsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _eventsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(
                  auth.user?.fullName ?? 'Студент',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  auth.user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming events widget
          const Text('Предстоящие мероприятия', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _eventsLoading
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ))
              : _events.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: const Row(children: [
                        Icon(Icons.event_available, color: Colors.grey, size: 32),
                        SizedBox(width: 12),
                        Text('Предстоящих мероприятий нет', style: TextStyle(color: Colors.grey)),
                      ]),
                    )
                  : Column(
                      children: _events.map((e) => _EventChip(event: e)).toList(),
                    ),

          const SizedBox(height: 24),
          const Text('Быстрый доступ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _QuickCard(
                icon: Icons.assignment_outlined,
                label: 'Задолженности',
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentDebtsScreen())),
              ),
              _QuickCard(
                icon: Icons.send_outlined,
                label: 'Заявки',
                color: Colors.green,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentRequestsScreen())),
              ),
              _QuickCard(
                icon: Icons.fact_check_outlined,
                label: 'Посещаемость',
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAttendanceScreen())),
              ),
              _QuickCard(
                icon: Icons.notifications,
                label: 'Уведомления',
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentNotificationsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  final dynamic event;
  const _EventChip({required this.event});

  @override
  Widget build(BuildContext context) {
    final isUnplanned = (event['eventType'] ?? '') == 'Внеплановое';
    final color = isUnplanned ? Colors.orange : Colors.blue;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(isUnplanned ? Icons.notification_important : Icons.event, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event['title'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          Row(children: [
            Text(event['eventDateStr'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            if (event['location'] != null) ...[
              const Text(' • ', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Expanded(child: Text(event['location'], style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ]),
        ])),
        if (isUnplanned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: const Text('Внепл.', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
