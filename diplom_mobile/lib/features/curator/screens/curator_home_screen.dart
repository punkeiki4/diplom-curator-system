import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_provider.dart';
import 'curator_students_screen.dart';
import 'curator_attendance_screen.dart';
import 'curator_tasks_screen.dart';
import 'curator_reports_screen.dart';
import 'curator_notifications_screen.dart';
import 'curator_hour_plans_screen.dart';
import 'curator_events_screen.dart';
import 'curator_parent_contacts_screen.dart';

class CuratorHomeScreen extends StatefulWidget {
  const CuratorHomeScreen({super.key});

  @override
  State<CuratorHomeScreen> createState() => _CuratorHomeScreenState();
}

class _CuratorHomeScreenState extends State<CuratorHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _CuratorDashboard(),
    CuratorStudentsScreen(),
    CuratorAttendanceScreen(),
    CuratorHourPlansScreen(),
    CuratorEventsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Куратор'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_phone_outlined),
            tooltip: 'Контакты родителей',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuratorParentContactsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            tooltip: 'Отчёты',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuratorReportsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Уведомления',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuratorNotificationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Студенты'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Посещ.'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Планы'),
          NavigationDestination(icon: Icon(Icons.celebration_outlined), selectedIcon: Icon(Icons.celebration), label: 'Мерополр.'),
        ],
      ),
    );
  }
}

class _CuratorDashboard extends StatelessWidget {
  const _CuratorDashboard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.manage_accounts, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(
                  auth.user?.fullName ?? 'Куратор',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('Куратор группы', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Панель куратора', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _CuratorCard(
            icon: Icons.group,
            title: 'Студенты группы',
            subtitle: 'Просмотр списка студентов',
            color: Colors.blue,
            onTap: () {},
          ),
          _CuratorCard(
            icon: Icons.fact_check,
            title: 'Отметить посещаемость',
            subtitle: 'Отмечайте присутствие на занятиях',
            color: Colors.green,
            onTap: () {},
          ),
          _CuratorCard(
            icon: Icons.event_note,
            title: 'Планы кураторских часов',
            subtitle: 'Планируйте и отслеживайте кураторские часы',
            color: Colors.teal,
            onTap: () {},
          ),
          _CuratorCard(
            icon: Icons.celebration,
            title: 'Мероприятия',
            subtitle: 'Плановые и внеплановые мероприятия',
            color: Colors.orange,
            onTap: () {},
          ),
          _CuratorCard(
            icon: Icons.contact_phone,
            title: 'Контакты родителей',
            subtitle: 'Телефоны родителей и записи разговоров',
            color: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuratorParentContactsScreen())),
          ),
          _CuratorCard(
            icon: Icons.task,
            title: 'Задания',
            subtitle: 'Управление заданиями для студентов',
            color: Colors.indigo,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuratorTasksScreen())),
          ),
          _CuratorCard(
            icon: Icons.summarize,
            title: 'Отчёты',
            subtitle: 'Создание и просмотр отчётов',
            color: Colors.brown,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuratorReportsScreen())),
          ),
        ],
      ),
    );
  }
}

class _CuratorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CuratorCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
