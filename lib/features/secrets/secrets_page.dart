import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../models/app_models.dart';
import '../../runtime/runtime_models.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/section_tabs.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/surface_card.dart';
import '../../widgets/top_bar.dart';

class SecretsPage extends StatefulWidget {
  const SecretsPage({
    super.key,
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  State<SecretsPage> createState() => _SecretsPageState();
}

class _SecretsPageState extends State<SecretsPage> {
  String _tab = 'Vault';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(
                title: 'Secrets',
                subtitle:
                    'Manage secret providers, credentials, and secure references across modules.',
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
                        await controller.testVaultConnection();
                        await controller.settingsController.initialize();
                      },
                      icon: const Icon(Icons.sync_rounded),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => controller.navigateTo(
                        WorkspaceDestination.settings,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Secret'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionTabs(
                items: const ['Vault', 'Local Store', 'Providers', 'Audit'],
                value: _tab,
                onChanged: (value) => setState(() => _tab = value),
              ),
              const SizedBox(height: 24),
              switch (_tab) {
                'Vault' => _VaultPanel(
                  controller: controller,
                  onOpenDetail: widget.onOpenDetail,
                ),
                'Local Store' => _LocalStorePanel(
                  controller: controller,
                  onOpenDetail: widget.onOpenDetail,
                ),
                'Providers' => _ProvidersPanel(
                  controller: controller,
                  onOpenDetail: widget.onOpenDetail,
                ),
                'Audit' => _AuditPanel(
                  controller: controller,
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

class _VaultPanel extends StatelessWidget {
  const _VaultPanel({
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final vault = controller.settings.vault;
    final metrics = [
      MetricSummary(
        label: 'Provider',
        value: 'Vault',
        caption: controller.settingsController.vaultStatus,
        icon: Icons.key_rounded,
        status: _statusForString(controller.settingsController.vaultStatus),
      ),
      MetricSummary(
        label: 'Token Ref',
        value: vault.tokenRef,
        caption: 'Stored via secure refs',
        icon: Icons.lock_rounded,
      ),
      MetricSummary(
        label: 'Secret Refs',
        value: '${controller.secretReferences.where((item) => item.provider == 'Vault').length}',
        caption: 'Referenced by modules',
        icon: Icons.link_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 20),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vault Server', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Address: ${vault.address}\nNamespace: ${vault.namespace}\nAuth mode: ${vault.authMode}\nToken ref: ${vault.tokenRef}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: controller.testVaultConnection,
                    child: const Text('连接测试'),
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
        SectionHeader(
          title: '引用列表',
          subtitle: '只展示 masked reference，不暴露真实 secret value。',
        ),
        const SizedBox(height: 14),
        _SecretRefsTable(
          entries: controller.secretReferences
              .where((item) => item.provider == 'Vault')
              .toList(growable: false),
          onOpenDetail: onOpenDetail,
        ),
      ],
    );
  }
}

class _LocalStorePanel extends StatelessWidget {
  const _LocalStorePanel({
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final refs = controller.secretReferences;
    final metrics = [
      MetricSummary(
        label: 'Local Store',
        value: 'Enabled',
        caption: 'flutter_secure_storage + shared prefs',
        icon: Icons.lock_rounded,
      ),
      MetricSummary(
        label: 'Entries',
        value: '${refs.length}',
        caption: 'masked secret references',
        icon: Icons.key_rounded,
      ),
      MetricSummary(
        label: 'Last Audit',
        value: controller.secretAuditTrail.isEmpty
            ? 'None'
            : controller.secretAuditTrail.first.timeLabel,
        caption: '最近一次安全操作',
        icon: Icons.schedule_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 20),
        _SecretRefsTable(entries: refs, onOpenDetail: onOpenDetail),
      ],
    );
  }
}

class _ProvidersPanel extends StatelessWidget {
  const _ProvidersPanel({
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final providers = [
      _ProviderCardData(
        name: 'HashiCorp Vault',
        description: 'Namespace-aware Vault integration with token refs.',
        status: _statusForString(controller.settingsController.vaultStatus),
        capabilities: ['KV', 'Namespace', 'Health'],
      ),
      const _ProviderCardData(
        name: 'Environment Variables',
        description: 'Read-only secure provider for local bridge tools.',
        status: StatusInfo('Available', StatusTone.neutral),
        capabilities: ['Read env', 'Mask refs'],
      ),
      const _ProviderCardData(
        name: 'Local Store',
        description: 'OS-backed secure storage for local secrets and tokens.',
        status: StatusInfo('Enabled', StatusTone.success),
        capabilities: ['Local refs', 'Masking'],
      ),
      const _ProviderCardData(
        name: 'External Secret Manager',
        description: 'Reserved adapter surface for external secret services.',
        status: StatusInfo('Preview', StatusTone.accent),
        capabilities: ['Reserved', 'Extensible'],
      ),
    ];

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
          children: providers
              .map(
                (provider) => SizedBox(
                  width: width,
                  child: SurfaceCard(
                    onTap: () => onOpenDetail(
                      DetailPanelData(
                        title: provider.name,
                        subtitle: 'Secret Provider',
                        icon: Icons.key_rounded,
                        status: provider.status,
                        description: provider.description,
                        meta: provider.capabilities,
                        actions: const ['Connect', 'Configure'],
                        sections: [
                          DetailSection(
                            title: 'Capabilities',
                            items: provider.capabilities
                                .map(
                                  (item) => DetailItem(
                                    label: 'Capability',
                                    value: item,
                                  ),
                                )
                                .toList(),
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
                                provider.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            StatusBadge(status: provider.status, compact: true),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(provider.description),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.capabilities
                              .map((item) => Chip(label: Text(item)))
                              .toList(),
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

class _AuditPanel extends StatelessWidget {
  const _AuditPanel({
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final items = controller.secretAuditTrail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '搜索审计',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            OutlinedButton(onPressed: () {}, child: const Text('状态过滤')),
            OutlinedButton(onPressed: () {}, child: const Text('时间过滤')),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          SurfaceCard(
            child: Text(
              '还没有安全审计条目。保存 Gateway / Vault / Ollama secret 时会在这里出现记录。',
            ),
          )
        else
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: items.map((entry) {
                return InkWell(
                  onTap: () => onOpenDetail(
                    DetailPanelData(
                      title: entry.action,
                      subtitle: 'Audit Entry',
                      icon: Icons.policy_outlined,
                      status: _statusForString(entry.status),
                      description: '${entry.provider} · ${entry.target}',
                      meta: [entry.timeLabel, entry.module],
                      actions: const ['View'],
                      sections: [
                        DetailSection(
                          title: 'Audit',
                          items: [
                            DetailItem(label: 'Provider', value: entry.provider),
                            DetailItem(label: 'Target', value: entry.target),
                            DetailItem(label: 'Module', value: entry.module),
                            DetailItem(label: 'Status', value: entry.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(entry.timeLabel)),
                        Expanded(flex: 2, child: Text(entry.action)),
                        Expanded(flex: 2, child: Text(entry.provider)),
                        Expanded(flex: 2, child: Text(entry.target)),
                        Expanded(flex: 2, child: Text(entry.module)),
                        StatusBadge(
                          status: _statusForString(entry.status),
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _SecretRefsTable extends StatelessWidget {
  const _SecretRefsTable({
    required this.entries,
    required this.onOpenDetail,
  });

  final List<SecretReferenceEntry> entries;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SurfaceCard(
        child: Text('No secret references available yet.'),
      );
    }
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: entries.map((reference) {
          return InkWell(
            onTap: () => onOpenDetail(
              DetailPanelData(
                title: reference.name,
                subtitle: 'Secret Reference',
                icon: Icons.key_rounded,
                status: _statusForString(reference.status),
                description: reference.maskedValue,
                meta: [reference.provider, reference.module],
                actions: const ['Reveal Ref', 'Open Settings'],
                sections: [
                  DetailSection(
                    title: 'Reference',
                    items: [
                      DetailItem(label: 'Provider', value: reference.provider),
                      DetailItem(label: 'Module', value: reference.module),
                      DetailItem(label: 'Masked value', value: reference.maskedValue),
                      DetailItem(label: 'Status', value: reference.status),
                    ],
                  ),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      reference.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Expanded(flex: 2, child: Text(reference.provider)),
                  Expanded(flex: 2, child: Text(reference.module)),
                  Expanded(flex: 2, child: Text(reference.maskedValue)),
                  StatusBadge(status: _statusForString(reference.status), compact: true),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProviderCardData {
  const _ProviderCardData({
    required this.name,
    required this.description,
    required this.status,
    required this.capabilities,
  });

  final String name;
  final String description;
  final StatusInfo status;
  final List<String> capabilities;
}

StatusInfo _statusForString(String raw) {
  final value = raw.trim().toLowerCase();
  if (value.contains('connected') || value.contains('enabled') || value.contains('success')) {
    return const StatusInfo('Connected', StatusTone.success);
  }
  if (value.contains('fail') || value.contains('error')) {
    return const StatusInfo('Error', StatusTone.danger);
  }
  if (value.contains('preview') || value.contains('reachable')) {
    return const StatusInfo('Preview', StatusTone.accent);
  }
  return const StatusInfo('Idle', StatusTone.neutral);
}
