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
    defaultValue: 'https://iqpmrhooncalxqxzjwfl.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxcG1yaG9vbmNhbHhxeHpqd2ZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMwOTMyODIsImV4cCI6MjEwODY2OTI4Mn0.0u-pzdyJPOtlFoEnBRVaS-WiN2hTYFomjexO1C7Q2_0',
  );

  static bool get isConfigured =>
      !url.contains('YOUR-PROJECT-REF') && !anonKey.startsWith('YOUR_');
}
