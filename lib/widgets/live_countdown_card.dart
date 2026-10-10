import 'package:flutter/material.dart';
import '../services/railway_service.dart';
import '../theme/app_theme.dart';

class LiveCountdownCard extends StatelessWidget {
  final RailwayService railwayService;
  final VoidCallback onSelectStation;
  final VoidCallback onSelectTrain;

  const LiveCountdownCard({
    super.key,
    required this.railwayService,
    required this.onSelectStation,
    required this.onSelectTrain,
  });

  @override
  Widget build(BuildContext context) {
    final train = railwayService.activeTrackedTrain;
    final boardingStation = railwayService.userBoardingStation;
    final countdown = railwayService.formattedCountdownToBoarding;
    final stop = train?.getStopForStation(boardingStation.code);
    final platform = stop?.platform ?? 2;
    final delay = train?.delayMinutes ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient graphic
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.train_rounded,
              size: 160,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Active Train & Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: onSelectTrain,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_railway_filled, size: 16, color: AppColors.accent),
                            const SizedBox(width: 6),
                            Text(
                              train != null ? '${train.trainNumber} • ${train.trainName}' : 'Select Train',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    // Live Pulse Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVE GPS',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Boarding Station Header
                Row(
                  children: [
                    const Icon(Icons.pin_drop_rounded, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Boarding Station:',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onSelectStation,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${boardingStation.name} (${boardingStation.code})',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.edit_location_alt_rounded, size: 14, color: AppColors.secondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Central Countdown Display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      countdown,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: delay > 0 ? AppColors.warning.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        delay > 0 ? '+${delay}m delay' : 'On-Time',
                        style: TextStyle(
                          color: delay > 0 ? AppColors.warning : AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  train?.currentLocationDescription ?? 'In transit',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 14),

                // Telemetry Badges: Platform, Speed, Next Halt
                Row(
                  children: [
                    _buildTelemetryBadge(
                      icon: Icons.meeting_room_rounded,
                      label: 'Platform',
                      value: 'PF $platform',
                      valueColor: AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    _buildTelemetryBadge(
                      icon: Icons.speed_rounded,
                      label: 'Current Speed',
                      value: '${train?.currentSpeedKmph ?? 0} km/h',
                      valueColor: AppColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    _buildTelemetryBadge(
                      icon: Icons.airline_seat_recline_extra_rounded,
                      label: 'Coach Guide',
                      value: 'B3 near FOB #2',
                      valueColor: AppColors.textPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
