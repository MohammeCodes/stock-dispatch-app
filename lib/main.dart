// Cool Day Ethiopia - Warehouse Dispatch & Sales Order + Store Stock Card
// Single-file Flutter app. Packages: http, intl. Backend: Firebase Realtime Database (REST).
//
// pubspec.yaml dependencies:
//   http: ^1.2.0
// Example inside the AppBar:
title: Text(isAm ? 'የ Cool Day መጋዘን ትዕዛዝ' : 'Cool Day Store Order'),

//   intl: ^0.19.0

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ============================================================================
// CONFIG
// ============================================================================

String firebaseUrl = "https://moha-cbdcc-default-rtdb.firebaseio.com";

const String kRoleAdmin = 'admin';
const String kRoleSales = 'sales';
const String kRoleStore = 'store';

const List<String> kStatuses = ['Pending', 'Approved', 'Dispatched', 'Rejected'];
const List<String> kPayments = ['Cash', 'Bank Transfer', 'Credit', 'Cheque'];
const List<String> kWarehouses = ['Main Warehouse', 'Showroom Store', 'Shop Store'];

// ============================================================================
// TRANSLATIONS (English / Amharic)
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
    'app_title': 'Cool-Day warehouse order ',
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
  },
  'am': {
    'app_title': 'ኩልዴይ የመጋዘን ትዕዛዝ',
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
      return Colors.red;
    case 'Out of Stock':
      return Colors.red.shade900;
    default:
      return Colors.grey;
  }
}

Color _fg(Color c, bool dark) =>
    HSLColor.fromColor(c).withLightness(dark ? 0.72 : 0.30).toColor();

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

List<StockItem> _parseStock(dynamic raw) {
  final out = <StockItem>[];
  if (raw is Map) {
    raw.forEach((k, v) {
      if (v is Map) out.add(StockItem.fromJson('$k', v));
    });
  }
  out.sort((a, b) => a.itemNo.compareTo(b.itemNo));
  return out;
}

