import 'package:ticketing_flutter/public/booking_confirmation.dart';
import 'package:ticketing_flutter/services/flight.dart';
import 'package:ticketing_flutter/user/account_details.dart';

class UserBookingConfirmationPage extends BookingConfirmationPage {
  UserBookingConfirmationPage({
    super.key,
    required Flight flight,
    required Map<String, dynamic> bundle,
    required List<Map<String, dynamic>> guests,
    required List<String> seatAssignments,
    required double selectedPrice,
    required String travelClass,
    required int adults,
    required int children,
    required int infants,
    String? paymentMethod,
  }) : super(
         flight: flight,
         bundle: bundle,
         guests: guests,
         seatAssignments: seatAssignments,
         selectedPrice: selectedPrice,
         travelClass: travelClass,
         adults: adults,
         children: children,
         infants: infants,
         paymentMethod: paymentMethod,
         accountCtaPageBuilder: (context) => const UserAccountDetailsPage(),
       );
}
