import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAuthenticated) {
      return _buildUnauthenticatedView(context);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: authProvider.user!),
                ),
              );
            },
          ),
        ],
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Аватар
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    child: Text(
                      authProvider.user!.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Имя пользователя
                  Text(
                    authProvider.user!.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Email
                  Text(
                    authProvider.user!.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  
                  if (authProvider.user!.isAdmin)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Администратор',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  const Divider(height: 32),
                  
                  // Информация о пользователе
                  _buildInfoCard(
                    context,
                    title: 'Личная информация',
                    items: [
                      if (authProvider.user!.fullName != null)
                        _buildInfoItem(
                          icon: Icons.person,
                          label: 'Полное имя',
                          value: authProvider.user!.fullName!,
                        ),
                      if (authProvider.user!.phone != null)
                        _buildInfoItem(
                          icon: Icons.phone,
                          label: 'Телефон',
                          value: authProvider.user!.phone!,
                        ),
                      _buildInfoItem(
                        icon: Icons.calendar_today,
                        label: 'Дата регистрации',
                        value: _formatDate(authProvider.user!.createdAt),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Кнопки действий
                  _buildActionButton(
                    icon: Icons.book_online,
                    label: 'Мои бронирования',
                    onTap: () {
                      Navigator.of(context).pushNamed('/bookings');
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildActionButton(
                    icon: Icons.favorite,
                    label: 'Избранные отели',
                    onTap: () {
                      Navigator.of(context).pushNamed('/favorites');
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (authProvider.user!.isAdmin)
                    _buildActionButton(
                      icon: Icons.admin_panel_settings,
                      label: 'Панель администратора',
                      onTap: () {
                        Navigator.of(context).pushNamed('/admin');
                      },
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Кнопка выхода
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Выйти из аккаунта'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.errorColor,
                        side: const BorderSide(color: AppConstants.errorColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildUnauthenticatedView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Вы не авторизованы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Войдите в систему или зарегистрируйтесь, чтобы получить доступ к профилю',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppConstants.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}