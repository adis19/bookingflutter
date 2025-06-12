import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_constants.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/hotel_card.dart';
import 'hotel_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Проверяем авторизацию перед загрузкой избранного
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!_isInitialized && authProvider.isAuthenticated) {
      _isInitialized = true;
      // Используем Future.microtask чтобы отложить загрузку данных до завершения сборки виджета
      Future.microtask(() => _loadFavorites());
    }
  }

  Future<void> _loadFavorites() async {
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    try {
      await favoriteProvider.loadFavorites();
      if (mounted) {
        // Проверяем наличие ошибок после загрузки
        if (favoriteProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${favoriteProvider.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить избранное: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Проверяем, авторизован ли пользователь
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Избранные отели',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppConstants.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Требуется авторизация',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Войдите или зарегистрируйтесь,\nчтобы видеть избранные отели',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Войти',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Избранные отели',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          // Кнопка обновления списка
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Обновить список',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: favoriteProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoriteProvider.favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          favoriteProvider.error != null
                              ? 'Ошибка загрузки избранного'
                              : 'У вас пока нет избранных отелей',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (favoriteProvider.error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                            child: Text(
                              favoriteProvider.error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadFavorites,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Обновить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteProvider.favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = favoriteProvider.favorites[index];
                      // Проверяем, что hotel не null
                      if (favorite.hotel == null) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ошибка загрузки отеля',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'ID: ${favorite.id}',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await favoriteProvider.removeFromFavorites(favorite.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Dismissible(
                          key: Key('favorite-${favorite.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: AppConstants.errorColor,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Удалить из избранного',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Вы уверены, что хотите удалить этот отель из избранного?',
                                  style: GoogleFonts.montserrat(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'Отмена',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConstants.errorColor,
                                    ),
                                    child: Text(
                                      'Удалить',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) async {
                            await favoriteProvider.removeFromFavorites(favorite.id);
                          },
                          child: HotelCard(
                            hotel: favorite.hotel!,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HotelDetailsScreen(hotel: favorite.hotel!),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
} 