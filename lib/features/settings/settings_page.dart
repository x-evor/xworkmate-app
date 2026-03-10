import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_metadata.dart';
import '../../runtime/runtime_controllers.dart';
import '../../runtime/runtime_models.dart';
import '../../widgets/gateway_connect_dialog.dart';
import '../../widgets/section_tabs.dart';
import '../../widgets/surface_card.dart';
import '../../widgets/top_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.controller,
  });

  final AppController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _tab = 'General';
  late final TextEditingController _apisixYamlController;
  late final TextEditingController _vaultTokenController;
  late final TextEditingController _ollamaApiKeyController;

  @override
  void initState() {
    super.initState();
    _apisixYamlController = TextEditingController(
      text: widget.controller.settings.apisix.inlineYaml,
    );
    _vaultTokenController = TextEditingController();
    _ollamaApiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _apisixYamlController.dispose();
    _vaultTokenController.dispose();
    _ollamaApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final settings = controller.settings;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(
                title: 'Settings',
                subtitle: '配置 $kProductBrandName 工作区、网关默认项、界面与诊断选项',
                trailing: SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: '搜索',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SectionTabs(
                items: const [
                  'General',
                  'Workspace',
                  'Gateway',
                  'Appearance',
                  'Diagnostics',
                  'Experimental',
                  'About',
                ],
                value: _tab,
                onChanged: (value) => setState(() => _tab = value),
              ),
              const SizedBox(height: 24),
              ...switch (_tab) {
                'General' => _buildGeneral(context, controller, settings),
                'Workspace' => _buildWorkspace(context, controller, settings),
                'Gateway' => _buildGateway(context, controller, settings),
                'Appearance' => _buildAppearance(context, controller),
                'Diagnostics' => _buildDiagnostics(context, controller),
                'Experimental' => _buildExperimental(context, controller, settings),
                'About' => _buildAbout(context, controller),
                _ => const <Widget>[],
              },
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildGeneral(
    BuildContext context,
    AppController controller,
    SettingsSnapshot settings,
  ) {
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Application', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _SwitchRow(
              label: 'Active workspace shell',
              value: settings.appActive,
              onChanged: (value) => _saveSettings(
                controller,
                settings.copyWith(appActive: value),
              ),
            ),
            _SwitchRow(
              label: 'Launch at login',
              value: settings.launchAtLogin,
              onChanged: (value) => _saveSettings(
                controller,
                settings.copyWith(launchAtLogin: value),
              ),
            ),
            _SwitchRow(
              label: 'Show dock icon',
              value: settings.showDockIcon,
              onChanged: (value) => _saveSettings(
                controller,
                settings.copyWith(showDockIcon: value),
              ),
            ),
            _SwitchRow(
              label: 'Account local mode',
              value: settings.accountLocalMode,
              onChanged: (value) => _saveSettings(
                controller,
                settings.copyWith(accountLocalMode: value),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Access', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _EditableField(
              label: 'Account Base URL',
              value: settings.accountBaseUrl,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(accountBaseUrl: value),
              ),
            ),
            _EditableField(
              label: 'Account Username',
              value: settings.accountUsername,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(accountUsername: value),
              ),
            ),
            _EditableField(
              label: 'Workspace Label',
              value: settings.accountWorkspace,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(accountWorkspace: value),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildWorkspace(
    BuildContext context,
    AppController controller,
    SettingsSnapshot settings,
  ) {
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workspace', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _EditableField(
              label: 'Workspace Path',
              value: settings.workspacePath,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(workspacePath: value),
              ),
            ),
            _EditableField(
              label: 'Remote Project Root',
              value: settings.remoteProjectRoot,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(remoteProjectRoot: value),
              ),
            ),
            _EditableField(
              label: 'CLI Path',
              value: settings.cliPath,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(cliPath: value),
              ),
            ),
            _EditableField(
              label: 'Default Model',
              value: settings.defaultModel,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(defaultModel: value),
              ),
            ),
            _EditableField(
              label: 'Default Provider',
              value: settings.defaultProvider,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(defaultProvider: value),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ollama Local', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _EditableField(
              label: 'Endpoint',
              value: settings.ollamaLocal.endpoint,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(
                  ollamaLocal: settings.ollamaLocal.copyWith(endpoint: value),
                ),
              ),
            ),
            _EditableField(
              label: 'Default Model',
              value: settings.ollamaLocal.defaultModel,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(
                  ollamaLocal: settings.ollamaLocal.copyWith(defaultModel: value),
                ),
              ),
            ),
            _SwitchRow(
              label: 'Auto Discover',
              value: settings.ollamaLocal.autoDiscover,
              onChanged: (value) => _saveSettings(
                controller,
                settings.copyWith(
                  ollamaLocal: settings.ollamaLocal.copyWith(autoDiscover: value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () => controller.testOllamaConnection(cloud: false),
                child: Text('Test Connection · ${controller.settingsController.ollamaStatus}'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ollama Cloud', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _EditableField(
              label: 'Base URL',
              value: settings.ollamaCloud.baseUrl,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(
                  ollamaCloud: settings.ollamaCloud.copyWith(baseUrl: value),
                ),
              ),
            ),
            _EditableField(
              label: 'Workspace / Org',
              value:
                  '${settings.ollamaCloud.organization} / ${settings.ollamaCloud.workspace}',
              onSubmitted: (value) {
                final parts = value.split('/');
                _saveSettings(
                  controller,
                  settings.copyWith(
                    ollamaCloud: settings.ollamaCloud.copyWith(
                      organization: parts.isNotEmpty ? parts.first.trim() : '',
                      workspace: parts.length > 1 ? parts[1].trim() : '',
                    ),
                  ),
                );
              },
            ),
            _EditableField(
              label: 'Default Model',
              value: settings.ollamaCloud.defaultModel,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(
                  ollamaCloud: settings.ollamaCloud.copyWith(defaultModel: value),
                ),
              ),
            ),
            TextField(
              controller: _ollamaApiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'API Key (${settings.ollamaCloud.apiKeyRef})',
              ),
              onSubmitted: controller.settingsController.saveOllamaCloudApiKey,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () => controller.testOllamaConnection(cloud: true),
                child: Text('Test Cloud · ${controller.settingsController.ollamaStatus}'),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildGateway(
    BuildContext context,
    AppController controller,
    SettingsSnapshot settings,
  ) {
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gateway Connection', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              '${controller.connection.status.label} · ${controller.connection.remoteAddress ?? settings.gateway.host}:${settings.gateway.port}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonal(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => GatewayConnectDialog(
                      controller: controller,
                      onDone: () => Navigator.of(context).pop(),
                    ),
                  ),
                  child: const Text('Open Connect Panel'),
                ),
                OutlinedButton(
                  onPressed: controller.refreshGatewayHealth,
                  child: const Text('Refresh Health'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: controller.selectedAgentId.isEmpty
                  ? ''
                  : controller.selectedAgentId,
              decoration: const InputDecoration(labelText: 'Selected Agent'),
              items: [
                const DropdownMenuItem<String>(value: '', child: Text('Main')),
                ...controller.agents.map(
                  (agent) => DropdownMenuItem<String>(
                    value: agent.id,
                    child: Text(agent.name),
                  ),
                ),
              ],
              onChanged: controller.selectAgent,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vault Server', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _EditableField(
              label: 'Address',
              value: settings.vault.address,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(vault: settings.vault.copyWith(address: value)),
              ),
            ),
            _EditableField(
              label: 'Namespace',
              value: settings.vault.namespace,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(
                  vault: settings.vault.copyWith(namespace: value),
                ),
              ),
            ),
            _EditableField(
              label: 'Auth Mode',
              value: settings.vault.authMode,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(vault: settings.vault.copyWith(authMode: value)),
              ),
            ),
            _EditableField(
              label: 'Token Ref',
              value: settings.vault.tokenRef,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(vault: settings.vault.copyWith(tokenRef: value)),
              ),
            ),
            TextField(
              controller: _vaultTokenController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Vault Token (${settings.vault.tokenRef})',
              ),
              onSubmitted: controller.settingsController.saveVaultToken,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: controller.testVaultConnection,
                child: Text('Test Vault · ${controller.settingsController.vaultStatus}'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('APISIX YAML', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _EditableField(
              label: 'Profile Name',
              value: settings.apisix.name,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(apisix: settings.apisix.copyWith(name: value)),
              ),
            ),
            _EditableField(
              label: 'Source Type',
              value: settings.apisix.sourceType,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(
                  apisix: settings.apisix.copyWith(sourceType: value),
                ),
              ),
            ),
            _EditableField(
              label: 'File Path',
              value: settings.apisix.filePath,
              onSubmitted: (value) => _saveSettings(
                controller,
                settings.copyWith(apisix: settings.apisix.copyWith(filePath: value)),
              ),
            ),
            TextField(
              controller: _apisixYamlController,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Inline YAML',
                hintText: 'Paste APISIX route / upstream YAML for validation',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonal(
                  onPressed: () => _saveSettings(
                    controller,
                    settings.copyWith(
                      apisix: settings.apisix.copyWith(
                        inlineYaml: _apisixYamlController.text,
                      ),
                    ),
                  ),
                  child: const Text('Save Draft'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final updated = settings.apisix.copyWith(
                      inlineYaml: _apisixYamlController.text,
                    );
                    final result = await controller.validateApisixYaml(updated);
                    if (!mounted) {
                      return;
                    }
                    messenger.showSnackBar(SnackBar(content: Text(result.validationMessage)));
                  },
                  child: Text(
                    'Validate · ${settings.apisix.validationState}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              settings.apisix.validationMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildAppearance(
    BuildContext context,
    AppController controller,
  ) {
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ChoiceChip(
                  label: const Text('Light'),
                  selected: controller.themeMode == ThemeMode.light,
                  onSelected: (_) => controller.setThemeMode(ThemeMode.light),
                ),
                ChoiceChip(
                  label: const Text('Dark'),
                  selected: controller.themeMode == ThemeMode.dark,
                  onSelected: (_) => controller.setThemeMode(ThemeMode.dark),
                ),
                ChoiceChip(
                  label: const Text('System'),
                  selected: controller.themeMode == ThemeMode.system,
                  onSelected: (_) => controller.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildDiagnostics(
    BuildContext context,
    AppController controller,
  ) {
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gateway Diagnostics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InfoRow(label: 'Connection', value: controller.connection.status.label),
            _InfoRow(
              label: 'Address',
              value: controller.connection.remoteAddress ?? 'Offline',
            ),
            _InfoRow(label: 'Agent', value: controller.activeAgentName),
            _InfoRow(
              label: 'Health Payload',
              value: controller.connection.healthPayload == null
                  ? 'Unavailable'
                  : encodePrettyJson(controller.connection.healthPayload!),
            ),
            _InfoRow(
              label: 'Status Payload',
              value: controller.connection.statusPayload == null
                  ? 'Unavailable'
                  : encodePrettyJson(controller.connection.statusPayload!),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InfoRow(label: 'Platform', value: controller.runtime.deviceInfo.platformLabel),
            _InfoRow(label: 'Device Family', value: controller.runtime.deviceInfo.deviceFamily),
            _InfoRow(
              label: 'Model Identifier',
              value: controller.runtime.deviceInfo.modelIdentifier,
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildExperimental(
    BuildContext context,
    AppController controller,
    SettingsSnapshot settings,
  ) {
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Experimental', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _SwitchRow(
              label: 'Canvas host',
              value: settings.experimentalCanvas,
              onChanged: (value) => _saveSettings(
                controller,
                settings.copyWith(experimentalCanvas: value),
              ),
            ),
            _SwitchRow(
              label: 'Bridge mode',
              value: settings.experimentalBridge,
              onChanged: (value) => _saveSettings(
                controller,
                settings.copyWith(experimentalBridge: value),
              ),
            ),
            _SwitchRow(
              label: 'Debug runtime',
              value: settings.experimentalDebug,
              onChanged: (value) => _saveSettings(
                controller,
                settings.copyWith(experimentalDebug: value),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildAbout(
    BuildContext context,
    AppController controller,
  ) {
    return [
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InfoRow(label: 'App', value: kSystemAppName),
            _InfoRow(label: 'Version', value: controller.runtime.packageInfo.version),
            _InfoRow(label: 'Build', value: controller.runtime.packageInfo.buildNumber),
            _InfoRow(label: 'Package', value: controller.runtime.packageInfo.packageName),
          ],
        ),
      ),
    ];
  }

  Future<void> _saveSettings(
    AppController controller,
    SettingsSnapshot snapshot,
  ) {
    return controller.saveSettings(snapshot);
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.value,
    required this.onSubmitted,
  });

  final String label;
  final String value;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        key: ValueKey('$label:$value'),
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        onFieldSubmitted: onSubmitted,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(width: 16),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
