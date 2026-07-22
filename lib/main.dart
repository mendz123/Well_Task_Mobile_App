import 'package:flutter/material.dart';
import 'core/services/deep_link_service.dart';

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
import 'screens/TaskManager/view_task.dart';

// ── Other tabs ────────────────────────────────────────────────────────────────
import 'screens/Noti/notification.dart';
import 'screens/Chat/chat_group.dart';
import 'screens/Profile/profile_user.dart';

void main() {
  runApp(const WellTaskApp());
}

class WellTaskApp extends StatefulWidget {
  const WellTaskApp({super.key});

  @override
  State<WellTaskApp> createState() => _WellTaskAppState();
}

class _WellTaskAppState extends State<WellTaskApp> {
  // Key quan trọng để quản lý Navigator từ Service bên ngoài
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Khởi tạo Deep Link Service ngay lập tức nhưng xử lý UI thông qua GlobalKey
    DeepLinkService().init(_navigatorKey);
  }

  @override
  void dispose() {
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey, // Gán key để Service có thể gọi Navigator
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
          bodyLarge: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainShell(),
        '/projects': (context) => const ProjectListScreen(),
        '/projects/new': (context) => const CreateProjectScreen(),
        '/projects/detail': (context) => const KanbanScreen(),
        '/tasks': (context) => const TaskManagerScreen(),
        '/tasks/detail': (context) => const TaskDetailScreen(),
        '/tasks/new': (context) => const CreateTaskScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/chat': (context) => const ChatScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ProjectListScreen(),
    NotificationScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Kiểm tra xem có lời mời dự án nào đang chờ xử lý hay không
    DeepLinkService().checkPendingInvitation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
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
            selectedIcon: Icon(
              Icons.notifications_rounded,
              color: Color(0xFF6C63FF),
            ),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(
              Icons.chat_bubble_rounded,
              color: Color(0xFF6C63FF),
            ),
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
