enum TrainStatus { onTime, delayed, arrived, departed, scheduled }

class Station {
  final String code;
  final String name;
  final String city;
  final int platforms;

  const Station({
    required this.code,
    required this.name,
    required this.city,
    this.platforms = 8,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Station && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class TrainStop {
  final Station station;
  final String scheduledArrival;
  final String scheduledDeparture;
  String actualArrival;
  String actualDeparture;
  int platform;
  final double distanceKm;
  TrainStatus status;
  int delayMinutes;

  TrainStop({
    required this.station,
    required this.scheduledArrival,
    required this.scheduledDeparture,
    required this.actualArrival,
    required this.actualDeparture,
    required this.platform,
    required this.distanceKm,
    this.status = TrainStatus.scheduled,
    this.delayMinutes = 0,
  });
}

class SeatClass {
  final String code; // 1A, 2A, 3A, SL, CC, EC
  final String name; // AC First, AC 2-Tier, AC 3-Tier, Sleeper, Chair Car, Exec
  final double fare;
  final int availableSeats;
  final String statusText; // "AVAILABLE-42", "RAC 12", "WL 5"

  const SeatClass({
    required this.code,
    required this.name,
    required this.fare,
    required this.availableSeats,
    required this.statusText,
  });
}

class Train {
  final String trainNumber;
  final String trainName;
  final String trainType; // Vande Bharat, Rajdhani Superfast, Shatabdi, Superfast
  final Station source;
  final Station destination;
  final List<TrainStop> stops;
  final List<SeatClass> classes;
  int currentSpeedKmph;
  String currentLocationDescription;
  int currentStopIndex;
  int delayMinutes;
  final List<String> coaches; // ['ENG', 'EOG', 'C1', 'C2', 'C3', 'E1', 'EOG']

  Train({
    required this.trainNumber,
    required this.trainName,
    required this.trainType,
    required this.source,
    required this.destination,
    required this.stops,
    required this.classes,
    this.currentSpeedKmph = 85,
    this.currentLocationDescription = 'Approaching Mathura Junction',
    this.currentStopIndex = 1,
    this.delayMinutes = 4,
    required this.coaches,
  });

  TrainStop? getStopForStation(String stationCode) {
    for (final stop in stops) {
      if (stop.station.code.toUpperCase() == stationCode.toUpperCase()) {
        return stop;
      }
    }
    return null;
  }

  // Calculate ETA in minutes to a given station code
  int getMinutesUntilArrivalAt(String stationCode) {
    final targetIndex = stops.indexWhere(
      (s) => s.station.code.toUpperCase() == stationCode.toUpperCase(),
    );
    if (targetIndex == -1) return -1;
    if (targetIndex < currentStopIndex) return 0; // Already passed

    // Approximate travel time based on remaining stops + delay
    int stopsAway = targetIndex - currentStopIndex;
    int baseMinutes = stopsAway * 35 + (targetIndex == currentStopIndex ? 12 : 0);
    return (baseMinutes + delayMinutes).clamp(1, 1440);
  }
}

class Booking {
  final String pnr;
  final String trainNumber;
  final String trainName;
  final String trainType;
  final Station sourceStation;
  final Station destinationStation;
  final DateTime travelDate;
  final String departureTime;
  final String arrivalTime;
  final String coach;
  final String seatNumber;
  final String berthType; // Lower, Middle, Upper, Side Lower, Window
  final String seatClass;
  final String passengerName;
  final int passengerAge;
  final String passengerGender;
  final double fare;
  final String status; // CONFIRMED, RAC, WL
  final int platform;

  Booking({
    required this.pnr,
    required this.trainNumber,
    required this.trainName,
    required this.trainType,
    required this.sourceStation,
    required this.destinationStation,
    required this.travelDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.coach,
    required this.seatNumber,
    required this.berthType,
    required this.seatClass,
    required this.passengerName,
    required this.passengerAge,
    required this.passengerGender,
    required this.fare,
    this.status = 'CONFIRMED',
    this.platform = 3,
  });
}

enum MessageSender { user, ai, system }

class ChatAction {
  final String label;
  final String actionType; // 'view_ticket', 'track_train', 'confirm_booking', 'quick_query'
  final dynamic payload;

  ChatAction({
    required this.label,
    required this.actionType,
    this.payload,
  });
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final List<String> suggestedChips;
  final List<ChatAction> actions;
  final Booking? bookingCard;
  final Train? trainStatusCard;
  final List<String>? reasoningSteps;
  final bool isThinking;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.suggestedChips = const [],
    this.actions = const [],
    this.bookingCard,
    this.trainStatusCard,
    this.reasoningSteps,
    this.isThinking = false,
  });
}
