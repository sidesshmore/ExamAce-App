import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:clipboard/clipboard.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:examaceapp/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:developer';
import 'package:record/record.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatUser _user = ChatUser(id: '1', firstName: 'User');
  final ChatUser _examAce = ChatUser(
      id: '2', firstName: 'ExamAce', profileImage: 'assets/App-Icon.png');

  List<ChatMessage> _messages = [];
  List<ChatUser> _typingUsers = [];
  final TextEditingController _textController = TextEditingController();
  bool _isRecording = false;
  String _transcription = '';
  bool _hasMicPermission = false;
  String? _recordingPath;
  bool isRecording = false;
  bool isTranscribing = false;
  final AudioRecorder _audioRecorder = AudioRecorder();

  // API URL
  String? _apiUrl;

  // Supabase client
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? _subjectData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubjectData();
    });
    _checkAndRequestPermissions();
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _loadSubjectData() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _subjectData = args;
        _apiUrl = args['chatUrl'];
      });
    }
  }

  void _sendMessage(ChatMessage message) {
    // Add user message to the list
    setState(() {
      _messages.insert(0, message);
      _typingUsers.add(_examAce);
    });

    // Call API
    _getResponse(message.text);
  }

  Future<void> _getResponse(String question) async {
    try {
      if (_apiUrl == null || _apiUrl!.isEmpty) {
        _handleApiError('Chat service URL not available for this subject.');
        return;
      }

      final headers = {'Content-Type': 'application/json'};
      final body = {'question': '$question. Explain in detail'};

      final response = await http.post(
        Uri.parse(_apiUrl!), // Use the URL from the database
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);

        ChatMessage responseMessage = ChatMessage(
          text: decodedResponse['answer'],
          user: _examAce,
          createdAt: DateTime.now(),
        );

        setState(() {
          _messages.insert(0, responseMessage);
          _typingUsers.remove(_examAce);
        });
      } else {
        _handleApiError(
            'Unable to generate the answer. Please try again later.');
      }
    } catch (e) {
      _handleApiError('Server is busy. Please try again later.');
    }
  }

  void _handleApiError(String errorMessage) {
    ChatMessage errorResponse = ChatMessage(
      text: errorMessage,
      user: _examAce,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, errorResponse);
      _typingUsers.remove(_examAce);
    });
  }

  void _toggleRecording() async {
    if (isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  // Save bookmark to Supabase
  Future<void> _saveBookmark(String questionText, String answerText) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        _showSnackBar('You need to be logged in to bookmark');
        return;
      }

      await supabase.from('bookmarks').insert({
        'user_id': userId,
        'question_text': questionText,
        'answer_text': answerText,
        'subject_name': _subjectData?['subjectName'] ?? 'General',
      });

      _showSnackBar('Bookmark saved');
    } catch (e) {
      _showSnackBar('Failed to save bookmark: ${e.toString()}');
    }
  }

  // Save dislike to Supabase
  Future<void> _saveDislike(String questionText, String answerText) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        _showSnackBar('You need to be logged in to submit feedback');
        return;
      }

      await supabase.from('dislikes').insert({
        'user_id': userId,
        'question_text': questionText,
        'answer_text': answerText,
        'subject_name': _subjectData?['subjectName'] ?? 'General',
      });

      _showSnackBar('Dislike submitted');
    } catch (e) {
      _showSnackBar('Failed to submit feedback: ${e.toString()}');
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      setState(() {
        _hasMicPermission = result.isGranted;
      });
    } else {
      setState(() {
        _hasMicPermission = status.isGranted;
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        final directory = await getApplicationDocumentsDirectory();
        _recordingPath = path.join(
          directory.path,
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        log('Starting recording at path: $_recordingPath');

        final config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        );

        await _audioRecorder.start(config, path: _recordingPath!);
        setState(() => isRecording = true);
      } else {
        log('Microphone permission denied');
        _showSnackBar('Microphone permission is required for recording');
      }
    } catch (e) {
      log('Error starting recording: $e');
      _showSnackBar('Error starting recording: ${e.toString()}');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
        isTranscribing = true; // Start transcription loading state
      });

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          try {
            final deepgram = Deepgram(
              dotenv.env['DEEPGRAM_API_KEY']!,
              baseQueryParams: {
                'model': 'nova-2-general',
                'detect_language': true,
                'punctuation': true,
                'filler_words': false,
              },
            );

            // Use the same method as in recordingButton.dart
            final result = await deepgram.listen.file(file);

            log(result.transcript!);
            if (result.transcript != null && result.transcript!.isNotEmpty) {
              _textController.text = result.transcript!;

              // Optionally send the message automatically
              // ChatMessage message = ChatMessage(
              //   text: result.transcript!,
              //   user: _user,
              //   createdAt: DateTime.now(),
              // );
              // _sendMessage(message);
            } else {
              _showSnackBar('Failed to capture audio. Please record again');
            }
          } catch (e) {
            log('Transcription or storage error: $e');
            _showSnackBar('Error processing recording: ${e.toString()}');
          } finally {
            setState(() =>
                isTranscribing = false); // End transcription loading state
          }
        }
      }
    } catch (e) {
      log('Error stopping recording: $e');
      _showSnackBar('Error stopping recording: ${e.toString()}');
      setState(() =>
          isTranscribing = false); // End transcription loading state on error
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Globals.customBlack,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Globals.customWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Globals.customBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Globals.customYellow.withOpacity(0.2),
              child: Icon(Icons.school, color: Globals.customYellow),
            ),
            SizedBox(width: Globals.screenWidth * 0.02),
            Expanded(
              child: Text(
                _subjectData?['subjectName'] ?? 'Subject Chat',
                style: TextStyle(
                  color: Globals.customBlack,
                  fontSize: Globals.screenHeight * 0.022,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Divider(height: 1, color: Globals.customGreyLight),
          Expanded(
            child: DashChat(
              currentUser: _user,
              messages: _messages,
              typingUsers: _typingUsers,
              onSend: _sendMessage,
              messageOptions: MessageOptions(
                messageTextBuilder: (message, previousMessage, nextMessage) {
                  final isCurrentUser = message.user.id == _user.id;
                  return Container(
                    padding: EdgeInsets.all(Globals.screenHeight * 0.015),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Globals.customYellow
                          : Globals.customWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: !isCurrentUser
                          ? Border.all(color: Globals.customGreyLight)
                          : null,
                    ),
                    child: MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: isCurrentUser
                              ? Globals.customBlack
                              : Globals.customBlack,
                          fontSize: Globals.screenHeight * 0.016,
                        ),
                        strong: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser
                              ? Globals.customBlack
                              : Globals.customBlack,
                        ),
                        code: TextStyle(
                          fontFamily: 'monospace',
                          color: isCurrentUser
                              ? Globals.customBlack
                              : Globals.customBlack,
                          backgroundColor: isCurrentUser
                              ? Globals.customYellow.withOpacity(0.3)
                              : Globals.customGreyLight.withOpacity(0.3),
                        ),
                        a: TextStyle(
                          color: Globals.customYellow,
                          decoration: TextDecoration.underline,
                        ),
                        h1: TextStyle(
                          color: isCurrentUser
                              ? Globals.customBlack
                              : Globals.customBlack,
                          fontSize: Globals.screenHeight * 0.024,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: TextStyle(
                          color: isCurrentUser
                              ? Globals.customBlack
                              : Globals.customBlack,
                          fontSize: Globals.screenHeight * 0.022,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: TextStyle(
                          color: isCurrentUser
                              ? Globals.customBlack
                              : Globals.customBlack,
                          fontSize: Globals.screenHeight * 0.020,
                          fontWeight: FontWeight.bold,
                        ),
                        blockquote: TextStyle(
                          color: isCurrentUser
                              ? Globals.customBlack.withOpacity(0.8)
                              : Globals.customBlack.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        listBullet: TextStyle(
                          color: isCurrentUser
                              ? Globals.customBlack
                              : Globals.customBlack,
                        ),
                      ),
                    ),
                  );
                },
                showTime: true,
                currentUserContainerColor: Globals.customYellow,
                currentUserTextColor: Globals.customBlack,
                containerColor: Globals.customWhite,
                textColor: Globals.customBlack,
                // Add three buttons for bot messages
                bottom: (message, previousMessage, nextMessage) =>
                    message.user.id != _user.id
                        ? Row(
                            children: [
                              // Bookmark button
                              IconButton(
                                onPressed: () {
                                  // Find the corresponding question message
                                  String questionText = '';
                                  int messageIndex = _messages.indexOf(message);
                                  if (messageIndex < _messages.length - 1) {
                                    questionText =
                                        _messages[messageIndex + 1].text;
                                  }

                                  _saveBookmark(questionText, message.text);
                                },
                                icon: Icon(
                                  Icons.bookmark_border,
                                  size: Globals.screenWidth * 0.04,
                                  color: Globals.customGreyDark,
                                ),
                                tooltip: 'Bookmark',
                              ),
                              // Copy button
                              IconButton(
                                onPressed: () {
                                  FlutterClipboard.copy(message.text).then(
                                    (value) =>
                                        _showSnackBar("Copied to clipboard"),
                                  );
                                },
                                icon: Icon(
                                  Icons.copy,
                                  size: Globals.screenWidth * 0.04,
                                  color: Globals.customGreyDark,
                                ),
                                tooltip: 'Copy',
                              ),
                              // Dislike button
                              IconButton(
                                onPressed: () {
                                  // Find the corresponding question message
                                  String questionText = '';
                                  int messageIndex = _messages.indexOf(message);
                                  if (messageIndex < _messages.length - 1) {
                                    questionText =
                                        _messages[messageIndex + 1].text;
                                  }

                                  _saveDislike(questionText, message.text);
                                },
                                icon: Icon(
                                  Icons.thumb_down_alt_outlined,
                                  size: Globals.screenWidth * 0.04,
                                  color: Globals.customGreyDark,
                                ),
                                tooltip: 'Dislike',
                              ),
                            ],
                          )
                        : Container(),
              ),
              inputOptions: InputOptions(
                inputDecoration: InputDecoration(
                  hintText: isRecording
                      ? "Recording..."
                      : isTranscribing
                          ? "Transcribing..."
                          : "Type your question...",
                  hintStyle: TextStyle(
                    color: isRecording
                        ? Colors.red
                        : isTranscribing
                            ? Colors.orange
                            : Globals.customGreyDark,
                    fontSize: Globals.screenHeight * 0.016,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Globals.customGreyLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isRecording
                          ? Colors.red
                          : isTranscribing
                              ? Colors.orange
                              : Globals.customGreyLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Globals.customYellow),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Globals.screenWidth * 0.04,
                    vertical: Globals.screenHeight * 0.01,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textController: _textController,
                leading: [
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isTranscribing
                          ? SizedBox(
                              width: Globals.screenHeight * 0.025,
                              height: Globals.screenHeight * 0.025,
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Icon(
                              isRecording ? Icons.stop : Icons.mic,
                              key: ValueKey<bool>(isRecording),
                              color: isRecording
                                  ? Colors.red
                                  : Globals.customGreyDark,
                              size: Globals.screenHeight * 0.028,
                            ),
                    ),
                    onPressed: isTranscribing ? null : _toggleRecording,
                  ),
                ],
                sendButtonBuilder: (onSend) {
                  return Container(
                    margin: EdgeInsets.only(
                      right: Globals.screenWidth * 0.02,
                      left: Globals.screenWidth * 0.01,
                    ),
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Globals.customYellow,
                      elevation: 0,
                      onPressed: isRecording || isTranscribing ? null : onSend,
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: Globals.screenHeight * 0.024,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
