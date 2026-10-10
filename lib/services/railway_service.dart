import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/railway_models.dart';

class RailwayService extends ChangeNotifier {
  // Predefined popular stations
  static const Station ndls = Station(code: 'NDLS', name: 'New Delhi', city: 'Delhi', platforms: 16);
  static const Station mtj = Station(code: 'MTJ', name: 'Mathura Junction', city: 'Mathura', platforms: 10);
  static const Station agc = Station(code: 'AGC', name: 'Agra Cantt', city: 'Agra', platforms: 6);
  static const Station gwl = Station(code: 'GWL', name: 'Gwalior Junction', city: 'Gwalior', platforms: 5);
  static const Station vglb = Station(code: 'VGLB', name: 'Virangana Lakshmibai (Jhansi)', city: 'Jhansi', platforms: 8);
  static const Station bpl = Station(code: 'BPL', name: 'Bhopal Junction', city: 'Bhopal', platforms: 6);
  static const Station kota = Station(code: 'KOTA', name: 'Kota Junction', city: 'Kota', platforms: 4);
  static const Station brc = Station(code: 'BRC', name: 'Vadodara Junction', city: 'Vadodara', platforms: 7);
  static const Station st = Station(code: 'ST', name: 'Surat', city: 'Surat', platforms: 4);
  static const Station mmct = Station(code: 'MMCT', name: 'Mumbai Central', city: 'Mumbai', platforms: 5);
  static const Station bsb = Station(code: 'BSB', name: 'Varanasi Junction', city: 'Varanasi', platforms: 9);
  static const Station cnb = Station(code: 'CNB', name: 'Kanpur Central', city: 'Kanpur', platforms: 10);
  static const Station pryj = Station(code: 'PRYJ', name: 'Prayagraj Junction', city: 'Prayagraj', platforms: 10);
  static const Station sbc = Station(code: 'SBC', name: 'KSR Bengaluru', city: 'Bengaluru', platforms: 10);
  static const Station mas = Station(code: 'MAS', name: 'Chennai Central', city: 'Chennai', platforms: 12);
  static const Station hwh = Station(code: 'HWH', name: 'Howrah Junction', city: 'Kolkata', platforms: 23);

  final List<Station> allStations = [
    ndls, mtj, agc, gwl, vglb, bpl, kota, brc, st, mmct, bsb, cnb, pryj, sbc, mas, hwh,
  ];

  late List<Train> _trains;
  List<Train> get trains => _trains;

  Station _userBoardingStation = mtj; // Default user boarding station
  Station get userBoardingStation => _userBoardingStation;

  Train? _activeTrackedTrain;
  Train? get activeTrackedTrain => _activeTrackedTrain;

  Timer? _liveTicker;
  int _secondsCounter = 14 * 60 + 35; // Simulated seconds to arrival

  RailwayService() {
    _initTrains();
    _activeTrackedTrain = _trains.first;
    _startLiveSimulation();
  }

