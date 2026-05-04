import 'package:equatable/equatable.dart';

sealed class AddExpenseState extends Equatable {
  const AddExpenseState();

  @override
  List<Object?> get props => [];
}

final class AddExpenseInitial extends AddExpenseState {
  const AddExpenseInitial();
}

final class AddExpenseSubmitting extends AddExpenseState {
  const AddExpenseSubmitting();
}

final class AddExpenseSuccess extends AddExpenseState {
  const AddExpenseSuccess();
}

final class AddExpenseFailure extends AddExpenseState {
  const AddExpenseFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
