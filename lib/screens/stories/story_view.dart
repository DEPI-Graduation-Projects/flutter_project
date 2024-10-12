import 'dart:async';
import 'package:flutter/material.dart';
import '../../cubit/app_cubit.dart';
import '../../models/stories_model.dart';

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
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Simulate loading time
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
    _timer?.cancel(); // Cancel the timer
    _pageController.dispose();
    super.dispose();
  }

  void _startProgress() {
    setState(() {
      _progressList[_currentIndex] = 0.0; // Reset progress for current story
    });

    _timer = Timer(_storyDuration, () {
      if (mounted) {
        _goToNextStory(); // Only call if mounted
      }
    });
  }

  void _goToNextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _startProgress(); // Restart progress for the next story
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
    return SafeArea(
      child: Scaffold(
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
              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : PageView.builder(
                controller: _pageController,
                itemCount: widget.stories.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _startProgress(); // Restart progress on page change
                  });
                },
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.stories[index].imgURL),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (_showUserName)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                          child: Text(
                            widget.stories[index].userId == AppCubit.userId
                                ? 'My Story'
                                : '${AppCubit.get(context).userNames[widget.stories[index].userId]}\'s Story',
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
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: LinearProgressIndicator(
                        value: _progressList[index],
                        backgroundColor: index >= _currentIndex ? Colors.grey : Colors.blue,
                        minHeight: 4,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.stories[_currentIndex].userId == AppCubit.userId
            ? FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            AppCubit.get(context).deleteStory(storyId: widget.stories[_currentIndex].id);
          },
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}
