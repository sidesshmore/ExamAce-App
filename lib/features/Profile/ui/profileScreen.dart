import 'package:examaceapp/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String? _selectedBranch;
  String? _selectedSemester;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  final List<String> _branches = ['CE', 'IT', 'AIDS', 'AIML', 'CSEIOT'];
  final List<String> _semesters = ['III', 'IV', 'V', 'VI', 'VII', 'VIII'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        // Handle the case where userId is not found
        throw Exception('User ID not found');
      }

      // Fetch user data from profiles table
      final response =
          await supabase.from('profiles').select().eq('id', userId).single();

      setState(() {
        _userData = response;
        _emailController.text = _userData?['email'] ?? '';
        _selectedBranch = _userData?['branch'];
        _selectedSemester = _userData?['semester'];
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load profile: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      await supabase.from('profiles').update({
        'branch': _selectedBranch,
        'semester': _selectedSemester,
      }).eq('id', userId!);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Globals.customYellow,
          ),
        );
      }
    } catch (e) {
      setState(
          () => _errorMessage = 'Failed to update profile: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to logout: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Globals.customBlack,
            fontWeight: FontWeight.bold,
            fontSize: Globals.screenHeight * 0.032,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.check, color: Globals.customYellow),
              onPressed: _isLoading ? null : _updateProfile,
            )
          else
            IconButton(
              icon: Icon(Icons.edit, color: Globals.customYellow),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: Icon(Icons.logout, color: Globals.customYellow),
            onPressed: _isLoading ? null : _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading && _userData == null
            ? Center(
                child: CircularProgressIndicator(color: Globals.customYellow),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Globals.screenWidth * 0.08,
                  vertical: Globals.screenHeight * 0.03,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Globals.screenHeight * 0.025),

                      // Email field (readonly)
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
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Your email',
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
                            icon: Icon(Icons.arrow_drop_down,
                                color: Globals.customGreyDark),
                            dropdownColor: Globals.customGreyLight,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: _isEditing
                                ? (String? newValue) {
                                    setState(() => _selectedBranch = newValue);
                                  }
                                : null,
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
                            icon: Icon(Icons.arrow_drop_down,
                                color: Globals.customGreyDark),
                            dropdownColor: Globals.customGreyLight,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: _isEditing
                                ? (String? newValue) {
                                    setState(
                                        () => _selectedSemester = newValue);
                                  }
                                : null,
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

                      if (_isEditing) ...[
                        SizedBox(height: Globals.screenHeight * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: Globals.screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Globals.customYellow,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: Globals.screenHeight * 0.015,
                              ),
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
                                    'Update Profile',
                                    style: TextStyle(
                                      fontSize: Globals.screenHeight * 0.018,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
