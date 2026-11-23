// Cool Day Ethiopia - Warehouse Dispatch & Sales Order + Store Stock Card
// Single-file Flutter application with animated splash screen, bilingual support, and Firebase sync.
//
// Dependencies in pubspec.yaml:
//   flutter:
//     sdk: flutter
//   http: ^1.2.0
//   intl: ^0.19.0

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ============================================================================
// CONFIGURATION
// ============================================================================

String firebaseUrl = "https://moha-cbdcc-default-rtdb.firebaseio.com";

const String kRoleAdmin = 'admin';
const String kRoleSales = 'sales';
const String kRoleStore = 'store';

const List<String> kStatuses = ['Pending', 'Approved', 'Dispatched', 'Rejected'];
const List<String> kPayments = ['Cash', 'Bank Transfer', 'Credit', 'Cheque'];
const List<String> kWarehouses = ['Main Warehouse', 'Showroom Store', 'Shop Store'];

// ============================================================================
// TRANSLATIONS (English & Amharic)
// ============================================================================

const Map<String, String> _valKeys = {
  'Pending': 'pending',
  'Approved': 'approved',
  'Dispatched': 'dispatched',
  'Rejected': 'rejected',
  'Cash': 'cash',
  'Bank Transfer': 'bank',
  'Credit': 'credit',
  'Cheque': 'cheque',
  'Main Warehouse': 'main_wh',
  'Showroom Store': 'showroom_wh',
  'Shop Store': 'shop_wh',
  'In Stock': 'in_stock',
  'Low Stock Alert': 'low_stock',
  'Out of Stock': 'out_stock',
  'All': 'all',
};

