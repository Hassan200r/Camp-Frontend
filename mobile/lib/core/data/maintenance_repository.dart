import '../../features/maintenance/domain/maintenance_item_model.dart';
import '../../features/maintenance/domain/service_schedule_item.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceItem>> loadMaintenanceItems();
  Future<void> saveMaintenanceItems(List<MaintenanceItem> items);
  Future<void> deleteMaintenanceItem(String id);
  Future<List<ServiceScheduleItem>> loadServiceSchedule(String bikeId);
  Future<void> saveServiceSchedule(String bikeId, List<ServiceScheduleItem> items);
  Future<bool> loadHarshConditions(String bikeId);
  Future<void> saveHarshConditions(String bikeId, bool isHarsh);
  Future<void> deleteServiceSchedule(String bikeId);
  Future<Map<String, dynamic>?> loadJettingBaseline();
  Future<void> saveJettingBaseline(Map<String, dynamic>? baseline);
  Future<Map<String, bool>> loadChecklist();
  Future<void> saveChecklist(Map<String, bool> checklist);
  Future<void> clear();
  Future<void> flush();
}
