import '../models/priority_model.dart';
import '../services/priority_service.dart';

class PriorityController {
  final PriorityService _priorityService = PriorityService();

  Future<void> addPriority(String name) {
    return _priorityService.addPriority(name);
  }

  Future<List<PriorityModel>> fetchPriorities() {
    return _priorityService.fetchPriorities();
  }

  Future<PriorityModel> getPriorityById(int id) {
    return _priorityService.getPriorityById(id);
  }

  Future<void> updatePriority(int id, String priorityName) {
    return _priorityService.updatePriority(id, priorityName);
  }

  Future<void> deletePriority(int id) {
    return _priorityService.deletePriority(id);
  }
}