const Map<String, Map<String, String>> _tr = {
  'en': {
    'app_title': 'Cool Day Store Order',
    'app_subtitle': 'Warehouse Dispatch & Sales Order',
    'sign_in': 'Sign In',
    'select_role': 'Select your role',
    'admin': 'Admin',
    'sales': 'Sales',
    'store': 'Warehouse Keeper',
    'admin_desc': 'Full control of stock, orders and analytics',
    'sales_desc': 'Check stock and submit dispatch orders',
    'store_desc': 'Verify, approve and dispatch orders',
    'pin': 'PIN',
    'your_name': 'Your name',
    'wrong_pin': 'Wrong PIN. Try again.',
    'required': 'This field is required',
    'logout': 'Logout',
    'dashboard': 'Dashboard',
    'orders': 'Orders',
    'stock': 'Stock',
    'new_order': 'New Order',
    'queue': 'Dispatch Queue',
    'total_sales': 'Total Sales (Dispatched)',
    'today_sales': "Today's Sales",
    'pending': 'Pending',
    'approved': 'Approved',
    'dispatched': 'Dispatched',
    'rejected': 'Rejected',
    'all': 'All',
    'low_stock': 'Low Stock Alert',
    'in_stock': 'In Stock',
    'out_stock': 'Out of Stock',
    'item_name_model': 'Item Name / Model / Code',
    'brand': 'Brand',
    'quantity': 'Quantity Sold',
    'unit_price': 'Unit Price (ETB)',
    'total_amount': 'Total Amount',
    'payment_status': 'Payment Status',
    'cash': 'Cash',
    'bank': 'Bank Transfer',
    'credit': 'Credit',
    'cheque': 'Cheque',
    'customer': 'Customer Name & Phone Number',
    'customer_hint': 'e.g. Abebe Kebede - 0911 000 000',
    'ordered_by': 'Ordered By (Sales Rep)',
    'signature': 'Digital Signature',
    'signature_hint': 'Type your full name to confirm',
    'store_verification': 'Store Verification / Dispatched Warehouse',
    'warehouse_pending': 'Not assigned yet',
    'main_wh': 'Main Warehouse',
    'showroom_wh': 'Showroom Store',
    'shop_wh': 'Shop Store',
    'status': 'Status',
    'submit': 'Submit Order',
    'approve': 'Approve',
    'reject': 'Reject',
    'dispatch': 'Mark Dispatched',
    'delete': 'Delete',
    'cancel': 'Cancel',
    'save': 'Save',
    'confirm': 'Confirm',
    'add_item': 'Add Stock Item',
    'edit_item': 'Edit Item',
    'edit': 'Edit',
    'stock_in_btn': 'Stock In',
    'item_no': 'Item No.',
    'opening_stock': 'Opening Stock',
    'stock_in': 'Stock In',
    'stock_out': 'Stock Out',
    'remaining': 'Remaining',
    'reorder_level': 'Reorder Level',
    'order_no': 'Order No.',
    'date_time': 'Date & Time',
    'search': 'Search...',
    'no_data': 'Nothing here yet',
    'online': 'Live sync',
    'offline': 'Offline - retrying...',
    'change_pins': 'Change PINs',
    'view_admin': 'View as Admin',
    'view_sales': 'View as Sales',
    'view_store': 'View as Warehouse Keeper',
    'insufficient': 'Not enough stock',
    'order_submitted': 'Order submitted successfully',
    'saved': 'Saved',
    'confirm_delete': 'Delete this item permanently?',
    'confirm_delete_dispatched':
        'This order is already dispatched. Deleting it will return the quantity to stock. Continue?',
    'confirm_dispatch': 'Mark as dispatched? The quantity will be deducted from stock.',
    'confirm_reject': 'Reject this order?',
    'available': 'Available',
    'invalid_number': 'Enter a valid number',
    'sales_by_payment': 'Sales by Payment Type',
    'top_items': 'Top Selling Items',
    'total_orders': 'Total Orders',
    'new_pin': 'New PIN (min. 4 characters)',
    'pin_invalid': 'PIN must be at least 4 characters',
    'override_status': 'Override status',
    'warehouse_required': 'Choose or type a warehouse',
    'mine_only': 'My orders',
    'etb': 'ETB',
    'items_count': 'Stock Items',
    'low_items': 'Low / Out of Stock',
    'low_alerts': 'Low Stock Alerts',
    'network_error': 'Network error. Check your connection.',
    'item_missing': 'Stock item not found',
    'stock_updated': 'Stock updated',
    'qty_to_add': 'Quantity to add',
    'pins_saved': 'PINs updated',
    'sold_units': 'sold',
    'units_left': 'Units in stock',
    'viewing_as': 'Viewing as',
  },
  'am': {
    'app_title': 'የ Cool Day መጋዘን ትዕዛዝ',
    'app_subtitle': 'የመጋዘን እቃ መውጫ እና የሽያጭ ትዕዛዝ',
    'sign_in': 'ግባ',
    'select_role': 'ሚናዎን ይምረጡ',
    'admin': 'አስተዳዳሪ',
    'sales': 'ሽያጭ',
    'store': 'መጋዘን ጠባቂ',
    'admin_desc': 'የክምችት፣ የትዕዛዞችና የትንታኔ ሙሉ ቁጥጥር',
    'sales_desc': 'ክምችት ይመልከቱ እና የመላኪያ ትዕዛዝ ያስገቡ',
    'store_desc': 'ትዕዛዞችን ያረጋግጡ፣ ያጽድቁ እና ይላኩ',
    'pin': 'ፒን',
    'your_name': 'ስምዎ',
    'wrong_pin': 'የተሳሳተ ፒን። እንደገና ይሞክሩ።',
    'required': 'ይህ መስክ ያስፈልጋል',
    'logout': 'ውጣ',
    'dashboard': 'ዳሽቦርድ',
    'orders': 'ትዕዛዞች',
    'stock': 'ክምችት',
    'new_order': 'አዲስ ትዕዛዝ',
    'queue': 'የመላኪያ ወረፋ',
    'total_sales': 'ጠቅላላ ሽያጭ (የተላከ)',
    'today_sales': 'የዛሬ ሽያጭ',
    'pending': 'በመጠባበቅ ላይ',
    'approved': 'ጸድቋል',
    'dispatched': 'ተልኳል',
    'rejected': 'ውድቅ ተደርጓል',
    'all': 'ሁሉም',
    'low_stock': 'ዝቅተኛ ክምችት ማስጠንቀቂያ',
    'in_stock': 'በክምችት አለ',
    'out_stock': 'ክምችት አልቋል',
    'item_name_model': 'የዕቃ ስም / ሞዴል / ኮድ',
    'brand': 'ብራንድ',
    'quantity': 'የተሸጠ ብዛት',
    'unit_price': 'የአንዱ ዋጋ (ብር)',
    'total_amount': 'ጠቅላላ መጠን',
    'payment_status': 'የክፍያ ሁኔታ',
    'cash': 'ጥሬ ገንዘብ',
    'bank': 'የባንክ ዝውውር',
    'credit': 'ዱቤ',
    'cheque': 'ቼክ',
    'customer': 'የደንበኛ ስም እና ስልክ ቁጥር',
    'customer_hint': 'ለምሳሌ አበበ ከበደ - 0911 000 000',
    'ordered_by': 'ያዘዘው (የሽያጭ ሠራተኛ)',
    'signature': 'ዲጂታል ፊርማ',
    'signature_hint': 'ለማረጋገጥ ሙሉ ስምዎን ይጻፉ',
    'store_verification': 'የመጋዘን ማረጋገጫ / የተላከበት መጋዘን',
    'warehouse_pending': 'እስካሁን አልተመደበም',
    'main_wh': 'ዋና መጋዘን',
    'showroom_wh': 'የሾውሩም መደብር',
    'shop_wh': 'የሱቅ መደብር',
    'status': 'ሁኔታ',
    'submit': 'ትዕዛዝ አስገባ',
    'approve': 'አጽድቅ',
    'reject': 'ውድቅ አድርግ',
    'dispatch': 'እንደተላከ ምልክት አድርግ',
    'delete': 'ሰርዝ',
    'cancel': 'ይቅር',
    'save': 'አስቀምጥ',
    'confirm': 'አረጋግጥ',
    'add_item': 'የክምችት ዕቃ ጨምር',
    'edit_item': 'ዕቃ አስተካክል',
    'edit': 'አስተካክል',
    'stock_in_btn': 'ክምችት ጨምር',
    'item_no': 'የዕቃ ቁጥር',
    'opening_stock': 'መነሻ ክምችት',
    'stock_in': 'የገባ ክምችት',
    'stock_out': 'የወጣ ክምችት',
    'remaining': 'ቀሪ',
    'reorder_level': 'የማዘዣ ደረጃ',
    'order_no': 'የትዕዛዝ ቁጥር',
    'date_time': 'ቀን እና ሰዓት',
    'search': 'ፈልግ...',
    'no_data': 'እስካሁን ምንም የለም',
    'online': 'ቀጥታ ማመሳሰል',
    'offline': 'ከመስመር ውጭ - እንደገና በመሞከር ላይ...',
    'change_pins': 'ፒን ቀይር',
    'view_admin': 'እንደ አስተዳዳሪ ይመልከቱ',
    'view_sales': 'እንደ ሽያጭ ይመልከቱ',
    'view_store': 'እንደ መጋዘን ጠባቂ ይመልከቱ',
    'insufficient': 'በቂ ክምችት የለም',
    'order_submitted': 'ትዕዛዝ በተሳካ ሁኔታ ገብቷል',
    'saved': 'ተቀምጧል',
    'confirm_delete': 'ይህ በቋሚነት ይሰረዝ?',
    'confirm_delete_dispatched':
        'ይህ ትዕዛዝ ቀድሞ ተልኳል። ሲሰረዝ ብዛቱ ወደ ክምችት ይመለሳል። ይቀጥሉ?',
    'confirm_dispatch': 'እንደተላከ ምልክት ይደረግ? ብዛቱ ከክምችት ይቀነሳል።',
    'confirm_reject': 'ይህ ትዕዛዝ ውድቅ ይደረግ?',
    'available': 'ይገኛል',
    'invalid_number': 'ትክክለኛ ቁጥር ያስገቡ',
    'sales_by_payment': 'ሽያጭ በክፍያ አይነት',
    'top_items': 'በብዛት የተሸጡ ዕቃዎች',
    'total_orders': 'ጠቅላላ ትዕዛዞች',
    'new_pin': 'አዲስ ፒን (ቢያንስ 4 ቁምፊ)',
    'pin_invalid': 'ፒን ቢያንስ 4 ቁምፊ መሆን አለበት',
    'override_status': 'ሁኔታ ቀይር',
    'warehouse_required': 'መጋዘን ይምረጡ ወይም ይጻፉ',
    'mine_only': 'የእኔ ትዕዛዞች',
    'etb': 'ብር',
    'items_count': 'የክምችት ዕቃዎች',
    'low_items': 'ዝቅተኛ / ያለቀ',
    'low_alerts': 'የዝቅተኛ ክምችት ማስጠንቀቂያዎች',
    'network_error': 'የኔትወርክ ችግር። ግንኙነትዎን ያረጋግጡ።',
    'item_missing': 'የክምችት ዕቃ አልተገኘም',
    'stock_updated': 'ክምችት ተዘምኗል',
    'qty_to_add': 'የሚጨመር ብዛት',
    'pins_saved': 'ፒኖች ተዘምነዋል',
    'sold_units': 'ተሸጧል',
    'units_left': 'በክምችት ያሉ ክፍሎች',
    'viewing_as': 'እንደ ሚና እየታየ ያለ',
  },
};

