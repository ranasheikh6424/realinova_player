import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:just_audio/just_audio.dart';

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

  @override
  void initState() {
    super.initState();
    requestPermission();
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

  Future<void> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      fetchAudio();
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> fetchAudio() async {
    final audioAlbums = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
      onlyAll: false,
    );

    List<AssetEntity> allAudio = [];
    for (final album in audioAlbums) {
      final count = await album.assetCountAsync;
      final assets = await album.getAssetListRange(start: 0, end: count);
      allAudio.addAll(assets);
    }

    setState(() {
      audioFiles = allAudio;
    });
  }

  Future<void> playAudio(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      if (_currentlyPlaying == asset) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          _audioPlayer.play();
        }
      } else {
        await _audioPlayer.setFilePath(file.path);
        _audioPlayer.play();
        setState(() {
          _currentlyPlaying = asset;
        });
      }
    } else {
      print('Unable to load audio file.');
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _currentlyPlaying = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Stack(
        children: [
          audioFiles.isEmpty
              ? Center(child: LoadingAnimationWidget.fourRotatingDots(color: Colors.purple, size:34))
              : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: audioFiles.length,
            itemBuilder: (_, index) {
              final asset = audioFiles[index];
              final isPlayingThis = asset == _currentlyPlaying && _isPlaying;

              return Card(
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(12),
                // ),
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                color: asset == _currentlyPlaying
                    ? Colors.deepPurple[50]
                    : Colors.white,
                child: ListTile(
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  leading: Icon(
                    isPlayingThis ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: isPlayingThis ? Colors.deepPurple : Colors.grey[700],
                    size: 32,
                  ),
                  title: Text(
                    asset.title ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
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
