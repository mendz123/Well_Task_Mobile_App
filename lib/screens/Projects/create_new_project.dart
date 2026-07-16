import 'package:flutter/material.dart';

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: const CreateProjectAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTextField(
                label: 'Project Name',
                hintText: 'Project Name (e.g., Graduation Thesis)',
              ),
              const SizedBox(height: 24),
              const CategorySelector(
                label: 'Category',
                categories: ['Study', 'Personal', 'Club', 'Research'],
                activeIndex: 0,
              ),
              const SizedBox(height: 24),
              const CustomTextField(
                label: 'Project Goal',
                hintText: 'Brief description of what you want to achieve...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(
                    child: DatePickerField(
                      label: 'Start Date',
                      hintText: 'mm/dd/yyyy',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DatePickerField(
                      label: 'Deadline',
                      hintText: 'mm/dd/yyyy',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFF3F0FF)),
              const SizedBox(height: 24),
              const MemberSection(
                label: 'Members',
                memberAvatars: [
                  'https://i.pravatar.cc/100?img=12',
                  'https://i.pravatar.cc/100?img=32',
                ],
                extraCount: 2,
              ),
              const SizedBox(height: 40),
              PrimaryButton(text: "Create Project", onPressed: () { Navigator.pop(context); },
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}

class CreateProjectAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateProjectAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)), onPressed: () { Navigator.pop(context); }),
      centerTitle: true,
      title: const Text(
        'Create New Project',
        style: TextStyle(
          color: Color(0xFF6C63FF),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF3F0FF).withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class CategorySelector extends StatelessWidget {
  final String label;
  final List<String> categories;
  final int activeIndex;

  const CategorySelector({
    super.key,
    required this.label,
    required this.categories,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(categories.length, (index) {
              final bool isActive = index == activeIndex;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(categories[index]),
                  selected: isActive,
                  onSelected: (val) {},
                  selectedColor: const Color(0xFF6C63FF),
                  backgroundColor: const Color(0xFFF3F0FF),
                  labelStyle: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF1A1A1A),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide.none,
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class DatePickerField extends StatelessWidget {
  final String label;
  final String hintText;

  const DatePickerField({super.key, required this.label, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0FF).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFFB0B0B0), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hintText,
                  style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                ),
              ),
              const Icon(Icons.calendar_month, color: Color(0xFF1A1A1A), size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class MemberSection extends StatelessWidget {
  final String label;
  final List<String> memberAvatars;
  final int extraCount;

  const MemberSection({
    super.key,
    required this.label,
    required this.memberAvatars,
    required this.extraCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                ...memberAvatars.map((url) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(url),
                  ),
                )),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F0FF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+$extraCount',
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Members'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6C63FF),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.rocket_launch_outlined, size: 24),
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
        color: Color(0xFFFCF8FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          NavItem(icon: Icons.home_outlined, label: 'Home'),
          NavItem(icon: Icons.grid_view_rounded, label: 'PROJECT', isActive: true),
          NavItem(icon: Icons.notifications_none_rounded, label: 'Notifications'),
          NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
          NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const NavItem({super.key, required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF1A1A1A)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
