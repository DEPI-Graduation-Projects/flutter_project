import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:flutter_project/widgets/stories_widgets/seen_list.dart';
import 'package:flutter_project/widgets/stories_widgets/story_content.dart';
import 'package:flutter_project/widgets/stories_widgets/story_progress.dart';
import '../../Components/constants.dart';
import '../../cubit/app_cubit.dart';
import '../../cubit/app_states.dart';
import '../../cubit/story_cubit.dart';
import '../../models/stories_model.dart';
import 'package:get/get.dart';

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
  final Duration _storyDuration = const Duration(seconds: 10);
  late List<double> _progressList;
  Timer? _timer;
  bool _isLoading = true;
  Duration _remainingDuration = const Duration(seconds: 5);
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
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

  void _navigateToSeenList() async {
    _pauseProgress();
    await Get.to(
          () => SeenList(storyId: widget.stories[_currentIndex].id),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 800),
    );
    if (mounted) {
      setState(() {
        _resumeProgress();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return bloc.BlocProvider(
      create: (context) =>
      StoryCubit()

        ..getStories()
        ..fetchAllUserNames(),
      child: SafeArea(
        child: Scaffold(
          body: bloc.BlocConsumer<StoryCubit, AppStates>(
            listener: (BuildContext context, state) {
              if (state is DeleteStoryLoadingState) {
                const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is DeleteStorySuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Story Deleted Successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Constants.appThirColor,
                ));
              } else if (state is DeleteStoryFailedState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Failed to delete story!',
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
                        ? const Center(
                      child: CircularProgressIndicator(),
                    ) : StoryContent(stories: widget.stories,
                        pageController: _pageController,
                        currentIndex: _currentIndex,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                            _remainingDuration = _storyDuration;
                            _startProgress();
                          });
                        }),
                    StoryProgressBar(progressList: _progressList,
                        currentIndex: _currentIndex,
                        storyCount: widget.stories.length)
                  ],
                ),
              );
            },
          ),
          floatingActionButton:
          widget.stories[_currentIndex].userId == AppCubit.userId
              ? Stack(children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FloatingActionButton(
                  backgroundColor: Constants.appPrimaryColor,
                  onPressed: () {
                    StoryCubit.get(context).deleteStory(
                        storyId: widget.stories[_currentIndex].id);
                  },
                  child: const Icon(Icons.delete,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: bloc.BlocBuilder<StoryCubit, AppStates>(
                builder: (context, state) {
                  final storyCubit = context.read<StoryCubit>();

                  storyCubit.getStorySeenBy(widget.stories[_currentIndex].id);
                  final seenCount = storyCubit.storySeenByCount(
                      widget.stories[_currentIndex].id);

                  if (state is GetStorySeenByLoadingState) {
                    return buildSeenButton('Loading...', null);
                  } else if (state is GetStorySeenByErrorState) {
                    return buildSeenButton('Error', null);
                  } else {
                    return buildSeenButton('$seenCount', _navigateToSeenList);
                  }
                },
              ),
            )
          ])
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

}

