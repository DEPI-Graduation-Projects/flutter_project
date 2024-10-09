import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/app_cubit.dart';
import '../../cubit/app_states.dart';
import '../../data/user_story.dart';

class StoryView extends StatefulWidget {
  final List<UserStory> stories;
  final int initialIndex;

  const StoryView({super.key, required this.stories, this.initialIndex = 0});

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUserName = true;
  final Duration _storyDuration = const Duration(seconds: 5);
  late List<double> _progressList;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _progressList = List<double>.filled(widget.stories.length, 0.0);

    _startProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startProgress() {
    setState(() {
      _progressList[_currentIndex] = 0.0;
    });

    Future.delayed(Duration.zero, () {
      TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: _storyDuration,
        builder: (context, value, child) {
          setState(() {
            _progressList[_currentIndex] = value;
          });

          if (value == 1.0) {
            _goToNextStory();
          }

          return SizedBox();
        },
      );
    });
  }

  void _goToNextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _startProgress();
      });

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => AppCubit(),
        child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {
            if (state is DeleteStorySuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story deleted successfully!')),
              );
              if (widget.stories.length > 1) {
                setState(() {
                  widget.stories.removeAt(_currentIndex);
                  if (_currentIndex > 0) _currentIndex--;
                });
              } else {
                Navigator.pop(context);
              }
            } else if (state is DeleteStoryFailedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete story!')),
              );
            }
          },
          builder: (context, state) {
            var cubit = AppCubit.get(context);
            return Scaffold(
              body: GestureDetector(
                onTap: () => _goToNextStory(),
                onLongPress: () {
                  setState(() {
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
                    PageView.builder(
                      controller: _pageController,
                      itemCount: widget.stories.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _startProgress();
                        });
                      },
                      itemBuilder: (context, index) {
                        int storyIndex = widget.stories.length - 1 - index;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      widget.stories[storyIndex].imgURL),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (_showUserName)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10),
                                child: Text(
                                  '${cubit.currentUser?.name}\'s Story',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: Colors.black,
                                        offset: Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    Row(
                      children: List.generate(widget.stories.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 2.0),
                            child: LinearProgressIndicator(
                              value: _progressList[widget.stories.length - 1 - index],
                              backgroundColor: index >= _currentIndex
                                  ? Colors.grey
                                  : Colors.blue,
                              minHeight: 4,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              floatingActionButton: IconButton(
                onPressed: () {
                  cubit.deleteStory(storyId: widget.stories[widget.stories.length - 1 - _currentIndex].id);
                },
                icon: state is DeleteStoryLoadingState
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.delete,
                    color: Colors.blue,
                    size: 40,
                    shadows: [
                      Shadow(
                        blurRadius: 50.0,
                        color: Colors.grey,
                        offset: Offset(2.0, 2.0),
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
