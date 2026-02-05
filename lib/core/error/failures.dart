abstract class Failure {
  final String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure([String? message]) : super(message ?? 'Ha ocurrido un error inesperado');
}
