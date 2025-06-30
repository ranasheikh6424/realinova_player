import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  List<AssetEntity> audioFiles = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  AssetEntity? _currentlyPlaying;
  bool _isPlaying = false;
  bool _loading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAudio();
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionAudio() async {
    // First, check and request READ_MEDIA_AUDIO or fallback to storage for older APIs
    PermissionStatus status;

    if (await Permission.audio.isGranted) {
      status = PermissionStatus.granted;
    } else {
      status = await Permission.audio.request();
    }

    if (status.isGranted) {
      // Also request photo_manager permission for safety
      final photoPerm = await PhotoManager.requestPermissionExtend();
      if (photoPerm.isAuth) {
        await fetchAudio();
        setState(() {
          _permissionDenied = false;
          _loading = false;
        });
      } else {
        // permission denied by photo_manager, open settings
        setState(() {
          _permissionDenied = true;
          _loading = false;
        });
      }
    } else {
      // permission denied by permission_handler
      setState(() {
        _permissionDenied = true;
        _loading = false;
      });
    }
  }

  Future<void> fetchAudio() async {
    final audioAlbums = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
      onlyAll: false,
    );
    print('Found audio albums: ${audioAlbums.length}');
    List<AssetEntity> allAudio = [];
    for (final album in audioAlbums) {
      final count = await album.assetCountAsync;
      print('Album: ${album.name}, assets count: $count');
      final assets = await album.getAssetListRange(start: 0, end: count);
      allAudio.addAll(assets);
    }
    print('Total audio files found: ${allAudio.length}');

    setState(() {
      audioFiles = allAudio;
    });
  }

  Future<void> playAudio(AssetEntity asset) async {
    File? file = await asset.file;
    file ??= await asset.originFile;

    if (file == null || !await file.exists()) {
      debugPrint('No local file found.');
      return;
    }

    debugPrint('Release file path: ${file.path}');

    await _audioPlayer.setFilePath(file.path);
    _audioPlayer.play();

    setState(() {
      _currentlyPlaying = asset;
    });
  }


  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _currentlyPlaying = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.purple.shade50,
        body: Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.purple,
            size: 34,
          ),
        ),
      );
    }

    if (_permissionDenied) {
      return Scaffold(
        backgroundColor: Colors.purple.shade50,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Permission denied.\nPlease allow audio access in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  PhotoManager.openSetting();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Stack(
        children: [
          audioFiles.isEmpty
              ? const Center(
            child: Text('No audio files found.'),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: audioFiles.length,
            itemBuilder: (_, index) {
              final asset = audioFiles[index];
              final isPlayingThis = asset == _currentlyPlaying && _isPlaying;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                color: asset == _currentlyPlaying
                    ? Colors.deepPurple[50]
                    : Colors.white,
                child: ListTile(
                  leading: Icon(
                    isPlayingThis ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: isPlayingThis ? Colors.deepPurple : Colors.grey[700],
                    size: 32,
                  ),
                  title: Text(
                    asset.title ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${asset.createDateTime.toLocal()}'.split(' ')[0],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () => playAudio(asset),
                ),
              );
            },
          ),
          if (_currentlyPlaying != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 100,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 20,
                  color: Colors.deepPurple[100],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentlyPlaying?.title ?? 'Playing...',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 28,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            if (_isPlaying) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.stop_circle,
                            size: 28,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => stopAudio(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
