import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/ingredient_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sync_status_widget.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({Key? key}) : super(key: key);

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _currentBottomNavIndex = 0;

  // Mock data for pharmaceutical ingredients
  final List<Map<String, dynamic>> _allIngredients = [
    {
      "id": "ing_001",
      "name": "Acetaminophen",
      "quantity": 2500,
      "unitTypes": ["tablets", "bottles", "cases"],
      "qrCodeId": "QR_ACE_001",
      "category": "Analgesic",
      "expiryDate": "2025-12-15",
      "batchNumber": "ACE2024001"
    },
    {
      "id": "ing_002",
      "name": "Ibuprofen",
      "quantity": 45,
      "unitTypes": ["tablets", "bottles"],
      "qrCodeId": "QR_IBU_002",
      "category": "Anti-inflammatory",
      "expiryDate": "2025-08-20",
      "batchNumber": "IBU2024002"
    },
    {
      "id": "ing_003",
      "name": "Amoxicillin",
      "quantity": 0,
      "unitTypes": ["capsules", "bottles", "boxes"],
      "qrCodeId": "QR_AMO_003",
      "category": "Antibiotic",
      "expiryDate": "2025-06-30",
      "batchNumber": "AMO2024003"
    },
    {
      "id": "ing_004",
      "name": "Metformin",
      "quantity": 1200,
      "unitTypes": ["tablets", "bottles"],
      "qrCodeId": "QR_MET_004",
      "category": "Antidiabetic",
      "expiryDate": "2026-01-10",
      "batchNumber": "MET2024004"
    },
    {
      "id": "ing_005",
      "name": "Lisinopril",
      "quantity": 35,
      "unitTypes": ["tablets", "bottles"],
      "qrCodeId": "QR_LIS_005",
      "category": "ACE Inhibitor",
      "expiryDate": "2025-09-25",
      "batchNumber": "LIS2024005"
    },
    {
      "id": "ing_006",
      "name": "Atorvastatin",
      "quantity": 800,
      "unitTypes": ["tablets", "bottles", "cases"],
      "qrCodeId": "QR_ATO_006",
      "category": "Statin",
      "expiryDate": "2025-11-18",
      "batchNumber": "ATO2024006"
    },
    {
      "id": "ing_007",
      "name": "Omeprazole",
      "quantity": 25,
      "unitTypes": ["capsules", "bottles"],
      "qrCodeId": "QR_OME_007",
      "category": "Proton Pump Inhibitor",
      "expiryDate": "2025-07-12",
      "batchNumber": "OME2024007"
    },
    {
      "id": "ing_008",
      "name": "Levothyroxine",
      "quantity": 0,
      "unitTypes": ["tablets", "bottles"],
      "qrCodeId": "QR_LEV_008",
      "category": "Thyroid Hormone",
      "expiryDate": "2025-10-05",
      "batchNumber": "LEV2024008"
    }
  ];

  List<Map<String, dynamic>> _filteredIngredients = [];
  late AnimationController _refreshAnimationController;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _initializeData();
    _checkConnectivity();
    _lastSyncTime = DateTime.now();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _filteredIngredients = List.from(_allIngredients);
    _applyFilters();
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });

      if (_isOnline) {
        _syncData();
      }
    });
  }

  void _syncData() async {
    if (!_isOnline) return;

    setState(() {
      _isSyncing = true;
    });

    // Simulate Firebase sync

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSyncing = false;
      _lastSyncTime = DateTime.now();
    });

    Fluttertoast.showToast(
      msg: "Data synchronized successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      textColor: AppTheme.lightTheme.colorScheme.onTertiary,
    );
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allIngredients);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ingredient) {
        final name = (ingredient['name'] as String).toLowerCase();
        final category = (ingredient['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
    }

    // Apply stock filter
    switch (_selectedFilter) {
      case 'low_stock':
        filtered = filtered.where((ingredient) {
          final quantity = ingredient['quantity'] as int;
          return quantity > 0 && quantity < 50;
        }).toList();
        break;
      case 'out_of_stock':
        filtered = filtered.where((ingredient) {
          final quantity = ingredient['quantity'] as int;
          return quantity == 0;
        }).toList();
        break;
      case 'all':
      default:
        // No additional filtering needed
        break;
    }

    setState(() {
      _filteredIngredients = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  void _onRefresh() async {
    _refreshAnimationController.forward();
    _syncData();
    _refreshAnimationController.reset();
  }

  void _onIngredientTap(Map<String, dynamic> ingredient) {
    // Show ingredient details or navigate to detail screen
    Fluttertoast.showToast(
      msg: "Viewing ${ingredient['name']} details",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onGenerateQR(Map<String, dynamic> ingredient) {
    Navigator.pushNamed(context, '/qr-code-generation', arguments: ingredient);
  }

  void _onEditStock(Map<String, dynamic> ingredient) {
    // Navigate to stock editing screen or show dialog
    Fluttertoast.showToast(
      msg: "Editing stock for ${ingredient['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onViewHistory(Map<String, dynamic> ingredient) {
    // Navigate to history screen
    Fluttertoast.showToast(
      msg: "Viewing history for ${ingredient['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        // Scan
        Navigator.pushNamed(context, '/qr-code-scanner');
        break;
      case 2:
        // Profile
        Fluttertoast.showToast(
          msg: "Profile screen coming soon",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        break;
    }
  }

  void _onFABPressed() {
    Navigator.pushNamed(context, '/qr-code-scanner');
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PharmaStock Manager',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Inventory Dashboard',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _onRefresh,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RotationTransition(
                        turns: _refreshAnimationController,
                        child: CustomIconWidget(
                          iconName: 'refresh',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SearchBarWidget(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onFilterTap: () {
                // Show filter bottom sheet
                Fluttertoast.showToast(
                  msg: "Advanced filters coming soon",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
            FilterChipsWidget(
              selectedFilter: _selectedFilter,
              onFilterChanged: _onFilterChanged,
            ),
            SyncStatusWidget(
              isOnline: _isOnline,
              isSyncing: _isSyncing,
              lastSyncTime: _lastSyncTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    if (_filteredIngredients.isEmpty) {
      String emptyTitle = 'No ingredients found';
      String emptySubtitle = 'Try adjusting your search or filters';
      String emptyIcon = 'search_off';

      if (_searchQuery.isEmpty) {
        switch (_selectedFilter) {
          case 'low_stock':
            emptyTitle = 'No low stock items';
            emptySubtitle = 'All ingredients are well stocked';
            emptyIcon = 'inventory_2';
            break;
          case 'out_of_stock':
            emptyTitle = 'No out of stock items';
            emptySubtitle = 'All ingredients are available';
            emptyIcon = 'check_circle';
            break;
          default:
            emptyTitle = 'No ingredients added';
            emptySubtitle =
                'Start by adding your first pharmaceutical ingredient to the inventory';
            emptyIcon = 'medication';
            break;
        }
      }

      return EmptyStateWidget(
        title: emptyTitle,
        subtitle: emptySubtitle,
        iconName: emptyIcon,
        onActionTap: _selectedFilter == 'all' && _searchQuery.isEmpty
            ? () {
                Fluttertoast.showToast(
                  msg: "Add ingredient feature coming soon",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            : null,
        actionText: _selectedFilter == 'all' && _searchQuery.isEmpty
            ? 'Add Ingredient'
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredIngredients.length,
        itemBuilder: (context, index) {
          final ingredient = _filteredIngredients[index];
          return IngredientCardWidget(
            ingredient: ingredient,
            onTap: () => _onIngredientTap(ingredient),
            onGenerateQR: () => _onGenerateQR(ingredient),
            onEditStock: () => _onEditStock(ingredient),
            onViewHistory: () => _onViewHistory(ingredient),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildIngredientsList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFABPressed,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'qr_code_scanner',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }
}