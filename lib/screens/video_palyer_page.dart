import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';

class VideoPlayerPage extends StatefulWidget {
  final AssetEntity asset;

  const VideoPlayerPage({super.key, required this.asset});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  // Double-tap
  DateTime? _lastTapLeft;
  DateTime? _lastTapRight;

  // Swipe
  double _startVerticalDragPos = 0.0;
  bool _isLeftSide = true;
  double _startBrightness = 0.5;
  double _startVolume = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setPreferredOrientations();
    initializeVideo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _resetPreferredOrientations();
    super.dispose();
  }

  void _setPreferredOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _resetPreferredOrientations() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  Future<void> initializeVideo() async {
    final file = await widget.asset.file;
    if (file != null) {
      final controller = VideoPlayerController.file(file);

      try {
        await controller.initialize();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unsupported video format')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        allowFullScreen: true,
        allowedScreenSleep: false,
        showControls: true,
      );

      setState(() {
        _videoPlayerController = controller;
        _chewieController = chewieController;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video file not found')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _handleDoubleTap(bool isLeft) {
    final controller = _videoPlayerController;
    if (controller == null) return;

    final currentPos = controller.value.position;
    final skip = Duration(seconds: 10);
    final duration = controller.value.duration;

    final newMillis = isLeft
        ? currentPos.inMilliseconds - skip.inMilliseconds
        : currentPos.inMilliseconds + skip.inMilliseconds;

    final clampedMillis = newMillis.clamp(0, duration.inMilliseconds);

    controller.seekTo(Duration(milliseconds: clampedMillis));
  }


  void _onDoubleTapDown(TapDownDetails details, BoxConstraints constraints) {
    final dx = details.globalPosition.dx;
    final screenWidth = constraints.maxWidth;

    if (dx < screenWidth / 2) {
      _handleDoubleTap(true);
    } else {
      _handleDoubleTap(false);
    }
  }

  void _onVerticalDragStart(DragStartDetails details, double screenWidth) async {
    _startVerticalDragPos = details.globalPosition.dy;
    _isLeftSide = details.globalPosition.dx < screenWidth / 2;

    if (_isLeftSide) {
      _startBrightness = await ScreenBrightness().current;
    } else {
      _startVolume = await VolumeController.instance.getVolume();
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) async {
    double dragDelta = _startVerticalDragPos - details.globalPosition.dy;
    double delta = dragDelta / 300;

    if (_isLeftSide) {
      double newBrightness = (_startBrightness + delta).clamp(0.0, 1.0);
      await ScreenBrightness().setScreenBrightness(newBrightness);
    } else {
      double newVolume = (_startVolume + delta).clamp(0.0, 1.0);
      VolumeController.instance.setVolume(newVolume);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _resetPreferredOrientations();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _resetPreferredOrientations();
              Navigator.pop(context);
            },
          ),
          title: const Text('Playing Video', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onDoubleTapDown: (details) =>
                    _onDoubleTapDown(details, constraints),
                onVerticalDragStart: (details) =>
                    _onVerticalDragStart(details, constraints.maxWidth),
                onVerticalDragUpdate: _onVerticalDragUpdate,
                child: AspectRatio(
                  aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
