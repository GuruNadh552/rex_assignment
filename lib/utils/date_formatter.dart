import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _format = DateFormat(
    'dd MMM yyyy',
  );

  static String format(
    DateTime date,
  ) {
    return _format.format(date);
  }
}
