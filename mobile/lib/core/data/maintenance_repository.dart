import '../../features/maintenance/domain/maintenance_item_model.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceItem>> loadMaintenanceItems();
  Future<void> saveMaintenanceItems(List<MaintenanceItem> items);
  Future<void> deleteMaintenanceItem(String id);
  Future<Map<String, dynamic>?> loadJettingBaseline();
  Future<void> saveJettingBaseline(Map<String, dynamic>? baseline);
  Future<Map<String, bool>> loadChecklist();
  Future<void> saveChecklist(Map<String, bool> checklist);
  Future<void> clear();
  Future<void> flush();
}
