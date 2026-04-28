enum BillStatus { paid, unpaid, pending }

class Bill {
  final String id;
  final String month;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;

  Bill({
    required this.id,
    required this.month,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      month: json['month'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      status: BillStatus.values.firstWhere(
        (e) => e.toString() == 'BillStatus.${json['status']}',
        orElse: () => BillStatus.unpaid,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }
}
