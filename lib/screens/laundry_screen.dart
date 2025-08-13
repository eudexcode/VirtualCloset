import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';

class LaundryScreen extends StatefulWidget {
  const LaundryScreen({super.key});

  @override
  State<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends State<LaundryScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _dirtyClothes = [];
  bool _isLoading = true;
  Set<String> _selectedItems = {};
  
  // Animaciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
    _loadDirtyClothes();
  }

  Future<void> _loadDirtyClothes() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('clothes')
            .select()
            .eq('user_id', user.id)
            .eq('is_dirty', true)
            .order('created_at', ascending: false);

        setState(() {
          _dirtyClothes = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dirty clothes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _washItem(String itemId) async {
    try {
      await Supabase.instance.client
          .from('clothes')
          .update({'is_dirty': false})
          .eq('id', itemId);

      setState(() {
        _dirtyClothes.removeWhere((item) => item['id'] == itemId);
        _selectedItems.remove(itemId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).laundryScreenItemWashed)),
      );
    } catch (e) {
      print('Error washing item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).laundryScreenErrorWashingItem)),
      );
    }
  }

  Future<void> _washAllSelected() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).laundryScreenSelectAtLeastOne)),
      );
      return;
    }

    try {
      await Supabase.instance.client
          .from('clothes')
          .update({'is_dirty': false})
          .inFilter('id', _selectedItems.toList());

      setState(() {
        _dirtyClothes.removeWhere((item) => _selectedItems.contains(item['id']));
        _selectedItems.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedItems.length} prendas lavadas correctamente'),
        ),
      );
    } catch (e) {
      print('Error washing selected items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).laundryScreenErrorWashingSelected)),
      );
    }
  }

  Future<void> _washAll() async {
    if (_dirtyClothes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay prendas sucias')),
      );
      return;
    }

    try {
      final itemIds = _dirtyClothes.map((item) => item['id']).toList();
      
      await Supabase.instance.client
          .from('clothes')
          .update({'is_dirty': false})
          .inFilter('id', itemIds);

      setState(() {
        _dirtyClothes.clear();
        _selectedItems.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${itemIds.length} prendas lavadas correctamente'),
        ),
      );
    } catch (e) {
      print('Error washing all items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).laundryScreenErrorWashingAll)),
      );
    }
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).laundryTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.thistle,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadDirtyClothes();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_dirtyClothes.length} ${AppLocalizations.of(context).laundryScreenDirtyClothesCount}',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      if (_dirtyClothes.isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: _selectedItems.isEmpty ? null : _washAllSelected,
                          icon: const Icon(Icons.local_laundry_service, size: 18),
                          label: Text(
                            AppLocalizations.of(context).laundryScreenWashSelected,
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.thistle,
                            side: const BorderSide(color: AppColors.thistle),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _washAll,
                          icon: const Icon(Icons.local_laundry_service, size: 18),
                          label: Text(
                            AppLocalizations.of(context).laundryScreenWashAll,
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.thistle,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _dirtyClothes.isEmpty
                      ? _buildEmptyState()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _dirtyClothes.length,
                              itemBuilder: (context, index) {
                                final item = _dirtyClothes[index];
                                return _buildAnimatedClothingCard(item, index);
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.5 + (0.5 * value),
                    child: Icon(
                      Icons.local_laundry_service,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).noDirtyClothes,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).allClothesClean,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedClothingCard(Map<String, dynamic> item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildClothingCard(item),
          ),
        );
      },
    );
  }

  Widget _buildClothingCard(Map<String, dynamic> item) {
    final itemId = item['id'] as String;
    final isSelected = _selectedItems.contains(itemId);
    final imageUrl = item['image_url'] as String?;
    final name = item['name'] as String? ?? 'Sin nombre';
    final type = item['type'] as String? ?? 'Sin tipo';
    final subtype = item['subtype'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.thistle : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleSelection(itemId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleSelection(itemId),
                activeColor: AppColors.thistle,
              ),
              const SizedBox(width: 12),

              // Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getClothingIcon(type),
                              color: AppColors.thistle,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
                        _getClothingIcon(type),
                        color: AppColors.thistle,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$type${subtype.isNotEmpty ? ' - $subtype' : ''}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Wash button
              IconButton(
                onPressed: () => _washItem(itemId),
                icon: const Icon(
                  Icons.local_laundry_service,
                  color: AppColors.thistle,
                ),
                tooltip: AppLocalizations.of(context).laundryScreenWashIndividualTooltip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getClothingIcon(String? type) {
    switch (type) {
      case 'Superior':
        return Icons.checkroom;
      case 'Inferior':
        return Icons.accessibility;
      case 'Calzado':
        return Icons.sports_soccer;
      case 'Accesorios':
        return Icons.style;
      default:
        return Icons.checkroom;
    }
  }
} 