  void _initTrains() {
    _trains = [
      Train(
        trainNumber: '12952',
        trainName: 'Mumbai Tejas Rajdhani',
        trainType: 'Tejas Superfast',
        source: ndls,
        destination: mmct,
        currentSpeedKmph: 112,
        currentLocationDescription: 'Cruising between Palwal and Mathura',
        currentStopIndex: 1,
        delayMinutes: 6,
        coaches: ['LOCO', 'EOG', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'A1', 'A2', 'H1', 'PC', 'EOG'],
        classes: const [
          SeatClass(code: '3A', name: 'AC 3-Tier', fare: 2150, availableSeats: 34, statusText: 'AVAILABLE-34'),
          SeatClass(code: '2A', name: 'AC 2-Tier', fare: 3045, availableSeats: 18, statusText: 'AVAILABLE-18'),
          SeatClass(code: '1A', name: 'AC First Class', fare: 4980, availableSeats: 4, statusText: 'AVAILABLE-04'),
        ],
        stops: [
          TrainStop(
            station: ndls,
            scheduledArrival: '16:55',
            scheduledDeparture: '16:55',
            actualArrival: '16:55',
            actualDeparture: '16:58',
            platform: 3,
            distanceKm: 0,
            status: TrainStatus.departed,
          ),
          TrainStop(
            station: mtj,
            scheduledArrival: '18:18',
            scheduledDeparture: '18:20',
            actualArrival: '18:24',
            actualDeparture: '18:26',
            platform: 2,
            distanceKm: 141,
            status: TrainStatus.delayed,
            delayMinutes: 6,
          ),
          TrainStop(
            station: kota,
            scheduledArrival: '21:30',
            scheduledDeparture: '21:40',
            actualArrival: '21:36',
            actualDeparture: '21:45',
            platform: 1,
            distanceKm: 465,
            status: TrainStatus.scheduled,
            delayMinutes: 6,
          ),
          TrainStop(
            station: brc,
            scheduledArrival: '03:40',
            scheduledDeparture: '03:50',
            actualArrival: '03:45',
            actualDeparture: '03:55',
            platform: 4,
            distanceKm: 992,
            status: TrainStatus.scheduled,
            delayMinutes: 5,
          ),
          TrainStop(
            station: st,
            scheduledArrival: '05:13',
            scheduledDeparture: '05:18',
            actualArrival: '05:18',
            actualDeparture: '05:23',
            platform: 1,
            distanceKm: 1122,
            status: TrainStatus.scheduled,
            delayMinutes: 5,
          ),
          TrainStop(
            station: mmct,
            scheduledArrival: '08:35',
            scheduledDeparture: '08:35',
            actualArrival: '08:40',
            actualDeparture: '08:40',
            platform: 5,
            distanceKm: 1386,
            status: TrainStatus.scheduled,
            delayMinutes: 5,
          ),
        ],
      ),
      Train(
        trainNumber: '22436',
        trainName: 'Vande Bharat Express',
        trainType: 'Semi High-Speed',
        source: ndls,
        destination: bsb,
        currentSpeedKmph: 130,
        currentLocationDescription: 'Passed Aligarh Jn, high speed run',
        currentStopIndex: 1,
        delayMinutes: 0,
        coaches: ['DTC1', 'NDTC1', 'NDTC2', 'MC1', 'TC1', 'MC2', 'NDTC3', 'DTC2'],
        classes: const [
          SeatClass(code: 'CC', name: 'Chair Car', fare: 1750, availableSeats: 58, statusText: 'AVAILABLE-58'),
          SeatClass(code: 'EC', name: 'Executive Class', fare: 3300, availableSeats: 12, statusText: 'AVAILABLE-12'),
        ],
        stops: [
          TrainStop(
            station: ndls,
            scheduledArrival: '06:00',
            scheduledDeparture: '06:00',
            actualArrival: '06:00',
            actualDeparture: '06:00',
            platform: 16,
            distanceKm: 0,
            status: TrainStatus.departed,
          ),
          TrainStop(
            station: cnb,
            scheduledArrival: '10:08',
            scheduledDeparture: '10:10',
            actualArrival: '10:08',
            actualDeparture: '10:10',
            platform: 5,
            distanceKm: 440,
            status: TrainStatus.onTime,
          ),
          TrainStop(
            station: pryj,
            scheduledArrival: '12:08',
            scheduledDeparture: '12:10',
            actualArrival: '12:08',
            actualDeparture: '12:10',
            platform: 6,
            distanceKm: 635,
            status: TrainStatus.scheduled,
          ),
          TrainStop(
            station: bsb,
            scheduledArrival: '14:00',
            scheduledDeparture: '14:00',
            actualArrival: '14:00',
            actualDeparture: '14:00',
            platform: 1,
            distanceKm: 759,
            status: TrainStatus.scheduled,
          ),
        ],
      ),
      Train(
        trainNumber: '12002',
        trainName: 'Bhopal Shatabdi Express',
        trainType: 'Superfast Shatabdi',
        source: ndls,
        destination: bpl,
        currentSpeedKmph: 98,
        currentLocationDescription: 'Entering Kosi Kalan',
        currentStopIndex: 1,
        delayMinutes: 2,
        coaches: ['EOG', 'C1', 'C2', 'C3', 'C4', 'C5', 'E1', 'EOG'],
        classes: const [
          SeatClass(code: 'CC', name: 'Chair Car', fare: 1285, availableSeats: 82, statusText: 'AVAILABLE-82'),
          SeatClass(code: 'EC', name: 'Executive Class', fare: 2190, availableSeats: 16, statusText: 'AVAILABLE-16'),
        ],
        stops: [
          TrainStop(
            station: ndls,
            scheduledArrival: '06:00',
            scheduledDeparture: '06:00',
            actualArrival: '06:00',
            actualDeparture: '06:00',
            platform: 1,
            distanceKm: 0,
            status: TrainStatus.departed,
          ),
          TrainStop(
            station: mtj,
            scheduledArrival: '07:19',
            scheduledDeparture: '07:20',
            actualArrival: '07:21',
            actualDeparture: '07:22',
            platform: 3,
            distanceKm: 141,
            status: TrainStatus.onTime,
          ),
          TrainStop(
            station: agc,
            scheduledArrival: '07:50',
            scheduledDeparture: '07:55',
            actualArrival: '07:52',
            actualDeparture: '07:57',
            platform: 1,
            distanceKm: 195,
            status: TrainStatus.scheduled,
          ),
          TrainStop(
            station: gwl,
            scheduledArrival: '09:23',
            scheduledDeparture: '09:28',
            actualArrival: '09:25',
            actualDeparture: '09:30',
            platform: 2,
            distanceKm: 313,
            status: TrainStatus.scheduled,
          ),
          TrainStop(
            station: vglb,
            scheduledArrival: '10:45',
            scheduledDeparture: '10:53',
            actualArrival: '10:47',
            actualDeparture: '10:55',
            platform: 1,
            distanceKm: 411,
            status: TrainStatus.scheduled,
          ),
          TrainStop(
            station: bpl,
            scheduledArrival: '14:40',
            scheduledDeparture: '14:40',
            actualArrival: '14:42',
            actualDeparture: '14:42',
            platform: 1,
            distanceKm: 703,
            status: TrainStatus.scheduled,
          ),
        ],
      ),
      Train(
        trainNumber: '12626',
        trainName: 'Kerala Superfast Express',
        trainType: 'Superfast Mail',
        source: ndls,
        destination: sbc,
        currentSpeedKmph: 75,
        currentLocationDescription: 'Crossing Faridabad outer',
        currentStopIndex: 1,
        delayMinutes: 12,
        coaches: ['LOCO', 'SLR', 'S1', 'S2', 'S3', 'S4', 'S5', 'B1', 'B2', 'B3', 'A1', 'SLR'],
        classes: const [
          SeatClass(code: 'SL', name: 'Sleeper', fare: 710, availableSeats: 15, statusText: 'RAC 8'),
          SeatClass(code: '3A', name: 'AC 3-Tier', fare: 1890, availableSeats: 21, statusText: 'AVAILABLE-21'),
          SeatClass(code: '2A', name: 'AC 2-Tier', fare: 2750, availableSeats: 8, statusText: 'AVAILABLE-08'),
        ],
        stops: [
          TrainStop(
            station: ndls,
            scheduledArrival: '20:10',
            scheduledDeparture: '20:10',
            actualArrival: '20:10',
            actualDeparture: '20:22',
            platform: 5,
            distanceKm: 0,
            status: TrainStatus.departed,
            delayMinutes: 12,
          ),
          TrainStop(
            station: mtj,
            scheduledArrival: '21:40',
            scheduledDeparture: '21:45',
            actualArrival: '21:52',
            actualDeparture: '21:57',
            platform: 3,
            distanceKm: 141,
            status: TrainStatus.delayed,
            delayMinutes: 12,
          ),
          TrainStop(
            station: agc,
            scheduledArrival: '22:20',
            scheduledDeparture: '22:25',
            actualArrival: '22:32',
            actualDeparture: '22:37',
            platform: 2,
            distanceKm: 195,
            status: TrainStatus.delayed,
            delayMinutes: 12,
          ),
          TrainStop(
            station: gwl,
            scheduledArrival: '23:50',
            scheduledDeparture: '23:55',
            actualArrival: '00:02',
            actualDeparture: '00:07',
            platform: 1,
            distanceKm: 313,
            status: TrainStatus.scheduled,
            delayMinutes: 12,
          ),
          TrainStop(
            station: bpl,
            scheduledArrival: '05:30',
            scheduledDeparture: '05:40',
            actualArrival: '05:42',
            actualDeparture: '05:50',
            platform: 1,
            distanceKm: 703,
            status: TrainStatus.scheduled,
            delayMinutes: 10,
          ),
        ],
      ),
    ];
  }

