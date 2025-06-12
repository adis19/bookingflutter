import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user.dart';
import '../../models/booking.dart';
import '../../constants/app_constants.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Загружаем данные при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadAllData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Панель администратора',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
              tooltip: 'Выйти из аккаунта',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Статистика', icon: Icon(Icons.dashboard)),
            Tab(text: 'Пользователи', icon: Icon(Icons.people)),
            Tab(text: 'Бронирования', icon: Icon(Icons.book_online)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StatsTab(),
          _UsersTab(),
          _BookingsTab(),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Выход из аккаунта',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите выйти из аккаунта администратора?',
            style: GoogleFonts.montserrat(
              color: AppConstants.secondaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.secondaryTextColor,
              ),
              child: Text(
                'Отмена',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Выйти',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatisticsCards(),
          const SizedBox(height: 24),
          Text(
            'Популярные отели',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
            ),
          ),
          const SizedBox(height: 16),
          const _TopHotelsChart(),
        ],
      ),
    );
  }
}

class _StatisticsCards extends StatelessWidget {
  const _StatisticsCards({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: const [
        _StatCard(
          title: 'Пользователей',
          value: '42',
          icon: Icons.people_rounded,
          gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
          trend: '+12%',
        ),
        _StatCard(
          title: 'Бронирований',
          value: '156',
          icon: Icons.book_online_rounded,
          gradient: [Color(0xFF11998e), Color(0xFF38ef7d)],
          trend: '+8%',
        ),
        _StatCard(
          title: 'Отелей',
          value: '78',
          icon: Icons.hotel_rounded,
          gradient: [Color(0xFFfc4a1a), Color(0xFFf7b733)],
          trend: '+3%',
        ),
        _StatCard(
          title: 'Выручка',
          value: '29К ₽',
          icon: Icons.payments_rounded,
          gradient: [Color(0xFF8360c3), Color(0xFF2ebf91)],
          trend: '+15%',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final String trend;
  
  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.trend,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon, 
                        size: 20, 
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          trend,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHotelsChart extends StatelessWidget {
  const _TopHotelsChart({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'График популярности отелей\n(здесь будет диаграмма)',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingUsers) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (adminProvider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Нет данных о пользователях',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adminProvider.users.length,
          itemBuilder: (context, index) {
            final user = adminProvider.users[index];
            return _UserCard(user: user);
          },
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  
  const _UserCard({Key? key, required this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppConstants.primaryColor,
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? user.username,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Регистрация: ${dateFormat.format(user.createdAt)}',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (user.isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Админ',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (adminProvider.isLoadingBookings) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (adminProvider.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_online_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Нет данных о бронированиях',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adminProvider.bookings.length,
          itemBuilder: (context, index) {
            final booking = adminProvider.bookings[index];
            return _BookingCard(booking: booking);
          },
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  
  const _BookingCard({Key? key, required this.booking}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.hotel?.name ?? 'Отель',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        booking.hotel?.address ?? 'Адрес не указан',
                        style: GoogleFonts.montserrat(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: GoogleFonts.montserrat(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Даты: ${dateFormat.format(booking.checkIn)} - ${dateFormat.format(booking.checkOut)}',
              style: GoogleFonts.montserrat(fontSize: 14),
            ),
            Text(
              'Гостей: ${booking.guests} • Стоимость: ${booking.totalPrice} ₽',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
