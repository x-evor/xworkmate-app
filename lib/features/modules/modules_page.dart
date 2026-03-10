import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_metadata.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../runtime/runtime_controllers.dart';
import '../../runtime/runtime_models.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/section_tabs.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/surface_card.dart';
import '../../widgets/top_bar.dart';

class ModulesPage extends StatefulWidget {
  const ModulesPage({
    super.key,
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  String _tab = 'Gateway';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final metrics = [
      MetricSummary(
        label: 'Gateway',
        value: controller.connection.status.label,
        caption: controller.connection.remoteAddress ?? kAppVersionLabel,
        icon: Icons.wifi_tethering_rounded,
        status: _connectionStatus(controller.connection.status),
      ),
      MetricSummary(
        label: 'Nodes',
        value: '${controller.instances.length}',
        caption: '${controller.instances.where((item) => item.mode == 'active').length} active',
        icon: Icons.developer_board_rounded,
      ),
      MetricSummary(
        label: 'Agents',
        value: '${controller.agents.length}',
        caption: controller.activeAgentName,
        icon: Icons.hub_rounded,
      ),
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(
                title: 'Modules',
                subtitle:
                    'Manage gateway, agents, nodes, skills, and platform services.',
                trailing: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '搜索',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await controller.refreshGatewayHealth();
                        await controller.refreshAgents();
                        await controller.refreshSessions();
                        await controller.instancesController.refresh();
                        await controller.skillsController.refresh(
                          agentId: controller.selectedAgentId.isEmpty
                              ? null
                              : controller.selectedAgentId,
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => controller.navigateTo(
                        WorkspaceDestination.settings,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('接入模块'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionTabs(
                items: const [
                  'Gateway',
                  'Nodes',
                  'Agents',
                  'Skills',
                  'ClawHub',
                  'Connectors',
                ],
                value: _tab,
                onChanged: (value) => setState(() => _tab = value),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth > 980
                      ? (constraints.maxWidth - 32) / 3
                      : constraints.maxWidth > 640
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: metrics
                        .map(
                          (metric) => SizedBox(
                            width: width,
                            child: MetricCard(metric: metric),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 28),
              switch (_tab) {
                'Gateway' => _GatewayPanel(
                  controller: controller,
                  onOpenDetail: widget.onOpenDetail,
                ),
                'Nodes' => _NodesPanel(
                  controller: controller,
                  onOpenDetail: widget.onOpenDetail,
                ),
                'Agents' => _AgentsPanel(
                  controller: controller,
                  onOpenDetail: widget.onOpenDetail,
                ),
                'Skills' => _SkillsPanel(
                  controller: controller,
                  onOpenDetail: widget.onOpenDetail,
                ),
                'ClawHub' => _FallbackHubPanel(onOpenDetail: widget.onOpenDetail),
                'Connectors' => _FallbackConnectorsPanel(
                  onOpenDetail: widget.onOpenDetail,
                ),
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        );
      },
    );
  }
}

class _GatewayPanel extends StatelessWidget {
  const _GatewayPanel({
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final connection = controller.connection;
    final metrics = [
      MetricSummary(
        label: 'Mode',
        value: controller.settings.gateway.mode.label,
        caption: controller.settings.gateway.useSetupCode
            ? 'Setup code'
            : 'Manual profile',
        icon: Icons.link_rounded,
      ),
      MetricSummary(
        label: 'Active Sessions',
        value: '${controller.sessions.length}',
        caption: 'Current key ${controller.currentSessionKey}',
        icon: Icons.chat_bubble_outline_rounded,
      ),
      MetricSummary(
        label: 'Today Runs',
        value: '${controller.tasksController.running.length + controller.tasksController.history.length}',
        caption: 'Derived from live session activity',
        icon: Icons.bolt_rounded,
      ),
      MetricSummary(
        label: 'Skills',
        value: '${controller.skills.length}',
        caption: 'Loaded from gateway',
        icon: Icons.extension_rounded,
      ),
    ];

    final statusPayload = connection.statusPayload ?? const <String, dynamic>{};
    final healthPayload = connection.healthPayload ?? const <String, dynamic>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 1180
                ? (constraints.maxWidth - 48) / 4
                : constraints.maxWidth > 860
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: metrics
                  .map(
                    (metric) => SizedBox(
                      width: width,
                      child: MetricCard(metric: metric),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          onTap: () => onOpenDetail(
            DetailPanelData(
              title: 'Gateway Overview',
              subtitle: 'Runtime',
              icon: Icons.wifi_tethering_rounded,
              status: _connectionStatus(connection.status),
              description:
                  'Live gateway control plane summary aligned with the macOS workspace shell.',
              meta: [
                connection.remoteAddress ?? 'No target',
                controller.activeAgentName,
              ],
              actions: const ['Refresh', 'Open Settings'],
              sections: [
                DetailSection(
                  title: 'Connection',
                  items: [
                    DetailItem(label: 'Status', value: connection.status.label),
                    DetailItem(
                      label: 'Address',
                      value: connection.remoteAddress ?? 'Offline',
                    ),
                    DetailItem(label: 'Mode', value: controller.settings.gateway.mode.label),
                    DetailItem(label: 'Agent', value: controller.activeAgentName),
                  ],
                ),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gateway', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                '${connection.status.label} · ${connection.remoteAddress ?? 'No target'} · ${controller.activeAgentName}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: controller.refreshGatewayHealth,
                    child: const Text('刷新状态'),
                  ),
                  OutlinedButton(
                    onPressed: controller.refreshSessions,
                    child: const Text('刷新会话'),
                  ),
                  OutlinedButton(
                    onPressed: () => controller.navigateTo(
                      WorkspaceDestination.settings,
                    ),
                    child: const Text('配置'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('状态摘要', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              _KeyValueLine(
                label: 'Health',
                value: healthPayload.isEmpty ? 'Unavailable' : encodePrettyJson(healthPayload),
              ),
              const SizedBox(height: 12),
              _KeyValueLine(
                label: 'Status',
                value: statusPayload.isEmpty ? 'Unavailable' : encodePrettyJson(statusPayload),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NodesPanel extends StatelessWidget {
  const _NodesPanel({
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final items = controller.instances;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Nodes',
          subtitle: 'Live system-presence data from the gateway runtime.',
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          SurfaceCard(
            child: Text(
              controller.connection.status == RuntimeConnectionStatus.connected
                  ? 'No live instances reported yet.'
                  : 'Connect a gateway to load instances / presence.',
            ),
          )
        else
          ...items.map(
            (node) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SurfaceCard(
                onTap: () => onOpenDetail(
                  DetailPanelData(
                    title: node.host ?? node.id,
                    subtitle: 'Instance',
                    icon: Icons.developer_board_rounded,
                    status: _instanceStatus(node),
                    description: node.text,
                    meta: [
                      node.platform ?? 'unknown',
                      node.deviceFamily ?? 'unknown',
                    ],
                    actions: const ['Refresh'],
                    sections: [
                      DetailSection(
                        title: 'Runtime',
                        items: [
                          DetailItem(label: 'IP', value: node.ip ?? 'n/a'),
                          DetailItem(label: 'Version', value: node.version ?? 'n/a'),
                          DetailItem(label: 'Mode', value: node.mode ?? 'n/a'),
                          DetailItem(
                            label: 'Last Input',
                            value: node.lastInputSeconds == null
                                ? 'n/a'
                                : '${node.lastInputSeconds}s',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.host ?? node.id,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${node.platform ?? 'unknown'} · ${node.deviceFamily ?? 'unknown'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: StatusBadge(status: _instanceStatus(node)),
                    ),
                    Expanded(flex: 2, child: Text(node.version ?? 'n/a')),
                    Expanded(flex: 2, child: Text(node.mode ?? 'n/a')),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AgentsPanel extends StatelessWidget {
  const _AgentsPanel({
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final items = controller.agents;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 1220
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth > 760
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        if (items.isEmpty) {
          return SurfaceCard(
            child: Text(
              controller.connection.status == RuntimeConnectionStatus.connected
                  ? 'No agents reported by the gateway.'
                  : 'Connect a gateway to load agents.',
            ),
          );
        }
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items
              .map(
                (agent) => SizedBox(
                  width: width,
                  child: SurfaceCard(
                    onTap: () => onOpenDetail(
                      DetailPanelData(
                        title: agent.name,
                        subtitle: 'Agent',
                        icon: Icons.hub_rounded,
                        status: controller.selectedAgentId == agent.id
                            ? const StatusInfo('Selected', StatusTone.accent)
                            : const StatusInfo('Available', StatusTone.success),
                        description: 'Gateway operator agent available for session routing.',
                        meta: [agent.id, agent.theme],
                        actions: const ['Select', 'Open Session'],
                        sections: [
                          DetailSection(
                            title: 'Identity',
                            items: [
                              DetailItem(label: 'Name', value: agent.name),
                              DetailItem(label: 'ID', value: agent.id),
                              DetailItem(label: 'Theme', value: agent.theme),
                            ],
                          ),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                agent.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            StatusBadge(
                              status: controller.selectedAgentId == agent.id
                                  ? const StatusInfo('Selected', StatusTone.accent)
                                  : const StatusInfo('Ready', StatusTone.success),
                              compact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('ID: ${agent.id}', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonal(
                              onPressed: () => controller.selectAgent(agent.id),
                              child: const Text('选择'),
                            ),
                            OutlinedButton(
                              onPressed: () => controller.refreshSessions(),
                              child: const Text('打开'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SkillsPanel extends StatelessWidget {
  const _SkillsPanel({
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final items = controller.skills;
    if (items.isEmpty) {
      return SurfaceCard(
        child: Text(
          controller.connection.status == RuntimeConnectionStatus.connected
              ? 'No skills loaded for the active gateway / agent.'
              : 'Connect a gateway to load skills.',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (skill) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SurfaceCard(
                onTap: () => onOpenDetail(
                  DetailPanelData(
                    title: skill.name,
                    subtitle: 'Skill',
                    icon: Icons.extension_rounded,
                    status: skill.disabled
                        ? const StatusInfo('Disabled', StatusTone.warning)
                        : const StatusInfo('Enabled', StatusTone.success),
                    description: skill.description,
                    meta: [skill.source, skill.skillKey],
                    actions: const ['Refresh'],
                    sections: [
                      DetailSection(
                        title: 'Requirements',
                        items: [
                          DetailItem(
                            label: 'Missing bins',
                            value: skill.missingBins.isEmpty
                                ? 'None'
                                : skill.missingBins.join(', '),
                          ),
                          DetailItem(
                            label: 'Missing env',
                            value: skill.missingEnv.isEmpty
                                ? 'None'
                                : skill.missingEnv.join(', '),
                          ),
                          DetailItem(
                            label: 'Missing config',
                            value: skill.missingConfig.isEmpty
                                ? 'None'
                                : skill.missingConfig.join(', '),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            skill.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: StatusBadge(
                        status: skill.disabled
                            ? const StatusInfo('Disabled', StatusTone.warning)
                            : const StatusInfo('Enabled', StatusTone.success),
                      ),
                    ),
                    Expanded(flex: 2, child: Text(skill.source)),
                    Expanded(
                      flex: 2,
                      child: Text(skill.primaryEnv ?? 'workspace'),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FallbackHubPanel extends StatelessWidget {
  const _FallbackHubPanel({required this.onOpenDetail});

  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: MockData.workspaceModules
          .map(
            (item) => SizedBox(
              width: 360,
              child: SurfaceCard(
                onTap: () => onOpenDetail(MockData.moduleDetail(item)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(item.description),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FallbackConnectorsPanel extends StatelessWidget {
  const _FallbackConnectorsPanel({required this.onOpenDetail});

  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 1220
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth > 760
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: MockData.connectors
              .map(
                (connector) => SizedBox(
                  width: width,
                  child: SurfaceCard(
                    onTap: () => onOpenDetail(
                      DetailPanelData(
                        title: connector.name,
                        subtitle: 'Connector',
                        icon: Icons.cable_rounded,
                        status: connector.status,
                        description: connector.description,
                        meta: [connector.lastSync, connector.permission],
                        actions: const ['Open', 'Refresh'],
                        sections: [
                          DetailSection(
                            title: 'Connector',
                            items: [
                              DetailItem(
                                label: 'Last Sync',
                                value: connector.lastSync,
                              ),
                              DetailItem(
                                label: 'Permission',
                                value: connector.permission,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                connector.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            StatusBadge(status: connector.status, compact: true),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(connector.description),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _KeyValueLine extends StatelessWidget {
  const _KeyValueLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

StatusInfo _connectionStatus(RuntimeConnectionStatus status) => switch (status) {
  RuntimeConnectionStatus.connected => const StatusInfo('Healthy', StatusTone.success),
  RuntimeConnectionStatus.connecting => const StatusInfo('Connecting', StatusTone.accent),
  RuntimeConnectionStatus.error => const StatusInfo('Error', StatusTone.danger),
  RuntimeConnectionStatus.offline => const StatusInfo('Offline', StatusTone.neutral),
};

StatusInfo _instanceStatus(GatewayInstanceSummary item) {
  final mode = (item.mode ?? '').toLowerCase();
  if (mode.contains('error') || mode.contains('warn')) {
    return const StatusInfo('Warning', StatusTone.warning);
  }
  if (mode.contains('active') || mode.contains('online')) {
    return const StatusInfo('Online', StatusTone.success);
  }
  return const StatusInfo('Seen', StatusTone.neutral);
}
