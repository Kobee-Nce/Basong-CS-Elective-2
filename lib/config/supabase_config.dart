/// Supabase project credentials.
///
/// Get both values from: Supabase Dashboard → Project Settings → API.
/// Paste them as the defaults below, or pass them at run time:
///
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// Only ever use the public anon / publishable key here.
/// Never put the service_role (secret) key in client code.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR-PROJECT-REF.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static bool get isConfigured =>
      !url.contains('YOUR-PROJECT-REF') && !anonKey.startsWith('YOUR_');
}
