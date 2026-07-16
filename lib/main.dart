import 'package:flutter/material.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────
import 'screens/Auth/login.dart';
import 'screens/Auth/register.dart';

// ── Home / Onboarding ─────────────────────────────────────────────────────────
import 'screens/Home/intro_page.dart';
import 'screens/Home/home_page.dart';

// ── Projects ──────────────────────────────────────────────────────────────────
import 'screens/Projects/view_project.dart';
import 'screens/Projects/project_details.dart';
import 'screens/Projects/create_new_project.dart';

// ── Task Manager ──────────────────────────────────────────────────────────────
import 'screens/TaskManager/task_details.dart';
import 'screens/TaskManager/create_task.dart';

// ── Other tabs ────────────────────────────────────────────────────────────────
import 'screens/Noti/notification.dart';
import 'screens/Chat/chat_group.dart';
import 'screens/Profile/profile_user.dart';

void main() {
  runApp(const WellTaskApp());
}

class WellTaskApp extends StatelessWidget {
  const WellTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          surface: const Color(0xFFF8F9FF),
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
          displaySmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ),
      ),

      // ── Màn hình khởi đầu ──────────────────────────────────────────────────
      initialRoute: '/onboarding',

      // ── Bảng định tuyến All màn hình ───────────────────────────────────
      routes: {
        // Onboarding & Auth
        '/onboarding': (context) => const OnboardingScreen(),
        '/login':      (context) => const LoginScreen(),
        '/register':   (context) => const RegisterScreen(),

        // Main app shell (sau khi Log In)
        '/home':               (context) => const MainShell(),

        // Projects
        '/projects':           (context) => const ProjectListScreen(),
        '/projects/new':       (context) => const CreateProjectScreen(),
        '/projects/detail':    (context) => const KanbanScreen(),

        // Tasks
        '/tasks/detail':       (context) => const TaskDetailScreen(),
        '/tasks/new':          (context) => const CreateTaskScreen(),

        // Other
        '/notifications':      (context) => const NotificationScreen(),
        '/chat':               (context) => const ChatScreen(),
        '/profile':            (context) => const ProfileScreen(),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MainShell – Bottom Navigation Bar kết nối 5 tab chính
// ══════════════════════════════════════════════════════════════════════════════
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Danh sách màn hình cho từng tab
  final List<Widget> _screens = const [
    DashboardScreen(),
    ProjectListScreen(),
    NotificationScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF6C63FF).withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF6C63FF)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded, color: Color(0xFF6C63FF)),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded, color: Color(0xFF6C63FF)),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF6C63FF)),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF6C63FF)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