// ============================================================================
// HELPERS
// ============================================================================

double _d(dynamic v) => v is num ? v.toDouble() : (double.tryParse('$v') ?? 0);
int _i(dynamic v) => v is num ? v.toInt() : (int.tryParse('$v') ?? 0);

Color alpha(Color c, double o) => c.withAlpha((o * 255).round());

Color statusColor(String s) {
  switch (s) {
    case 'Pending':
      return Colors.orange;
    case 'Approved':
      return Colors.blue;
    case 'Dispatched':
      return Colors.green;
    case 'Rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

Color stockColor(String s) {
  switch (s) {
    case 'In Stock':
      return Colors.green;
    case 'Low Stock Alert':
      return Colors.orange;
    case 'Out of Stock':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

InputDecoration deco(String label, {IconData? icon, String? hint}) => InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

void toast(BuildContext c, String m, {bool error = false}) {
  final sm = ScaffoldMessenger.of(c);
  sm.hideCurrentSnackBar();
  sm.showSnackBar(SnackBar(
    content: Text(m),
    behavior: SnackBarBehavior.floating,
    backgroundColor: error ? Colors.red.shade700 : null,
  ));
}

// ============================================================================
// MODELS
// ============================================================================

class StockItem {
  String id, itemNo, name, brand;
  int opening, stockIn, stockOut, reorder;

  StockItem({
    required this.id,
    required this.itemNo,
    required this.name,
    required this.brand,
    this.opening = 0,
    this.stockIn = 0,
    this.stockOut = 0,
    this.reorder = 0,
  });

  int get remaining => opening + stockIn - stockOut;

  String get status =>
      remaining <= 0 ? 'Out of Stock' : (remaining <= reorder ? 'Low Stock Alert' : 'In Stock');

  bool get isLow => status != 'In Stock';

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_no': itemNo,
        'item_name_model': name,
        'brand': brand,
        'opening_stock': opening,
        'stock_in': stockIn,
        'stock_out': stockOut,
        'remaining_stock': remaining,
        'reorder_level': reorder,
        'stock_status': status,
      };

  factory StockItem.fromJson(String id, Map m) => StockItem(
        id: id,
        itemNo: '${m['item_no'] ?? ''}',
        name: '${m['item_name_model'] ?? ''}',
        brand: '${m['brand'] ?? ''}',
        opening: _i(m['opening_stock']),
        stockIn: _i(m['stock_in']),
        stockOut: _i(m['stock_out']),
        reorder: _i(m['reorder_level']),
      );
}

class OrderItem {
  final String id, orderNo, dateTime, stockId, itemName, brand, payment, customer, orderedBy, signature;
  final int createdMs, qty;
  final double unitPrice;
  final String warehouse, status;

  const OrderItem({
    required this.id,
    required this.orderNo,
    required this.dateTime,
    required this.createdMs,
    required this.stockId,
    required this.itemName,
    required this.brand,
    required this.qty,
    required this.unitPrice,
    required this.payment,
    required this.customer,
    required this.orderedBy,
    required this.signature,
    required this.warehouse,
    required this.status,
  });

  double get total => qty * unitPrice;

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_no': orderNo,
        'date_time': dateTime,
        'created_ms': createdMs,
        'stock_id': stockId,
        'item_name_model': itemName,
        'brand': brand,
        'quantity_sold': qty,
        'unit_price': unitPrice,
        'total_amount': total,
        'payment_status': payment,
        'customer_name_phone': customer,
        'ordered_by': orderedBy,
        'digital_signature': signature,
        'store_verification_warehouse': warehouse,
        'status': status,
      };

  factory OrderItem.fromJson(String id, Map m) => OrderItem(
        id: id,
        orderNo: '${m['order_no'] ?? ''}',
        dateTime: '${m['date_time'] ?? ''}',
        createdMs: _i(m['created_ms']),
        stockId: '${m['stock_id'] ?? ''}',
        itemName: '${m['item_name_model'] ?? ''}',
        brand: '${m['brand'] ?? ''}',
        qty: _i(m['quantity_sold']),
        unitPrice: _d(m['unit_price']),
        payment: '${m['payment_status'] ?? 'Cash'}',
        customer: '${m['customer_name_phone'] ?? ''}',
        orderedBy: '${m['ordered_by'] ?? ''}',
        signature: '${m['digital_signature'] ?? ''}',
        warehouse: '${m['store_verification_warehouse'] ?? ''}',
        status: '${m['status'] ?? 'Pending'}',
      );
}

List<StockItem> defaultStock() => [
      StockItem(id: 'stk_001', itemNo: 'ITM-001', name: 'Compressor Copeland ZB45KCE-TFD', brand: 'Copeland', opening: 12, reorder: 4),
      StockItem(id: 'stk_002', itemNo: 'ITM-002', name: 'Compressor Bitzer 4EES-6Y', brand: 'Bitzer', opening: 6, reorder: 2),
      StockItem(id: 'stk_003', itemNo: 'ITM-003', name: 'Compressor Danfoss SC21CL', brand: 'Danfoss', opening: 15, reorder: 5),
      StockItem(id: 'stk_004', itemNo: 'ITM-004', name: 'Compressor Embraco NEK6214Z', brand: 'Embraco', opening: 20, reorder: 6),
      StockItem(id: 'stk_005', itemNo: 'ITM-005', name: 'Cold Room Evaporator DD-40', brand: 'Kelvion', opening: 8, reorder: 3),
      StockItem(id: 'stk_006', itemNo: 'ITM-006', name: 'Cold Room Condensing Unit 5HP', brand: 'Bitzer', opening: 5, reorder: 2),
      StockItem(id: 'stk_007', itemNo: 'ITM-007', name: 'PUF Insulated Panel 100mm (sqm)', brand: 'Kingspan', opening: 120, reorder: 30),
      StockItem(id: 'stk_008', itemNo: 'ITM-008', name: 'Cold Room Sliding Door 2x2m', brand: 'Cool Day', opening: 4, reorder: 2),
      StockItem(id: 'stk_009', itemNo: 'ITM-009', name: 'Expansion Valve TEX 2', brand: 'Danfoss', opening: 25, reorder: 8),
      StockItem(id: 'stk_010', itemNo: 'ITM-010', name: 'Filter Drier DML 164', brand: 'Danfoss', opening: 40, reorder: 10),
      StockItem(id: 'stk_011', itemNo: 'ITM-011', name: 'Refrigerant Gas R404A 10.9kg', brand: 'Chemours', opening: 30, reorder: 10),
      StockItem(id: 'stk_012', itemNo: 'ITM-012', name: 'Copper Pipe 3/8" Coil 15m', brand: 'Mueller', opening: 50, reorder: 15),
      StockItem(id: 'stk_013', itemNo: 'ITM-013', name: 'Evaporator Fan Motor 16W', brand: 'EBM-Papst', opening: 35, reorder: 10),
      StockItem(id: 'stk_014', itemNo: 'ITM-014', name: 'Digital Thermostat Dixell XR20C', brand: 'Dixell', opening: 18, reorder: 6),
      StockItem(id: 'stk_015', itemNo: 'ITM-015', name: 'Contactor 3-Pole 25A', brand: 'Schneider', opening: 45, reorder: 12),
    ];

// ============================================================================
// FIREBASE REST API
// ============================================================================

class Api {
  static const Map<String, String> _h = {'Content-Type': 'application/json'};
  static const Duration _t = Duration(seconds: 15);

  static Uri _u(String p) => Uri.parse('${firebaseUrl.replaceAll(RegExp(r'/+$'), '')}$p');

  static dynamic _decode(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    if (r.body.isEmpty) return null;
    return jsonDecode(r.body);
  }

  static Future<dynamic> get(String p) async => _decode(await http.get(_u(p)).timeout(_t));

  static Future<dynamic> put(String p, Object body) async =>
      _decode(await http.put(_u(p), headers: _h, body: jsonEncode(body)).timeout(_t));

  static Future<dynamic> patch(String p, Object body) async =>
      _decode(await http.patch(_u(p), headers: _h, body: jsonEncode(body)).timeout(_t));

  static Future<dynamic> delete(String p) async => _decode(await http.delete(_u(p)).timeout(_t));
}

// ============================================================================
// APP STATE
// ============================================================================

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  String lang = 'am'; // Default language set to Amharic
  String? role;
  bool isAdminSession = false;
  String userName = '';
  List<StockItem> stock = [];
  List<OrderItem> orders = [];
  Map<String, String> pins = {kRoleAdmin: '1234', kRoleSales: '2222', kRoleStore: '3333'};
  bool online = true;
  bool loaded = false;

  Timer? _timer;
  bool _busy = false;
  bool _again = false;
  bool _seeded = false;

  String t(String k) => _tr[lang]?[k] ?? _tr['en']![k] ?? k;

  String tv(String v) {
    final k = _valKeys[v];
    return k == null ? v : t(k);
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleLang() {
    lang = lang == 'en' ? 'am' : 'en';
    notifyListeners();
  }

  bool login(String r, String pin, String name) {
    if (pins[r] != pin.trim()) return false;
    role = r;
    isAdminSession = r == kRoleAdmin;
    userName = name.trim().isEmpty ? t(r) : name.trim();
    notifyListeners();
    return true;
  }

  void switchView(String r) {
    if (!isAdminSession) return;
    role = r;
    notifyListeners();
  }

  void logout() {
    role = null;
    isAdminSession = false;
    userName = '';
    notifyListeners();
  }

  Future<void> start() async {
    await refresh();
    _timer ??= Timer.periodic(const Duration(seconds: 4), (_) => refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    if (_busy) {
      _again = true;
      return;
    }
    _busy = true;
    try {
      do {
        _again = false;
        await _load();
      } while (_again);
    } finally {
      _busy = false;
    }
  }

  Future<void> _load() async {
    try {
      final r = await Future.wait([
        Api.get('/stock.json'),
        Api.get('/orders.json'),
        Api.get('/pins.json'),
      ]);
      online = true;

      // Seed initial mock data if empty
      if (r[0] == null && !_seeded) {
        await _seed();
        return;
      }

      // Parse Stock
      final loadedStock = <StockItem>[];
      if (r[0] is Map) {
        (r[0] as Map).forEach((k, v) {
          if (v is Map) loadedStock.add(StockItem.fromJson('$k', v));
        });
      }
      loadedStock.sort((a, b) => a.itemNo.compareTo(b.itemNo));
      stock = loadedStock;

      // Parse Orders
      final loadedOrders = <OrderItem