  void _startLiveSimulation() {
    _liveTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsCounter > 0) {
        _secondsCounter--;
      } else {
        _secondsCounter = 15 * 60; // reset loop for demo
      }

      // Small jitter in speed to simulate live telemetry
      if (_activeTrackedTrain != null) {
        final delta = (DateTime.now().millisecond % 5) - 2;
        _activeTrackedTrain!.currentSpeedKmph =
            (_activeTrackedTrain!.currentSpeedKmph + delta).clamp(70, 135);
      }
      notifyListeners();
    });
  }

  // Live countdown formatting
  String get formattedCountdownToBoarding {
    final minutes = _secondsCounter ~/ 60;
    final seconds = _secondsCounter % 60;
    return '${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  int get remainingMinutes => _secondsCounter ~/ 60;

  void setUserBoardingStation(Station station) {
    _userBoardingStation = station;
    // recalculate simulated countdown based on train ETA
    if (_activeTrackedTrain != null) {
      final etaMin = _activeTrackedTrain!.getMinutesUntilArrivalAt(station.code);
      _secondsCounter = (etaMin > 0 ? etaMin : 12) * 60;
    }
    notifyListeners();
  }

  void setActiveTrackedTrain(Train train) {
    _activeTrackedTrain = train;
    final etaMin = train.getMinutesUntilArrivalAt(_userBoardingStation.code);
    _secondsCounter = (etaMin > 0 ? etaMin : 14) * 60;
    notifyListeners();
  }

  List<Train> searchTrains(String fromCode, String toCode) {
    return _trains.where((t) {
      final hasFrom = t.stops.any((s) => s.station.code.toUpperCase() == fromCode.toUpperCase());
      final hasTo = t.stops.any((s) => s.station.code.toUpperCase() == toCode.toUpperCase());
      if (!hasFrom || !hasTo) return false;
      final fromIndex = t.stops.indexWhere((s) => s.station.code.toUpperCase() == fromCode.toUpperCase());
      final toIndex = t.stops.indexWhere((s) => s.station.code.toUpperCase() == toCode.toUpperCase());
      return fromIndex < toIndex;
    }).toList();
  }

  Train? getTrainByNumber(String number) {
    try {
      return _trains.firstWhere((t) => t.trainNumber == number || t.trainName.toLowerCase().contains(number.toLowerCase()));
    } catch (_) {
      return null;
    }
  }

  Station? getStationByQuery(String query) {
    final q = query.trim().toUpperCase();
    try {
      return allStations.firstWhere(
        (s) => s.code == q || s.name.toUpperCase().contains(q) || s.city.toUpperCase().contains(q),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _liveTicker?.cancel();
    super.dispose();
  }
}
