import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const StockDispatchApp());
}

class StockDispatchApp extends StatefulWidget {
  const StockDispatchApp({super.key});

  @override
  State<StockDispatchApp> createState() => _StockDispatchAppState();
}

class _StockDispatchAppState extends State<StockDispatchApp> {
  bool isAmharic = true; // Default language: Amharic

  void toggleLanguage() {
    setState(() {
      isAmharic = !isAmharic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Dispatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          primary: const Color(0xFFD32F2F),
        ),
        useMaterial3: true,
      ),
      home: MainNavigationScreen(
        isAmharic: isAmharic,
        onToggleLanguage: toggleLanguage,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final bool isAmharic;
  final VoidCallback onToggleLanguage;

  const MainNavigationScreen({
    super.key,
    required this.isAmharic,
    required this.onToggleLanguage,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String firebaseUrl = "https://coolday-dispatch-default-rtdb.firebaseio.com";

  @override
  Widget build(BuildContext context) {
    final isAm = widget.isAmharic;

    final screens = [
      SalesRequestScreen(
        databaseUrl: firebaseUrl,
        isAmharic: isAm,
        onToggleLanguage: widget.onToggleLanguage,
      ),
      WarehouseDashboardScreen(
        databaseUrl: firebaseUrl,
        isAmharic: isAm,
        onToggleLanguage: widget.onToggleLanguage,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: isAm ? 'ሴልስ (Sales)' : 'Sales',
          ),
          NavigationDestination(
            icon: const Icon(Icons.warehouse_outlined),
            selectedIcon: const Icon(Icons.warehouse),
            label: isAm ? 'መጋዘን (Store)' : 'Warehouse',
          ),
        ],
      ),
    );
  }
}

// ------------------- 1. SALES SCREEN -------------------
class SalesRequestScreen extends StatefulWidget {
  final String databaseUrl;
  final bool isAmharic;
  final VoidCallback onToggleLanguage;

  const SalesRequestScreen({
    super.key,
    required this.databaseUrl,
    required this.isAmharic,
    required this.onToggleLanguage,
  });

  @override
  State<SalesRequestScreen> createState() => _SalesRequestScreenState();
}

class _SalesRequestScreenState extends State<SalesRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController();
  final _requesterController = TextEditingController();
  final _customerController = TextEditingController();
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final url = Uri.parse("${widget.databaseUrl}/requests.json");

    final payload = {
      "item": _itemController.text.trim(),
      "quantity": _qtyController.text.trim(),
      "requester": _requesterController.text.trim(),
      "customer": _customerController.text.trim(),
      "purpose": _purposeController.text.trim(),
      "notes": _notesController.text.trim(),
      "status": "Pending",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    try {
      final res = await http.post(url, body: jsonEncode(payload));
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isAmharic
                  ? 'የእቃ ጥያቄው ወደ መጋዘን በተሳካ ሁኔታ ተልኳል!'
                  : 'Dispatch request sent successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _itemController.clear();
        _qtyController.clear();
        _customerController.clear();
        _purposeController.clear();
        _notesController.clear();
      } else {
        throw Exception();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isAmharic
                ? 'ስህተት ተፈጥሯል፤ እባክዎ ኢንተርኔትዎን ያረጋግጡ'
                : 'Network error. Please verify your connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAm = widget.isAmharic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAm ? 'የእቃ መጠየቂያ ቅጽ' : 'Dispatch Request Form'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language, color: Colors.white, size: 20),
            label: Text(
              isAm ? 'English' : 'አማርኛ',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _itemController,
                decoration: InputDecoration(
                  labelText: isAm ? 'የእቃው ስም እና ሞዴል' : 'Item Name & Model',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty
                    ? (isAm ? 'እባክዎ የእቃውን ስም ያስገቡ' : 'Please enter item name')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAm ? 'ብዛት (Quantity)' : 'Quantity (PCS/Units)',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty
                    ? (isAm ? 'ብዛት ያስገቡ' : 'Please enter quantity')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _requesterController,
                decoration: InputDecoration(
                  labelText: isAm ? 'ጠያቂው (Sales Person)' : 'Requested By',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty
                    ? (isAm ? 'ስምዎን ያስገቡ' : 'Please enter your name')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerController,
                decoration: InputDecoration(
                  labelText: isAm ? 'የደንበኛው ስም (Customer)' : 'Customer / Company Name',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty
                    ? (isAm ? 'የደንበኛ ስም ያስገቡ' : 'Please enter customer name')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _purposeController,
                decoration: InputDecoration(
                  labelText: isAm ? 'ዓላማ (ቀጥታ ሽያጭ፣ የቅርንጫፍ ዝውውር)' : 'Purpose (Direct Sale, Transfer)',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty
                    ? (isAm ? 'ዓላማውን ይጥቀሱ' : 'Please enter purpose')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: isAm ? 'ተጨማሪ ማስታወሻ / ደረሰኝ ቁጥር' : 'Notes / Invoice Ref (Optional)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                  ),
                  icon: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.send),
                  label: Text(
                    isAm ? 'ወደ መጋዘን ላክ' : 'Send to Warehouse',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- 2. WAREHOUSE SCREEN -------------------
class WarehouseDashboardScreen extends StatefulWidget {
  final String databaseUrl;
  final bool isAmharic;
  final VoidCallback onToggleLanguage;

  const WarehouseDashboardScreen({
    super.key,
    required this.databaseUrl,
    required this.isAmharic,
    required this.onToggleLanguage,
  });

  @override
  State<WarehouseDashboardScreen> createState() => _WarehouseDashboardScreenState();
}

class _WarehouseDashboardScreenState extends State<WarehouseDashboardScreen> {
  List> _requests = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _fetchRequests());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    final url = Uri.parse("${widget.databaseUrl}/requests.json");
    try {
      final res = await http.get(url);
      if (res.statusCode == 200 && res.body != "null") {
        final Map<String, dynamic> data = jsonDecode(res.body);
        final List> loaded = [];
        data.forEach((key, val) {
          loaded.add({"id": key, ...val});
        });
        loaded.sort((a, b) => (b["timestamp"] ?? 0).compareTo(a["timestamp"] ?? 0));
        if (mounted) setState(() => _requests = loaded);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    final url = Uri.parse("${widget.databaseUrl}/requests/$id.json");
    await http.patch(url, body: jsonEncode({"status": newStatus}));
    _fetchRequests();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved": return Colors.blue;
      case "Dispatched": return Colors.green;
      case "Rejected": return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getStatusText(String status, bool isAm) {
    switch (status) {
      case "Approved": return isAm ? 'ተፈቅዷል' : 'Approved';
      case "Dispatched": return isAm ? 'ተልኳል' : 'Dispatched';
      case "Rejected": return isAm ? 'ውድቅ ተደርጓል' : 'Rejected';
      default: return isAm ? 'በመጠባበቅ ላይ' : 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAm = widget.isAmharic;

    return Scaffold(
      appBar: AppBar(
