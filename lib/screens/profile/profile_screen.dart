import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, _) {
          final user = authService.currentUser;

          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // Profile Options
                _buildProfileOptions(),
                const SizedBox(height: 24),

                // Stats Section
                _buildStatsSection(),
                const SizedBox(height: 24),

                // Settings Section
                _buildSettingsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: user.profilePicture != null
                ? ClipOval(
                    child: Image.network(
                      user.profilePicture!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // User Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Username and Email
          Text(
            '@${user.username}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Edit Profile Button
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to edit profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile feature coming soon!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildOptionTile(
          icon: Icons.rate_review,
          title: 'My Reviews',
          subtitle: 'View and manage your reviews',
          onTap: () {
            // TODO: Navigate to user reviews
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('My Reviews feature coming soon!'),
              ),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.favorite,
          title: 'Liked Reviews',
          subtitle: 'Reviews you have liked',
          onTap: () {
            // TODO: Navigate to liked reviews
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Liked Reviews feature coming soon!'),
              ),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.bookmark,
          title: 'Saved Colleges',
          subtitle: 'Your bookmarked colleges',
          onTap: () {
            // TODO: Navigate to saved colleges
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved Colleges feature coming soon!'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Reviews', '0'),
              _buildStatItem('Likes', '0'),
              _buildStatItem('Helped', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        _buildOptionTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          onTap: () {
            // TODO: Navigate to notification settings
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification settings coming soon!'),
              ),
            );
          },
        ),

        _buildOptionTile(
          icon: Icons.privacy_tip,
          title: 'Privacy',
          subtitle: 'Privacy and data settings',
          onTap: () {
            // TODO: Navigate to privacy settings
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Privacy settings coming soon!'),
              ),
            );
          },
        ),

        _buildOptionTile(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            // TODO: Navigate to help screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help & Support coming soon!'),
              ),
            );
          },
        ),

        _buildOptionTile(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {
            _showAboutDialog();
          },
        ),

        const SizedBox(height: 16),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Udaan',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.school,
          color: Colors.white,
          size: 24,
        ),
      ),
      children: [
        const Text('Find the perfect college for your future in Nepal.'),
        const SizedBox(height: 16),
        const Text('Made with ❤️ for students in Nepal'),
      ],
    );
  }
}
