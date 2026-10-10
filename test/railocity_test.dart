import 'package:flutter_test/flutter_test.dart';
import 'package:railocity/services/railway_service.dart';
import 'package:railocity/services/booking_service.dart';
import 'package:railocity/services/ai_agent_service.dart';
import 'package:railocity/main.dart';

void main() {
  group('RailwayService Tests', () {
    test('Initializes with default trains and boarding station', () {
      final railway = RailwayService();
      expect(railway.trains.isNotEmpty, true);
      expect(railway.userBoardingStation.code, 'MTJ');
      expect(railway.activeTrackedTrain, isNotNull);
      railway.dispose();
    });

    test('Calculates ETA minutes to boarding station', () {
      final railway = RailwayService();
      final train = railway.trains.first; // NDLS -> MMCT via MTJ
      final etaMin = train.getMinutesUntilArrivalAt('MTJ');
      expect(etaMin, greaterThan(0));

      railway.setUserBoardingStation(RailwayService.kota);
      expect(railway.userBoardingStation.code, 'KOTA');
      railway.dispose();
    });

    test('Searches trains between stations', () {
      final railway = RailwayService();
      final results = railway.searchTrains('NDLS', 'MMCT');
      expect(results.isNotEmpty, true);
      expect(results.first.trainNumber, '12952');
      railway.dispose();
    });
  });

  group('BookingService Tests', () {
    test('Initializes with sample upcoming bookings', () {
      final booking = BookingService();
      expect(booking.bookings.isNotEmpty, true);
      expect(booking.nextUpcomingBooking, isNotNull);
      expect(booking.nextUpcomingBooking?.pnr, '2849104821');
      booking.dispose();
    });

    test('Creates new booking with generated PNR and coach', () {
      final bookingService = BookingService();
      final railwayService = RailwayService();
      final train = railwayService.trains.first;

      final initialCount = bookingService.bookings.length;
      final newBooking = bookingService.createBooking(
        train: train,
        sourceStation: RailwayService.ndls,
        destinationStation: RailwayService.mmct,
        travelDate: DateTime.now().add(const Duration(days: 2)),
        seatClass: '3A',
        passengerName: 'Priya Sharma',
      );

      expect(newBooking.pnr.length, greaterThanOrEqualTo(10));
      expect(bookingService.bookings.length, initialCount + 1);
      expect(newBooking.status, 'CONFIRMED');

      bookingService.dispose();
      railwayService.dispose();
    });
  });

  group('AIAgentService Tests', () {
    test('Executes automated booking when user asks in natural language', () async {
      final railwayService = RailwayService();
      final bookingService = BookingService();
      final aiService = AIAgentService(
        railwayService: railwayService,
        bookingService: bookingService,
      );

      final initialBookingsCount = bookingService.bookings.length;

      await aiService.handleUserInput('Book ticket to Mumbai tomorrow');

      // AI should have added user message, then completed booking
      expect(bookingService.bookings.length, initialBookingsCount + 1);

      final lastMsg = aiService.messages.last;
      expect(lastMsg.bookingCard, isNotNull);
      expect(lastMsg.reasoningSteps?.isNotEmpty, true);
      expect(lastMsg.text.contains('Ticket Automated & Confirmed'), true);

      aiService.dispose();
      bookingService.dispose();
      railwayService.dispose();
    });

    test('Answers ETA and next train questions intelligently', () async {
      final railwayService = RailwayService();
      final bookingService = BookingService();
      final aiService = AIAgentService(
        railwayService: railwayService,
        bookingService: bookingService,
      );

      await aiService.handleUserInput('When is my next train arriving?');

      final lastMsg = aiService.messages.last;
      expect(lastMsg.text.contains('Live Arrival Countdown'), true);

      aiService.dispose();
      bookingService.dispose();
      railwayService.dispose();
    });
  });

  group('App Widget Test', () {
    testWidgets('App renders successfully and navigates tabs', (tester) async {
      await tester.pumpWidget(const RailocityApp());
      await tester.pump();

      expect(find.text('Railocity Companion'), findsOneWidget);
      expect(find.text('Live Boarding & ETA Tracker'), findsOneWidget);

      // Verify tabs exist
      expect(find.text('Live Boarding'), findsOneWidget);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('Railo AI'), findsOneWidget);
      expect(find.text('My Trips'), findsOneWidget);

      // Tap on Railo AI tab
      await tester.tap(find.text('Railo AI'));
      await tester.pumpAndSettle();

      expect(find.text('Railo AI Companion'), findsOneWidget);

      // Tap on Schedules tab
      await tester.tap(find.text('Schedules'));
      await tester.pumpAndSettle();

      expect(find.text('Train Schedules & Search'), findsOneWidget);

      // Tap on My Trips tab
      await tester.tap(find.text('My Trips'));
      await tester.pumpAndSettle();

      expect(find.text('My Trips & Passes'), findsOneWidget);
    });
  });
}
