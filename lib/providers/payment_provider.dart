import 'package:flutter/material.dart';
import 'package:teacher_notebook/models/payment_model.dart';
import 'package:teacher_notebook/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();
  List<Payment> _payments = [];
  List<Payment> _unpaidPayments = [];
  bool _isLoading = false;
  String? _error;
  double _totalIncome = 0.0;
  double _totalPending = 0.0;

  List<Payment> get payments => _payments;
  List<Payment> get unpaidPayments => _unpaidPayments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalIncome => _totalIncome;
  double get totalPending => _totalPending;

  Future<void> loadPayments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _payments = await _repository.getAllPayments();
      _totalIncome = await _repository.getTotalIncome();
      _totalPending = await _repository.getTotalPending();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnpaidPayments() async {
    try {
      _unpaidPayments = await _repository.getUnpaidPayments();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addPayment(Payment payment) async {
    try {
      await _repository.insertPayment(payment);
      await loadPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePayment(Payment payment) async {
    try {
      await _repository.updatePayment(payment);
      await loadPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePayment(int id) async {
    try {
      await _repository.deletePayment(id);
      await loadPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Payment>> getStudentPayments(int studentId) async {
    return await _repository.getStudentPayments(studentId);
  }
}
