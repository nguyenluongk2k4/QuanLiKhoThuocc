import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../core/toarst_services.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({Key? key}) : super(key: key);

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isConnected = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkConnectivity();
    _listenToConnectivity();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _authenticateUser(String email, String password, bool rememberMeCheckbox) async {
    final authen = Authen();

    if (email.isEmpty || password.isEmpty) {
      ToastService.show('Vui lòng nhập đầy đủ thông tin đăng nhập.');
      return;
    }
    if (!email.contains('@')) {
      ToastService.show('Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }
    if (password.length < 6) {
      ToastService.show('Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await authen.signIn(email, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (success) {
      ToastService.show('Đăng nhập thành công! Chào mừng đến với PharmaStock Manager.');
      Navigator.pushReplacementNamed(context, '/inventory-dashboard');
    } else {
      ToastService.show('Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.');
    }
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _handleGoogleSignIn() async {
    if (!_isConnected) {
      ToastService.show('Please check your internet connection and try again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate authentication process with realistic delay
    await Future.delayed(const Duration(seconds: 2)); // Changed to 2 seconds for a more realistic delay

      // Provide haptic feedback on success
      HapticFeedback.lightImpact();

    ToastService.show('Sign in successful! Welcome to PharmaStock Manager.');

      // Navigate to inventory dashboard with fade transition
    await Future.delayed(const Duration(seconds: 1)); // Changed to 1 second for a smoother transition

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/inventory-dashboard');
      }
    } catch (e) {
      _handleSignInError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignInError(dynamic error) {
    String errorMessage = 'Authentication failed. Please try again.';

    // Handle specific error types
    if (error.toString().contains('network')) {
      errorMessage = 'Network error. Please check your connection.';
    } else if (error.toString().contains('cancelled')) {
      errorMessage = 'Sign in was cancelled.';
    } else if (error.toString().contains('unavailable')) {
      errorMessage = 'Google services are currently unavailable.';
    }

    ToastService.show(errorMessage);
  }

  void _handleBackButton() {
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              (8.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // _buildBackButton(),
            // SizedBox(height: 2.h),

            _buildLogo(),
            SizedBox(height: 4.h),
            _buildBranding(),
            SizedBox(height: 6.h),
            _buildDescription(),
            SizedBox(height: 8.h),
            _buildSignInButton(),
            // SizedBox(height: 4.h),
            // _buildTrustIndicators(),
            SizedBox(height: 6.h),
            _buildConnectivityStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: _handleBackButton,
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
        padding: EdgeInsets.all(2.w),
        constraints: BoxConstraints(
          minWidth: 12.w,
          minHeight: 6.h,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 32.w,
      height: 16.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'medical_services',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 48,
          ),
          SizedBox(height: 1.h),
          Text(
            'PS',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Text(
          'PHẦN MỀM QUẢN LÍ KHO THUỐC',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),

      ],
    );
  }

  Widget _buildDescription() {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool rememberMe = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Địa chỉ email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (val) {
                      setState(() => rememberMe = val ?? false);
                    },
                  ),
                  Text("Ghi nhớ"),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      _authenticateUser(
                        emailController.text.trim(),
                        passwordController.text,
                        rememberMe,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    child: Text("Bắt đầu"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Chưa có tài khoản ?"),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register-screen');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    child: Text("Đăng kí ngay"),

                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 7.h,
      constraints: BoxConstraints(
        maxWidth: 85.w,
        minHeight: 6.h,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
          elevation: 2,
          shadowColor: AppTheme.lightTheme.colorScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
            side: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImageWidget(
                    imageUrl:
                        'https://developers.google.com/identity/images/g-logo.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Sign in with Google',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildConnectivityStatus() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _isConnected
            ? AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: _isConnected
              ? AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _isConnected ? 'wifi' : 'wifi_off',
            color: _isConnected
                ? AppTheme.lightTheme.colorScheme.tertiary
                : AppTheme.lightTheme.colorScheme.error,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            _isConnected
                ? 'Connected - Ready for authentication'
                : 'No internet connection - Please connect to continue',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: _isConnected
                  ? AppTheme.lightTheme.colorScheme.tertiary
                  : AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
