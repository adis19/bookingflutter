import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _fullNameController = TextEditingController(text: widget.user.fullName ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.updateProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Профиль успешно обновлен'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Ошибка при обновлении профиля'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Имя пользователя
                    CustomTextField(
                      controller: _usernameController,
                      labelText: 'Имя пользователя',
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите имя пользователя';
                        }
                        if (value.length < 3) {
                          return 'Имя пользователя должно содержать не менее 3 символов';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Пожалуйста, введите корректный email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Полное имя
                    CustomTextField(
                      controller: _fullNameController,
                      labelText: 'Полное имя (опционально)',
                      prefixIcon: const Icon(Icons.badge),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Телефон
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Телефон (опционально)',
                      prefixIcon: const Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Кнопка сохранения
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Сохранить изменения'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 