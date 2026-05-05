import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'joystick_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'theme_controller.dart';
import 'l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ReportsScreen(),
    const JoystickScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final pink = context.appPink;
    final lavender = context.appLavender;
    final navBg = context.isDarkTheme
        ? context.appSurface.withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);
    final t = AppLocalizations.of(context);
    final navItems = [
      _NavItem(icon: Icons.home_rounded, label: t.nav_home),
      _NavItem(icon: Icons.analytics_rounded, label: t.nav_reports),
      _NavItem(icon: Icons.gamepad_rounded, label: t.nav_joystick),
      _NavItem(icon: Icons.settings_rounded, label: t.nav_settings),
    ];

    return Scaffold(
      backgroundColor: context.appCream,
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          (bottomPadding > 0 ? bottomPadding : 16),
        ),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: pink.withValues(alpha: 0.22),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: lavender.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Row(
              children: List.generate(
                navItems.length,
                (i) => Expanded(
                  child: _NavBarButton(
                    item: navItems[i],
                    isSelected: _selectedIndex == i,
                    onTap: () => _onItemTapped(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavBarButton extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarButton> createState() => _NavBarButtonState();
}

class _NavBarButtonState extends State<_NavBarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _dotScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _iconScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _dotScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    );

    if (widget.isSelected) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_NavBarButton old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward(from: 0);
    } else if (!widget.isSelected && old.isSelected) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pink = context.appPink;
    final lavender = context.appLavender;
    final inactiveColor = context.appMuted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final selected = widget.isSelected;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [pink, lavender],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _iconScale,
                  child: Icon(
                    widget.item.icon,
                    size: 24,
                    color: selected ? Colors.white : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : inactiveColor,
                    letterSpacing: 0.2,
                  ),
                  child: Text(widget.item.label),
                ),
                const SizedBox(height: 2),
                ScaleTransition(
                  scale: _dotScale,
                  child: Container(
                    width: selected ? 5 : 0,
                    height: selected ? 5 : 0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
