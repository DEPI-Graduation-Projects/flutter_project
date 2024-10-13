import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:flutter_project/widgets/stories_widgets/seen_list.dart';
import '../../cubit/app_cubit.dart';
import '../../cubit/app_states.dart';
import '../../models/stories_model.dart';
import 'package:get/get.dart';

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
      AppCubit()
        ..getStories()
        ..fetchAllUserNames(),
      child: SafeArea(
        child: Scaffold(
          body: bloc.BlocConsumer<AppCubit, AppStates>(
            listener: (BuildContext context, state) {
              if (state is DeleteStoryLoadingState) {
                Center(child: CircularProgressIndicator(),);
              } else if (state is DeleteStorySuccessState) {
                SnackBar(content: Text('Story Deleted Successfully!'),);
              } else if (state is DeleteStoryFailedState) {
                SnackBar(content: Text('Failed to delete story!'),);
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
                    )
                        : PageView.builder(
                      controller: _pageController,
                      itemCount: widget.stories.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _remainingDuration = _storyDuration;
                          _startProgress();
                        });
                      },
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      widget.stories[index].imgURL),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (_showUserName)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10),
                                child: Text(
                                  widget.stories[index].userId ==
                                      AppCubit.userId
                                      ? 'My Story'
                                      : '${AppCubit
                                      .get(context)
                                      .userNames[widget.stories[index]
                                      .userId]}\'s Story',
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0),
                            child: LinearProgressIndicator(
                              value: _progressList[index],
                              backgroundColor:
                              index >= _currentIndex ? Colors.grey : Colors
                                  .blue,
                              minHeight: 4,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: widget.stories[_currentIndex].userId ==
              AppCubit.userId
              ? Stack(
              children: [
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () {
                  AppCubit.get(context).deleteStory(
                      storyId: widget.stories[_currentIndex].id);
                },
                child:
                const Icon(Icons.delete, color: Colors.white, size: 30),
              ),
            ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FutureBuilder<List<String>>(
                    future: AppCubit.get(context).getStorySeenBy(widget.stories[_currentIndex].id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.blue),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Loading...',
                                style: TextStyle(color: Colors.white, fontSize: 17),
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.blue),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Error',
                                style: TextStyle(color: Colors.white, fontSize: 17),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final seenCount = snapshot.data?.length ?? 0;
                        return ElevatedButton(
                          onPressed: () {
                            _timer?.cancel();
                            Get.to(SeenList(widget.stories[_currentIndex].id, seenCount),
                                transition: Transition.downToUp,
                                duration: Duration(seconds: 1));
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => SeenList(widget.stories[_currentIndex].id)));
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.blue),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$seenCount',
                                style: const TextStyle(color: Colors.white, fontSize: 17),
                              ),
                            ],
                          ),
                        );
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
