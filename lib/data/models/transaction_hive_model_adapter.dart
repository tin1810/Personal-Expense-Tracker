import 'package:hive/hive.dart';
import 'package:personal_expense_tracker_app/data/models/transaction_hive_model.dart';

const int transactionHiveTypeId = 1;

class TransactionHiveModelAdapter extends TypeAdapter<TransactionHiveModel> {
  @override
  final int typeId = transactionHiveTypeId;

  @override
  TransactionHiveModel read(BinaryReader reader) {
    return TransactionHiveModel(
      id: reader.readString(),
      title: reader.readString(),
      amount: reader.readDouble(),
      dateMillis: reader.readInt(),
      currencyCode: reader.readString(),
      kindKey: reader.readString(),
      categoryKey: reader.readString(),
      note: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TransactionHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.dateMillis);
    writer.writeString(obj.currencyCode);
    writer.writeString(obj.kindKey);
    writer.writeString(obj.categoryKey);
    writer.writeString(obj.note);
  }
}
