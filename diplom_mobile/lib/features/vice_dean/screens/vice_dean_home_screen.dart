import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_provider.dart';
import 'vice_dean_debts_screen.dart';
import 'vice_dean_tasks_screen.dart';
import 'vice_dean_requests_screen.dart';
import 'vice_dean_reports_screen.dart';
import 'vice_dean_events_screen.dart';

class ViceDeanHomeScreen extends StatefulWidget {
  const ViceDeanHomeScreen({super.key});

  @override
  State<ViceDeanHomeScreen> createState() => _ViceDeanHomeScreenState();
}

class _ViceDeanHomeScreenState extends State<ViceDeanHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _ViceDeanDashboard(),
    ViceDeanDebtsScreen(),
    ViceDeanTasksScreen(),
    ViceDeanRequestsScreen(),
    ViceDeanReportsScreen(),
    ViceDeanEventsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Проректор'),
        actions: [
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
          NavigationDestination(icon: Icon(Icons.warning_amber_outlined), selectedIcon: Icon(Icons.warning_amber), label: 'Долги'),
          NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task), label: 'Задания'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Заявки'),
          NavigationDestination(icon: Icon(Icons.summarize_outlined), selectedIcon: Icon(Icons.summarize), label: 'Отчёты'),
          NavigationDestination(icon: Icon(Icons.celebration_outlined), selectedIcon: Icon(Icons.celebration), label: 'Мерополр.'),
        ],
      ),
    );
  }
}

class _ViceDeanDashboard extends StatelessWidget {
  const _ViceDeanDashboard();

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
                colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(auth.user?.fullName ?? 'Проректор',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Проректор', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Управление', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _MenuItem(icon: Icons.warning_amber, title: 'Академические долги', color: Colors.red, subtitle: 'Просмотр задолженностей студентов'),
          _MenuItem(icon: Icons.task, title: 'Задания кураторам', color: Colors.orange, subtitle: 'Назначение и контроль заданий'),
          _MenuItem(icon: Icons.inbox, title: 'Заявки студентов', color: Colors.blue, subtitle: 'Рассмотрение заявок'),
          _MenuItem(icon: Icons.summarize, title: 'Отчёты кураторов', color: Colors.green, subtitle: 'Проверка и утверждение отчётов'),
          _MenuItem(icon: Icons.celebration, title: 'Мероприятия', color: Colors.purple, subtitle: 'Все плановые и внеплановые мероприятия'),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _MenuItem({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
