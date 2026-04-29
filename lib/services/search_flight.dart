import 'package:flutter/material.dart';
import 'package:ticketing_flutter/services/flight.dart';
import 'package:ticketing_flutter/public/home.dart';
import 'package:ticketing_flutter/public/bundle.dart';

final List<Flight> _mockFlights = [
  Flight(
    id: 1,
    flightNumber: "PR123",
    from: "Philippines - Manila",
    to: "Philippines - Cebu",
    airline: "Philippine Airlines",
    date: "2026-12-20",
    time: "08:00 AM",
    price: 125.00,
    departureTime: DateTime.parse("2025-12-20T08:00:00"),
    arrivalTime: DateTime.parse("2025-12-20T09:30:00"),
  ),
  Flight(
    id: 2,
    flightNumber: "5J456",
    from: "Philippines - Manila",
    to: "Philippines - Cebu",
    airline: "Cebu Pacific",
    date: "2025-12-20",
    time: "11:30 AM",
    price: 98.50,
    departureTime: DateTime.parse("2025-12-20T11:30:00"),
    arrivalTime: DateTime.parse("2025-12-20T13:00:00"),
  ),
  Flight(
    id: 3,
    flightNumber: "KE678",
    from: "Philippines - Cebu",
    to: "South Korea - Seoul",
    airline: "Korean Air",
    date: "2025-10-22",
    time: "02:00 PM",
    price: 420.75,
    departureTime: DateTime.parse("2025-10-22T14:00:00"),
    arrivalTime: DateTime.parse("2025-10-22T20:05:00"),
  ),
  Flight(
    id: 4,
    flightNumber: "DL905",
    from: "Japan - Tokyo",
    to: "Japan - Osaka",
    airline: "Delta Airlines",
    date: "2025-10-29",
    time: "10:00 PM",
    price: 180.00,
    departureTime: DateTime.parse("2025-10-29T22:00:00"),
    arrivalTime: DateTime.parse("2025-10-29T23:10:00"),
  ),
  Flight(
    id: 5,
    flightNumber: "SQ908",
    from: "Singapore - Singapore",
    to: "Philippines - Manila",
    airline: "Singapore Airlines",
    date: "2025-11-05",
    time: "07:45 AM",
    price: 310.40,
    departureTime: DateTime.parse("2025-11-05T07:45:00"),
    arrivalTime: DateTime.parse("2025-11-05T11:25:00"),
  ),
  Flight(
    id: 6,
    flightNumber: "QF718",
    from: "Australia - Sydney",
    to: "Philippines - Manila",
    airline: "Qantas",
    date: "2025-11-05",
    time: "09:00 AM",
    price: 512.30,
    departureTime: DateTime.parse("2025-11-05T09:00:00"),
    arrivalTime: DateTime.parse("2025-11-05T15:10:00"),
  ),
];

class SearchFlightsPage extends StatefulWidget {
  final String from;
  final String to;
  final String departureDate;
  final int adults;
  final int children;
  final int infants;

  const SearchFlightsPage({
    super.key,
    required this.from,
    required this.to,
    required this.departureDate,
    required this.adults,
    required this.children,
    required this.infants,
  });

  @override
  State<SearchFlightsPage> createState() => _SearchFlightsPageState();
}

class _SearchFlightsPageState extends State<SearchFlightsPage> {
  String selectedTripType = "One Way";
  final List<String> tripTypes = ["One Way", "Roundtrip", "Multicity"];
  late Future<List<Flight>> _flightsFuture;
  double? _selectedTotalPrice;
  String _selectedClass = "Economy"; // default travel class

  @override
  void initState() {
    super.initState();
    _flightsFuture = _loadFlights();
  }

  String _normalizeDate(String value) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) return value.trim().toLowerCase();
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  Future<List<Flight>> _loadFlights() async {
    await Future.delayed(const Duration(milliseconds: 350));
    final routeMatches = _mockFlights.where((flight) {
      final fromMatch =
          flight.from.toLowerCase().contains(widget.from.toLowerCase()) ||
          widget.from.toLowerCase().contains(flight.from.toLowerCase());

      final toMatch =
          flight.to.toLowerCase().contains(widget.to.toLowerCase()) ||
          widget.to.toLowerCase().contains(flight.to.toLowerCase());

      return fromMatch && toMatch;
    }).toList();

    final targetDate = _normalizeDate(widget.departureDate);
    final dateMatches = routeMatches
        .where((flight) => _normalizeDate(flight.date) == targetDate)
        .toList();

    // If no exact date match exists, still show same-route options.
    return dateMatches.isNotEmpty ? dateMatches : routeMatches;
  }

  void _navigateToPage(String tripType) {
    Widget page;

    switch (tripType) {
      case "One Way":
        page = SearchFlightsPage(
          from: widget.from,
          to: widget.to,
          departureDate: widget.departureDate,
          adults: widget.adults,
          children: widget.children,
          infants: widget.infants,
        );
        break;
      case "Roundtrip":
        page = const Home();
        break;
      case "Multicity":
        page = const Home();
        break;
      default:
        page = SearchFlightsPage(
          from: widget.from,
          to: widget.to,
          departureDate: widget.departureDate,
          adults: widget.adults,
          children: widget.children,
          infants: widget.infants,
        );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Read arguments passed via RouteSettings.arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (_selectedTotalPrice == null) {
        final raw = args['selectedPrice'];
        if (raw is double) _selectedTotalPrice = raw;
        if (raw is int) _selectedTotalPrice = raw.toDouble();
      }
      if (args['selectedClass'] != null) {
        _selectedClass = args['selectedClass'] as String;
      }
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Available Flights + Trip Type
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Available Flights",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Choose your option",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: selectedTripType,
                  underline: Container(),
                  items: tripTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTripType = newValue!;
                    });
                    _navigateToPage(newValue!);
                  },
                ),
              ],
            ),
          ),

          // Travel Class Selector

          // Flight List
          Expanded(
            child: FutureBuilder<List<Flight>>(
              future: _flightsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No flights available"));
                }

                final flights = snapshot.data!;
                return ListView.builder(
                  itemCount: flights.length,
                  itemBuilder: (context, index) {
                    final flight = flights[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: InkWell(
                        splashColor: const Color.fromARGB(
                          255,
                          20,
                          92,
                          151,
                        ).withAlpha(80),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      FlightBundlesPage(
                                        flight: flight,
                                        adults: widget.adults,
                                        children: widget.children,
                                        infants: widget.infants,
                                      ),
                              settings: RouteSettings(
                                arguments: {
                                  'selectedPrice': _selectedTotalPrice,
                                  'selectedClass': _selectedClass,
                                },
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: const Icon(
                            Icons.flight_takeoff,
                            color: Colors.blue,
                          ),
                          title: Text("${flight.from} →\n${flight.to}"),
                          subtitle: Text(
                            "Flight ${flight.flightNumber} · ${flight.airline}\n"
                            "Date: ${flight.date}  Time: ${flight.time}",
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
