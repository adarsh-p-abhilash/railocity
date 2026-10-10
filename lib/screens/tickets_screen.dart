import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/railway_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_pass_card.dart';

class TicketsScreen extends StatelessWidget {
  final BookingService bookingService;
  final RailwayService railwayService;
  final VoidCallback onNavigateToLive;
  final VoidCallback onNavigateToAI;

  const TicketsScreen({
    super.key,
    required this.bookingService,
    required this.railwayService,
    required this.onNavigateToLive,
    required this.onNavigateToAI,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bookingService,
      builder: (context, _) {
        final bookings = bookingService.bookings;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Trips & Passes', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                tooltip: 'Book New with AI',
                icon: const Icon(Icons.add_circle_outline, color: AppColors.secondary),
                onPressed: onNavigateToAI,
              ),
            ],
          ),
          body: bookings.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return TicketPassCard(
                      booking: b,
                      onTrackTrain: () {
                        final train = railwayService.getTrainByNumber(b.trainNumber);
                        if (train != null) {
                          railwayService.setActiveTrackedTrain(train);
                        }
                        railwayService.setUserBoardingStation(b.sourceStation);
                        onNavigateToLive();
                      },
                      onCancel: () {
                        _showCancelDialog(context, b.pnr);
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderHighlight),
              ),
              child: const Icon(Icons.confirmation_number_outlined, size: 60, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Active Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask Railo AI to automate your booking or search trains to book tickets instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Book with Railo AI', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: onNavigateToAI,
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String pnr) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Cancel Ticket?', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to cancel PNR $pnr? Refund will be processed back to original source.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Ticket', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                bookingService.cancelBooking(pnr);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ticket $pnr cancelled successfully.')),
                );
              },
              child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
