import 'package:hive/hive.dart';
import 'package:personal_expense_tracker_app/data/models/expense_hive_model.dart';

const int expenseHiveTypeId = 0;

/// Manual adapter 
class ExpenseHiveModelAdapter extends TypeAdapter<ExpenseHiveModel> {
  @override
  final int typeId = expenseHiveTypeId;

  @override
  ExpenseHiveModel read(BinaryReader reader) {
    return ExpenseHiveModel(
      id: reader.readString(),
      title: reader.readString(),
      amount: reader.readDouble(),
      dateMillis: reader.readInt(),
      categoryKey: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.dateMillis);
    writer.writeString(obj.categoryKey);
  }
}
