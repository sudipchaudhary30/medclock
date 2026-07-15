import 'package:flutter/material.dart';
import 'package:medclock/config/app_theme.dart';

class McBottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const McBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppTheme.primaryDark;
    const inactiveColor = AppTheme.textPrimary;

    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.history_rounded, 'label': 'History'},
      {'icon': Icons.medical_services_outlined, 'label': 'Refill'},
      {'icon': Icons.settings_outlined, 'label': 'Settings'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedIndex == index;
            final color = isSelected ? activeColor : inactiveColor;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item['icon'] as IconData, color: color, size: 24),
                    const SizedBox(height: 2),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontFamily: 'serif',
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
