import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/widgets/stories_widgets/bottom_bar_story_view.dart';
import 'package:flutter_project/widgets/stories_widgets/seen_list.dart';
import 'package:flutter_project/widgets/stories_widgets/story_content.dart';
import 'package:flutter_project/widgets/stories_widgets/story_progress.dart';

import '../../Components/constants.dart';
import '../../cubit/app_cubit.dart';
import '../../cubit/app_states.dart';
import '../../cubit/story_cubit.dart';
import '../../models/stories_model.dart';
import '../../widgets/stories_widgets/seen_button.dart';

class StoryView extends StatefulWidget {
  final List<UserStory> stories;
  final int initialIndex;

  const StoryView({super.key, required this.stories, this.initialIndex = 0});

  @override
  StoryViewState createState() => StoryViewState();
}

class StoryViewState extends State<StoryView> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUserName = true;
  final Duration _storyDuration = const Duration(seconds: 5);
  late List<double> _progressList;
  Timer? _timer;
  bool _isLoading = true;
  Duration _remainingDuration = const Duration(seconds: 5);
  late DateTime _startTime;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = _findFirstUnseenStoryIndex();
    _pageController = PageController(initialPage: _currentIndex);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;

        context.read<StoryCubit>().markStoryAsSeen(widget.stories[_currentIndex].id, Constants.userAccount.userId);
      });
    });

    _progressList = List<double>.filled(widget.stories.length, 0.0);
    _startProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startProgress() {
    _startTime = DateTime.now();
    _progressList[_currentIndex] = 0.0;

    _timer = Timer(_remainingDuration, () {
      if (mounted) {
        _goToNextStory();
      }
    });
  }

  void _pauseProgress() {
    final elapsedTime = DateTime.now().difference(_startTime);
    _remainingDuration = _storyDuration - elapsedTime;
    _timer?.cancel();
  }

  void _resumeProgress() {
    _startTime = DateTime.now();
    _timer = Timer(_remainingDuration, () {
      if (mounted) {
        _goToNextStory();
      }
    });
  }

  void _navigateToSeenList(seenCount, state, storyCubit) async {
    _pauseProgress();
    showModalBottomSheet(
        backgroundColor: Constants.appThirColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        context: context,
        builder: (context) => Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Constants.appPrimaryColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.remove_red_eye,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(seenCount.toString(),
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    seenList(context, state, storyCubit,
                        widget.stories[_currentIndex].id)
                  ],
                ),
              ),
            )).then((_) {
      if (mounted) {
        setState(() {
          _resumeProgress();
        });
      }
    });
  }

  void _goToNextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _remainingDuration = _storyDuration;
        _startProgress();
      });

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }

  Future<void> _sendReply() async {
    final storyCubit = context.read<StoryCubit>();
    final currentStory = widget.stories[_currentIndex];

    storyCubit.replyToStory(
      storyId: currentStory.id,
      replyingUserId: Constants.userAccount.userId,
      replyContent: _replyController.text,
    );

    String? chatId = await _getChatId(currentStory.userId);

    storyCubit.addMessage(
        userId: Constants.userAccount.userId,
        chatId: chatId,
        type: false,
        replyMessage: widget.stories[_currentIndex].id,
        replyMessageId: currentStory.id,
        imagaeUrl: widget.stories[_currentIndex].imgURL,
        message: _replyController.text);

    _replyController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply sent!')),
    );
  }

  Future<String?> _getChatId(String otherUserId) async {
    final appCubit = context.read<AppCubit>();
    return await appCubit.getChatId(Constants.userAccount.userId, otherUserId);
  }

  int _findFirstUnseenStoryIndex() {
    for (int i = 0; i < widget.stories.length; i++) {
      if (!widget.stories[i].seenBy.contains(Constants.userAccount.userId)) {
        return i;
      }
    }
    return widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        widget.stories[_currentIndex].userId == Constants.userAccount.userId;

    return bloc.BlocProvider(
      create: (context) => StoryCubit()
        ..getStories()
        ..fetchAllUserNames()
        ..fetchAllUsers(),
      child: SafeArea(
        child: Scaffold(
          body: bloc.BlocConsumer<StoryCubit, AppStates>(
            listener: (BuildContext context, state) {
              if (state is DeleteStoryLoadingState) {
                    (child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Constants.appPrimaryColor,
                      value: loadingProgress.expectedTotalBytes !=
                          null
                          ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ??
                              1)
                          : null,
                    ),
                  );
                };
              } else if (state is DeleteStorySuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                    'Story Deleted Successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Constants.appThirColor,
                ));
              } else if (state is DeleteStoryFailedState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                    'Failed to delete story!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Constants.appThirColor,
                ));
              }
            },
            builder: (context, state) {
              return GestureDetector(
                onTap: () => _goToNextStory(),
                onLongPress: () {
                  setState(() {
                    _pauseProgress();
                    _showUserName = !_showUserName;
                  });
                },
                onLongPressUp: () {
                  setState(() {
                    _resumeProgress();
                    _showUserName = !_showUserName;
                  });
                },
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy > 0) {
                    Navigator.pop(context);
                  }
                },
                child: Stack(
                  children: [
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator( color: Constants.appPrimaryColor,),
                          )
                        : StoryContent(
                            stories: widget.stories,
                            pageController: _pageController,
                            currentIndex: _currentIndex,
                            showUserName: _showUserName,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                                _remainingDuration = _storyDuration;
                                _timer?.cancel();
                                _startProgress();
                              });
                              final currentStory = widget.stories[_currentIndex];
                              context.read<StoryCubit>().markStoryAsSeen(currentStory.id, Constants.userAccount.userId);
                            }),
                    _showUserName ? StoryProgressBar(
                        progressList: _progressList,
                        currentIndex: _currentIndex,
                        storyCount: widget.stories.length) : SizedBox.shrink(),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: _showUserName ? isCurrentUser
              ? Stack(
                  children: [

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: BlocBuilder<StoryCubit, AppStates>(
                        builder: (context, state) {
                          final storyCubit = context.read<StoryCubit>();
                          storyCubit
                              .getStorySeenBy(widget.stories[_currentIndex].id);
                          final seenCount = storyCubit.storySeenByCount(
                              widget.stories[_currentIndex].id);

                          if (state is GetStorySeenByLoadingState) {
                            return buildSeenButton('Loading...', null);
                          } else if (state is GetStorySeenByErrorState) {
                            return buildSeenButton('Error', null);
                          } else {
                            return buildSeenButton(
                              '$seenCount',
                                  () => _navigateToSeenList(
                                  seenCount, state, storyCubit),
                            );
                          }
                        },
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: FloatingActionButton(
                          backgroundColor: Constants.appPrimaryColor,
                          onPressed: () {
                            context.read<StoryCubit>().deleteStory(
                                storyId: widget.stories[_currentIndex].id);
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                  ],
                )
              : bottomNav(context, _replyController, _sendReply, widget.stories[_currentIndex].id) : SizedBox.shrink(),
        ),
      ),
    );
  }
}
