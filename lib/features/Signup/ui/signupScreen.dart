import 'package:examaceapp/constants.dart';
import 'package:examaceapp/features/Signup/widgets/appBranding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _branches = ['CE', 'IT', 'AIDS', 'AIML', 'CSEIOT'];
  final List<String> _semesters = ['III', 'IV', 'V', 'VI', 'VII', 'VIII'];

  String? _selectedBranch;
  String? _selectedSemester;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Globals.initialize(context);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranch == null || _selectedSemester == null) {
        setState(() {
          _errorMessage = 'Please select both Branch and Semester';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final supabase = Supabase.instance.client;
        final response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null) {
          // Store additional user data in Supabase profiles table
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'email': _emailController.text.trim(),
            'branch': _selectedBranch,
            'semester': _selectedSemester,
            'created_at': DateTime.now().toIso8601String(),
          });

          // Store user ID in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', response.user!.id);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Globals.customYellow,
              ),
            );
            Navigator.pushReplacementNamed(context, 'customNav');
          }
        }
      } on AuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Globals.screenWidth * 0.08,
              vertical: Globals.screenHeight * 0.03,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Globals.screenHeight * 0.03),
                  // Logo and App name
                  AppBranding(),

                  SizedBox(height: Globals.screenHeight * 0.04),

                  // Email field
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                      color: Globals.customBlack,
                    ),
                  ),
                  SizedBox(height: Globals.screenHeight * 0.01),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        color: Globals.customGreyDark,
                        fontSize: Globals.screenHeight * 0.016,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Globals.customGreyDark,
                        size: Globals.screenHeight * 0.025,
                      ),
                      filled: true,
                      fillColor: Globals.customGreyLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: Globals.screenHeight * 0.02,
                        horizontal: Globals.screenWidth * 0.04,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: Globals.screenHeight * 0.025),

                  // Password field
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                      color: Globals.customBlack,
                    ),
                  ),
                  SizedBox(height: Globals.screenHeight * 0.01),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Create a password',
                      hintStyle: TextStyle(
                        color: Globals.customGreyDark,
                        fontSize: Globals.screenHeight * 0.016,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Globals.customGreyDark,
                        size: Globals.screenHeight * 0.025,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Globals.customGreyDark,
                          size: Globals.screenHeight * 0.025,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Globals.customGreyLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: Globals.screenHeight * 0.02,
                        horizontal: Globals.screenWidth * 0.04,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: Globals.screenHeight * 0.025),

                  // Branch dropdown
                  Text(
                    'Branch',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                      color: Globals.customBlack,
                    ),
                  ),
                  SizedBox(height: Globals.screenHeight * 0.01),
                  Container(
                    decoration: BoxDecoration(
                      color: Globals.customGreyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Globals.screenWidth * 0.04,
                      vertical: Globals.screenHeight * 0.005,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedBranch,
                        hint: Text(
                          'Select your branch',
                          style: TextStyle(
                            color: Globals.customGreyDark,
                            fontSize: Globals.screenHeight * 0.016,
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Globals.customGreyDark,
                        ),
                        dropdownColor: Globals.customGreyLight,
                        borderRadius: BorderRadius.circular(12),
                        items: _branches.map((String branch) {
                          return DropdownMenuItem<String>(
                            value: branch,
                            child: Text(
                              branch,
                              style: TextStyle(
                                color: Globals.customBlack,
                                fontSize: Globals.screenHeight * 0.016,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBranch = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: Globals.screenHeight * 0.025),

                  // Semester dropdown
                  Text(
                    'Semester',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                      color: Globals.customBlack,
                    ),
                  ),
                  SizedBox(height: Globals.screenHeight * 0.01),
                  Container(
                    decoration: BoxDecoration(
                      color: Globals.customGreyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Globals.screenWidth * 0.04,
                      vertical: Globals.screenHeight * 0.005,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedSemester,
                        hint: Text(
                          'Select your semester',
                          style: TextStyle(
                            color: Globals.customGreyDark,
                            fontSize: Globals.screenHeight * 0.016,
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Globals.customGreyDark,
                        ),
                        dropdownColor: Globals.customGreyLight,
                        borderRadius: BorderRadius.circular(12),
                        items: _semesters.map((String semester) {
                          return DropdownMenuItem<String>(
                            value: semester,
                            child: Text(
                              semester,
                              style: TextStyle(
                                color: Globals.customBlack,
                                fontSize: Globals.screenHeight * 0.016,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSemester = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    SizedBox(height: Globals.screenHeight * 0.02),
                    Container(
                      padding: EdgeInsets.all(Globals.screenHeight * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: Globals.screenHeight * 0.02,
                          ),
                          SizedBox(width: Globals.screenWidth * 0.02),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: Globals.screenHeight * 0.014,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: Globals.screenHeight * 0.04),

                  // Sign up button
                  SizedBox(
                    width: double.infinity,
                    height: Globals.screenHeight * 0.06,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Globals.customYellow,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: Globals.screenHeight * 0.015),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: Globals.screenHeight * 0.02,
                              width: Globals.screenHeight * 0.02,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: Globals.screenHeight * 0.018,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: Globals.screenHeight * 0.025),

                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Globals.customGreyDark,
                            fontSize: Globals.screenHeight * 0.016,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, 'login');
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: Globals.customYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: Globals.screenHeight * 0.016,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
