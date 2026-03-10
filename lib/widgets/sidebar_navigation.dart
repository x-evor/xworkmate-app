import 'package:flutter/material.dart';

import '../app/app_metadata.dart';
import '../models/app_models.dart';
import '../theme/app_palette.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({
    super.key,
    required this.currentSection,
    required this.isCollapsed,
    required this.themeMode,
    required this.onSectionChanged,
    required this.onToggleCollapsed,
    required this.onOpenAccount,
    required this.onOpenThemeToggle,
  });

  final WorkspaceDestination currentSection;
  final bool isCollapsed;
  final ThemeMode themeMode;
  final ValueChanged<WorkspaceDestination> onSectionChanged;
  final VoidCallback onToggleCollapsed;
  final VoidCallback onOpenAccount;
  final VoidCallback onOpenThemeToggle;

  static const _mainSections = [
    WorkspaceDestination.assistant,
    WorkspaceDestination.tasks,
    WorkspaceDestination.modules,
    WorkspaceDestination.secrets,
    WorkspaceDestination.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: isCollapsed ? 78 : 252,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.sidebar,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.sidebarBorder),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 10 : 16,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SidebarHeader(isCollapsed: isCollapsed),
            const SizedBox(height: 18),
            Container(height: 1, color: palette.sidebarBorder),
            const SizedBox(height: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _mainSections
                            .map(
                              (section) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: SidebarNavItem(
                                  section: section,
                                  selected: currentSection == section,
                                  collapsed: isCollapsed,
                                  onTap: () => onSectionChanged(section),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: palette.sidebarBorder),
                  const SizedBox(height: 16),
                  SidebarFooter(
                    isCollapsed: isCollapsed,
                    themeMode: themeMode,
                    onOpenThemeToggle: onOpenThemeToggle,
                    onOpenSettings: () =>
                        onSectionChanged(WorkspaceDestination.settings),
                    onToggleCollapsed: onToggleCollapsed,
                    onOpenAccount: onOpenAccount,
                    accountSelected:
                        currentSection == WorkspaceDestination.account,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key, required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: palette.accentMuted,
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: palette.accent,
            size: 22,
          ),
        ),
        if (!isCollapsed) ...[
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kProductBrandName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  kProductSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class SidebarNavItem extends StatefulWidget {
  const SidebarNavItem({
    super.key,
    required this.section,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final WorkspaceDestination section;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<SidebarNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final active = widget.selected;
    final background = active
        ? palette.accentMuted
        : _hovered
        ? palette.hover
        : Colors.transparent;
    final foreground = active ? palette.accent : palette.textSecondary;

    final item = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 14,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(widget.section.icon, color: foreground, size: 20),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    widget.section.label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: foreground),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.collapsed ? widget.section.label : '',
        child: item,
      ),
    );
  }
}

class SidebarFooter extends StatelessWidget {
  const SidebarFooter({
    super.key,
    required this.isCollapsed,
    required this.themeMode,
    required this.onOpenThemeToggle,
    required this.onOpenSettings,
    required this.onToggleCollapsed,
    required this.onOpenAccount,
    required this.accountSelected,
  });

  final bool isCollapsed;
  final ThemeMode themeMode;
  final VoidCallback onOpenThemeToggle;
  final VoidCallback onOpenSettings;
  final VoidCallback onToggleCollapsed;
  final VoidCallback onOpenAccount;
  final bool accountSelected;

  @override
  Widget build(BuildContext context) {
    final themeButton = Tooltip(
      message: themeMode == ThemeMode.dark ? '切换浅色' : '切换暗色',
      child: IconButton(
        onPressed: onOpenThemeToggle,
        icon: Icon(
          themeMode == ThemeMode.dark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
        ),
      ),
    );

    final settingsButton = Tooltip(
      message: '打开设置',
      child: IconButton(
        onPressed: onOpenSettings,
        icon: const Icon(Icons.settings_rounded),
      ),
    );

    final collapseButton = Tooltip(
      message: isCollapsed ? '展开导航' : '折叠导航',
      child: IconButton(
        onPressed: onToggleCollapsed,
        icon: Icon(
          isCollapsed
              ? Icons.menu_open_rounded
              : Icons.keyboard_double_arrow_left_rounded,
        ),
      ),
    );

    return Column(
      children: [
        if (isCollapsed)
          Column(
            children: [
              themeButton,
              const SizedBox(height: 8),
              settingsButton,
              const SizedBox(height: 8),
              collapseButton,
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [themeButton, settingsButton, collapseButton],
          ),
        const SizedBox(height: 10),
        Tooltip(
          message: isCollapsed ? 'Account' : '',
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onOpenAccount,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: accountSelected
                    ? context.palette.accentMuted
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: isCollapsed
                  ? const Icon(Icons.account_circle_rounded)
                  : Row(
                      children: [
                        const CircleAvatar(radius: 18, child: Text('H')),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haitao Pan',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              'Account',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
