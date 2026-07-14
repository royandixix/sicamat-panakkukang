int? toIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? toDoubleValue(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool toBoolValue(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;

  final text = value.toString().trim().toLowerCase();
  return text == '1' ||
      text == 'true' ||
      text == 'yes' ||
      text == 'ya' ||
      text == 'aktif';
}

String toStringValue(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? toNullableString(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? toDateTimeValue(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}

String dateToSql(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}
