import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم، حاول مرة أخرى']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'تعذر الاتصال بالخادم، تحقق من الإنترنت']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'العنصر المطلوب غير موجود']);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'هذا الإجراء متعارض مع بيانات موجودة بالفعل']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'البيانات المدخلة غير صحيحة']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'ليس لديك صلاحية القيام بهذا الإجراء']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'حدث خطأ غير متوقع']);
}
