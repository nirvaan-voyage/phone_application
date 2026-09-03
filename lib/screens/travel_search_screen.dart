import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/travel_search_service.dart';
import '../models/travel_search_item.dart';

class TravelSearchScreen extends StatefulWidget {
  const TravelSearchScreen({
    super.key,
    required this.category,
    required this.title,
    required this.icon,
  });

  final String category;
  final String title;
  final IconData icon;

  @override
  State<TravelSearchScreen> createState() => _TravelSearchScreenState();
}

class _TravelSearchScreenState extends State<TravelSearchScreen> {
  final _service = TravelSearchService();
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late final TextEditingController _cityController;
  late Future<List<TravelSearchItem>> _future;

  @override
  void initState() {
    super.initState();
    final defaults = _defaultInputsFor(widget.category);
    _fromController = TextEditingController(text: defaults.from);
    _toController = TextEditingController(text: defaults.to);
    _cityController = TextEditingController(text: defaults.city);
    _future = _search();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<List<TravelSearchItem>> _search() {
    return _service.search(
      category: widget.category,
      from: _fromController.text,
      to: _toController.text,
      city: _cityController.text,
      date: DateTime.now()
          .add(const Duration(days: 14))
          .toIso8601String()
          .split('T')
          .first,
    );
  }

  void _refresh() {
    setState(() {
      _future = _search();
    });
  }

  bool get _usesRoute =>
      widget.category == 'trains' ||
      widget.category == 'buses' ||
      widget.category == 'flights';

  String get _fromLabel =>
      widget.category == 'trains' ? 'From station code' : 'From';

  String get _toLabel => widget.category == 'trains' ? 'To station code' : 'To';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1a3a5c),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _usesRoute
                ? _RouteInputs(
                    onSearch: _refresh,
                    fromController: _fromController,
                    toController: _toController,
                    fromLabel: _fromLabel,
                    toLabel: _toLabel,
                  )
                : _CityInput(onSearch: _refresh, controller: _cityController),
          ),
          Expanded(
            child: FutureBuilder<List<TravelSearchItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    ),
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${widget.title.toLowerCase()} found in India.',
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _TravelCard(
                    item: items[index],
                    icon: widget.icon,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteInputs extends StatelessWidget {
  const _RouteInputs({
    required this.onSearch,
    required this.fromController,
    required this.toController,
    required this.fromLabel,
    required this.toLabel,
  });

  final VoidCallback onSearch;
  final TextEditingController fromController;
  final TextEditingController toController;
  final String fromLabel;
  final String toLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _SearchField(controller: fromController, label: fromLabel)),
        const SizedBox(width: 10),
        Expanded(child: _SearchField(controller: toController, label: toLabel)),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }
}

class _CityInput extends StatelessWidget {
  const _CityInput({required this.onSearch, required this.controller});

  final VoidCallback onSearch;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _SearchField(controller: controller, label: 'Indian city')),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: onSearch,
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _TravelCard extends StatelessWidget {
  const _TravelCard({required this.item, required this.icon});

  final TravelSearchItem item;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final routeParts = <String>[
      if (item.origin?.isNotEmpty == true) item.origin!,
      if (item.destination?.isNotEmpty == true) item.destination!,
    ];
    final route = routeParts.join(' to ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF3D6B9E).withValues(alpha: 0.12),
            child: Icon(icon, color: const Color(0xFF2A5480)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D3F63),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  route.isNotEmpty ? route : item.subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.provider,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          if (item.price != null)
            Text(
              '${item.currency ?? 'INR'} ${item.price}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.green.shade700,
              ),
            ),
        ],
      ),
    );
  }
}

({String from, String to, String city}) _defaultInputsFor(String category) {
  switch (category) {
    case 'trains':
      return (from: 'NDLS', to: 'BCT', city: 'Mumbai');
    case 'flights':
      return (from: 'DEL', to: 'BOM', city: 'Mumbai');
    case 'buses':
      return (from: 'Delhi', to: 'Jaipur', city: 'Jaipur');
    case 'hotels':
      return (from: 'Delhi', to: 'Mumbai', city: 'Delhi');
    case 'shows':
      return (from: 'Delhi', to: 'Mumbai', city: 'Mumbai');
    default:
      return (from: 'Delhi', to: 'Mumbai', city: 'Mumbai');
  }
}
