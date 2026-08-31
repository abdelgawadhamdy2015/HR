import 'package:hr_attendance_app/features/auth/data/models/auth_request_models.dart';
import 'package:hr_attendance_app/features/auth/data/models/auth_response_model.dart';

import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResponseModel> call({required RegisterRequest request}) {
    return repository.register(request: request);
  }
}
