import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_metadata.dart';
import '../../widgets/section_tabs.dart';
import '../../widgets/surface_card.dart';
import '../../widgets/top_bar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _tab = 'Profile';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final settings = controller.settings;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(title: 'Account', subtitle: '用户身份、工作区切换与登录会话。'),
              const SizedBox(height: 24),
              SectionTabs(
                items: const ['Profile', 'Workspace', 'Sessions'],
                value: _tab,
                size: SectionTabsSize.small,
                onChanged: (value) => setState(() => _tab = value),
              ),
              const SizedBox(height: 24),
              if (_tab == 'Profile')
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.accountUsername.trim().isEmpty
                            ? 'Local Operator'
                            : settings.accountUsername,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.accountLocalMode
                            ? 'Local mode · Placeholder account session'
                            : 'Unified account entry pending backend integration',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: ValueKey(settings.accountBaseUrl),
                        initialValue: settings.accountBaseUrl,
                        decoration: const InputDecoration(labelText: 'Service URL'),
                        onFieldSubmitted: (value) => controller.saveSettings(
                          settings.copyWith(accountBaseUrl: value),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: ValueKey(settings.accountUsername),
                        initialValue: settings.accountUsername,
                        decoration: const InputDecoration(labelText: 'Email / Username'),
                        onFieldSubmitted: (value) => controller.saveSettings(
                          settings.copyWith(accountUsername: value),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_tab == 'Workspace')
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.accountWorkspace,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Workspace shell for $kProductBrandName'),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: ValueKey(settings.accountWorkspace),
                        initialValue: settings.accountWorkspace,
                        decoration: const InputDecoration(labelText: 'Workspace Label'),
                        onFieldSubmitted: (value) => controller.saveSettings(
                          settings.copyWith(accountWorkspace: value),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_tab == 'Sessions')
                if (controller.sessions.isEmpty)
                  const SurfaceCard(
                    child: Text('No gateway sessions yet. Connect and start a chat first.'),
                  )
                else
                  ...controller.sessions.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SurfaceCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.label,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${session.surface ?? 'Session'} · ${session.kind ?? 'chat'}',
                                  ),
                                ],
                              ),
                            ),
                            Text(session.model ?? 'gateway'),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
