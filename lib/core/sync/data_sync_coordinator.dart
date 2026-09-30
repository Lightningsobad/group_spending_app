import 'package:flutter/foundation.dart';

enum DataSyncScope { groups, debts, funds, all }

/// Lớp điều phối sự kiện đồng bộ dữ liệu giữa các phân hệ tại core/sync.
/// Không phụ thuộc trực tiếp vào bất kỳ Feature Cubit hay Repository nào.
class DataSyncCoordinator extends ChangeNotifier {
  DataSyncScope? _lastScope;
  DataSyncScope? get lastScope => _lastScope;

  void notifyDataChanged([DataSyncScope scope = DataSyncScope.all]) {
    _lastScope = scope;
    notifyListeners();
  }
}
