import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../services/railway_service.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/live_countdown_card.dart';
import '../widgets/coach_locator_widget.dart';
import '../widgets/route_stepper_widget.dart';

class LiveTrackerScreen extends StatefulWidget {
  final RailwayService railwayService;
  final BookingService bookingService;
  final VoidCallback onNavigateToAI;

  const LiveTrackerScreen({
    super.key,
    required this.railwayService,
    required this.bookingService,
    required this.onNavigateToAI,
  });

  @override
  State<LiveTrackerScreen> createState() => _LiveTrackerScreenState();
}

class _LiveTrackerScreenState extends State<LiveTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.railwayService, widget.bookingService]),
      builder: (context, _) {
        final train = widget.railwayService.activeTrackedTrain;
        final boardingStation = widget.railwayService.userBoardingStation;
        final nextBooking = widget.bookingService.nextUpcomingBooking;
        final stop = train?.getStopForStation(boardingStation.code);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.radar_rounded, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Railocity Companion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'Live Boarding & ETA Tracker',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Ask Railo AI',
                icon: const Icon(Icons.auto_awesome, color: AppColors.accent),
                onPressed: widget.onNavigateToAI,
              ),
              IconButton(
                tooltip: 'Select Boarding Station',
                icon: const Icon(Icons.location_on_outlined, color: AppColors.textPrimary),
                onPressed: _showStationPickerSheet,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Next Upcoming Train Quick Banner (if any booking)
                if (nextBooking != null)
                  _buildNextBookingBanner(nextBooking),

                const SizedBox(height: 12),

                // 2. Primary Live Boarding Arrival Countdown Card
                LiveCountdownCard(
                  railwayService: widget.railwayService,
                  onSelectStation: _showStationPickerSheet,
                  onSelectTrain: _showTrainPickerSheet,
                ),

                const SizedBox(height: 20),

                // 3. Coach Position Guide on Platform
                if (train != null)
                  CoachLocatorWidget(
                    coaches: train.coaches,
                    highlightedCoach: nextBooking?.coach ?? 'B3',
                    platform: stop?.platform ?? 2,
                  ),

                const SizedBox(height: 20),

                // 4. Quick Action Callout for Railo AI
                _buildAICalloutBanner(),

                const SizedBox(height: 20),

                // 5. Complete Train Halts & Route Visualizer
                if (train != null)
                  RouteStepperWidget(
                    train: train,
                    boardingStation: boardingStation,
                    onStationTap: (station) {
                      widget.railwayService.setUserBoardingStation(station);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Boarding station changed to ${station.name} (${station.code})'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextBookingBanner(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHighlight),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_added_rounded, color: AppColors.secondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR NEXT CONFIRMED TRAIN',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
                Text(
                  '${booking.trainName} • Coach ${booking.coach}, Seat ${booking.seatNumber}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
          Text(
            booking.departureTime,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildAICalloutBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.2), AppColors.surfaceLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Need to change berth or automate booking?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Railo AI handles automated bookings & platform alerts instantly.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: widget.onNavigateToAI,
            child: const Text('Open AI', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showStationPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Boarding Station',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Text(
                    'Railocity calculates real-time ETA specifically to this station.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: widget.railwayService.allStations.length,
                      separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                      itemBuilder: (context, index) {
                        final station = widget.railwayService.allStations[index];
                        final isSelected = station.code == widget.railwayService.userBoardingStation.code;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AppColors.secondary : AppColors.surfaceLight,
                            child: Text(
                              station.code,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          title: Text(
                            station.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.secondary : Colors.white,
                            ),
                          ),
                          subtitle: Text('${station.city} • ${station.platforms} platforms', style: const TextStyle(fontSize: 11)),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.secondary) : null,
                          onTap: () {
                            widget.railwayService.setUserBoardingStation(station);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTrainPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Track Train Live',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a train to view live countdown and speed telemetries:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ...widget.railwayService.trains.map((t) {
                final isSelected = t.trainNumber == widget.railwayService.activeTrackedTrain?.trainNumber;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.train, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    '${t.trainNumber} - ${t.trainName}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.secondary : Colors.white,
                    ),
                  ),
                  subtitle: Text('${t.source.code} ➔ ${t.destination.code} • ${t.currentSpeedKmph} km/h'),
                  trailing: isSelected ? const Icon(Icons.radio_button_checked, color: AppColors.secondary) : null,
                  onTap: () {
                    widget.railwayService.setActiveTrackedTrain(t);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
