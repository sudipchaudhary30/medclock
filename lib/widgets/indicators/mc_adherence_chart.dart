import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McAdherenceChart extends StatelessWidget {
  final List<double> values;
  final List<String> days;

  const McAdherenceChart({
    super.key,
    required this.values,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    // A clean CustomPaint bar chart to avoid dependency compile errors in early tests.
    // The user can customize this visually, but it provides a clean, premium bar chart representation.
    return AspectRatio(
      aspectRatio: 1.7,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Adherence', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (index) {
                  final val = values[index];
                  final day = days[index];
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: FractionallySizedBox(
                            heightFactor: val.clamp(0.0, 1.0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: val >= 0.8 ? AppTheme.successColor : AppTheme.warningColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(day, style: AppTheme.caption),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
