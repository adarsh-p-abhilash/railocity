import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/railway_models.dart';
import 'railway_service.dart';

class BookingService extends ChangeNotifier {
  final List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  Booking? get nextUpcomingBooking {
    if (_bookings.isEmpty) return null;
    return _bookings.first;
  }

  BookingService() {
    _initSampleBookings();
  }

  void _initSampleBookings() {
    final now = DateTime.now();
    _bookings.add(
      Booking(
        pnr: '2849104821',
        trainNumber: '12952',
        trainName: 'Mumbai Tejas Rajdhani',
        trainType: 'Tejas Superfast',
        sourceStation: RailwayService.mtj,
        destinationStation: RailwayService.mmct,
        travelDate: now.add(const Duration(hours: 1)),
        departureTime: '18:24',
        arrivalTime: '08:40',
        coach: 'B3',
        seatNumber: '42',
        berthType: 'Window (Lower Berth)',
        seatClass: '3A',
        passengerName: 'Adarsh P. Abhilash',
        passengerAge: 27,
        passengerGender: 'Male',
        fare: 2150.0,
        status: 'CONFIRMED',
        platform: 2,
      ),
    );

    _bookings.add(
      Booking(
        pnr: '8104928172',
        trainNumber: '22436',
        trainName: 'Vande Bharat Express',
        trainType: 'Semi High-Speed',
        sourceStation: RailwayService.ndls,
        destinationStation: RailwayService.bsb,
        travelDate: now.add(const Duration(days: 3)),
        departureTime: '06:00',
        arrivalTime: '14:00',
        coach: 'C2',
        seatNumber: '18',
        berthType: 'Window Seat',
        seatClass: 'CC',
        passengerName: 'Adarsh P. Abhilash',
        passengerAge: 27,
        passengerGender: 'Male',
        fare: 1750.0,
        status: 'CONFIRMED',
        platform: 16,
      ),
    );
  }

  Booking createBooking({
    required Train train,
    required Station sourceStation,
    required Station destinationStation,
    required DateTime travelDate,
    required String seatClass,
    required String passengerName,
    int passengerAge = 28,
    String passengerGender = 'Male',
    String? preferredBerth,
  }) {
    final random = Random();
    final pnr = '${random.nextInt(900000000) + 1000000000}';
    
    // Choose coach and seat according to class
    String coach = 'B2';
    if (seatClass == '1A') {
      coach = 'H1';
    } else if (seatClass == '2A') {
      coach = 'A1';
    } else if (seatClass == '3A') {
      coach = 'B${random.nextInt(4) + 1}';
    } else if (seatClass == 'CC') {
      coach = 'C${random.nextInt(4) + 1}';
    } else if (seatClass == 'EC') {
      coach = 'E1';
    } else {
      coach = 'S${random.nextInt(6) + 1}';
    }

    final seatNum = '${random.nextInt(64) + 1}';
    final berth = preferredBerth ?? (seatClass.contains('C') ? 'Window' : ['Lower Berth', 'Side Lower', 'Upper Berth'][random.nextInt(3)]);

    final sourceStop = train.getStopForStation(sourceStation.code);
    final destStop = train.getStopForStation(destinationStation.code);

    final depTime = sourceStop?.actualDeparture ?? sourceStop?.scheduledDeparture ?? '18:30';
    final arrTime = destStop?.actualArrival ?? destStop?.scheduledArrival ?? '08:45';

    final selectedClass = train.classes.firstWhere(
      (c) => c.code == seatClass,
      orElse: () => train.classes.first,
    );

    final booking = Booking(
      pnr: pnr,
      trainNumber: train.trainNumber,
      trainName: train.trainName,
      trainType: train.trainType,
      sourceStation: sourceStation,
      destinationStation: destinationStation,
      travelDate: travelDate,
      departureTime: depTime,
      arrivalTime: arrTime,
      coach: coach,
      seatNumber: seatNum,
      berthType: berth,
      seatClass: seatClass,
      passengerName: passengerName,
      passengerAge: passengerAge,
      passengerGender: passengerGender,
      fare: selectedClass.fare,
      status: 'CONFIRMED',
      platform: sourceStop?.platform ?? 2,
    );

    _bookings.insert(0, booking);
    notifyListeners();
    return booking;
  }

  void cancelBooking(String pnr) {
    _bookings.removeWhere((b) => b.pnr == pnr);
    notifyListeners();
  }
}
