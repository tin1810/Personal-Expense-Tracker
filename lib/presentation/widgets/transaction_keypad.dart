import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_transaction/add_transaction_bloc.dart';
import 'package:personal_expense_tracker_app/presentation/bloc/add_transaction/add_transaction_event.dart';

/// Reference-style custom keypad for a single currency amount (Bloc-driven).
class TransactionKeypad extends StatelessWidget {
  const TransactionKeypad({required this.onOk, super.key});

  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    void dispatch(AddTransactionEvent event) => context.read<AddTransactionBloc>().add(event);

    Widget keyBtn(String label, VoidCallback onTap, {Color? color}) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            height: 52 * 4,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: keyBtn('1', () => dispatch(const AddTransactionDigitPressed('1')))),
                      Expanded(child: keyBtn('2', () => dispatch(const AddTransactionDigitPressed('2')))),
                      Expanded(child: keyBtn('3', () => dispatch(const AddTransactionDigitPressed('3')))),
                      Expanded(
                        child: keyBtn(
                          '⌫',
                          () => dispatch(const AddTransactionBackspacePressed()),
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: keyBtn('4', () => dispatch(const AddTransactionDigitPressed('4')))),
                      Expanded(child: keyBtn('5', () => dispatch(const AddTransactionDigitPressed('5')))),
                      Expanded(child: keyBtn('6', () => dispatch(const AddTransactionDigitPressed('6')))),
                      Expanded(
                        child: keyBtn(
                          'AC',
                          () => dispatch(const AddTransactionClearPressed()),
                          color: Theme.of(context).colorScheme.errorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: keyBtn('7', () => dispatch(const AddTransactionDigitPressed('7')))),
                      Expanded(child: keyBtn('8', () => dispatch(const AddTransactionDigitPressed('8')))),
                      Expanded(child: keyBtn('9', () => dispatch(const AddTransactionDigitPressed('9')))),
                      Expanded(child: keyBtn('.', () => dispatch(const AddTransactionDotPressed()))),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: keyBtn('00', () => dispatch(const AddTransactionDoubleZeroPressed()))),
                      Expanded(child: keyBtn('0', () => dispatch(const AddTransactionDigitPressed('0')))),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FilledButton(
                            onPressed: onOk,
                            child: const Text('OK'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
