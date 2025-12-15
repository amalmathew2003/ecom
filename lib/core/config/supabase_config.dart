import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://vejtrbrznozxmjnpmfiy.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlanRyYnJ6bm96eG1qbnBtZml5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2MTA2ODMsImV4cCI6MjA4MTE4NjY4M30.9IOj_wb-CFC3h0prF-qXN-BA-Sci0NqZAShhXKQWWc0',
    );
  }
}
