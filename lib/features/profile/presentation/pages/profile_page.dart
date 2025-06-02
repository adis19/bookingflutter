import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Text(
                  'Профиль',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 32),

                // User Info Section
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    if (authService.isAuthenticated && authService.userModel != null) {
                      final user = authService.userModel!;
                      return Column(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Name
                          Text(
                            user.fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Email
                          Text(
                            user.email,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Гость',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              AppRoutes.pushNamed(context, AppRoutes.login);
                            },
                            child: const Text('Войти в аккаунт'),
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 40),

                // Menu Items
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'История бронирований',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.favorite,
                  title: 'Избранное',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Настройки',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.help,
                  title: 'Помощь',
                  onTap: () {},
                ),
                
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    if (authService.isAuthenticated) {
                      return _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Выйти',
                        isDestructive: true,
                        onTap: () async {
                          await authService.signOut();
                          if (context.mounted) {
                            AppRoutes.pushNamedAndClearStack(context, AppRoutes.login);
                          }
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppTheme.errorColor : AppTheme.textSecondary,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
