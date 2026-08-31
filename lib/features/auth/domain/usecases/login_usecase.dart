import 'package:hr_attendance_app/features/auth/data/models/auth_request_models.dart';
import 'package:hr_attendance_app/features/auth/data/models/auth_response_model.dart';

import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResponseModel> call({required LoginRequest request}) {
    return repository.login(request: request);
  }
}
