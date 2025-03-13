import 'package:examaceapp/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _subjects = [];
  String? _userName;
  String? _userBranch;
  String? _userSemester;

  @override
  void initState() {
    super.initState();
    _fetchUserSubjects();
  }

  Future<void> _fetchUserSubjects() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final supabase = Supabase.instance.client;

      // Fetch user profile data
      final profileData =
          await supabase.from('profiles').select().eq('id', userId).single();

      setState(() {
        _userBranch = profileData['branch'];
        _userSemester = profileData['semester'];
        _userName =
            profileData['email']?.split('@').first; // Extract name from email
      });

      // Convert Roman numeral semester to integer
      int? semesterInt;
      switch (_userSemester) {
        case 'III':
          semesterInt = 3;
          break;
        case 'IV':
          semesterInt = 4;
          break;
        case 'V':
          semesterInt = 5;
          break;
        case 'VI':
          semesterInt = 6;
          break;
        case 'VII':
          semesterInt = 7;
          break;
        case 'VIII':
          semesterInt = 8;
          break;
      }

      // Fetch subjects for the user's branch and semester
      final subjectsData = await supabase
          .from('subjects')
          .select()
          .eq('branch', _userBranch!)
          .eq('semester', semesterInt!)
          .order('subject_name');

      setState(() {
        _subjects = List<Map<String, dynamic>>.from(subjectsData);
      });
    } catch (e) {
      setState(
          () => _errorMessage = 'Failed to load subjects: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToChatScreen(Map<String, dynamic> subject) {
    Navigator.pushNamed(
      context,
      'chat',
      arguments: {
        'subjectId': subject['id'],
        'subjectName': subject['subject_name'],
        'chatUrl': subject['chat_url'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Globals.screenWidth * 0.05,
            vertical: Globals.screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and user info section
              Text(
                'Hello! 👋',
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Globals.customBlack,
                ),
              ),
              SizedBox(height: Globals.screenHeight * 0.005),
              Row(
                children: [
                  Text(
                    _userBranch != null ? '$_userBranch · ' : '',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.018,
                      color: Globals.customGreyDark,
                    ),
                  ),
                  Text(
                    _userSemester != null ? 'Semester $_userSemester' : '',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.018,
                      color: Globals.customGreyDark,
                    ),
                  ),
                ],
              ),

              SizedBox(height: Globals.screenHeight * 0.03),

              Text(
                'Your Subjects',
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.022,
                  fontWeight: FontWeight.w600,
                  color: Globals.customBlack,
                ),
              ),

              SizedBox(height: Globals.screenHeight * 0.02),

              // Error message if any
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(Globals.screenHeight * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: Globals.screenHeight * 0.025,
                      ),
                      SizedBox(width: Globals.screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: Globals.screenHeight * 0.016,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Loading indicator or subjects list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Globals.customYellow,
                        ),
                      )
                    : _subjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: Globals.screenHeight * 0.08,
                                  color: Globals.customGreyDark,
                                ),
                                SizedBox(height: Globals.screenHeight * 0.02),
                                Text(
                                  'No subjects found for your semester',
                                  style: TextStyle(
                                    fontSize: Globals.screenHeight * 0.018,
                                    color: Globals.customGreyDark,
                                  ),
                                ),
                                SizedBox(height: Globals.screenHeight * 0.01),
                                ElevatedButton(
                                  onPressed: _fetchUserSubjects,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Globals.customYellow,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Refresh'),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.only(
                                top: Globals.screenHeight * 0.01),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: Globals.screenWidth * 0.04,
                              mainAxisSpacing: Globals.screenHeight * 0.02,
                            ),
                            itemCount: _subjects.length,
                            itemBuilder: (context, index) {
                              final subjectIcons = [
                                Icons.calculate_outlined,
                                Icons.computer_outlined,
                                Icons.science_outlined,
                                Icons.psychology_outlined,
                                Icons.biotech_outlined,
                              ];
                              final iconIndex = index % subjectIcons.length;

                              return _buildSubjectCard(
                                _subjects[index],
                                subjectIcons[iconIndex],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateToChatScreen(subject),
      child: Container(
        decoration: BoxDecoration(
          color: Globals.customWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Globals.screenHeight * 0.015),
              decoration: BoxDecoration(
                color: Globals.customYellow.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Globals.screenHeight * 0.035,
                color: Globals.customYellow,
              ),
            ),
            SizedBox(height: Globals.screenHeight * 0.015),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Globals.screenWidth * 0.02),
              child: Text(
                subject['subject_name'],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.016,
                  fontWeight: FontWeight.w600,
                  color: Globals.customBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
