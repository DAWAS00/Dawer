import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/restaurant_signup_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantStepBasicProfile extends StatelessWidget {
  const RestaurantStepBasicProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantSignupViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Basic Profile',
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Let\'s start with your company details. This information helps us verify your business and build trust with customers.',
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () {
              // Simulated image picking
              vm.updateBasicProfile(photoPath: 'dummy/path/to/photo.jpg');
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: vm.data.photoPath != null
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 40)
                  : const Icon(Icons.camera_alt, color: Colors.grey, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: vm.data.companyName,
          onChanged: (val) => vm.updateBasicProfile(companyName: val, ownerName: vm.data.ownerName),
          decoration: InputDecoration(
            labelText: 'Restaurant / Company Name',
            hintText: 'e.g., The Golden Spoon',
            errorText: vm.errors['companyName'],
            border: OutlineBinding.border(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: vm.data.ownerName,
          onChanged: (val) => vm.updateBasicProfile(ownerName: val, companyName: vm.data.companyName),
          decoration: InputDecoration(
            labelText: 'Owner Name',
            hintText: 'e.g., John Doe',
            errorText: vm.errors['ownerName'],
            border: OutlineBinding.border(),
          ),
        ),
      ],
    );
  }
}

class OutlineBinding {
  static OutlineInputBorder border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );
  }
}
