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
      final loadedOrders = <OrderItem>[];
      if (r[1] is Map) {
        (r[1] as Map).forEach((k, v) {
          if (v is Map) loadedOrders.add(OrderItem.fromJson('$k', v));
        });
      }
      loadedOrders.sort((a, b) => b.createdMs.compareTo(a.createdMs));
      orders = loadedOrders;

      // Parse Pins
      if (r[2] is Map) {
        final p = r[2] as Map;
        pins = {
          kRoleAdmin: '${p[kRoleAdmin] ?? pins[kRoleAdmin]}',
          kRoleSales: '${p[kRoleSales] ?? pins[kRoleSales]}',
          kRoleStore: '${p[kRoleStore] ?? pins[kRoleStore]}',
        };
      }

      loaded = true;
      notifyListeners();
    } catch (_) {
      online = false;
      notifyListeners();
    }
  }

  Future<void> _seed() async {
    _seeded = true;
    try {
      final m = <String, dynamic>{};
      for (final s in defaultStock()) {
        m[s.id] = s.toJson();
      }
      await Future.wait([
        Api.put('/stock.json', m),
        Api.put('/pins.json', pins),
      ]);
      await _load();
    } catch (_) {}
  }

  // ---- Stock Actions ----
  Future<bool> addStockItem(StockItem s) async {
    try {
      await Api.put('/stock/${s.id}.json', s.toJson());
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> editStockItem(StockItem s) async {
    try {
      await Api.patch('/stock/${s.id}.json', s.toJson());
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stockIn(String stockId, int amount) async {
    try {
      final it = stock.firstWhere((e) => e.id == stockId);
      final newIn = it.stockIn + amount;
      final newRem = it.opening + newIn - it.stockOut;
      final newStatus = newRem <= 0 ? 'Out of Stock' : (newRem <= it.reorder ? 'Low Stock Alert' : 'In Stock');

      await Api.patch('/stock/$stockId.json', {
        'stock_in': newIn,
        'remaining_stock': newRem,
        'stock_status': newStatus,
      });
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteStockItem(String stockId) async {
    try {
      await Api.delete('/stock/$stockId.json');
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- Order Actions ----
  Future<bool> submitOrder(OrderItem o) async {
    try {
      await Api.put('/orders/${o.id}.json', o.toJson());
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus, {String? warehouse}) async {
    try {
      final o = orders.firstWhere((e) => e.id == orderId);
      final oldStatus = o.status;

      final updates = <String, dynamic>{'status': newStatus};
      if (warehouse != null && warehouse.isNotEmpty) {
        updates['store_verification_warehouse'] = warehouse;
      }

      await Api.patch('/orders/$orderId.json', updates);

      // Handle stock deduction when dispatched
      if (newStatus == 'Dispatched' && oldStatus != 'Dispatched') {
        final it = stock.firstWhere((e) => e.id == o.stockId);
        final newOut = it.stockOut + o.qty;
        final newRem = it.opening + it.stockIn - newOut;
        final newSt = newRem <= 0 ? 'Out of Stock' : (newRem <= it.reorder ? 'Low Stock Alert' : 'In Stock');

        await Api.patch('/stock/${it.id}.json', {
          'stock_out': newOut,
          'remaining_stock': newRem,
          'stock_status': newSt,
        });
      }
      // Revert stock deduction if status moves away from dispatched
      else if (oldStatus == 'Dispatched' && newStatus != 'Dispatched') {
        final it = stock.firstWhere((e) => e.id == o.stockId);
        final newOut = math.max(0, it.stockOut - o.qty);
        final newRem = it.opening + it.stockIn - newOut;
        final newSt = newRem <= 0 ? 'Out of Stock' : (newRem <= it.reorder ? 'Low Stock Alert' : 'In Stock');

        await Api.patch('/stock/${it.id}.json', {
          'stock_out': newOut,
          'remaining_stock': newRem,
          'stock_status': newSt,
        });
      }

      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      final o = orders.firstWhere((e) => e.id == orderId);
      if (o.status == 'Dispatched') {
        try {
          final it = stock.firstWhere((e) => e.id == o.stockId);
          final newOut = math.max(0, it.stockOut - o.qty);
          final newRem = it.opening + it.stockIn - newOut;
          final newSt = newRem <= 0 ? 'Out of Stock' : (newRem <= it.reorder ? 'Low Stock Alert' : 'In Stock');

          await Api.patch('/stock/${it.id}.json', {
            'stock_out': newOut,
            'remaining_stock': newRem,
            'stock_status': newSt,
          });
        } catch (_) {}
      }
      await Api.delete('/orders/$orderId.json');
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePin(String r, String newPin) async {
    try {
      pins[r] = newPin;
      await Api.patch('/pins.json', {r: newPin});
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

// ============================================================================
// MAIN APPLICATION
// ============================================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState()..start();
  runApp(AppScope(state: state, child: const CoolDayApp()));
}

class CoolDayApp extends StatelessWidget {
  const CoolDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isAm = state.lang == 'am';

    return MaterialApp(
      title: isAm ? 'የ Cool Day መጋዘን ትዕዛዝ' : 'Cool Day Store Order',
      debugShowCheckedModeBanner: false,
      themeMode: state.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFFD32F2F),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardTheme: const CardTheme(elevation: 1, margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFD32F2F),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardTheme(elevation: 2, margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12)),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================================
// ANIMATED SPLASH SCREEN
// ============================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _phase = 0; // 0 = Cool Day Warehouse Order, 1 = Created by Mohammed Ahmed

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    // Phase 0: Show "Cool Day Warehouse Order" for 2.2 seconds
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    setState(() => _phase = 1);

    // Phase 1: Show "Created by Mohammed Ahmed" for 2.2 seconds
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    // Transition to the Login Screen with smooth fade
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const PinLoginScreen(),
        transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _phase == 0
              // ----- Brand Screen -----
              ? Column(
                  key: const ValueKey(0),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F).withAlpha(35),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                      ),
                      child: const Icon(Icons.warehouse_rounded, size: 70, color: Color(0xFFD32F2F)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Cool Day',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Warehouse Order System',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1.1),
                      ),
                    ),
                  ],
                )
              // ----- Developer Attribution Screen -----
              : Column(
                  key: const ValueKey(1),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: const Icon(Icons.code_rounded, size: 50, color: Color(0xFFD32F2F)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'DESIGNED & DEVELOPED BY',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400, letterSpacing: 2.2),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Mohammed Ahmed',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 44,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOGIN SCREEN
// ============================================================================

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _selectedRole = kRoleSales;
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscure = true;

  void _doLogin() {
    final state = AppScope.of(context);
    final ok = state.login(_selectedRole, _pinController.text, _nameController.text);
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      toast(context, state.t('wrong_pin'), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.t('app_title')),
        actions: [
          IconButton(
            tooltip: 'Dark / Light',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: state.toggleTheme,
          ),
          TextButton.icon(
            icon: const Icon(Icons.language, size: 18),
            label: Text(state.lang == 'en' ? 'አማርኛ' : 'English', style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: state.toggleLang,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_person_rounded, size: 48, color: Color(0xFFD32F2F)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.t('sign_in'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              state.t('select_role'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Role selection cards
            _roleCard(state, kRoleAdmin, Icons.admin_panel_settings, 'admin', 'admin_desc'),
            _roleCard(state, kRoleSales, Icons.point_of_sale, 'sales', 'sales_desc'),
            _roleCard(state, kRoleStore, Icons.warehouse, 'store', 'store_desc'),

            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: deco(state.t('your_name'), icon: Icons.person_outline),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: state.t('pin'),
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _doLogin(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _doLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.login),
                label: Text(state.t('sign_in'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(AppState state, String roleKey, IconData icon, String titleKey, String descKey) {
    final isSelected = _selectedRole == roleKey;
    return Card(
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFFD32F2F) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFFD32F2F) : Colors.grey, size: 28),
        title: Text(state.t(titleKey), style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        subtitle: Text(state.t(descKey), style: const TextStyle(fontSize: 12)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFD32F2F)) : null,
        onTap: () => setState(() => _selectedRole = roleKey),
      ),
    );
  }
}

// ============================================================================
// MAIN SHELL SCREEN (WITH ROLE ROUTING)
// ============================================================================

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isAm = state.lang == 'am';
    final role = state.role ?? kRoleSales;

    List<Widget> tabs;
    List<NavigationDestination> navItems;

    if (role == kRoleSales) {
      tabs = const [StockTab(), NewOrderTab(), OrdersTab()];
      navItems = [
        NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2), label: state.t('stock')),
        NavigationDestination(icon: const Icon(Icons.add_shopping_cart), selectedIcon: const Icon(Icons.add_shopping_cart_sharp), label: state.t('new_order')),
        NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: state.t('orders')),
      ];
    } else if (role == kRoleStore) {
      tabs = const [WarehouseQueueTab(), OrdersTab(), StockTab()];
      navItems = [
        NavigationDestination(icon: const Icon(Icons.pending_actions), selectedIcon: const Icon(Icons.pending_actions_outlined), label: state.t('queue')),
        NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: state.t('orders')),
        NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2), label: state.t('stock')),
      ];
    } else {
      // Admin
      tabs = const [AdminDashboardTab(), StockTab(), OrdersTab()];
      navItems = [
        NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: state.t('dashboard')),
        NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2), label: state.t('stock')),
        NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: state.t('orders')),
      ];
    }

    if (_tabIndex >= tabs.length) _tabIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAm ? 'የ Cool Day መጋዘን ትዕዛዝ' : 'Cool Day Store Order', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Text('${state.userName} (${state.t(role)})', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ],
        ),
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              state.online ? Icons.cloud_done : Icons.cloud_off,
              color: state.online ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          // Theme Toggle
          IconButton(
            icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: state.toggleTheme,
          ),
          // Language Toggle
          TextButton(
            child: Text(state.lang == 'en' ? 'አማ' : 'EN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: state.toggleLang,
          ),
          // Role & Settings Popup
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'logout') {
                state.logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PinLoginScreen()));
              } else if (val == 'change_pins') {
                _showChangePinsDialog(context, state);
              } else if (val.startsWith('view_')) {
                final r = val.replaceFirst('view_', '');
                state.switchView(r);
              } else if (val == 'refresh') {
                state.refresh();
              }
            },
            itemBuilder: (ctx) => [
              if (state.isAdminSession) ...[
                PopupMenuItem(value: 'view_$kRoleAdmin', child: Text(state.t('view_admin'))),
                PopupMenuItem(value: 'view_$kRoleSales', child: Text(state.t('view_sales'))),
                PopupMenuItem(value: 'view_$kRoleStore', child: Text(state.t('view_store'))),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'change_pins', child: Text(state.t('change_pins'))),
                const PopupMenuDivider(),
              ],
              PopupMenuItem(value: 'refresh', child: Text(state.t('online'))),
              PopupMenuItem(value: 'logout', child: Text(state.t('logout'), style: const TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (!state.online)
            Container(
              width: double.infinity,
              color: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(state.t('offline'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          Expanded(child: tabs[_tabIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: navItems,
      ),
    );
  }

  void _showChangePinsDialog(BuildContext context, AppState state) {
    final adminCtl = TextEditingController(text: state.pins[kRoleAdmin]);
    final salesCtl = TextEditingController(text: state.pins[kRoleSales]);
    final storeCtl = TextEditingController(text: state.pins[kRoleStore]);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(state.t('change_pins')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: adminCtl, decoration: deco(state.t('admin'), icon: Icons.admin_panel_settings)),
            const SizedBox(height: 10),
            TextField(controller: salesCtl, decoration: deco(state.t('sales'), icon: Icons.point_of_sale)),
            const SizedBox(height: 10),
            TextField(controller: storeCtl, decoration: deco(state.t('store'), icon: Icons.warehouse)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              await state.updatePin(kRoleAdmin, adminCtl.text);
              await state.updatePin(kRoleSales, salesCtl.text);
              await state.updatePin(kRoleStore, storeCtl.text);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                toast(ctx, state.t('pins_saved'));
              }
            },
            child: Text(state.t('save')),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: NEW ORDER (SALES)
// ============================================================================

class NewOrderTab extends StatefulWidget {
  const NewOrderTab({super.key});

  @override
  State<NewOrderTab> createState() => _NewOrderTabState();
}

class _NewOrderTabState extends State<NewOrderTab> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStockId;
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();
  final _signatureController = TextEditingController();
  String _payment = 'Cash';
  bool _submitting = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _customerController.dispose();
    _notesController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    final q = int.tryParse(_qtyController.text) ?? 0;
    final p = double.tryParse(_priceController.text) ?? 0;
    return q * p;
  }

  void _submit() async {
    final state = AppScope.of(context);
    if (!_formKey.currentState!.validate() || _selectedStockId == null) return;

    final it = state.stock.firstWhere((e) => e.id == _selectedStockId);
    final qty = int.parse(_qtyController.text);
    if (qty > it.remaining) {
      toast(context, '${state.t('insufficient')} (${it.remaining} ${state.t('available')})', error: true);
      return;
    }

    setState(() => _submitting = true);
    final now = DateTime.now();
    final orderNo = 'ORD-${DateFormat('yyMMdd-HHmmss').format(now)}';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

    final newOrder = OrderItem(
      id: 'ord_${now.millisecondsSinceEpoch}',
      orderNo: orderNo,
      dateTime: dateStr,
      createdMs: now.millisecondsSinceEpoch,
      stockId: it.id,
      itemName: it.name,
      brand: it.brand,
      qty: qty,
      unitPrice: double.parse(_priceController.text),
      payment: _payment,
      customer: _customerController.text.trim(),
      orderedBy: state.userName,
      signature: _signatureController.text.trim(),
      warehouse: '',
      status: 'Pending',
    );

    final ok = await state.submitOrder(newOrder);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      toast(context, state.t('order_submitted'));
      _qtyController.clear();
      _priceController.clear();
      _customerController.clear();
      _signatureController.clear();
      setState(() => _selectedStockId = null);
    } else {
      toast(context, state.t('network_error'), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    // Filter available stock items for sales
    final availableItems = state.stock.where((e) => e.remaining > 0).toList();

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(state.t('new_order'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              // Item selector
              DropdownButtonFormField<String>(
                value: _selectedStockId,
                isExpanded: true,
                decoration: deco(state.t('item_name_model'), icon: Icons.category),
                items: availableItems.map((e) {
                  return DropdownMenuItem(
                    value: e.id,
                    child: Text('${e.name} (${e.brand}) - [${e.remaining} in stock]'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedStockId = val),
                validator: (v) => v == null ? state.t('required') : null,
              ),
              const SizedBox(height: 12),

              // Quantity & Unit Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: deco(state.t('quantity'), icon: Icons.numbers),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return state.t('invalid_number');
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: deco(state.t('unit_price'), icon: Icons.attach_money),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) return state.t('invalid_number');
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Total display card
              Card(
                color: const Color(0xFFD32F2F).withAlpha(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(state.t('total_amount'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${NumberFormat('#,##0.00').format(_totalAmount)} ${state.t('etb')}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Payment Status Dropdown
              DropdownButtonFormField<String>(
                value: _payment,
                decoration: deco(state.t('payment_status'), icon: Icons.payment),
                items: kPayments.map((p) => DropdownMenuItem(value: p, child: Text(state.tv(p)))).toList(),
                onChanged: (v) => setState(() => _payment = v ?? 'Cash'),
              ),
              const SizedBox(height: 12),

              // Customer name & phone
              TextFormField(
                controller: _customerController,
                decoration: deco(state.t('customer'), icon: Icons.person, hint: state.t('customer_hint')),
                validator: (v) => v!.isEmpty ? state.t('required') : null,
              ),
              const SizedBox(height: 12),

              // Digital signature confirmation
              TextFormField(
                controller: _signatureController,
                decoration: deco(state.t('signature'), icon: Icons.draw, hint: state.t('signature_hint')),
                validator: (v) => v!.isEmpty ? state.t('required') : null,
              ),
              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _submitting ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.send),
                  label: Text(state.t('submit'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: WAREHOUSE QUEUE (DISPATCH VERIFICATION)
// ============================================================================

class WarehouseQueueTab extends StatelessWidget {
  const WarehouseQueueTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pendingOrders = state.orders.where((e) => e.status == 'Pending' || e.status == 'Approved').toList();

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: pendingOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.done_all_rounded, size: 56, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(state.t('no_data'), style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: pendingOrders.length,
              itemBuilder: (ctx, i) {
                final o = pendingOrders[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(o.orderNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Chip(
                              label: Text(state.tv(o.status), style: const TextStyle(color: Colors.white, fontSize: 12)),
                              backgroundColor: statusColor(o.status),
                            ),
                          ],
                        ),
                        Text(o.itemName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text('${state.t('quantity')}: ${o.qty} PCS  |  ${NumberFormat('#,##0.00').format(o.total)} ${state.t('etb')}',
                            style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                        const Divider(),
                        Text('${state.t('customer')}: ${o.customer}'),
                        Text('${state.t('ordered_by')}: ${o.orderedBy}  |  ${o.dateTime}'),
                        if (o.warehouse.isNotEmpty) Text('${state.t('store_verification')}: ${o.warehouse}'),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (o.status == 'Pending') ...[
                              OutlinedButton(
                                onPressed: () => _confirmReject(context, state, o),
                                child: Text(state.t('reject'), style: const TextStyle(color: Colors.red)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _showApproveDialog(context, state, o),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                child: Text(state.t('approve')),
                              ),
                            ],
                            if (o.status == 'Approved')
                              ElevatedButton.icon(
                                onPressed: () => _confirmDispatch(context, state, o),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                icon: const Icon(Icons.check),
                                label: Text(state.t('dispatch')),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showApproveDialog(BuildContext context, AppState state, OrderItem o) {
    String selectedWh = kWarehouses.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(state.t('approve')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.t('store_verification')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedWh,
                items: kWarehouses.map((w) => DropdownMenuItem(value: w, child: Text(state.tv(w)))).toList(),
                onChanged: (v) => setDState(() => selectedWh = v ?? kWarehouses.first),
                decoration: deco(state.t('store_verification')),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await state.updateOrderStatus(o.id, 'Approved', warehouse: selectedWh);
                if (context.mounted) toast(context, state.t('saved'));
              },
              child: Text(state.t('confirm')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDispatch(BuildContext context, AppState state, OrderItem o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(state.t('dispatch')),
        content: Text(state.t('confirm_dispatch')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.updateOrderStatus(o.id, 'Dispatched');
              if (context.mounted) toast(context, state.t('stock_updated'));
            },
            child: Text(state.t('confirm')),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context, AppState state, OrderItem o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(state.t('reject')),
        content: Text(state.t('confirm_reject')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.updateOrderStatus(o.id, 'Rejected');
            },
            child: Text(state.t('confirm')),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 3: ADMIN DASHBOARD
// ============================================================================

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    // Sales Calculations
    double totalDispatchedSales = 0;
    double todaySales = 0;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (final o in state.orders) {
      if (o.status == 'Dispatched') {
        totalDispatchedSales += o.total;
        if (o.dateTime.startsWith(todayStr)) {
          todaySales += o.total;
        }
      }
    }

    final lowStockItems = state.stock.where((e) => e.isLow).toList();

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KPI Summary Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: [
                _kpiCard(state.t('total_sales'), '${NumberFormat('#,##0').format(totalDispatchedSales)} ${state.t('etb')}', Icons.monetization_on, Colors.green),
                _kpiCard(state.t('today_sales'), '${NumberFormat('#,##0').format(todaySales)} ${state.t('etb')}', Icons.today, Colors.blue),
                _kpiCard(state.t('total_orders'), '${state.orders.length}', Icons.receipt, Colors.purple),
                _kpiCard(state.t('low_alerts'), '${lowStockItems.length}', Icons.warning_amber, Colors.red),
              ],
            ),
            const SizedBox(height: 16),

            // Low Stock Alert Section
            if (lowStockItems.isNotEmpty) ...[
              Text(state.t('low_alerts'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              ...lowStockItems.map((it) => Card(
                    color: Colors.red.withAlpha(25),
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${state.t('remaining')}: ${it.remaining} / ${state.t('reorder_level')}: ${it.reorder}'),
                      trailing: Chip(label: Text(state.tv(it.status), style: const TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: Colors.red),
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Top items overview
            Text(state.t('stock'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stockMetric(state.t('items_count'), '${state.stock.length}'),
                        _stockMetric(state.t('in_stock'), '${state.stock.where((e) => !e.isLow).length}'),
                        _stockMetric(state.t('low_items'), '${lowStockItems.length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color c) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: c, size: 20),
                const SizedBox(width: 6),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _stockMetric(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ============================================================================
// TAB 4: STOCK MANAGEMENT
// ============================================================================

class StockTab extends StatefulWidget {
  const StockTab({super.key});

  @override
  State<StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  String _search = '';
  bool _onlyLow = false;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isStoreOrAdmin = state.role == kRoleAdmin || state.role == kRoleStore;

    var list = state.stock.where((e) {
      final m = e.name.toLowerCase().contains(_search.toLowerCase()) ||
          e.brand.toLowerCase().contains(_search.toLowerCase()) ||
          e.itemNo.toLowerCase().contains(_search.toLowerCase());
      if (_onlyLow) return m && e.isLow;
      return m;
    }).toList();

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: deco(state.t('search'), icon: Icons.search),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(state.t('low_stock')),
                  selected: _onlyLow,
                  onSelected: (v) => setState(() => _onlyLow = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text(state.t('no_data')))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final it = list[i];
                      return Card(
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: stockColor(it.status).withAlpha(30),
                            child: Text('${it.remaining}', style: TextStyle(color: stockColor(it.status), fontWeight: FontWeight.bold)),
                          ),
                          title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${it.itemNo}  |  ${it.brand}'),
                          trailing: Chip(
                            label: Text(state.tv(it.status), style: const TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: stockColor(it.status),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${state.t('opening_stock')}: ${it.opening}'),
                                      Text('${state.t('stock_in')}: ${it.stockIn}'),
                                      Text('${state.t('stock_out')}: ${it.stockOut}'),
                                      Text('${state.t('remaining')}: ${it.remaining}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                                    ],
                                  ),
                                  const Divider(),
                                  if (isStoreOrAdmin)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.add, size: 16),
                                          label: Text(state.t('stock_in_btn')),
                                          onPressed: () => _showStockInDialog(context, state, it),
                                        ),
                                        if (state.role == kRoleAdmin) ...[
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _showEditItemDialog(context, state, it),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _confirmDeleteItem(context, state, it),
                                          ),
                                        ],
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (state.role == kRoleAdmin)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
                  icon: const Icon(Icons.add),
                  label: Text(state.t('add_item')),
                  onPressed: () => _showAddItemDialog(context, state),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showStockInDialog(BuildContext context, AppState state, StockItem it) {
    final qtyCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${state.t('stock_in_btn')} - ${it.name}'),
        content: TextField(
          controller: qtyCtl,
          keyboardType: TextInputType.number,
          decoration: deco(state.t('qty_to_add'), icon: Icons.add_box),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              final val = int.tryParse(qtyCtl.text);
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                await state.stockIn(it.id, val);
                if (context.mounted) toast(context, state.t('stock_updated'));
              }
            },
            child: Text(state.t('confirm')),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, AppState state) {
    final nameCtl = TextEditingController();
    final brandCtl = TextEditingController();
    final noCtl = TextEditingController(text: 'ITM-0${state.stock.length + 1}');
    final openingCtl = TextEditingController(text: '10');
    final reorderCtl = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(state.t('add_item')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtl, decoration: deco(state.t('item_name_model'))),
              const SizedBox(height: 8),
              TextField(controller: brandCtl, decoration: deco(state.t('brand'))),
              const SizedBox(height: 8),
              TextField(controller: noCtl, decoration: deco(state.t('item_no'))),
              const SizedBox(height: 8),
              TextField(controller: openingCtl, keyboardType: TextInputType.number, decoration: deco(state.t('opening_stock'))),
              const SizedBox(height: 8),
              TextField(controller: reorderCtl, keyboardType: TextInputType.number, decoration: deco(state.t('reorder_level'))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              if (nameCtl.text.isEmpty) return;
              final newItem = StockItem(
                id: 'stk_${DateTime.now().millisecondsSinceEpoch}',
                itemNo: noCtl.text,
                name: nameCtl.text,
                brand: brandCtl.text,
                opening: int.tryParse(openingCtl.text) ?? 0,
                reorder: int.tryParse(reorderCtl.text) ?? 0,
              );
              Navigator.pop(ctx);
              await state.addStockItem(newItem);
              if (context.mounted) toast(context, state.t('saved'));
            },
            child: Text(state.t('save')),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, AppState state, StockItem it) {
    final nameCtl = TextEditingController(text: it.name);
    final brandCtl = TextEditingController(text: it.brand);
    final reorderCtl = TextEditingController(text: '${it.reorder}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(state.t('edit_item')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtl, decoration: deco(state.t('item_name_model'))),
            const SizedBox(height: 8),
            TextField(controller: brandCtl, decoration: deco(state.t('brand'))),
            const SizedBox(height: 8),
            TextField(controller: reorderCtl, keyboardType: TextInputType.number, decoration: deco(state.t('reorder_level'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              it.name = nameCtl.text;
              it.brand = brandCtl.text;
              it.reorder = int.tryParse(reorderCtl.text) ?? it.reorder;
              Navigator.pop(ctx);
              await state.editStockItem(it);
              if (context.mounted) toast(context, state.t('saved'));
            },
            child: Text(state.t('save')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, AppState state, StockItem it) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(state.t('delete')),
        content: Text(state.t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.deleteStockItem(it.id);
            },
            child: Text(state.t('confirm')),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 5: ORDERS LIST
// ============================================================================

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  String _filterStatus = 'All';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    var list = state.orders.where((e) {
      final matchesStatus = _filterStatus == 'All' || e.status == _filterStatus;
      final matchesSearch = e.orderNo.toLowerCase().contains(_search.toLowerCase()) ||
          e.customer.toLowerCase().contains(_search.toLowerCase()) ||
          e.itemName.toLowerCase().contains(_search.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              decoration: deco(state.t('search'), icon: Icons.search),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: ['All', ...kStatuses].map((st) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(state.tv(st)),
                    selected: _filterStatus == st,
                    onSelected: (_) => setState(() => _filterStatus = st),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text(state.t('no_data')))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final o = list[i];
                      return Card(
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor(o.status).withAlpha(30),
                            child: Icon(Icons.receipt_long, color: statusColor(o.status)),
                          ),
                          title: Text(o.orderNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${o.itemName} (${o.qty} PCS)'),
                          trailing: Chip(
                            label: Text(state.tv(o.status), style: const TextStyle(fontSize: 11, color: Colors.white)),
                            backgroundColor: statusColor(o.status),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${state.t('unit_price')}: ${o.unitPrice}'),
                                      Text('${state.t('total_amount')}: ${NumberFormat('#,##0.00').format(o.total)} ${state.t('etb')}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${state.t('payment_status')}: ${state.tv(o.payment)}'),
                                  Text('${state.t('customer')}: ${o.customer}'),
                                  Text('${state.t('ordered_by')}: ${o.orderedBy}  |  ${o.dateTime}'),
                                  if (o.signature.isNotEmpty) Text('${state.t('signature')}: ${o.signature}'),
                                  if (o.warehouse.isNotEmpty) Text('${state.t('store_verification')}: ${o.warehouse}'),
                                  if (state.role == kRoleAdmin) ...[
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          child: Text(state.t('delete'), style: const TextStyle(color: Colors.red)),
                                          onPressed: () => _confirmDeleteOrder(context, state, o),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOrder(BuildContext context, AppState state, OrderItem o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(state.t('delete')),
        content: Text(o.status == 'Dispatched' ? state.t('confirm_delete_dispatched') : state.t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.deleteOrder(o.id);
              if (context.mounted) toast(context, state.t('saved'));
            },
            child: Text(state.t('confirm')),
          ),
        ],
      ),
    );
  }
}
