import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String invoiceNumber;
  final String date;
  final String truckNumber;
  final String recipientName;
  final String containerNumber;
  final String unloadingCharge;
  final String axleType;
  final String destination;
  final String hireCharge;
  final String tollCharge;
  final String weighingCharge;
  final String haltingCharge;
  final String advanceAmount;
  final String driverName;
  final String totalAmount;
  final String pdfUrl;
  final String userId;
  final DateTime createdAt;

  Bill({
    required this.invoiceNumber,
    required this.date,
    required this.truckNumber,
    required this.recipientName,
    required this.containerNumber,
    required this.unloadingCharge,
    required this.axleType,
    required this.destination,
    required this.hireCharge,
    required this.tollCharge,
    required this.weighingCharge,
    required this.haltingCharge,
    required this.advanceAmount,
    required this.driverName,
    required this.totalAmount,
    required this.pdfUrl,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'date': date,
      'truckNumber': truckNumber,
      'recipientName': recipientName,
      'containerNumber': containerNumber,
      'unloadingCharge': unloadingCharge,
      'axleType': axleType,
      'destination': destination,
      'hireCharge': hireCharge,
      'tollCharge': tollCharge,
      'weighingCharge': weighingCharge,
      'haltingCharge': haltingCharge,
      'advanceAmount': advanceAmount,
      'driverName': driverName,
      'totalAmount': totalAmount,
      'pdfUrl': pdfUrl,
      'userId': userId,
      'createdAt': createdAt,
      'recipientNameSearch':
          recipientName.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim(),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      invoiceNumber: map['invoiceNumber'] ?? '',
      date: map['date'] ?? '',
      truckNumber: map['truckNumber'] ?? '',
      recipientName: map['recipientName'] ?? '',
      containerNumber: map['containerNumber'] ?? '',
      unloadingCharge: map['unloadingCharge'] ?? '',
      axleType: map['axleType'] ?? '',
      destination: map['destination'] ?? '',
      hireCharge: map['hireCharge'] ?? '',
      tollCharge: map['tollCharge'] ?? '',
      weighingCharge: map['weighingCharge'] ?? '',
      haltingCharge: map['haltingCharge'] ?? '',
      advanceAmount: map['advanceAmount'] ?? '',
      driverName: map['driverName'] ?? '',
      totalAmount: map['totalAmount'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
