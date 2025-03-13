import 'package:examaceapp/features/BottomNav/widgets/searchBox.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:examaceapp/constants.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
// Import the SearchBox widget

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bookmarks = [];
  List<Map<String, dynamic>> _filteredBookmarks = [];
  bool _isLoading = true;
  Set<int> _expandedItems = {};

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _searchFilters = ['All', 'Subject', 'Question', 'Answer'];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBookmarks();

    // Add listener to update search results when text changes
    _searchController.addListener(() {
      _updateSearchResults();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchResults() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _filteredBookmarks = List.from(_bookmarks);
      } else {
        _filteredBookmarks = _bookmarks.where((bookmark) {
          final subject = (bookmark['subject_name'] ?? '').toLowerCase();
          final question = (bookmark['question_text'] ?? '').toLowerCase();
          final answer = (bookmark['answer_text'] ?? '').toLowerCase();

          switch (_selectedFilter) {
            case 'Subject':
              return subject.contains(query);
            case 'Question':
              return question.contains(query);
            case 'Answer':
              return answer.contains(query);
            case 'All':
            default:
              return subject.contains(query) ||
                  question.contains(query) ||
                  answer.contains(query);
          }
        }).toList();
      }
    });
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        // Handle unauthenticated state
        setState(() {
          _isLoading = false;
          _bookmarks = [];
          _filteredBookmarks = [];
        });
        return;
      }

      final response = await supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _bookmarks = List<Map<String, dynamic>>.from(response);
        _filteredBookmarks = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load bookmarks');
    }
  }

  Future<void> _deleteBookmark(int id) async {
    try {
      await supabase.from('bookmarks').delete().eq('id', id);
      setState(() {
        _bookmarks.removeWhere((bookmark) => bookmark['id'] == id);
        _filteredBookmarks.removeWhere((bookmark) => bookmark['id'] == id);
      });
      _showSuccessSnackBar('Bookmark deleted');
    } catch (e) {
      _showErrorSnackBar('Failed to delete bookmark');
    }
  }

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedItems.contains(index)) {
        _expandedItems.remove(index);
      } else {
        _expandedItems.add(index);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Globals.customBlack,
      ),
    );
  }

  void _onFilterChanged(String? filter) {
    if (filter != null && filter != _selectedFilter) {
      setState(() {
        _selectedFilter = filter;
      });
      _updateSearchResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Globals.customWhite,
        elevation: 0,
        title: Text(
          'My Bookmarks',
          style: TextStyle(
            color: Globals.customBlack,
            fontSize: Globals.screenHeight * 0.024,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Globals.customBlack),
            onPressed: _loadBookmarks,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search section
            Padding(
              padding: EdgeInsets.all(Globals.screenWidth * 0.04),
              child: Column(
                children: [
                  SearchBox(
                    controller: _searchController,
                    onChanged: (value) {
                      _updateSearchResults();
                    },
                    hintText: 'Search bookmarks...',
                    onClear: () {
                      _updateSearchResults();
                    },
                  ),
                  SizedBox(height: Globals.screenHeight * 0.01),

                  // Filter chips
                  SizedBox(
                    height: Globals.screenHeight * 0.04,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _searchFilters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: EdgeInsets.only(
                              right: Globals.screenWidth * 0.02),
                          child: ChoiceChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected
                                    ? Globals.customWhite
                                    : Globals.customBlack,
                                fontSize: Globals.screenHeight * 0.014,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Globals.customYellow,
                            backgroundColor:
                                Globals.customGreyLight.withOpacity(0.2),
                            onSelected: (selected) {
                              if (selected) _onFilterChanged(filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Bookmarks list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Globals.customYellow,
                      ),
                    )
                  : _filteredBookmarks.isEmpty
                      ? _buildEmptyState()
                      : _buildBookmarksList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.bookmark_border,
            size: Globals.screenHeight * 0.08,
            color: Globals.customGreyLight,
          ),
          SizedBox(height: Globals.screenHeight * 0.02),
          Text(
            _searchQuery.isNotEmpty ? 'No results found' : 'No bookmarks yet',
            style: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.02,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Globals.screenHeight * 0.01),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term or filter'
                : 'Bookmarked questions will appear here',
            style: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.016,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: Globals.screenWidth * 0.04,
        vertical: Globals.screenHeight * 0.01,
      ),
      itemCount: _filteredBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = _filteredBookmarks[index];
        final isExpanded = _expandedItems.contains(index);

        // Highlight matched text if searching
        Widget buildHighlightedText(String text, String type) {
          TextStyle getTextStyle(String type) {
            switch (type) {
              case 'subject':
                return TextStyle(
                  color: Globals.customYellow,
                  fontSize: Globals.screenHeight * 0.014,
                  fontWeight: FontWeight.w500,
                );
              case 'question':
                return TextStyle(
                  fontSize: Globals.screenHeight * 0.018,
                  fontWeight: FontWeight.w500,
                  color: Globals.customBlack,
                );
              case 'answer':
                return TextStyle(
                  color: Globals.customBlack,
                  fontSize: Globals.screenHeight * 0.016,
                );
              default:
                return TextStyle(
                  color: Globals.customBlack,
                  fontSize: Globals.screenHeight * 0.016,
                );
            }
          }

          if (_searchQuery.isEmpty) {
            return Text(
              text,
              style: getTextStyle(type),
            );
          }

          final List<TextSpan> spans = [];
          final lowerText = text.toLowerCase();
          final lowerQuery = _searchQuery.toLowerCase();

          int lastMatchEnd = 0;

          // Only highlight if the current filter includes this type or is set to 'All'
          bool shouldHighlight = _selectedFilter == 'All' ||
              (_selectedFilter == 'Subject' && type == 'subject') ||
              (_selectedFilter == 'Question' && type == 'question') ||
              (_selectedFilter == 'Answer' && type == 'answer');

          if (shouldHighlight && lowerText.contains(lowerQuery)) {
            int startIndex = 0;
            while (true) {
              final int index = lowerText.indexOf(lowerQuery, startIndex);
              if (index == -1) break;

              if (index > lastMatchEnd) {
                spans.add(TextSpan(
                  text: text.substring(lastMatchEnd, index),
                  style: getTextStyle(type),
                ));
              }

              spans.add(TextSpan(
                text: text.substring(index, index + lowerQuery.length),
                style: getTextStyle(type).copyWith(
                  backgroundColor: Globals.customYellow.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                ),
              ));

              lastMatchEnd = index + lowerQuery.length;
              startIndex = lastMatchEnd;
            }

            if (lastMatchEnd < text.length) {
              spans.add(TextSpan(
                text: text.substring(lastMatchEnd),
                style: getTextStyle(type),
              ));
            }

            return RichText(text: TextSpan(children: spans));
          } else {
            return Text(
              text,
              style: getTextStyle(type),
            );
          }
        }

        return Card(
          margin: EdgeInsets.only(bottom: Globals.screenHeight * 0.02),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Globals.customGreyLight, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question section
              InkWell(
                onTap: () => _toggleExpanded(index),
                child: Padding(
                  padding: EdgeInsets.all(Globals.screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Globals.screenWidth * 0.02,
                              vertical: Globals.screenHeight * 0.004,
                            ),
                            decoration: BoxDecoration(
                              color: Globals.customYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: buildHighlightedText(
                              bookmark['subject_name'] ?? 'General',
                              'subject',
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(
                              Icons.delete_outline,
                              size: Globals.screenHeight * 0.022,
                              color: Globals.customGreyDark,
                            ),
                            onPressed: () => _deleteBookmark(bookmark['id']),
                          ),
                        ],
                      ),
                      SizedBox(height: Globals.screenHeight * 0.01),

                      // Question text
                      buildHighlightedText(
                        bookmark['question_text'] ?? 'No question',
                        'question',
                      ),

                      SizedBox(height: Globals.screenHeight * 0.01),

                      // Expand/collapse indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            isExpanded ? 'Hide answer' : 'Show answer',
                            style: TextStyle(
                              color: Globals.customYellow,
                              fontSize: Globals.screenHeight * 0.014,
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Globals.customYellow,
                            size: Globals.screenHeight * 0.02,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Answer section (collapsible)
              if (isExpanded)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Globals.screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Globals.customGreyLight.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: _searchQuery.isEmpty ||
                          _selectedFilter == 'All' ||
                          _selectedFilter != 'Answer'
                      ? MarkdownBody(
                          data:
                              bookmark['answer_text'] ?? 'No answer available',
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: Globals.customBlack,
                              fontSize: Globals.screenHeight * 0.016,
                            ),
                            strong: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Globals.customBlack,
                            ),
                            code: TextStyle(
                              fontFamily: 'monospace',
                              color: Globals.customBlack,
                              backgroundColor:
                                  Globals.customGreyLight.withOpacity(0.3),
                            ),
                            h1: TextStyle(
                              color: Globals.customBlack,
                              fontSize: Globals.screenHeight * 0.022,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: TextStyle(
                              color: Globals.customBlack,
                              fontSize: Globals.screenHeight * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: TextStyle(
                              color: Globals.customBlack,
                              fontSize: Globals.screenHeight * 0.018,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : buildHighlightedText(
                          bookmark['answer_text'] ?? 'No answer available',
                          'answer',
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}
