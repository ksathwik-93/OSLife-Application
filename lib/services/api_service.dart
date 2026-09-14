/// Prepared REST API HTTP Client stub (Dio / Http replacement ready).
abstract class APIService {
  Future<dynamic> get(String endpoint);
  Future<dynamic> post(String endpoint, Map<String, dynamic> data);
}

class MockAPIService implements APIService {
  @override
  Future<dynamic> get(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'status': 'success', 'data': []};
  }

  @override
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'status': 'success', 'result': data};
  }
}
