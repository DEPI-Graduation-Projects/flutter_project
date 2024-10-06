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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                onTap: () => Navigator.pop(context),
                onLongPress: () {
                  setState(() {
                    _showUserName = !_showUserName;
                  });
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.stories.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
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
              ),
              floatingActionButton: IconButton(
                onPressed: () {
                  cubit.deleteStory(storyId: widget.stories[_currentIndex].id);
                },
                icon: state is DeleteStoryLoadingState
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.delete, color: Colors.white, size: 40, shadows: [
                  Shadow(
                    blurRadius: 50.0,
                    color: Colors.grey,
                    offset: Offset(2.0, 2.0),
                  ),
                ],),
              ),
            );
          },
        ),
      ),
    );
  }
}
