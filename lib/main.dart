import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DialingScreen(),
    );
  }
}

class DialingScreen extends StatelessWidget {
  const DialingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 320,
            height: 570,
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 25,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF292940),
                width: 12,
              ),
              borderRadius: BorderRadius.circular(42),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Column(
              children: [
                // Title
                Text(
                  'Dialing',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 40),

                // Profile
                ProfilePicture(),

                SizedBox(height: 25),

                // Name
                Text(
                  'Perlas de Luna',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                // Phone number
                Text(
                  '+ 1 234 567 890',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 35),

                // Divider
                Divider(
                  color: Color(0xFFE0E0E0),
                  thickness: 1,
                ),

                SizedBox(height: 20),

                // Top controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CallControl(
                      icon: Icons.mic_none,
                      label: 'Mute',
                    ),
                    CallControl(
                      icon: Icons.bluetooth,
                      label: 'Bluetooth',
                    ),
                    CallControl(
                      icon: Icons.phone_in_talk_outlined,
                      label: 'Hold',
                    ),
                  ],
                ),

                Spacer(),

                // Bottom controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.grid_view_outlined,
                      size: 22,
                      color: Colors.grey,
                    ),

                    CallButton(),

                    Icon(
                      Icons.volume_up_outlined,
                      size: 23,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE4FAFC),
          ),
        ),

        Container(
          width: 98,
          height: 98,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF92E8F0),
          ),
        ),

        Container(
          width: 78,
          height: 78,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF13BBD4),
          ),
        ),

        const CircleAvatar(
          radius: 34,
          backgroundImage: AssetImage(
            'assets/profile.jpg',
          ),
        ),
      ],
    );
  }
}


class CallControl extends StatelessWidget {
  final IconData icon;
  final String label;

  const CallControl({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 23,
          color: Colors.grey,
        ),

        const SizedBox(height: 7),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}


class CallButton extends StatelessWidget {
  const CallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF15C4DD),
      ),
      child: const Icon(
        Icons.phone,
        color: Colors.white,
        size: 27,
      ),
    );
  }
}