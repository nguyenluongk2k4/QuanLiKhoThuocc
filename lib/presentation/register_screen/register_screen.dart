import 'package:flutter/material.dart';
import 'package:pharmastock_manager/services/user/user_responsitory.dart';
import 'package:sizer/sizer.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../core/app_export.dart';

import '../../core/toarst_services.dart';
import '../../services/auth/auth_respository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String _fullPhoneNumber = ''; // Lưu số điện thoại ở định dạng E.164
  bool _isLoading = false;

  // password criteria
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecial = false;

  bool get _passwordValid => _hasMinLength && _hasUppercase && _hasLowercase && _hasDigit;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final s = _passwordController.text;
    setState(() {
      _hasMinLength = s.length >= 6;
      _hasUppercase = s.contains(RegExp(r'[A-Z]'));
      _hasLowercase = s.contains(RegExp(r'[a-z]'));
      _hasDigit = s.contains(RegExp(r'\d'));
      _hasSpecial = s.contains(RegExp(r'[!@#\$%\^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final phone = _fullPhoneNumber.trim(); // Sử dụng số điện thoại E.164
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ToastService.show("Vui lòng điền đủ thông tin");
      return;
    }

    // Kiểm tra số điện thoại Việt Nam
    if (phone.startsWith('+84') && phone.length != 13) { // +84 + 10 số = 13 ký tự
      ToastService.show("Số điện thoại Việt Nam phải có đúng 10 số");
      return;
    }

    if (!_passwordValid) {
      ToastService.show('Mật khẩu chưa đạt yêu cầu bảo mật.');
      return;
    }

    if (password != confirm) {
      ToastService.show('Mật khẩu xác nhận không khớp.');
      return;
    }

    setState(() => _isLoading = true);

    final authen = AuthRepository();
    final userRe = UserResponsitory();
    Users user = new Users(email: email, phone: phone, fullName: name, createdAt: DateTime.now(), updatedAt: DateTime.now(), emailConfirmed: true);
    final success = await authen.signUp(user, password);
    final updateSuccess = await userRe.updateUser(user);
    setState(() => _isLoading = false);

    if (success && updateSuccess) {
      ToastService.show('Đăng ký thành công. Kiểm tra email để xác nhận.');
      Navigator.pushReplacementNamed(context, AppRoutes.googleSignIn);
    }
    else if(!updateSuccess){
      ToastService.show('Thêm thông tin thất bại. Vui lòng thử lại.');
      Navigator.pushReplacementNamed(context, AppRoutes.googleSignIn);
    }
    else {
      ToastService.show('Đăng ký thất bại. Vui lòng thử lại.');
    }
  }

  Widget _criteriaRow(bool ok, String text) {
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
            color: ok ? Colors.green : Colors.grey, size: 18),
        SizedBox(width: 2.w),
        Text(text, style: TextStyle(color: ok ? Colors.green : Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pushReplacementNamed(context, '/google-sign-in-screen'),
          ),

          title: const Text('Đăng ký tài khoản')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ tên'),
            ),
            SizedBox(height: 2.h),
            IntlPhoneField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
                hintText: 'Nhập 10 số (ví dụ: 0987654321)',
              ),
              initialCountryCode: 'VN', // Mặc định Việt Nam
              validator: (phone) {
                if (phone?.countryCode == '+84') {
                  // Kiểm tra số điện thoại Việt Nam: đúng 10 số
                  if (phone!.number.length != 10) {
                    return 'Số điện thoại Việt Nam phải có đúng 10 số';
                  }
                  // Kiểm tra đầu số hợp lệ (03, 05, 07, 08, 09)
                  final firstTwoDigits = phone.number.substring(0, 2);
                  if (!['03', '05', '07', '08', '09'].contains(firstTwoDigits)) {
                    return 'Đầu số không hợp lệ (phải bắt đầu bằng 03, 05, 07, 08, 09)';
                  }
                }
                return null;
              },
              onChanged: (phone) {
                _fullPhoneNumber = phone.completeNumber; // Lưu số E.164
              },
              onCountryChanged: (country) {
                // Reset số điện thoại khi đổi quốc gia
                _phoneController.clear();
                _fullPhoneNumber = '';
                print('Đã chọn quốc gia: ${country.name}');
              },
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Địa chỉ Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Xác nhận Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 2.h),

            // Password criteria
            _criteriaRow(_hasMinLength, 'Ít nhất 6 ký tự'),
            SizedBox(height: 1.h),
            _criteriaRow(_hasUppercase, 'Có chữ hoa (A-Z)'),
            SizedBox(height: 1.h),
            _criteriaRow(_hasLowercase, 'Có chữ thường (a-z)'),
            SizedBox(height: 1.h),
            _criteriaRow(_hasDigit, 'Có số (0-9)'),
            SizedBox(height: 1.h),
            _criteriaRow(_hasSpecial, 'Có ký tự đặc biệt (!@#...)'),

            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || !_passwordValid) ? null : _register,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Đăng ký'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
