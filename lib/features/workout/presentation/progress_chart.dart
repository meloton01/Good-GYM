import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/formatting/measurement_format.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/progress_point.dart';
import 'progress_metric.dart';
import 'workout_format.dart';

/// Линейный график показателя по тренировкам; цвета и размеры из токенов темы.
class ProgressChart extends StatelessWidget {
  /// Создаёт график точек [points] по показателю [metric].
  const ProgressChart({
    super.key,
    required this.points,
    required this.metric,
    required this.format,
  });

  /// Сколько подписей дат помещается под осью.
  static const int _dateLabels = 4;

  final List<ProgressPoint> points;
  final ProgressMetric metric;
  final WorkoutFormat format;

  /// Строит график с подписью для скринридера.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final sizes = context.sizes;
    final textScaler = MediaQuery.textScalerOf(context);
    final labelStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: colors.textSecondary);
    final spots = [
      for (var index = 0; index < points.length; index++)
        if (metric.valueOf(points[index].best) case final value?)
          FlSpot(index.toDouble(), _display(value)),
    ];
    final step = max(1, (points.length / _dateLabels).ceil()).toDouble();
    final line = BorderSide(color: colors.border);
    return Semantics(
      label: l10n.progressChartLabel(
        metric.label(l10n),
        spots.isEmpty ? '' : _label(spots.last.y),
      ),
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: sizes.chartAspectRatio,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: max(1, points.length - 1).toDouble(),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: colors.border),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(bottom: line, left: line),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: textScaler.scale(sizes.chartAxisReserved),
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(_label(value), style: labelStyle),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: step,
                    reservedSize: textScaler.scale(sizes.chartAxisReserved),
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      final visible =
                          index == value && index >= 0 && index < points.length;
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          visible ? format.shortDate(points[index].date) : '',
                          style: labelStyle,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: colors.accentContent,
                  barWidth: sizes.chartLineWidth,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: sizes.chartDotRadius,
                          color: colors.accentContent,
                        ),
                  ),
                ),
              ],
            ),
            duration: Duration.zero,
          ),
        ),
      ),
    );
  }

  /// Значение для оси: вес в единицах пользователя, повторы как есть.
  double _display(double value) =>
      metric.isWeight ? format.unit.fromKilograms(value) : value;

  /// Подпись значения оси в формате локали.
  String _label(double value) => MeasurementFormat.format(value, format.locale);
}
