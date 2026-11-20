/// "₱1,250" (or "₱1,250.50" when there are centavos).
String peso(num value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return parts[1] == '00' ? '₱$whole' : '₱$whole.${parts[1]}';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Nov 19, 2026 • 10:51 PM" in the device's local time.
String formatDateTime(DateTime value) {
  final d = value.toLocal();
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour < 12 ? 'AM' : 'PM';
  return '${_months[d.month - 1]} ${d.day}, ${d.year} • $hour:$minute $ampm';
}

/// "#000042"
String orderNumber(int id) => '#${id.toString().padLeft(6, '0')}';