List<OrderItem> _parseOrders(dynamic raw) {
  final out = <OrderItem>[];
  if (raw is Map) {
    raw.forEach((k, v) {
      if (v is Map) out.add(OrderItem.fromJson('$k', v));
    });
  }
  out.sort((a, b) => b.createdMs.compareTo(a.createdMs));
  return out;
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
  ThemeMode themeMode = ThemeMode.light;
  String lang = 'en';
  String? role; // effective view role
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

  // ---- auth ----
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

  // ---- sync ----
  Future<void> start() async {
    await refresh();
    _timer ??= Timer.periodic(const Duration(seconds: 4), (_) => refresh());
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
      if (r[0] == null && !_seeded) {
        await _seed();
      } else {
        stock = _parseStock(r[0]);
      }
      _seeded = true;
      orders = _parseOrders(r[1]);
      final p = r[2];
      if (p is Map) {
        for (final k in pins.keys.toList()) {
          if (p[k] != null && '${p[k]}'.isNotEmpty) pins[k] = '${p[k]}';
        }
      }
      online = true;
    } catch (_) {
      online = false;
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _seed() async {
    final items = defaultStock();
    await Api.put('/stock.json', {for (final s in items) s.id: s.toJson()});
    stock = items;
  }

  // ---- helpers ----
  String nextOrderNo() {
    int mx = 0;
    for (final o in orders) {
      final m = RegExp(r'(\d+)$').firstMatch(o.orderNo);
      if (m != null) mx = math.max(mx, int.parse(m.group(1)!));
    }
    return 'CD-${(mx + 1).toString().padLeft(4, '0')}';
  }

  String nextItemNo() {
    int mx = 0;
    for (final s in stock) {
      final m = RegExp(r'(\d+)$').firstMatch(s.itemNo);
      if (m != null) mx = math.max(mx, int.parse(m.group(1)!));
    }
    return 'ITM-${(mx + 1).toString().padLeft(3, '0')}';
  }

  String _stockIdFor(OrderItem o) {
    if (o.stockId.isNotEmpty) return o.stockId;
    for (final s in stock) {
      if (s.name == o.itemName) return s.id;
    }
    return '';
  }

  // ---- orders ----
  Future<String?> submitOrder(OrderItem o) async {
    StockItem? s;
    for (final x in stock) {
      if (x.id == o.stockId) s = x;
    }
    if (s == null) return 'item_missing';
    if (o.qty > s.remaining) return 'insufficient';
    try {
      await Api.put('/orders/${o.id}.json', o.toJson());
      await refresh();
      return null;
    } catch (_) {
      return 'network_error';
    }
  }

  /// Changes order status. Dispatch deducts stock; leaving Dispatched restores it.
  /// Order + stock are updated in ONE atomic multi-path PATCH.
  Future<String?> setStatus(OrderItem o, String newStatus, {String? warehouse}) async {
    try {
      final upd = <String, dynamic>{};
      final wh = (warehouse ?? o.warehouse).trim();
      upd['orders/${o.id}/status'] = newStatus;
      if (wh.isNotEmpty) upd['orders/${o.id}/store_verification_warehouse'] = wh;

      final wasD = o.status == 'Dispatched';
      final willD = newStatus == 'Dispatched';
      if (wasD != willD) {
        final sid = _stockIdFor(o);
        if (sid.isEmpty) return 'item_missing';
        final raw = await Api.get('/stock/$sid.json');
        if (raw is! Map) return 'item_missing';
        final item = StockItem.fromJson(sid, raw);
        if (willD) {
          if (o.qty > item.remaining) return 'insufficient';
          item.stockOut += o.qty;
        } else {
          item.stockOut = math.max(0, item.stockOut - o.qty);
        }
        upd['stock/$sid/stock_out'] = item.stockOut;
        upd['stock/$sid/remaining_stock'] = item.remaining;
        upd['stock/$sid/stock_status'] = item.status;
      }
      await Api.patch('/.json', upd);
      await refresh();
      return null;
    } catch (_) {
      return 'network_error';
    }
  }

  Future<String?> deleteOrder(OrderItem o) async {
    try {
      final upd = <String, dynamic>{'orders/${o.id}': null};
      if (o.status == 'Dispatched') {
        final sid = _stockIdFor(o);
        if (sid.isNotEmpty) {
          final raw = await Api.get('/stock/$sid.json');
          if (raw is Map) {
            final item = StockItem.fromJson(sid, raw);
            item.stockOut = math.max(0, item.stockOut - o.qty);
            upd['stock/$sid/stock_out'] = item.stockOut;
            upd['stock/$sid/remaining_stock'] = item.remaining;
            upd['stock/$sid/stock_status'] = item.status;
          }
        }
      }
      await Api.patch('/.json', upd);
      await refresh();
      return null;
    } catch (_) {
      return 'network_error';
    }
  }

  // ---- stock ----
  Future<String?> saveStock(StockItem s) async {
    try {
      await Api.put('/stock/${s.id}.json', s.toJson());
      await refresh();
      return null;
    } catch (_) {
      return 'network_error';
    }
  }

  Future<String?> deleteStock(StockItem s) async {
    try {
      await Api.delete('/stock/${s.id}.json');
      await refresh();
      return null;
    } catch (_) {
      return 'network_error';
    }
  }

  Future<String?> addStockIn(StockItem s, int qty) async {
    try {
      final raw = await Api.get('/stock/${s.id}.json');
      if (raw is! Map) return 'item_missing';
      final item = StockItem.fromJson(s.id, raw);
      item.stockIn += qty;
      await Api.patch('/stock/${s.id}.json', {
        'stock_in': item.stockIn,
        'remaining_stock': item.remaining,
        'stock_status': item.status,
      });
      await refresh();
      return null;
    } catch (_) {
      return 'network_error';
    }
  }

  Future<String?> savePins(Map<String, String> p) async {
    try {
      await Api.put('/pins.json', p);
      pins = Map<String, String>.from(p);
      notifyListeners();
      return null;
    } catch (_) {
      return 'network_error';
    }
  }
}

final AppState app = AppState();
String t(String k) => app.t(k);
String tv(String v) => app.tv(v);
String money(num v) => '${NumberFormat('#,##0.00').format(v)} ${t('etb')}';
String n0(num v) => NumberFormat('#,##0').format(v);

// ============================================================================
// ENTRY
// ============================================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoolDayApp());
  app.start();
}

ThemeData buildTheme(Brightness b) {
  final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E99), brightness: b);
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );
}

class CoolDayApp extends StatelessWidget {
  const CoolDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cool Day Dispatch',
          themeMode: app.themeMode,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          home: app.role == null ? const LoginScreen() : HomeShell(key: ValueKey(app.role)),
        );
      },
    );
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================

