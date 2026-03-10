import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_palette.dart';
import 'status_badge.dart';
import 'surface_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.metric});

  final MetricSummary metric;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.accentMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(metric.icon, color: palette.accent, size: 20),
              ),
              const Spacer(),
              if (metric.status != null)
                StatusBadge(status: metric.status!, compact: true),
            ],
          ),
          const SizedBox(height: 18),
          Text(metric.label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(metric.value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(metric.caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
