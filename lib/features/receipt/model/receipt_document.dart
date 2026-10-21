import 'dart:convert';

/// One item line printed on a receipt.
class ReceiptLineItem {
  const ReceiptLineItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.note,
  });

  final String name;
  final int quantity;
  final int price;
  final String? note;

  int get total => quantity * price;

  /// Compact representation keeps the receipt QR payload small.
  List<Object?> toJson() {
    if (note == null || note!.isEmpty) {
      return <Object?>[name, quantity, price];
    }

    return <Object?>[name, quantity, price, note];
  }

  factory ReceiptLineItem.fromJson(List<dynamic> json) {
    return ReceiptLineItem(
      name: json.isNotEmpty ? '${json[0]}' : '',
      quantity: json.length > 1 ? _asInt(json[1]) : 0,
      price: json.length > 2 ? _asInt(json[2]) : 0,
      note: json.length > 3 && json[3] != null ? '${json[3]}' : null,
    );
  }
}

/// Everything needed to render the same receipt in the POS preview and on the
/// public receipt page.
///
/// Until the receipt API is connected, the document travels inside the QR code
/// as a compact, base64url encoded payload. A backend can later replace this
/// with an invoice lookup while keeping the page and receipt layout unchanged.
class ReceiptDocument {
  const ReceiptDocument({
    required this.invoiceNumber,
    required this.branchName,
    required this.branchCode,
    required this.branchAddress,
    required this.branchBin,
    required this.cashierName,
    required this.customerName,
    required this.tableLabel,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    required this.vatPercent,
    required this.vat,
    required this.cashoutPercent,
    required this.cashout,
    required this.total,
    required this.tenderLabel,
    required this.paidAmount,
    required this.discount,
    required this.changeDue,
    required this.isCash,
    required this.isMobileWallet,
  });

  final int invoiceNumber;
  final String branchName;
  final String branchCode;
  final String branchAddress;
  final String branchBin;
  final String cashierName;
  final String customerName;
  final String tableLabel;
  final DateTime createdAt;
  final List<ReceiptLineItem> items;
  final int subtotal;
  final double vatPercent;
  final int vat;
  final double cashoutPercent;
  final int cashout;
  final int total;
  final String tenderLabel;
  final int paidAmount;
  final int discount;
  final int changeDue;
  final bool isCash;
  final bool isMobileWallet;

  int get itemCount {
    return items.fold(0, (int sum, ReceiptLineItem line) {
      return sum + line.quantity;
    });
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'v': 1,
      'inv': invoiceNumber,
      'bn': branchName,
      'bc': branchCode,
      'ba': branchAddress,
      'bb': branchBin,
      'ca': cashierName,
      'cu': customerName,
      'tb': tableLabel,
      'at': createdAt.toIso8601String(),
      'it': items.map((ReceiptLineItem line) => line.toJson()).toList(),
      'st': subtotal,
      'vp': vatPercent,
      'vt': vat,
      'cp': cashoutPercent,
      'co': cashout,
      'tt': total,
      'td': tenderLabel,
      'pd': paidAmount,
      'dc': discount,
      'ch': changeDue,
      'ic': isCash,
      'mw': isMobileWallet,
    };
  }

  factory ReceiptDocument.fromJson(Map<String, Object?> json) {
    return ReceiptDocument(
      invoiceNumber: _asInt(json['inv']),
      branchName: _asString(json['bn']),
      branchCode: _asString(json['bc']),
      branchAddress: _asString(json['ba']),
      branchBin: _asString(json['bb']),
      cashierName: _asString(json['ca']),
      customerName: _asString(json['cu']),
      tableLabel: _asString(json['tb']),
      createdAt: DateTime.tryParse(_asString(json['at'])) ?? DateTime.now(),
      items: (json['it'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<List<dynamic>>()
          .map(ReceiptLineItem.fromJson)
          .toList(growable: false),
      subtotal: _asInt(json['st']),
      vatPercent: _asDouble(json['vp']),
      vat: _asInt(json['vt']),
      cashoutPercent: _asDouble(json['cp']),
      cashout: _asInt(json['co']),
      total: _asInt(json['tt']),
      tenderLabel: _asString(json['td']),
      paidAmount: _asInt(json['pd']),
      discount: _asInt(json['dc']),
      changeDue: _asInt(json['ch']),
      isCash: json['ic'] == true,
      isMobileWallet: json['mw'] == true,
    );
  }

  /// URL-safe token used by the public receipt link.
  String encode() {
    return base64Url
        .encode(utf8.encode(jsonEncode(toJson())))
        .replaceAll('=', '');
  }

  /// Returns `null` when the token is missing, corrupt, or from a future
  /// payload version.
  static ReceiptDocument? tryDecode(String token) {
    if (token.isEmpty) return null;

    try {
      final String padded = base64Url.normalize(token);
      final Object? decoded = jsonDecode(utf8.decode(base64Url.decode(padded)));

      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['v'] != 1 || decoded['inv'] == null) return null;
      if (decoded['it'] is! List<dynamic>) return null;
      if (DateTime.tryParse(_asString(decoded['at'])) == null) return null;

      return ReceiptDocument.fromJson(Map<String, Object?>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}

int _asInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

String _asString(Object? value) => value == null ? '' : '$value';
