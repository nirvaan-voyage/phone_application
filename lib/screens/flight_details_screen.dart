import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/flight_model.dart'; // Make sure this matches your model file name!

class FlightDetailsScreen extends StatelessWidget {
  final Flight flight;

  const FlightDetailsScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review Booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1a3a5c),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // THE DIGITAL TICKET
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Half: Flight Info
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(flight.departure, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1D3F63))),
                            const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF2A5480), size: 32),
                            Text(flight.arrival, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1D3F63))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Airline', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                Text(flight.airline, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Class', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                Text('Economy', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // The Dashed Divider Line
                  Row(
                    children: [
                      const SizedBox(height: 20, width: 10, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFF4F6FA), borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))))),
                      Expanded(child: LayoutBuilder(builder: (context, constraints) {
                        return Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: List.generate((constraints.constrainWidth() / 10).floor(), (index) => SizedBox(width: 5, height: 1.5, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey.shade300)))),
                        );
                      })),
                      const SizedBox(height: 20, width: 10, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFF4F6FA), borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))))),
                    ],
                  ),

                  // Bottom Half: Price
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Fare', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
                        Text('${flight.currency} ${flight.price}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.green.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // PROCEED TO PAYMENT BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Processing payment for ${flight.airline}...'),
                      backgroundColor: const Color(0xFF2A5480),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5480),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: Text('Proceed to Payment', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}