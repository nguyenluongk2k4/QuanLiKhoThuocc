import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DispensingDialog extends StatefulWidget {
  final Map<String, dynamic>? ingredientData;

  const DispensingDialog({
    Key? key,
    this.ingredientData,
  }) : super(key: key);

  @override
  State<DispensingDialog> createState() => _DispensingDialogState();
}

class _DispensingDialogState extends State<DispensingDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  String? _selectedUnit;
  double _convertedQuantity = 0.0;
  bool _isLoading = false;
  bool _isValidInput = false;

  // Mock ingredient data for demonstration
  final Map<String, dynamic> _mockIngredientData = {
    "id": "ing_001",
    "name": "Paracetamol",
    "quantity": 5000, // in smallest unit (tablets)
    "unitTypes": [
      {"name": "Tablet", "conversionFactor": 1},
      {"name": "Blister", "conversionFactor": 10},
      {"name": "Box", "conversionFactor": 100},
    ],
    "qrCodeId": "QR_PARA_001",
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _amountController.addListener(_validateInput);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _initializeData() {
    final ingredientData = widget.ingredientData ?? _mockIngredientData;
    final unitTypes = (ingredientData["unitTypes"] as List);

    if (unitTypes.isNotEmpty) {
      _selectedUnit =
          (unitTypes.first as Map<String, dynamic>)["name"] as String;
    }
  }

  void _validateInput() {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);

    setState(() {
      if (amount != null && amount > 0 && _selectedUnit != null) {
        _convertedQuantity = _calculateConvertedQuantity(amount);
        _isValidInput = _convertedQuantity <= _getCurrentStock();
      } else {
        _isValidInput = false;
        _convertedQuantity = 0.0;
      }
    });
  }

  double _calculateConvertedQuantity(double amount) {
    final ingredientData = widget.ingredientData ?? _mockIngredientData;
    final unitTypes = (ingredientData["unitTypes"] as List);

    final selectedUnitData = unitTypes.firstWhere(
      (unit) => (unit as Map<String, dynamic>)["name"] == _selectedUnit,
      orElse: () => unitTypes.first,
    ) as Map<String, dynamic>;

    final conversionFactor =
        (selectedUnitData["conversionFactor"] as num).toDouble();
    return amount * conversionFactor;
  }

  double _getCurrentStock() {
    final ingredientData = widget.ingredientData ?? _mockIngredientData;
    return (ingredientData["quantity"] as num).toDouble();
  }

  String _getIngredientName() {
    final ingredientData = widget.ingredientData ?? _mockIngredientData;
    return ingredientData["name"] as String;
  }

  List<Map<String, dynamic>> _getUnitTypes() {
    final ingredientData = widget.ingredientData ?? _mockIngredientData;
    return (ingredientData["unitTypes"] as List)
        .map((unit) => unit as Map<String, dynamic>)
        .toList();
  }

  void _incrementAmount() {
    final currentAmount = double.tryParse(_amountController.text) ?? 0.0;
    _amountController.text = (currentAmount + 1).toString();
  }

  void _decrementAmount() {
    final currentAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (currentAmount > 0) {
      _amountController.text = (currentAmount - 1).toString();
    }
  }

  Future<void> _dispenseIngredient() async {
    if (!_isValidInput) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate Firestore update delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock successful dispensing
      final newStock = _getCurrentStock() - _convertedQuantity;

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Show success toast
      Fluttertoast.showToast(
        msg: "Dispensed successfully! New stock: ${newStock.toInt()} tablets",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        textColor: AppTheme.lightTheme.colorScheme.surface,
        fontSize: 14.sp,
      );

      // Close dialog after success
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Handle error
      Fluttertoast.showToast(
        msg: "Dispensing failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.surface,
        fontSize: 14.sp,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _closeDialog() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeDialog();
        return false;
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Scaffold(
            backgroundColor:
                Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
            body: GestureDetector(
              onTap: _closeDialog,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Backdrop blur effect
                    Positioned.fill(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    // Dialog content
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Transform.translate(
                        offset: Offset(
                            0,
                            MediaQuery.of(context).size.height *
                                _slideAnimation.value),
                        child: GestureDetector(
                          onTap: () {}, // Prevent closing when tapping dialog
                          child: _buildDialogContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 85.h,
        minHeight: 50.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStockInfo(),
                  SizedBox(height: 3.h),
                  _buildUnitSelector(),
                  SizedBox(height: 3.h),
                  _buildAmountInput(),
                  SizedBox(height: 2.h),
                  _buildConversionInfo(),
                  SizedBox(height: 2.h),
                  _buildStockValidation(),
                  SizedBox(height: 4.h),
                  _buildActionButtons(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          // Title
          Row(
            children: [
              Expanded(
                child: Text(
                  "Dispense Ingredient",
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _closeDialog,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    size: 6.w,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Ingredient name
          Row(
            children: [
              Expanded(
                child: Text(
                  _getIngredientName(),
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo() {
    final currentStock = _getCurrentStock();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'inventory',
            size: 6.w,
            color: AppTheme.lightTheme.colorScheme.tertiary,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Stock",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  "${currentStock.toInt()} tablets",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Unit Type",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnit,
              isExpanded: true,
              icon: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              items: _getUnitTypes().map((unit) {
                final unitName = unit["name"] as String;
                final conversionFactor = unit["conversionFactor"] as num;
                return DropdownMenuItem<String>(
                  value: unitName,
                  child: Text("$unitName (${conversionFactor}x)"),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUnit = newValue;
                  _validateInput();
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Amount",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            // Decrement button
            GestureDetector(
              onTap: _decrementAmount,
              child: Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'remove',
                    size: 5.w,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Amount input field
            Expanded(
              child: Container(
                height: 6.h,
                child: TextFormField(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Increment button
            GestureDetector(
              onTap: _incrementAmount,
              child: Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'add',
                    size: 5.w,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConversionInfo() {
    if (_convertedQuantity <= 0) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'calculate',
            size: 5.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              "Equivalent: ${_convertedQuantity.toInt()} tablets",
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockValidation() {
    if (_convertedQuantity <= 0) return SizedBox.shrink();

    final currentStock = _getCurrentStock();
    final isInsufficientStock = _convertedQuantity > currentStock;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isInsufficientStock
            ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInsufficientStock
              ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isInsufficientStock ? 'warning' : 'check_circle',
            size: 5.w,
            color: isInsufficientStock
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.tertiary,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              isInsufficientStock
                  ? "Insufficient stock! Available: ${currentStock.toInt()} tablets"
                  : "Stock available. Remaining: ${(currentStock - _convertedQuantity).toInt()} tablets",
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isInsufficientStock
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : _closeDialog,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Text(
              "Cancel",
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        // Dispense button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed:
                (_isValidInput && !_isLoading) ? _dispenseIngredient : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValidInput
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              foregroundColor: AppTheme.lightTheme.colorScheme.surface,
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _isValidInput ? 2 : 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.surface,
                      ),
                    ),
                  )
                : Text(
                    "Dispense",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.surface,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
