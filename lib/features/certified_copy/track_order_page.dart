import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';
import 'certified_copy_token_page.dart';

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final TextEditingController _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<OrderModel>>? _userOrdersFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserOrders();
  }

  void _fetchUserOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userOrdersFuture = _firestoreService.getUserOrders(user.uid);
      });
    }
  }

  void _trackOrder({String? token}) {
    final tokenToTrack = token ?? _tokenController.text.trim();
    if (token == null && !_formKey.currentState!.validate()) return;
    if (tokenToTrack.isEmpty) return;

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CertifiedCopyTokenPage(
            token: tokenToTrack,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to OrderTimelinePage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Could not track order. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Track Order',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A032A),
              Color(0xFF1A0B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Enter Token Number',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the token number you received after payment to track your certified copy request.',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _tokenController,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'e.g., MP-REG-2024-1234',
                            hintStyle:
                                GoogleFonts.poppins(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.2),
                            prefixIcon: const Icon(Iconsax.ticket,
                                color: Color(0xFF02F1C3), size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFF02F1C3), width: 1.5),
                            ),
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter token number' : null,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _trackOrder(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF02F1C3),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Track Status',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_userOrdersFuture != null) ...[
                    Text(
                      'Your Recent Orders',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<OrderModel>>(
                      future: _userOrdersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Error loading orders',
                            style: GoogleFonts.poppins(color: Colors.red),
                          );
                        }
                        final orders = snapshot.data ?? [];
                        if (orders.isEmpty) {
                          return Text(
                            'No recent orders found.',
                            style: GoogleFonts.poppins(color: Colors.white54),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return _buildOrderCard(order);
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () => _trackOrder(token: order.token),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF02F1C3).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.document_text,
                color: Color(0xFF02F1C3),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.token,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'searching':
        return Colors.orange;
      case 'found':
        return Colors.blue;
      case 'not_found':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
