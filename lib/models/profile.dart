/// A row of `profiles`, joined with its role name from `roles`.
class Profile {
  final String id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final int? roleId;
  final String role; // 'admin' | 'customer'
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.roleId,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isCustomer => !isAdmin;

  String get fullName {
    final name = [firstname, lastname]
        .where((p) => p != null && p.trim().isNotEmpty)
        .join(' ');
    return name.isEmpty ? (email ?? 'Customer') : name;
  }

  /// Expects `select('*, roles(role)')`.
  factory Profile.fromMap(Map<String, dynamic> map) {
    final roleRow = map['roles'];
    return Profile(
      id: map['id'] as String,
      email: map['email'] as String?,
      firstname: map['firstname'] as String?,
      lastname: map['lastname'] as String?,
      roleId: (map['role_id'] as num?)?.toInt(),
      role: roleRow is Map ? (roleRow['role'] as String? ?? 'customer') : 'customer',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
