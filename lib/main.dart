import 'package:flutter/material.dart';
import 'services/railway_service.dart';
import 'services/booking_service.dart';
import 'services/ai_agent_service.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RailocityApp());
}

class RailocityApp extends StatefulWidget {
  const RailocityApp({super.key});

  @override
  State<RailocityApp> createState() => _RailocityAppState();
}

class _RailocityAppState extends State<RailocityApp> {
  late final RailwayService _railwayService;
  late final BookingService _bookingService;
  late final AIAgentService _aiAgentService;

  @override
  void initState() {
    super.initState();
    _railwayService = RailwayService();
    _bookingService = BookingService();
    _aiAgentService = AIAgentService(
      railwayService: _railwayService,
      bookingService: _bookingService,
    );
  }

  @override
  void dispose() {
    _railwayService.dispose();
    _bookingService.dispose();
    _aiAgentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Railocity - Railway Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeShell(
        railwayService: _railwayService,
        bookingService: _bookingService,
        aiAgentService: _aiAgentService,
      ),
    );
  }
}
