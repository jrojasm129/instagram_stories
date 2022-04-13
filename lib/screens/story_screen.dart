import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_histories/data/data.dart';
import 'package:instagram_histories/models/models.dart';
import 'package:video_player/video_player.dart';

class StoryScreen extends StatefulWidget {
  final List<Story> stories;
  const StoryScreen({ Key? key, required this.stories }) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin{

  late PageController _pageController;
  VideoPlayerController? _videoPlayerController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    _pageController = PageController();

    _animationController = AnimationController(vsync: this);
    _animationController.addStatusListener((status) {

      if(status == AnimationStatus.completed){
        _animationController.stop();
        _animationController.reset();
        setState(() {
            if(_currentIndex + 1 < stories.length){
              _currentIndex += 1;
              _loadStory(story: stories[_currentIndex], );
            }else{
              _currentIndex = 0;
              _loadStory(story: stories[_currentIndex], );
            }
        });
      }});

    final firstStorie = stories.first;
    _loadStory(story: firstStorie, animateToPage: false);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final Story story = widget.stories[_currentIndex];

    return Scaffold(

      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        child: Stack(
          children: [            
            PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              itemCount: widget.stories.length,
              itemBuilder: (_, index) {
      
                 final story = widget.stories[index];
      
                 switch (story.media) {
                   case MediaType.image:
                     return CachedNetworkImage(imageUrl: story.url, fit: BoxFit.cover);
                   case MediaType.video:
                     if(_videoPlayerController!.value.isInitialized){
                       return FittedBox(
                         fit: BoxFit.cover,
                         child: SizedBox.fromSize(
                           size: _videoPlayerController!.value.size,
                           child: VideoPlayer(_videoPlayerController!),
                         ),
                       );
                     }
                 } 
      
                return const SizedBox.shrink();
              
            },),
            Positioned(
              top: 40,
              left: 10,
              right: 5,
              child: Column(
                children: [
                  Row(
                    children: stories.asMap()
                     .map((i, value) => MapEntry(i, _AnimatedBar(
                       animationController: _animationController,
                       currentIndex: _currentIndex,
                       position: i,
                     )
                    )).values.toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        maxRadius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: CachedNetworkImageProvider(story.user.profileImageUrl),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(story.user.name,style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: (){
                          print('salir');
                        }, 
                        icon: const Icon(Icons.close, color: Colors.white, size: 20,)
                      )
                    ],
                  )
                ],
              )
            )
          ],
        ),
      ),
      
    );
  }

  _onTapDown(TapDownDetails details, Story story) {
    final screenSize = MediaQuery.of(context).size;
    final dx = details.globalPosition.dx;

    if(dx < screenSize.width / 3){
      setState(() {
      if(_currentIndex -1 >= 0) _currentIndex-= 1;  
      _loadStory(story: stories[_currentIndex]);
      });

    }else if(dx >= 2 * screenSize.width / 3){
      setState(() {
        if(_currentIndex+1 < stories.length){
          _currentIndex += 1;
          _loadStory(story: stories[_currentIndex]);
        }else{
          _currentIndex = 0;
          _loadStory(story: stories[_currentIndex]);
        }
      });
    }else{
      if(story.media == MediaType.video){
        if(_videoPlayerController!.value.isPlaying){
          _videoPlayerController!.pause();
          _animationController.stop();
        }else{
          _videoPlayerController!.play();
          _animationController.forward();
        }
      }
    }
  }

  void _loadStory({required Story story, bool animateToPage = true}) {
    _animationController.stop();
    _animationController.reset();

    switch (story.media) {
      case MediaType.image:
        _animationController.duration = story.duration;
        _animationController.forward();
        break;
      case MediaType.video:
         _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.network(story.url)
        ..initialize().then((value) => setState((){
          if(_videoPlayerController?.value.isInitialized ?? false){
            _animationController.duration = _videoPlayerController!.value.duration;
            _animationController.forward();
            _videoPlayerController!.play();
          }
        }));
        break;
    }

    if(animateToPage){
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }
}

class _AnimatedBar extends StatelessWidget {

  final AnimationController animationController;
  final int currentIndex;
  final int position;

  const _AnimatedBar({
    Key? key, required this.animationController, required this.currentIndex, required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              _BuildBar(width: constraints.maxWidth, color: position < currentIndex
                  ? Colors.white : Colors.white.withOpacity(0.4)),

              position == currentIndex
              ? AnimatedBuilder(
                animation: animationController, 
                builder: (_, __){
                  return _BuildBar(width: constraints.maxWidth * animationController.value, color: Colors.white);
                }
              )
              : const SizedBox.shrink()
            ],
          );
        }
      )
    );
  }
}

class _BuildBar extends StatelessWidget {

  final Color color;
  final double width;

  const _BuildBar({
    Key? key, required this.color, required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.3),
      width: width, 
      height: 3, 
      decoration: BoxDecoration(
        color:color,
        border: Border.all(
          color: Colors.black12,
          width: 0.5
        ),
        borderRadius: BorderRadius.circular(3)
      ),
    );
  }
}

  