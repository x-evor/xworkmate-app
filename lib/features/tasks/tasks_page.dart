import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../models/app_models.dart';
import '../../runtime/runtime_models.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/section_tabs.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/surface_card.dart';
import '../../widgets/top_bar.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({
    super.key,
    required this.controller,
    required this.onOpenDetail,
  });

  final AppController controller;
  final ValueChanged<DetailPanelData> onOpenDetail;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _tab = 'Queue';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final items = controller.taskItemsForTab(_tab);
    final metrics = [
      MetricSummary(
        label: 'Total',
        value: '${controller.tasksController.totalCount}',
        caption: '从 sessions / chat 派生',
        icon: Icons.layers_rounded,
      ),
      MetricSummary(
        label: 'Running',
        value: '${controller.tasksController.running.length}',
        caption: '当前活跃 run',
        icon: Icons.play_circle_outline_rounded,
        status: _statusInfoForTask('Running'),
      ),
      MetricSummary(
        label: 'Failed',
        value: '${controller.tasksController.failed.length}',
        caption: 'aborted / error run',
        icon: Icons.error_outline_rounded,
        status: _statusInfoForTask('Failed'),
      ),
      MetricSummary(
        label: 'Scheduled',
        value: '${controller.tasksController.scheduled.length}',
        caption: '等待自动化管理包接入',
        icon: Icons.event_repeat_rounded,
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
                title: 'Tasks',
                subtitle: '查看任务队列、执行状态与历史记录',
                trailing: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                      onPressed: controller.refreshSessions,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => controller.navigateTo(
                        WorkspaceDestination.assistant,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('新建'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionTabs(
                items: const ['Queue', 'Running', 'History', 'Failed', 'Scheduled'],
                value: _tab,
                onChanged: (value) => setState(() => _tab = value),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth > 980
                      ? (constraints.maxWidth - 48) / 4
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
              const SizedBox(height: 24),
              if (_tab == 'Scheduled' && items.isEmpty)
                SurfaceCard(
                  child: Text(
                    'Scheduled 任务将在自动化管理包接入后展示。本轮只显示来自 Gateway sessions / chat 的派生任务。',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              else if (items.isEmpty)
                SurfaceCard(
                  child: Text(
                    controller.connection.status == RuntimeConnectionStatus.connected
                        ? '当前 tab 暂无任务。'
                        : '连接 Gateway 后，这里会显示真实的 queue / running / history / failed 视图。',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              else
                ...items.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SurfaceCard(
                      onTap: () => widget.onOpenDetail(_taskDetail(task)),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 820) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  task.summary,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    StatusBadge(
                                      status: _statusInfoForTask(task.status),
                                    ),
                                    Text(task.owner),
                                    Text(task.startedAtLabel),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      task.summary,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: StatusBadge(
                                    status: _statusInfoForTask(task.status),
                                  ),
                                ),
                              ),
                              Expanded(flex: 2, child: Text(task.owner)),
                              Expanded(flex: 2, child: Text(task.startedAtLabel)),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '点击任务项后弹出 Detail Drawer',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DetailPanelData _taskDetail(DerivedTaskItem task) {
    return DetailPanelData(
      title: task.title,
      subtitle: 'Session-derived Task',
      icon: Icons.layers_rounded,
      status: _statusInfoForTask(task.status),
      description: task.summary,
      meta: [task.surface, task.sessionKey],
      actions: const ['Open Session', 'Refresh'],
      sections: [
        DetailSection(
          title: 'Task',
          items: [
            DetailItem(label: 'Owner', value: task.owner),
            DetailItem(label: 'Status', value: task.status),
            DetailItem(label: 'Started', value: task.startedAtLabel),
            DetailItem(label: 'Updated', value: task.durationLabel),
            DetailItem(label: 'Session Key', value: task.sessionKey),
          ],
        ),
      ],
    );
  }
}

StatusInfo _statusInfoForTask(String status) => switch (status) {
  'Running' => const StatusInfo('Running', StatusTone.accent),
  'Failed' => const StatusInfo('Failed', StatusTone.danger),
  'Queued' => const StatusInfo('Queued', StatusTone.neutral),
  'Scheduled' => const StatusInfo('Scheduled', StatusTone.accent),
  _ => const StatusInfo('Completed', StatusTone.success),
};
