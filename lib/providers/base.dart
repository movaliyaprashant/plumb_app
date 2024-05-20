import 'package:flutter/material.dart';

enum _NetworkStatus { loading, done }

abstract class BaseChangeNotifier extends ChangeNotifier {
  /// Indicates that ChangeNotifier is disposed or not.
  bool _disposed = false;

  /// Used along with network calls.
  /// to identify current network status.
  late _NetworkStatus _status;

  /// Errors.
  dynamic _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void setError(dynamic error) {
    print("BaseChangeNotifier: setError: ${error.toString()}");
    _error = error;
  }

  void hideError() {
    _error = null;
  }

  void setLoading() {
    _status = _NetworkStatus.loading;
    hideError();
    notifyListeners();
  }

  void hideLoading() {
    _status = _NetworkStatus.done;
  }

  dynamic get error => _error;

  bool isLoading() => _status == _NetworkStatus.loading;

  bool isError() => _error != null;

  bool isDone() => !isLoading() && !isError();
}
