import 'package:ecom/features/user/profile/data/profile_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final profile = Rxn<ProfileModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      isLoading.value = true;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        profile.value = ProfileModel.fromJson(data);
      }
    } catch (e) {
      print("Profile Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearProfile() {
    profile.value = null;
  }
}
