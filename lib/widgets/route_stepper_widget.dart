import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../theme/app_theme.dart';

class RouteStepperWidget extends StatelessWidget {
  final Train train;
  final Station boardingStation;
  final ValueChanged<Station> onStationTap;

  const RouteStepperWidget({
    super.key,
    required this.train,
    required this.boardingStation,
    required this.onStationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Route Progress & Halts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${train.stops.length} stations • ${train.source.code} ➔ ${train.destination.code}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: train.stops.length,
          itemBuilder: (context, index) {
            final stop = train.stops[index];
            final isBoardingStation = stop.station.code.toUpperCase() == boardingStation.code.toUpperCase();
            final isCurrentTrainStop = index == train.currentStopIndex;
            final isPassed = index < train.currentStopIndex;
            final isLast = index == train.stops.length - 1;

            return InkWell(
              onTap: () => onStationTap(stop.station),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator (Dot & Line)
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          _buildDot(isPassed, isCurrentTrainStop, isBoardingStation),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 48,
                              color: isPassed
                                  ? AppColors.success.withOpacity(0.5)
                                  : AppColors.borderHighlight,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Station details card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isBoardingStation
                              ? AppColors.primary.withOpacity(0.15)
                              : (isCurrentTrainStop ? AppColors.surfaceLight : AppColors.surface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isBoardingStation
                                ? AppColors.secondary
                                : (isCurrentTrainStop ? AppColors.primaryLight : AppColors.border),
                            width: isBoardingStation ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  stop.station.name,
                                  style: TextStyle(
                                    fontWeight: isBoardingStation ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 14,
                                    color: isPassed ? AppColors.textMuted : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    stop.station.code,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isBoardingStation)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'BOARDING HERE',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (isCurrentTrainStop && !isBoardingStation)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'TRAIN HERE',
                                      style: TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Arr: ${stop.actualArrival} (PF ${stop.platform})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isBoardingStation ? AppColors.secondary : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${stop.distanceKm.toInt()} km',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDot(bool isPassed, bool isCurrent, bool isBoarding) {
    if (isCurrent) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.train, size: 10, color: Colors.white),
        ),
      );
    }
    if (isBoarding) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
    }
    if (isPassed) {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderHighlight, width: 1.5),
      ),
    );
  }
}