class Panel extends StatelessWidget {
  final Widget child;
  final Color? accent;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const Panel({
    super.key,
    required this.child,
    this.accent,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    Widget inner = Padding(padding: padding, child: child);
    if (accent != null) {
      inner = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: accent),
            Expanded(child: inner),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: onTap, child: inner),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusChip({super.key, required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = _fg(color, dark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: alpha(color, 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: alpha(color, 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class StatData {
  final String label, value;
  final IconData icon;
  final Color color;
  const StatData(this.label, this.value, this.icon, this.color);
}

class StatGrid extends StatelessWidget {
  final List<StatData> items;
  const StatGrid(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final cols = box.maxWidth > 720 ? 4 : 2;
      const gap = 10.0;
      final w = (box.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: items.map((s) => SizedBox(width: w, child: _StatCard(s))).toList(),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final StatData s;
  const _StatCard(this.s);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: alpha(s.color, 0.16), shape: BoxShape.circle),
            child: Icon(s.icon, color: _fg(s.color, dark), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(s.value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ),
                Text(s.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 16, 2, 8),
        child: Text(text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  const EmptyState({super.key, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 56, color: alpha(c, 0.6)),
          const SizedBox(height: 8),
          Text(t('no_data'), style: TextStyle(color: c)),
        ],
      ),
    );
  }
}

class BarRow extends StatelessWidget {
  final String label, trailing;
  final double value, max;
  final Color color;

  const BarRow({
    super.key,
    required this.label,
    required this.trailing,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text(trailing, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: max <= 0 ? 0 : (value / max).clamp(0.0, 1.0).toDouble(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: color,
            backgroundColor: alpha(color, 0.15),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '$label: ', style: TextStyle(color: c, fontSize: 13)),
              TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ])),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DIALOG HELPERS
// ============================================================================

Future<bool> confirmDialog(BuildContext ctx, String msg, {bool danger = false}) async {
  final r = await showDialog<bool>(
    context: ctx,
    builder: (dc) => AlertDialog(
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc, false), child: Text(t('cancel'))),
        FilledButton(
          style: danger ? FilledButton.styleFrom(backgroundColor: Colors.red.shade700) : null,
          onPressed: () => Navigator.pop(dc, true),
          child: Text(t('confirm')),
        ),
      ],
    ),
  );
  return r == true;
}

Future<String?> askWarehouse(BuildContext ctx, String initial) {
  final c = TextEditingController(text: initial);
  final key = GlobalKey<FormState>();
  return showDialog<String>(
    context: ctx,
    builder: (dc) => StatefulBuilder(
      builder: (dc2, setS) => AlertDialog(
        title: Text(t('store_verification')),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: kWarehouses
                    .map((w) => ChoiceChip(
                          label: Text(tv(w)),
                          selected: c.text == w,
                          onSelected: (_) => setS(() => c.text = w),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: c,
                decoration: deco(t('store_verification'), icon: Icons.store_outlined),
                validator: (v) => (v == null || v.trim().isEmpty) ? t('warehouse_required') : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc2), child: Text(t('cancel'))),
          FilledButton(
            onPressed: () {
              if (key.currentState!.validate()) Navigator.pop(dc2, c.text.trim());
            },
            child: Text(t('confirm')),
          ),
        ],
      ),
    ),
  );
}

Widget _field(TextEditingController c, String label, {bool number = false, IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: deco(label, icon: icon),
      validator: (v) {
        final s = (v ?? '').trim();
        if (s.isEmpty) return t('required');
        if (number && (int.tryParse(s) ?? -1) < 0) return t('invalid_number');
        return null;
      },
    ),
  );
}

Future<void> editStockDialog(BuildContext ctx, StockItem? ex) async {
  final form = GlobalKey<FormState>();
  final no = TextEditingController(text: ex?.itemNo ?? app.nextItemNo());
  final name = TextEditingController(text: ex?.name ?? '');
  final brand = TextEditingController(text: ex?.brand ?? '');
  final opening = TextEditingController(text: '${ex?.opening ?? 0}');
  final sin = TextEditingController(text: '${ex?.stockIn ?? 0}');
  final reorder = TextEditingController(text: '${ex?.reorder ?? 0}');

  final ok = await showDialog<bool>(
    context: ctx,
    builder: (dc) => AlertDialog(
      title: Text(t(ex == null ? 'add_item' : 'edit_item')),
      content: SizedBox(
        width: 420,
        child: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(no, t('item_no'), icon: Icons.tag),
                _field(name, t('item_name_model'), icon: Icons.inventory_2_outlined),
                _field(brand, t('brand'), icon: Icons.branding_watermark_outlined),
                _field(opening, t('opening_stock'), number: true, icon: Icons.archive_outlined),
                _field(sin, t('stock_in'), number: true, icon: Icons.move_to_inbox_outlined),
                _field(reorder, t('reorder_level'), number: true, icon: Icons.notification_important_outlined),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc, false), child: Text(t('cancel'))),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) Navigator.pop(dc, true);
          },
          child: Text(t('save')),
        ),
      ],
    ),
  );
  if (ok != true) return;

  final item = StockItem(
    id: ex?.id ?? 'stk_${DateTime.now().millisecondsSinceEpoch}',
    itemNo: no.text.trim(),
    name: name.text.trim(),
    brand: brand.text.trim(),
    opening: int.parse(opening.text.trim()),
    stockIn: int.parse(sin.text.trim()),
    stockOut: ex?.stockOut ?? 0,
    reorder: int.parse(reorder.text.trim()),
  );
  final err = await app.saveStock(item);
  if (!ctx.mounted) return;
  toast(ctx, err == null ? t('saved') : t(err), error: err != null);
}

