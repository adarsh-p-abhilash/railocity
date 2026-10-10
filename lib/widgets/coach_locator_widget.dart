import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CoachLocatorWidget extends StatelessWidget {
  final List<String> coaches;
  final String highlightedCoach;
  final int platform;

  const CoachLocatorWidget({
    super.key,
    required this.coaches,
    this.highlightedCoach = 'B3',
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.view_column_rounded, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Text(
                    'Coach Layout & Position',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Platform $platform',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Locomotive direction is Left ➔ Right. Scroll horizontally to view the rake composition:',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          // Scrollable coach train
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: coaches.length,
              separatorBuilder: (context, i) => Container(
                width: 6,
                alignment: Alignment.center,
                child: Container(height: 2, color: AppColors.borderHighlight),
              ),
              itemBuilder: (context, index) {
                final coach = coaches[index];
                final isSelected = coach.toUpperCase() == highlightedCoach.toUpperCase();
                final isLoco = coach == 'LOCO' || coach == 'ENG';

                return Container(
                  width: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isLoco ? Colors.blueGrey.shade800 : AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : AppColors.borderHighlight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLoco ? Icons.electric_bolt_rounded : Icons.airline_seat_recline_normal_rounded,
                        size: 14,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coach,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Guide notice
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Coach $highlightedCoach will halt near middle FOB escalator. Overhead indicator display #$highlightedCoach is active.',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
