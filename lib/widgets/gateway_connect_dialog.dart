import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../runtime/runtime_models.dart';
import 'section_tabs.dart';

class GatewayConnectDialog extends StatefulWidget {
  const GatewayConnectDialog({
    super.key,
    required this.controller,
    this.compact = false,
    this.onDone,
  });

  final AppController controller;
  final bool compact;
  final VoidCallback? onDone;

  @override
  State<GatewayConnectDialog> createState() => _GatewayConnectDialogState();
}

class _GatewayConnectDialogState extends State<GatewayConnectDialog> {
  late final TextEditingController _setupCodeController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _mode = 'Setup Code';
  bool _tls = true;
  RuntimeConnectionMode _connectionMode = RuntimeConnectionMode.remote;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.settings.gateway;
    _setupCodeController = TextEditingController(text: profile.setupCode);
    _hostController = TextEditingController(text: profile.host);
    _portController = TextEditingController(text: '${profile.port}');
    _tls = profile.tls;
    _connectionMode = profile.mode;
    _mode = profile.useSetupCode ? 'Setup Code' : 'Manual';
  }

  @override
  void dispose() {
    _setupCodeController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Gateway Access', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Connect XWorkmate to an OpenClaw gateway with setup code or manual host / TLS.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          SectionTabs(
            items: const ['Setup Code', 'Manual'],
            value: _mode,
            size: SectionTabsSize.small,
            onChanged: (value) => setState(() => _mode = value),
          ),
          const SizedBox(height: 18),
          _StatusBanner(controller: widget.controller),
          const SizedBox(height: 18),
          if (_mode == 'Setup Code') ...[
            TextField(
              controller: _setupCodeController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Setup Code',
                hintText: 'Paste gateway setup code or JSON payload',
              ),
            ),
          ] else ...[
            DropdownButtonFormField<RuntimeConnectionMode>(
              initialValue: _connectionMode,
              decoration: const InputDecoration(labelText: 'Connection Mode'),
              items: RuntimeConnectionMode.values
                  .map(
                    (mode) => DropdownMenuItem<RuntimeConnectionMode>(
                      value: mode,
                      child: Text(mode.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _connectionMode = value;
                  if (value == RuntimeConnectionMode.local) {
                    _hostController.text = '127.0.0.1';
                    _portController.text = '18789';
                    _tls = false;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(labelText: 'Host'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Port'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _tls,
                    title: const Text('TLS'),
                    onChanged: _connectionMode == RuntimeConnectionMode.local
                        ? null
                        : (value) => setState(() => _tls = value),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          TextField(
            controller: _tokenController,
            decoration: const InputDecoration(
              labelText: 'Shared Token',
              hintText: 'Optional override for gateway token',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Optional shared password',
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              if (widget.controller.connection.status ==
                  RuntimeConnectionStatus.connected)
                OutlinedButton.icon(
                  onPressed: _submitting
                      ? null
                      : () async {
                          setState(() => _submitting = true);
                          await widget.controller.disconnectGateway();
                          if (mounted) {
                            setState(() => _submitting = false);
                          }
                        },
                  icon: const Icon(Icons.link_off_rounded),
                  label: const Text('Disconnect'),
                ),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: const Icon(Icons.wifi_tethering_rounded),
                label: Text(_submitting ? 'Connecting…' : 'Connect'),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.compact) {
      return body;
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: body,
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      if (_mode == 'Setup Code') {
        await widget.controller.connectWithSetupCode(
          setupCode: _setupCodeController.text,
          token: _tokenController.text,
          password: _passwordController.text,
        );
      } else {
        await widget.controller.connectManual(
          host: _hostController.text,
          port: int.tryParse(_portController.text.trim()) ?? 0,
          tls: _tls,
          mode: _connectionMode,
          token: _tokenController.text,
          password: _passwordController.text,
        );
      }
      widget.onDone?.call();
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connection = controller.connection;
    final tone = switch (connection.status) {
      RuntimeConnectionStatus.connected => theme.colorScheme.primaryContainer,
      RuntimeConnectionStatus.error => theme.colorScheme.errorContainer,
      RuntimeConnectionStatus.connecting => theme.colorScheme.secondaryContainer,
      RuntimeConnectionStatus.offline => theme.colorScheme.surfaceContainerHighest,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            connection.status.label,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            connection.remoteAddress ?? 'No active gateway target',
            style: theme.textTheme.bodyMedium,
          ),
          if ((connection.lastError ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(connection.lastError!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