Future<void> stockInDialog(BuildContext ctx, StockItem s) async {
  final form = GlobalKey<FormState>();
  final q = TextEditingController();
  final ok = await showDialog<bool>(
    context: ctx,
    builder: (dc) => AlertDialog(
      title: Text('${t('stock_in_btn')} - ${s.name}'),
      content: Form(
        key: form,
        child: TextFormField(
          controller: q,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: deco(t('qty_to_add'), icon: Icons.add_box_outlined),
          validator: (v) {
            final n = int.tryParse((v ?? '').trim());
            return (n == null || n <= 0) ? t('invalid_number') : null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc, false), child: Text(t('cancel'))),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) Navigator.pop(dc, true);
          },
          child: Text(t('save')),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final err = await app.addStockIn(s, int.parse(q.text.trim()));
  if (!ctx.mounted) return;
  toast(ctx, err == null ? t('stock_updated') : t(err), error: err != null);
}

Future<void> changePinsDialog(BuildContext ctx) async {
  final form = GlobalKey<FormState>();
  final cs = {
    kRoleAdmin: TextEditingController(text: app.pins[kRoleAdmin]),
    kRoleSales: TextEditingController(text: app.pins[kRoleSales]),
    kRoleStore: TextEditingController(text: app.pins[kRoleStore]),
  };
  final ok = await showDialog<bool>(
    context: ctx,
    builder: (dc) => AlertDialog(
      title: Text(t('change_pins')),
      content: SizedBox(
        width: 400,
        child: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: cs.entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextFormField(
                          controller: e.value,
                          obscureText: true,
                          decoration: deco('${t(e.key)} - ${t('pin')}', icon: Icons.lock_outline),
                          validator: (v) => (v ?? '').trim().length < 4 ? t('pin_invalid') : null,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc, false), child: Text(t('cancel'))),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) Navigator.pop(dc, true);
          },
          child: Text(t('save')),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final err = await app.savePins({for (final e in cs.entries) e.key: e.value.text.trim()});
  if (!ctx.mounted) return;
  toast(ctx, err == null ? t('pins_saved') : t(err), error: err != null);
}

Future<void> handleStatus(BuildContext ctx, OrderItem o, String ns) async {
  String? wh;
  if (ns == 'Approved') {
    wh = await askWarehouse(ctx, o.warehouse);
    if (wh == null) return;
  } else if (ns == 'Dispatched') {
    if (o.warehouse.isEmpty) {
      wh = await askWarehouse(ctx, '');
      if (wh == null) return;
    }
    if (!ctx.mounted) return;
    if (!await confirmDialog(ctx, t('confirm_dispatch'))) return;
  } else if (ns == 'Rejected') {
    if (!await confirmDialog(ctx, t('confirm_reject'), danger: true)) return;
  }
  final err = await app.setStatus(o, ns, warehouse: wh);
  if (!ctx.mounted) return;
  toast(ctx, err == null ? t('saved') : t(err), error: err != null);
}

Future<void> handleDeleteOrder(BuildContext ctx, OrderItem o) async {
  final msg = o.status == 'Dispatched' ? t('confirm_delete_dispatched') : t('confirm_delete');
  if (!await confirmDialog(ctx, msg, danger: true)) return;
  final err = await app.deleteOrder(o);
  if (!ctx.mounted) return;
  toast(ctx, err == null ? t('saved') : t(err), error: err != null);
}

// ============================================================================
// LOGIN
// ============================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _pin = TextEditingController();
  final _name = TextEditingController();
  String _role = kRoleSales;
  String? _err;
  bool _hide = true;

  @override
  void dispose() {
    _pin.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final ok = app.login(_role, _pin.text, _name.text);
    if (!ok) setState(() => _err = t('wrong_pin'));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: app.toggleLang,
                          child: Text(app.lang == 'en' ? 'አማርኛ' : 'English'),
                        ),
                        IconButton(
                          onPressed: app.toggleTheme,
                          icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Icon(Icons.ac_unit_rounded, size: 46, color: cs.onPrimaryContainer),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(t('app_title'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 22),
                    Text(t('select_role'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _roleTile(kRoleSales, Icons.point_of_sale_rounded),
                    _roleTile(kRoleStore, Icons.warehouse_rounded),
                    _roleTile(kRoleAdmin, Icons.admin_panel_settings_rounded),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: deco(t('your_name'), icon: Icons.person_outline),
                      validator: (v) =>
                          (_role == kRoleSales && (v ?? '').trim().isEmpty) ? t('required') : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pin,
                      obscureText: _hide,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: deco(t('pin'), icon: Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty ? t('required') : null,
                    ),
                    if (_err != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(_err!,
                            style: TextStyle(color: cs.error, fontWeight: FontWeight.w600)),
                      ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: _submit,
                      icon: const Icon(Icons.login_rounded),
                      label: Text(t('sign_in')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTile(String r, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final sel = _role == r;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: sel ? cs.primaryContainer : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sel ? cs.primary : cs.outlineVariant, width: sel ? 2 : 1),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: sel ? cs.primary : cs.onSurfaceVariant),
        title: Text(t(r), style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(t('${r}_desc')),
        trailing: sel ? Icon(Icons.check_circle, color: cs.primary) : null,
        onTap: () => setState(() {
          _role = r;
          _err = null;
        }),
      ),
    );
  }
}

// ============================================================================
// HOME SHELL (role router)
// ============================================================================

class _TabDef {
  final String labelKey;
  final IconData icon, selIcon;
  final Widget page;
  _TabDef(this.labelKey, this.icon, this.selIcon, this.page);
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  List<_TabDef> _tabs() {
    switch (app.role) {
      case kRoleAdmin:
        return [
          _TabDef('dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded, const DashboardPage()),
          _TabDef('orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded, const OrdersPage()),
          _TabDef('stock', Icons.inventory_2_outlined, Icons.inventory_2_rounded, const StockPage()),
        ];
      case kRoleStore:
        return [
          _TabDef('queue', Icons.local_shipping_outlined, Icons.local_shipping_rounded,
              const OrdersPage(initialFilter: 'Pending')),
          _TabDef('stock', Icons.inventory_2_outlined, Icons.inventory_2_rounded, const StockPage()),
        ];
      default:
        return [
          _TabDef('stock', Icons.inventory_2_outlined, Icons.inventory_2_rounded, const StockPage()),
          _TabDef('new_order', Icons.add_shopping_cart_outlined, Icons.add_shopping_cart_rounded,
              const NewOrderPage()),
          _TabDef('orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded, const OrdersPage()),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs();
    final idx = math.min(_index, tabs.length - 1);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('app_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text('${t(app.role!)} - ${app.userName}',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
        actions: [
          Tooltip(
            message: app.online ? t('online') : t('offline'),
            child: Icon(
              app.online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              color: app.online ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          TextButton(
            onPressed: app.toggleLang,
            child: Text(app.lang == 'en' ? 'አማ' : 'EN', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          IconButton(
            onPressed: app.toggleTheme,
            icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'view_admin':
                  app.switchView(kRoleAdmin);
                  break;
                case 'view_sales':
                  app.switchView(kRoleSales);
                  break;
                case 'view_store':
                  app.switchView(kRoleStore);
                  break;
                case 'pins':
                  changePinsDialog(context);
                  break;
                case 'logout':
                  app.logout();
                  break;
              }
            },
            itemBuilder: (_) => [
              if (app.isAdminSession) ...[
                PopupMenuItem(value: 'view_admin', child: _menuRow(Icons.admin_panel_settings_outlined, t('view_admin'))),
                PopupMenuItem(value: 'view_sales', child: _menuRow(Icons.point_of_sale_outlined, t('view_sales'))),
                PopupMenuItem(value: 'view_store', child: _menuRow(Icons.warehouse_outlined, t('view_store'))),
                PopupMenuItem(value: 'pins', child: _menuRow(Icons.password_rounded, t('change_pins'))),
                const PopupMenuDivider(),
              ],
              PopupMenuItem(value: 'logout', child: _menuRow(Icons.logout_rounded, t('logout'))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (!app.online)
            Container(
              width: double.infinity,
              color: cs.errorContainer,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(t('offline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onErrorContainer, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          Expanded(
            child: app.loaded
                ? IndexedStack(index: idx, children: tabs.map((e) => e.page).toList())
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: tabs
            .map((e) => NavigationDestination(
                  icon: Icon(e.icon),
                  selectedIcon: Icon(e.selIcon),
                  label: t(e.labelKey),
                ))
            .toList(),
      ),
    );
  }

  Widget _menuRow(IconData i, String s) => Row(children: [Icon(i, size: 20), const SizedBox(width: 12), Text(s)]);
}

// ============================================================================
// DASHBOARD (Admin analytics)
// ============================================================================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final disp = app.orders.where((o) => o.status == 'Dispatched').toList();
        final total = disp.fold<double>(0, (s, o) => s + o.total);
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final todayTotal =
            disp.where((o) => o.dateTime.startsWith(today)).fold<double>(0, (s, o) => s + o.total);
        final pending = app.orders.where((o) => o.status == 'Pending').length;
        final low = app.stock.where((s) => s.isLow).toList();

        final byPay = <String, double>{};
        final byItem = <String, int>{};
        for (final o in disp) {
          byPay[o.payment] = (byPay[o.payment] ?? 0) + o.total;
          byItem[o.itemName] = (byItem[o.itemName] ?? 0) + o.qty;
        }
        final payList = byPay.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final itemList = byItem.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final top = itemList.take(5).toList();

        return RefreshIndicator(
          onRefresh: app.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            children: [
              StatGrid([
                StatData(t('total_sales'), money(total), Icons.payments_outlined, Colors.green),
                StatData(t('today_sales'), money(todayTotal), Icons.today_outlined, Colors.blue),
                StatData(t('pending'), '$pending', Icons.hourglass_top_rounded, Colors.orange),
                StatData(t('low_items'), '${low.length}', Icons.warning_amber_rounded, Colors.red),
                StatData(t('total_orders'), '${app.orders.length}', Icons.receipt_long_outlined, Colors.indigo),
                StatData(t('items_count'), '${app.stock.length}', Icons.inventory_2_outlined, Colors.teal),
              ]),
              SectionTitle(t('sales_by_payment')),
              Panel(
                child: payList.isEmpty
                    ? const EmptyState(icon: Icons.bar_chart_rounded)
                    : Column(
                        children: payList
                            .map((e) => BarRow(
                                  label: tv(e.key),
                                  trailing: money(e.value),
                                  value: e.value,
                                  max: payList.first.value,
                                  color: Colors.green,
                                ))
                            .toList(),
                      ),
              ),
              SectionTitle(t('top_items')),
              Panel(
                child: top.isEmpty
                    ? const EmptyState(icon: Icons.leaderboard_outlined)
                    : Column(
                        children: top
                            .map((e) => BarRow(
                                  label: e.key,
                                  trailing: '${n0(e.value)} ${t('sold_units')}',
                                  value: e.value.toDouble(),
                                  max: top.first.value.toDouble(),
                                  color: Colors.blue,
                                ))
                            .toList(),
                      ),
              ),
              SectionTitle(t('low_alerts')),
              if (low.isEmpty)
                const Panel(child: EmptyState(icon: Icons.verified_outlined))
              else
                ...low.map((s) => Panel(
                      accent: stockColor(s.status),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('${t('remaining')}: ${n0(s.remaining)}  |  ${t('reorder_level')}: ${n0(s.reorder)}',
                                    style: TextStyle(
                                        fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          StatusChip(
                              text: tv(s.status), color: stockColor(s.status), icon: Icons.warning_amber_rounded),
                        ],
                      ),
                    )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// ORDERS
// ============================================================================

class OrdersPage extends StatefulWidget {
  final String initialFilter;
  const OrdersPage({super.key, this.initialFilter = 'All'});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late String _filter = widget.initialFilter;
  String _q = '';
  bool _mine = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        int count(String s) => app.orders.where((o) => o.status == s).length;
        final query = _q.trim().toLowerCase();
        final list = app.orders.where((o) {
          if (_filter != 'All' && o.status != _filter) return false;
          if (_mine && o.orderedBy != app.userName) return false;
          if (query.isEmpty) return true;
          return o.orderNo.toLowerCase().contains(query) ||
              o.itemName.toLowerCase().contains(query) ||
              o.customer.toLowerCase().contains(query) ||
              o.orderedBy.toLowerCase().contains(query);
        }).toList();

        return RefreshIndicator(
          onRefresh: app.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            children: [
              StatGrid([
                StatData(t('pending'), '${count('Pending')}', Icons.hourglass_top_rounded, statusColor('Pending')),
                StatData(t('approved'), '${count('Approved')}', Icons.thumb_up_alt_outlined, statusColor('Approved')),
                StatData(t('dispatched'), '${count('Dispatched')}', Icons.local_shipping_outlined,
                    statusColor('Dispatched')),
                StatData(t('rejected'), '${count('Rejected')}', Icons.cancel_outlined, statusColor('Rejected')),
              ]),
              const SizedBox(height: 12),
              TextField(
                decoration: deco(t('search'), icon: Icons.search),
                onChanged: (v) => setState(() => _q = v),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (app.role == kRoleSales)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(t('mine_only')),
                          selected: _mine,
                          onSelected: (v) => setState(() => _mine = v),
                        ),
                      ),
                    ...['All', ...kStatuses].map((s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tv(s)),
                            selected: _filter == s,
                            onSelected: (_) => setState(() => _filter = s),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (list.isEmpty) const EmptyState() else ...list.map((o) => OrderCard(o)),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderItem o;
  const OrderCard(this.o, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sc = statusColor(o.status);
    return Panel(
      accent: sc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.orderNo,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: cs.primary)),
                    Text(o.dateTime, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              StatusChip(text: tv(o.status), color: sc),
            ],
          ),
          const SizedBox(height: 8),
          Text(o.itemName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          if (o.brand.isNotEmpty)
            Text(o.brand, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${n0(o.qty)} x ${money(o.unitPrice)}', style: TextStyle(color: cs.onSurfaceVariant)),
              const Spacer(),
              Text(money(o.total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const Divider(height: 18),
          _InfoRow(Icons.person_outline, t('customer'), o.customer),
          _InfoRow(Icons.badge_outlined, t('ordered_by'), o.orderedBy),
          _InfoRow(Icons.payments_outlined, t('payment_status'), tv(o.payment)),
          _InfoRow(Icons.store_outlined, t('store_verification'),
              o.warehouse.isEmpty ? t('warehouse_pending') : tv(o.warehouse)),
          _InfoRow(Icons.draw_outlined, t('signature'), o.signature),
          _actions(context),
        ],
      ),
    );
  }

  Widget _actions(BuildContext ctx) {
    final role = app.role;
    final btns = <Widget>[];

    if (role == kRoleStore) {
      if (o.status == 'Pending') {
        btns.add(OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => handleStatus(ctx, o, 'Rejected'),
          icon: const Icon(Icons.close_rounded),
          label: Text(t('reject')),
        ));
        btns.add(FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade700),
          onPressed: () => handleStatus(ctx, o, 'Approved'),
          icon: const Icon(Icons.check_rounded),
          label: Text(t('approve')),
        ));
      } else if (o.status == 'Approved') {
        btns.add(OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () => handleStatus(ctx, o, 'Rejected'),
          icon: const Icon(Icons.close_rounded),
          label: Text(t('reject')),
        ));
        btns.add(FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
          onPressed: () => handleStatus(ctx, o, 'Dispatched'),
          icon: const Icon(Icons.local_shipping_rounded),
          label: Text(t('dispatch')),
        ));
      }
    }

    if (role == kRoleAdmin) {
      btns.add(PopupMenuButton<String>(
        onSelected: (s) => handleStatus(ctx, o, s),
        itemBuilder: (_) => kStatuses
            .where((s) => s != o.status)
            .map((s) => PopupMenuItem(
                  value: s,
                  child: Row(children: [
                    Icon(Icons.circle, size: 12, color: statusColor(s)),
                    const SizedBox(width: 10),
                    Text(tv(s)),
                  ]),
                ))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(ctx).colorScheme.outline),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.swap_horiz_rounded, size: 18),
            const SizedBox(width: 6),
            Text(t('override_status'), style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
      ));
      btns.add(IconButton(
        tooltip: t('delete'),
        onPressed: () => handleDeleteOrder(ctx, o),
        icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
      ));
    }

    if (btns.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: btns,
      ),
    );
  }
}

// ============================================================================
// STOCK CARD
// ============================================================================

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  String _q = '';
  bool _lowOnly = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final manage = app.role == kRoleAdmin;
        final query = _q.trim().toLowerCase();
        final list = app.stock.where((s) {
          if (_lowOnly && !s.isLow) return false;
          if (query.isEmpty) return true;
          return s.name.toLowerCase().contains(query) ||
              s.brand.toLowerCase().contains(query) ||
              s.itemNo.toLowerCase().contains(query);
        }).toList();
        final lowCount = app.stock.where((s) => s.isLow).length;
        final units = app.stock.fold<int>(0, (a, s) => a + math.max(0, s.remaining));

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: manage
              ? FloatingActionButton.extended(
                  onPressed: () => editStockDialog(context, null),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(t('add_item')),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: app.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(12, 12, 12, manage ? 88 : 24),
              children: [
                StatGrid([
                  StatData(t('items_count'), '${app.stock.length}', Icons.inventory_2_outlined, Colors.teal),
                  StatData(t('units_left'), n0(units), Icons.warehouse_outlined, Colors.blue),
                  StatData(t('low_items'), '$lowCount', Icons.warning_amber_rounded, Colors.red),
                  StatData(t('in_stock'), '${app.stock.length - lowCount}', Icons.check_circle_outline,
                      Colors.green),
                ]),
                const SizedBox(height: 12),
                TextField(
                  decoration: deco(t('search'), icon: Icons.search),
                  onChanged: (v) => setState(() => _q = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      avatar: const Icon(Icons.warning_amber_rounded, size: 18),
                      label: Text(t('low_stock')),
                      selected: _lowOnly,
                      onSelected: (v) => setState(() => _lowOnly = v),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (list.isEmpty) const EmptyState() else ...list.map((s) => StockCard(s, manage: manage)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StockCard extends StatelessWidget {
  final StockItem s;
  final bool manage;
  const StockCard(this.s, {super.key, required this.manage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sc = stockColor(s.status);
    final cap = math.max(math.max(s.reorder * 3, s.opening + s.stockIn), 1);
    final ratio = (math.max(0, s.remaining) / cap).clamp(0.0, 1.0).toDouble();

    Widget cell(String label, String value, {bool big = false, Color? color}) => Expanded(
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: big ? 20 : 15, color: color)),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(fontSize: 10.5, color: cs.onSurfaceVariant)),
            ],
          ),
        );

    return Panel(
      accent: sc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('${s.itemNo}  |  ${s.brand}',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                text: tv(s.status),
                color: sc,
                icon: s.isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: sc,
            backgroundColor: alpha(sc, 0.15),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cell(t('opening_stock'), n0(s.opening)),
              cell(t('stock_in'), n0(s.stockIn)),
              cell(t('stock_out'), n0(s.stockOut)),
              cell(t('remaining'), n0(s.remaining), big: true, color: sc),
              cell(t('reorder_level'), n0(s.reorder)),
            ],
          ),
          if (manage) ...[
            const Divider(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              children: [
                TextButton.icon(
                  onPressed: () => stockInDialog(context, s),
                  icon: const Icon(Icons.add_box_outlined, size: 18),
                  label: Text(t('stock_in_btn')),
                ),
                TextButton.icon(
                  onPressed: () => editStockDialog(context, s),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(t('edit')),
                ),
                IconButton(
                  tooltip: t('delete'),
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
                  onPressed: () async {
                    if (!await confirmDialog(context, t('confirm_delete'), danger: true)) return;
                    final err = await app.deleteStock(s);
                    if (!context.mounted) return;
                    toast(context, err == null ? t('saved') : t(err), error: err != null);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// NEW ORDER FORM (Sales)
// ============================================================================

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final _form = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _qty = TextEditingController();
  final _price = TextEditingController();
  final _customer = TextEditingController();
  final _by = TextEditingController();
  final _sign = TextEditingController();
  String? _stockId;
  String _payment = 'Cash';
  bool _busy = false;
  int _resetN = 0;

  @override
  void initState() {
    super.initState();
    _by.text = app.userName;
    _qty.addListener(_rebuild);
    _price.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _brand.dispose();
    _qty.dispose();
    _price.dispose();
    _customer.dispose();
    _by.dispose();
    _sign.dispose();
    super.dispose();
  }

  StockItem? _sel() {
    for (final s in app.stock) {
      if (s.id == _stockId) return s;
    }
    return null;
  }

  double get _total =>
      (int.tryParse(_qty.text.trim()) ?? 0) *
      (double.tryParse(_price.text.trim().replaceAll(',', '')) ?? 0);

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final s = _sel();
    if (s == null) return;
    setState(() => _busy = true);
    final now = DateTime.now();
    final stamp = DateFormat('yyyy-MM-dd HH:mm').format(now);
    final o = OrderItem(
      id: 'ord_${now.millisecondsSinceEpoch}',
      orderNo: app.nextOrderNo(),
      dateTime: stamp,
      createdMs: now.millisecondsSinceEpoch,
      stockId: s.id,
      itemName: s.name,
      brand: s.brand,
      qty: int.parse(_qty.text.trim()),
      unitPrice: double.parse(_price.text.trim().replaceAll(',', '')),
      payment: _payment,
      customer: _customer.text.trim(),
      orderedBy: _by.text.trim(),
      signature: '${_sign.text.trim()} - $stamp',
      warehouse: '',
      status: 'Pending',
    );
    final err = await app.submitOrder(o);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      toast(context, t(err), error: true);
      return;
    }
    toast(context, t('order_submitted'));
    _qty.clear();
    _price.clear();
    _customer.clear();
    _sign.clear();
    _brand.clear();
    setState(() {
      _stockId = null;
      _payment = 'Cash';
      _resetN++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        final s = _sel();
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey('item$_resetN'),
                        value: s?.id,
                        isExpanded: true,
                        decoration: deco(t('item_name_model'), icon: Icons.inventory_2_outlined),
                        items: app.stock
                            .map((x) => DropdownMenuItem<String>(
                                  value: x.id,
                                  enabled: x.remaining > 0,
                                  child: Text(
                                    '${x.name}  |  ${t('available')}: ${n0(x.remaining)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: x.remaining <= 0
                                        ? TextStyle(color: Theme.of(context).disabledColor)
                                        : null,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _stockId = v;
                          _brand.text = _sel()?.brand ?? '';
                        }),
                        validator: (v) => v == null ? t('required') : null,
                      ),
                      if (s != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: StatusChip(
                              text: '${t('available')}: ${n0(s.remaining)}  -  ${tv(s.status)}',
                              color: stockColor(s.status),
                              icon: s.isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _brand,
                        readOnly: true,
                        decoration: deco(t('brand'), icon: Icons.branding_watermark_outlined),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _qty,
                              keyboardType: TextInputType.number,
                              decoration: deco(t('quantity'), icon: Icons.numbers_rounded),
                              validator: (v) {
                                final n = int.tryParse((v ?? '').trim());
                                if (n == null || n <= 0) return t('invalid_number');
                                final cur = _sel();
                                if (cur != null && n > cur.remaining) {
                                  return '${t('insufficient')} (${cur.remaining})';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _price,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: deco(t('unit_price'), icon: Icons.sell_outlined),
                              validator: (v) {
                                final n = double.tryParse((v ?? '').trim().replaceAll(',', ''));
                                return (n == null || n <= 0) ? t('invalid_number') : null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calculate_outlined, color: cs.onPrimaryContainer),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(t('total_amount'),
                                  style: TextStyle(
                                      color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(money(_total),
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: cs.onPrimaryContainer)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('pay$_resetN'),
                        value: _payment,
                        decoration: deco(t('payment_status'), icon: Icons.payments_outlined),
                        items: kPayments
                            .map((p) => DropdownMenuItem(value: p, child: Text(tv(p))))
                            .toList(),
                        onChanged: (v) => setState(() => _payment = v ?? 'Cash'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customer,
                        decoration: deco(t('customer'),
                            icon: Icons.person_outline, hint: t('customer_hint')),
                        validator: (v) => (v ?? '').trim().isEmpty ? t('required') : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _by,
                        decoration: deco(t('ordered_by'), icon: Icons.badge_outlined),
                        validator: (v) => (v ?? '').trim().isEmpty ? t('required') : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _sign,
                        textCapitalization: TextCapitalization.words,
                        decoration: deco(t('signature'),
                            icon: Icons.draw_outlined, hint: t('signature_hint')),
                        validator: (v) => (v ?? '').trim().isEmpty ? t('required') : null,
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                        onPressed: _busy ? null : _submit,
                        icon: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send_rounded),
                        label: Text(t('submit')),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
