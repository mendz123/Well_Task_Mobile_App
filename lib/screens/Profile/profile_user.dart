import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: const ProfileAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const ProfileHeaderCard(
              name: 'Minh T.',
              email: 'minh.t@university.edu',
              joinDate: '15/08/2023',
              avatarUrl: 'https://i.pravatar.cc/100?img=12',
            ),
            const SizedBox(height: 24),
            const PersonalInfoSection(
              bio:
                  '3rd year Computer Science student. Passionate about UI Design & Coding.',
              phone: '0987 654 321',
            ),
            const SizedBox(height: 24),
            const SkillsSection(
              skills: ['Flutter', 'UI/UX', 'Python', 'Figma'],
            ),
            const SizedBox(height: 32),
            PrimaryOutlineButton(
              text: 'Change Password',
              icon: Icons.history_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            const LogoutButton(),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF3F0FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            color: Color(0xFF6C63FF),
            size: 20,
          ),
        ),
      ),
      title: const Text(
        'WellTask',
        style: TextStyle(
          color: Color(0xFF6C63FF),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Color(0xFF6C63FF)),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String joinDate;
  final String avatarUrl;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.joinDate,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFF3F0FF),
                child: CircleAvatar(
                  radius: 54,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(email, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(width: 8),
                Text(
                  'Joined since: $joinDate',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalInfoSection extends StatelessWidget {
  final String bio;
  final String phone;

  const PersonalInfoSection({
    super.key,
    required this.bio,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          const LabelText(label: 'Bio'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(bio, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 20),
          const LabelText(label: 'Phone Number'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: Color(0xFF666666),
                ),
                const SizedBox(width: 12),
                Text(phone, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8E4FF),
                foregroundColor: const Color(0xFF6C63FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LabelText extends StatelessWidget {
  final String label;
  const LabelText({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}

class SkillsSection extends StatelessWidget {
  final List<String> skills;

  const SkillsSection({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Skills', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    onDeleted: () {},
                    deleteIcon: const Icon(Icons.close, size: 14),
                    backgroundColor: const Color(0xFFF3F0FF),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class PrimaryOutlineButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const PrimaryOutlineButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          await AuthService.logout();
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEB),
          foregroundColor: const Color(0xFFD32F2F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded),
            SizedBox(width: 12),
            Text(
              'Log Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          NavItem(icon: Icons.home_outlined, label: 'Home'),
          NavItem(icon: Icons.folder_outlined, label: 'PROJECT'),
          NavItem(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
          ),
          NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
          NavItem(icon: Icons.person_rounded, label: 'Profile', isActive: true),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFB0B0B0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }
}
