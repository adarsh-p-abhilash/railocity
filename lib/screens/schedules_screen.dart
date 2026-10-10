import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/railway_models.dart';
import '../services/railway_service.dart';
import '../services/ai_agent_service.dart';
import '../theme/app_theme.dart';

class SchedulesScreen extends StatefulWidget {
  final RailwayService railwayService;
  final AIAgentService aiAgentService;
  final VoidCallback onNavigateToAI;

  const SchedulesScreen({
    super.key,
    required this.railwayService,
    required this.aiAgentService,
    required this.onNavigateToAI,
  });

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Station _fromStation;
  late Station _toStation;
  DateTime _travelDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fromStation = RailwayService.ndls;
    _toStation = RailwayService.mmct;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _swapStations() {
    setState(() {
      final temp = _fromStation;
      _fromStation = _toStation;
      _toStation = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Train Schedules & Search', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Search Trains', icon: Icon(Icons.search_rounded, size: 20)),
            Tab(text: 'Live Station Board', icon: Icon(Icons.departure_board_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrainSearchTab(),
          _buildStationBoardTab(),
        ],
      ),
    );
  }

  Widget _buildTrainSearchTab() {
    final searchResults = widget.railwayService.searchTrains(_fromStation.code, _toStation.code);
    final displayTrains = searchResults.isNotEmpty ? searchResults : widget.railwayService.trains;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station Selection Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStationSelector(
                        label: 'FROM STATION',
                        station: _fromStation,
                        onTap: () => _pickStation(isFrom: true),
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.swap_horiz_rounded, color: AppColors.secondary, size: 20),
                      ),
                      onPressed: _swapStations,
                    ),
                    Expanded(
                      child: _buildStationSelector(
                        label: 'TO STATION',
                        station: _toStation,
                        onTap: () => _pickStation(isFrom: false),
                        isRight: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('EEE, dd MMM yyyy').format(_travelDate),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'General Quota',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Available Trains Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Trains (${displayTrains.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text('Live Availability', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),

          const SizedBox(height: 12),

          ...displayTrains.map((train) => _buildTrainCard(train)),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStationSelector({
    required String label,
    required Station station,
    required VoidCallback onTap,
    bool isRight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              station.code,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            Text(
              station.name,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainCard(Train train) {
    final fromStop = train.getStopForStation(_fromStation.code) ?? train.stops.first;
    final toStop = train.getStopForStation(_toStation.code) ?? train.stops.last;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${train.trainNumber} • ${train.trainName}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    train.trainType,
                    style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Daily',
                  style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Timing summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fromStop.scheduledDeparture, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text(fromStop.station.name, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('PF ${fromStop.platform}', style: const TextStyle(fontSize: 10, color: AppColors.accent)),
                ],
              ),
              Column(
                children: [
                  const Text('15h 40m', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 80,
                    child: Row(
                      children: const [
                        CircleAvatar(radius: 3, backgroundColor: AppColors.secondary),
                        Expanded(child: Divider(color: AppColors.borderHighlight, thickness: 1)),
                        Icon(Icons.train, size: 14, color: AppColors.secondary),
                        Expanded(child: Divider(color: AppColors.borderHighlight, thickness: 1)),
                        CircleAvatar(radius: 3, backgroundColor: AppColors.secondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Direct', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(toStop.scheduledArrival, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text(toStop.station.name, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('PF ${toStop.platform}', style: const TextStyle(fontSize: 10, color: AppColors.accent)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Seat Classes
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: train.classes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final sc = train.classes[i];
                return InkWell(
                  onTap: () {
                    widget.aiAgentService.executeAutomatedBookingFromCard(train, sc);
                    widget.onNavigateToAI();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderHighlight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sc.code, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('₹${sc.fare.toInt()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sc.statusText,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationBoardTab() {
    final station = widget.railwayService.userBoardingStation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.departure_board, color: Colors.white, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Departure Board: ${station.name}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Next trains departing or arriving in upcoming 4 hours:',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...widget.railwayService.trains.map((train) {
            final stop = train.getStopForStation(station.code) ?? train.stops.first;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PF ${stop.platform}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${train.trainNumber} ${train.trainName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        Text(
                          'Towards ${train.destination.name} (${train.destination.code})',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stop.actualDeparture,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.accent),
                      ),
                      Text(
                        train.delayMinutes == 0 ? 'On Time' : '+${train.delayMinutes}m delay',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: train.delayMinutes == 0 ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _pickStation({required bool isFrom}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(isFrom ? 'Select Departure Station' : 'Select Destination Station',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            ...widget.railwayService.allStations.map(
              (st) => ListTile(
                title: Text(st.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${st.code} • ${st.city}'),
                onTap: () {
                  setState(() {
                    if (isFrom) {
                      _fromStation = st;
                    } else {
                      _toStation = st;
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }
}
