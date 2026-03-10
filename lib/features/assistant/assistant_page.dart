import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_metadata.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../runtime/runtime_models.dart';
import '../../widgets/gateway_connect_dialog.dart';
import '../../widgets/section_tabs.dart';
import '../../widgets/surface_card.dart';
import '../../widgets/top_bar.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({
    super.key,
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  String _mode = '代码开发';
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final theme = Theme.of(context);
    final messages = controller.chatMessages.reversed.take(6).toList(growable: false);
    final sessions = controller.sessions.take(3).toList(growable: false);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(
                title: 'Assistant',
                subtitle: '与 $kProductBrandName 对话，并发起任务',
                trailing: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _showConnectDialog,
                      icon: Icon(
                        controller.connection.status ==
                                RuntimeConnectionStatus.connected
                            ? Icons.wifi_tethering_rounded
                            : Icons.link_rounded,
                      ),
                      label: Text(
                        controller.connection.status ==
                                RuntimeConnectionStatus.connected
                            ? 'Gateway'
                            : '连接网关',
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: controller.chatController.hasPendingRun
                          ? controller.abortRun
                          : null,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('停止运行'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        kProductBrandName,
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        kProductTagline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _ConnectionChip(controller: controller),
                      const SizedBox(height: 24),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: SizedBox(
                          width: double.infinity,
                          child: SectionTabs(
                            items: const ['代码开发', '日常办公'],
                            value: _mode,
                            size: SectionTabsSize.small,
                            onChanged: (value) => setState(() => _mode = value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _inputController,
                              minLines: 5,
                              maxLines: 8,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: controller.connection.status ==
                                        RuntimeConnectionStatus.connected
                                    ? 'Ask XWorkmate anything…'
                                    : 'Connect a gateway first, then start a task…',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _showConnectDialog,
                                  icon: const Icon(Icons.attach_file_rounded),
                                  label: const Text('添加附件'),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: controller.selectAgent,
                                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: '',
                                      child: Text('Main'),
                                    ),
                                    ...controller.agents.map(
                                      (agent) => PopupMenuItem<String>(
                                        value: agent.id,
                                        child: Text(agent.name),
                                      ),
                                    ),
                                  ],
                                  child: OutlinedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.hub_rounded),
                                    label: Text(controller.activeAgentName),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => widget.onOpenDetail(
                                    DetailPanelData(
                                      title: controller.settings.defaultModel,
                                      subtitle: 'Default Model',
                                      icon: Icons.bolt_rounded,
                                      status: const StatusInfo(
                                        'Configured',
                                        StatusTone.accent,
                                      ),
                                      description: 'Default inference target from Settings.',
                                      meta: const ['Workspace', 'Gateway'],
                                      actions: const ['Open Settings'],
                                      sections: [
                                        DetailSection(
                                          title: 'Model',
                                          items: [
                                            DetailItem(
                                              label: 'Provider',
                                              value: controller.settings.defaultProvider,
                                            ),
                                            DetailItem(
                                              label: 'Model',
                                              value: controller.settings.defaultModel,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  icon: const Icon(Icons.bolt_rounded),
                                  label: Text(controller.settings.defaultModel),
                                ),
                                FilledButton.icon(
                                  onPressed: controller.connection.status ==
                                          RuntimeConnectionStatus.connected
                                      ? () async {
                                          final text = _inputController.text;
                                          await controller.sendChatMessage(text);
                                          if (mounted && text.trim().isNotEmpty) {
                                            _inputController.clear();
                                          }
                                        }
                                      : _showConnectDialog,
                                  icon: const Icon(Icons.send_rounded),
                                  label: Text(
                                    controller.connection.status ==
                                            RuntimeConnectionStatus.connected
                                        ? '发送'
                                        : '连接',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Quick Actions',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth > 760
                              ? (constraints.maxWidth - 16) / 2
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: MockData.quickActions
                                .map(
                                  (action) => SizedBox(
                                    width: width,
                                    child: SurfaceCard(
                                      onTap: () {
                                        _inputController.text = action.title;
                                        widget.onOpenDetail(
                                          DetailPanelData(
                                            title: action.title,
                                            subtitle: 'Quick Action',
                                            icon: action.icon,
                                            status: const StatusInfo(
                                              'Ready',
                                              StatusTone.accent,
                                            ),
                                            description: action.caption,
                                            meta: const ['Assistant', 'Preset'],
                                            actions: const ['Run', 'Save'],
                                            sections: const [
                                              DetailSection(
                                                title: 'Action',
                                                items: [
                                                  DetailItem(
                                                    label: 'Mode',
                                                    value: 'Interactive',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              color: theme.colorScheme.primary.withValues(
                                                alpha: 0.12,
                                              ),
                                            ),
                                            child: Icon(
                                              action.icon,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  action.title,
                                                  style: theme.textTheme.titleMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  action.caption,
                                                  style: theme.textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Live Session',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SurfaceCard(
                        child: controller.connection.status ==
                                RuntimeConnectionStatus.connected
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.forum_outlined,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          controller.currentSessionKey,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => controller.refreshSessions(),
                                        child: const Text('刷新'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (messages.isEmpty)
                                    Text(
                                      '当前 session 还没有消息，发送第一条指令即可开始。',
                                      style: theme.textTheme.bodyMedium,
                                    )
                                  else
                                    ...messages.map(
                                      (message) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 74,
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                message.role,
                                                style: theme.textTheme.labelLarge,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                message.text.isEmpty
                                                    ? 'Pending event'
                                                    : message.text,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodyMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : Text(
                                'Assistant 已准备好。先连接 Gateway，再进入真实会话与任务运行。',
                                style: theme.textTheme.bodyLarge,
                              ),
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '最近任务 / 最近会话',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth > 780
                              ? (constraints.maxWidth - 32) / 3
                              : constraints.maxWidth;
                          final cards = sessions.isEmpty
                              ? MockData.recentSessions.map(
                                  (session) => _SessionCardData(
                                    title: session.title,
                                    subtitle: session.timestamp,
                                    summary: session.summary,
                                  ),
                                )
                              : sessions.map(
                                  (session) => _SessionCardData(
                                    title: session.label,
                                    subtitle: session.surface ?? 'Session',
                                    summary:
                                        session.lastMessagePreview ??
                                        session.subject ??
                                        'No transcript preview yet.',
                                  ),
                                );
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: cards
                                .map(
                                  (session) => SizedBox(
                                    width: width,
                                    child: SurfaceCard(
                                      onTap: () => widget.onOpenDetail(
                                        DetailPanelData(
                                          title: session.title,
                                          subtitle: 'Session',
                                          icon: Icons.history_rounded,
                                          status: const StatusInfo(
                                            'Available',
                                            StatusTone.neutral,
                                          ),
                                          description: session.summary,
                                          meta: [session.subtitle, 'Assistant'],
                                          actions: const ['Open', 'Continue'],
                                          sections: [
                                            DetailSection(
                                              title: 'Summary',
                                              items: [
                                                DetailItem(
                                                  label: 'Context',
                                                  value: session.subtitle,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.title,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            session.subtitle,
                                            style: theme.textTheme.labelLarge,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            session.summary,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConnectDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => GatewayConnectDialog(
        controller: widget.controller,
        onDone: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _ConnectionChip extends StatelessWidget {
  const _ConnectionChip({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connection = controller.connection;
    final color = switch (connection.status) {
      RuntimeConnectionStatus.connected => theme.colorScheme.primaryContainer,
      RuntimeConnectionStatus.connecting => theme.colorScheme.secondaryContainer,
      RuntimeConnectionStatus.error => theme.colorScheme.errorContainer,
      RuntimeConnectionStatus.offline => theme.colorScheme.surfaceContainerHighest,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${connection.status.label} · ${connection.remoteAddress ?? 'No target'}',
        style: theme.textTheme.labelLarge,
      ),
    );
  }
}

class _SessionCardData {
  const _SessionCardData({
    required this.title,
    required this.subtitle,
    required this.summary,
  });

  final String title;
  final String subtitle;
  final String summary;
}
