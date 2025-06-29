import 'package:flutter/material.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const profileImage = 'assets/images/rana-DM4GML9S.jpg';
    const userName = 'Rana Sheikh';
    const userEmail = 'rana6424sheikh@gmail.com';
    const phone = '+8801613475871';

    return Scaffold(
      backgroundColor: Colors.purple.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(profileImage),
                ),
                const SizedBox(height: 12),
                const Text(
                  userName,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  phone,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('About Me'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'I am a Flutter developer who loves creating clean and user-friendly apps. '
                    'In my free time, I enjoy photography, traveling, and reading books.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('App Use Technique'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'To use this app effectively, keep it updated and explore all features. '
                    'Customize your settings to match your preferences and make sure to back up your data regularly.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Settings'),
            _buildListTile(
              icon: Icons.settings,
              title: 'Account Settings',
              onTap: () {
                // TODO: Implement navigation
              },
            ),
            _buildListTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Text(
                          'Privacy Policy',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          softWrap: true,
                          '''
                      
Your privacy is our top priority. Here’s how we protect your information:

Minimal Data Collection: We only collect the essential data needed to make the app work smoothly and improve your experience.

No Third-Party Sharing: Your personal information is never sold or shared with third parties without your explicit permission.

Data Security: We use industry-standard security measures to protect your data from unauthorized access, alteration, or disclosure.

User Control: You have full control over your data. You can manage your privacy settings and choose what information you want to share.

Transparency: We clearly explain what data we collect and how it’s used in our Privacy Policy.

Regular Updates: Keeping the app updated ensures you have the latest security patches and privacy enhancements.

Remember, always review our Privacy Policy to stay informed and feel free to contact us if you have any questions or concerns about your data privacy.
                          ''',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildListTile(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Text(
                          'About This App',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          softWrap: true,

                          '''
                    
This Video Player app is designed to provide a smooth and intuitive experience for playing videos stored locally on your device. It supports a wide range of video formats and offers essential playback features such as:

Easy Video Browsing: Quickly access all your videos from your device’s storage.

High-Quality Playback: Enjoy your videos with clear, crisp display and smooth controls.

User-Friendly Interface: Simple and clean design to make video watching effortless.

Playback Controls: Play, pause, seek, and toggle full-screen mode with ease.

Orientation Support: Switch seamlessly between portrait and landscape modes.

Background & Volume Control: Adjust brightness and volume directly from the player.

Privacy-Focused: The app does not upload or share your videos—everything stays on your device.

Whether you want to watch movies, clips, or personal videos, this app makes it easy and enjoyable to play your media files anytime, anywhere.

Thank you for choosing our Video Player app!
                          ''',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildListTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                // TODO: Implement logout
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.withOpacity(0.1),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
