import 'package:flutter/material.dart';
import '../services/railway_service.dart';
import '../services/booking_service.dart';
import '../services/ai_agent_service.dart';
import '../theme/app_theme.dart';
import 'live_tracker_screen.dart';
import 'schedules_screen.dart';
import 'ai_assistant_screen.dart';
import 'tickets_screen.dart';

class HomeShell extends StatefulWidget {
  final RailwayService railwayService;
  final BookingService bookingService;
  final AIAgentService aiAgentService;

  const HomeShell({
    super.key,
    required this.railwayService,
    required this.bookingService,
    required this.aiAgentService,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      LiveTrackerScreen(
        railwayService: widget.railwayService,
        bookingService: widget.bookingService,
        onNavigateToAI: () => _switchTab(2),
      ),
      SchedulesScreen(
        railwayService: widget.railwayService,
        aiAgentService: widget.aiAgentService,
        onNavigateToAI: () => _switchTab(2),
      ),
      AIAssistantScreen(
        aiAgentService: widget.aiAgentService,
        onNavigateToLive: () => _switchTab(0),
        onNavigateToTickets: () => _switchTab(3),
      ),
      TicketsScreen(
        bookingService: widget.bookingService,
        railwayService: widget.railwayService,
        onNavigateToLive: () => _switchTab(0),
        onNavigateToAI: () => _switchTab(2),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _switchTab,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withOpacity(0.3),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.radar_outlined),
              selectedIcon: Icon(Icons.radar, color: AppColors.secondary),
              label: 'Live Boarding',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.secondary),
              label: 'Schedules',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy, color: AppColors.secondary),
              label: 'Railo AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.confirmation_number_outlined),
              selectedIcon: Icon(Icons.confirmation_number, color: AppColors.secondary),
              label: 'My Trips',
            ),
          ],
        ),
      ),
    );
  }
}
