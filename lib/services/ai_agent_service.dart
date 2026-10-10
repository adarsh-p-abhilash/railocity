import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/railway_models.dart';
import 'railway_service.dart';
import 'booking_service.dart';

class AIAgentService extends ChangeNotifier {
  final RailwayService railwayService;
  final BookingService bookingService;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  AIAgentService({
    required this.railwayService,
    required this.bookingService,
  }) {
    _initWelcomeConversation();
  }

  void _initWelcomeConversation() {
    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        sender: MessageSender.ai,
        text: "Namaste! I'm **Railo AI**, your intelligent railway companion. 🚄\n\nI can continuously track how long until your train reaches your boarding station, automate your ticket bookings in seconds, and keep you updated on platform changes, coach positions, and delays.\n\nHow can I help you today?",
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        suggestedChips: [
          '⚡ Book ticket to Mumbai tomorrow',
          '⏱️ When is my next train arriving?',
          '🚉 Which platform is my coach on?',
          '⚠️ Check route delays & speed',
        ],
      ),
    );
  }

  Future<void> handleUserInput(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    // 1. Add user message
    _messages.add(
      ChatMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.user,
        text: query,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    _isProcessing = true;
    notifyListeners();

    // 2. Add thinking state message
    final thinkingMsgId = 'ai_thinking_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      ChatMessage(
        id: thinkingMsgId,
        sender: MessageSender.ai,
        text: "Railo AI is analyzing your request...",
        timestamp: DateTime.now(),
        isThinking: true,
      ),
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    // Remove thinking message and generate smart response
    _messages.removeWhere((m) => m.id == thinkingMsgId);

    await _processSmartResponse(query);

    _isProcessing = false;
    notifyListeners();
  }

  Future<void> _processSmartResponse(String rawQuery) async {
    final q = rawQuery.toLowerCase();

    // SCENARIO 1: Automated Ticket Booking Intent
    if (q.contains('book') || q.contains('ticket') || q.contains('reservation')) {
      await _handleAutomatedBookingIntent(q);
      return;
    }

    // SCENARIO 2: Boarding Arrival Countdown / ETA / "How long will it take"
    if (q.contains('how long') || q.contains('reach') || q.contains('eta') || q.contains('when is my next train') || q.contains('arriving')) {
      _handleEtaAndNextTrainIntent();
      return;
    }

    // SCENARIO 3: Platform Information & Coach Position
    if (q.contains('platform') || q.contains('coach') || q.contains('where to stand') || q.contains('position')) {
      _handlePlatformAndCoachIntent();
      return;
    }

    // SCENARIO 4: Delay, Speed & Live Telemetry
    if (q.contains('delay') || q.contains('late') || q.contains('speed') || q.contains('status')) {
      _handleDelayAndSpeedIntent();
      return;
    }

    // SCENARIO 5: Baggage, Rules, Food / Meals, Assistance
    if (q.contains('food') || q.contains('meal') || q.contains('baggage') || q.contains('luggage') || q.contains('help') || q.contains('pantry')) {
      _handleAmenitiesAndRulesIntent(q);
      return;
    }

    // Fallback General Intelligent Railway Assistant
    _messages.add(
      ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.ai,
        text: "I understand you're asking about: \"$rawQuery\".\n\nHere are some automated actions I can perform for you right now:",
        timestamp: DateTime.now(),
        suggestedChips: [
          '⚡ Book ticket to Mumbai tomorrow',
          '⏱️ Check arrival time at ${railwayService.userBoardingStation.name}',
          '📋 View my active ticket & PNR',
          '🚉 Track train 12952 live',
        ],
      ),
    );
  }

  Future<void> _handleAutomatedBookingIntent(String q) async {
    // Identify Destination
    Station dest = RailwayService.mmct;
    if (q.contains('varanasi') || q.contains('bsb')) {
      dest = RailwayService.bsb;
    } else if (q.contains('bhopal')) {
      dest = RailwayService.bpl;
    } else if (q.contains('bengaluru') || q.contains('bangalore')) {
      dest = RailwayService.sbc;
    } else if (q.contains('delhi')) {
      dest = RailwayService.ndls;
    }

    Station src = railwayService.userBoardingStation;
    if (src.code == dest.code) {
      src = RailwayService.ndls;
    }

    // Find train
    final trains = railwayService.searchTrains(src.code, dest.code);
    final chosenTrain = trains.isNotEmpty ? trains.first : railwayService.trains.first;

    // Class selection
    String seatClass = '3A';
    if (q.contains('1a') || q.contains('first')) {
      seatClass = '1A';
    } else if (q.contains('2a') || q.contains('second')) {
      seatClass = '2A';
    } else if (q.contains('cc') || q.contains('chair')) {
      seatClass = 'CC';
    } else if (q.contains('sleeper') || q.contains('sl')) {
      seatClass = 'SL';
    }

    // Simulate agent steps
    final steps = [
      '⚡ Step 1: Resolved route ${src.name} (${src.code}) ➔ ${dest.name} (${dest.code})',
      '🔍 Step 2: Queried IRCTC live inventory for ${chosenTrain.trainNumber} ${chosenTrain.trainName}',
      '🎟️ Step 3: Verified quota in class $seatClass (Confirmed seats available)',
      '👤 Step 4: Passenger identified: Adarsh P. Abhilash (Berth: Window/Lower Berth)',
      '💳 Step 5: Fast-booking token dispatched and payment auto-authorized',
      '✅ Step 6: PNR Issued & confirmed instant boarding pass generated!',
    ];

    // Create the actual booking in service
    final newBooking = bookingService.createBooking(
      train: chosenTrain,
      sourceStation: src,
      destinationStation: dest,
      travelDate: DateTime.now().add(const Duration(days: 1)),
      seatClass: seatClass,
      passengerName: 'Adarsh P. Abhilash',
      passengerAge: 27,
      passengerGender: 'Male',
      preferredBerth: 'Window (Lower Berth)',
    );

    railwayService.setActiveTrackedTrain(chosenTrain);

    _messages.add(
      ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.ai,
        text: "🎉 **Ticket Automated & Confirmed Successfully!**\n\nI have automatically booked your seat on **${chosenTrain.trainNumber} - ${chosenTrain.trainName}** from **${src.name}** to **${dest.name}**.\n\n- **PNR:** `${newBooking.pnr}`\n- **Coach & Seat:** **${newBooking.coach}** / Seat **${newBooking.seatNumber}** (${newBooking.berthType})\n- **Class:** ${newBooking.seatClass} • Fare: ₹${newBooking.fare.toInt()}\n- **Scheduled Departure:** ${newBooking.departureTime} from Platform **${newBooking.platform}**",
        timestamp: DateTime.now(),
        reasoningSteps: steps,
        bookingCard: newBooking,
        suggestedChips: [
          '⏱️ How long until this train reaches?',
          '📍 Show coach position on platform',
          '📱 View full Digital Boarding Pass',
        ],
      ),
    );
  }

  void _handleEtaAndNextTrainIntent() {
    final nextBooking = bookingService.nextUpcomingBooking;
    final train = railwayService.activeTrackedTrain ?? railwayService.trains.first;
    final boardingStation = railwayService.userBoardingStation;
    final countdown = railwayService.formattedCountdownToBoarding;
    final minutes = railwayService.remainingMinutes;

    final stop = train.getStopForStation(boardingStation.code);
    final platform = stop?.platform ?? 2;
    final delay = train.delayMinutes;

    String advice = minutes < 20
        ? "⚠️ **Recommendation:** You should head to Platform $platform now. The train is just approaching."
        : "💡 **Recommendation:** You have sufficient time. Estimated arrival is on schedule.";

    _messages.add(
      ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.ai,
        text: "⏱️ **Live Arrival Countdown for ${boardingStation.name} (${boardingStation.code}):**\n\n"
            "Your train **${train.trainNumber} ${train.trainName}** will reach your boarding station in:\n\n"
            "### ⏳ **$countdown** (~$minutes minutes)\n\n"
            "- **Live Location:** ${train.currentLocationDescription}\n"
            "- **Current Speed:** ${train.currentSpeedKmph} km/h\n"
            "- **Boarding Platform:** **Platform $platform**\n"
            "- **Punctuality:** ${delay == 0 ? '🟢 Running Right On Time' : '🟡 Running $delay minutes late'}\n\n"
            "$advice",
        timestamp: DateTime.now(),
        trainStatusCard: train,
        suggestedChips: [
          '🚉 Where will Coach ${nextBooking?.coach ?? 'B3'} halt on Platform $platform?',
          '🔄 Refresh live countdown',
          '🎫 View my ticket',
        ],
      ),
    );
  }

  void _handlePlatformAndCoachIntent() {
    final train = railwayService.activeTrackedTrain ?? railwayService.trains.first;
    final booking = bookingService.nextUpcomingBooking;
    final boardingStation = railwayService.userBoardingStation;
    final stop = train.getStopForStation(boardingStation.code);
    final platform = stop?.platform ?? 2;
    final targetCoach = booking?.coach ?? 'B3';

    _messages.add(
      ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.ai,
        text: "🚉 **Platform & Coach Position Guide**\n\n"
            "- **Station:** ${boardingStation.name} (${boardingStation.code})\n"
            "- **Train:** ${train.trainNumber} ${train.trainName}\n"
            "- **Platform:** **Platform $platform** (Dedicated express bay)\n"
            "- **Your Coach:** **$targetCoach** (Seat: ${booking?.seatNumber ?? '42'})\n\n"
            "🧭 **Platform Position Guide:**\n"
            "Coach **$targetCoach** will halt **approx. 110m from the center Foot-Over-Bridge (FOB #2)** near Escalator A. Look for electronic coach indicator board **#$targetCoach** hanging from the platform roof.",
        timestamp: DateTime.now(),
        suggestedChips: [
          '⏱️ When is the train arriving?',
          '🍽️ Does this train serve pantry food?',
          '🧳 What is the luggage allowance?',
        ],
      ),
    );
  }

  void _handleDelayAndSpeedIntent() {
    final train = railwayService.activeTrackedTrain ?? railwayService.trains.first;
    _messages.add(
      ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.ai,
        text: "📊 **Live Train Telemetry & Punctuality:**\n\n"
            "- **Train:** ${train.trainNumber} - ${train.trainName}\n"
            "- **Current Speed:** **${train.currentSpeedKmph} km/h**\n"
            "- **Delay:** ${train.delayMinutes == 0 ? 'Right On Time (0 min)' : '${train.delayMinutes} min delay (Recovering on green signal corridor)'}\n"
            "- **Current Position:** ${train.currentLocationDescription}\n"
            "- **Next Scheduled Halt:** ${train.stops[train.currentStopIndex].station.name} on Platform ${train.stops[train.currentStopIndex].platform}",
        timestamp: DateTime.now(),
        trainStatusCard: train,
        suggestedChips: [
          '⏱️ How long to my boarding station?',
          '⚡ Automate another ticket booking',
        ],
      ),
    );
  }

  void _handleAmenitiesAndRulesIntent(String q) {
    if (q.contains('food') || q.contains('meal') || q.contains('pantry')) {
      _messages.add(
        ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.ai,
          text: "🍽️ **Catering & Pantry Information:**\n\n"
              "- **Complimentary Catering:** For Rajdhani / Vande Bharat / Shatabdi passengers, hot dinner and evening snacks are included if opted during booking.\n"
              "- **E-Catering Delivery:** You can order Domino's, Haldiram's, or local thalis delivered directly to your berth at upcoming stops via IRCTC e-Catering using your PNR.\n"
              "- **Water:** 1L Packaged Rail Neer bottle provided upon departure.",
          timestamp: DateTime.now(),
          suggestedChips: ['⏱️ When is my train arriving?', '🎫 Show my ticket'],
        ),
      );
    } else {
      _messages.add(
        ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.ai,
          text: "🧳 **Luggage & Baggage Guidelines:**\n\n"
              "- **AC First (1A):** Up to 70 kg free allowance.\n"
              "- **AC 2-Tier (2A):** Up to 50 kg free allowance.\n"
              "- **AC 3-Tier / Chair Car (3A / CC):** Up to 40 kg free allowance.\n"
              "- **Sleeper (SL):** Up to 40 kg free allowance.\n\n"
              "⚠️ Trunks, suitcases, and bags should be placed under the lower berth and chained for safety.",
          timestamp: DateTime.now(),
          suggestedChips: ['⚡ Book another ticket', '⏱️ Track arrival time'],
        ),
      );
    }
  }

  void executeAutomatedBookingFromCard(Train train, SeatClass seatClass) {
    handleUserInput("Book ticket for ${train.trainNumber} in ${seatClass.code} class");
  }
}
