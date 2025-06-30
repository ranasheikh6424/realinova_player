import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:untitled5/screens/video_palyer_page.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<Map<String, dynamic>> videoFiles = []; // All videos
  List<Map<String, dynamic>> recentlyViewed = []; // Recently viewed videos

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      fetchVideos();
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> fetchVideos() async {
    final videoAlbums = await PhotoManager.getAssetPathList(type: RequestType.video);
    List<Map<String, dynamic>> allVideos = [];
    for (final album in videoAlbums) {
      final count = await album.assetCountAsync;
      final assets = await album.getAssetListRange(start: 0, end: count);

      for (var asset in assets) {
        allVideos.add({
          'asset': asset,
          'albumName': album.name,
        });
      }
    }
    setState(() {
      videoFiles = allVideos;
    });
  }

  void openVideoPlayer(AssetEntity asset) async {
    // Add video to recently viewed if not already there
    final existingIndex = recentlyViewed.indexWhere((element) => element['asset'].id == asset.id);
    if (existingIndex != -1) {
      // Move to front
      final existing = recentlyViewed.removeAt(existingIndex);
      recentlyViewed.insert(0, existing);
    } else {
      recentlyViewed.insert(0, {
        'asset': asset,
        'albumName': '', // Optionally fill album name if needed
      });
      // Limit to last 10 videos
      if (recentlyViewed.length > 10) {
        recentlyViewed.removeLast();
      }
    }
    setState(() {});

    // Navigate to video player page
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerPage(asset: asset)),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoFiles.isEmpty) {
      return Center(
        child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.purple, size: 34),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text("recently viewed",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
        ),


        // Carousel for recently viewed videos
        if (recentlyViewed.isNotEmpty) ...[
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: recentlyViewed.length,
              itemBuilder: (context, index) {
                final video = recentlyViewed[index];
                final asset = video['asset'] as AssetEntity;
                final duration = formatDuration(asset.videoDuration);
                return GestureDetector(
                  onTap: () => openVideoPlayer(asset),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AssetEntityImage(
                              asset,
                              fit: BoxFit.cover,
                              width: 120,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          asset.title ?? 'Untitled',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          duration,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
        ],

        // Expanded ListView for all videos below
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: videoFiles.length,
            itemBuilder: (_, index) {
              final assetMap = videoFiles[index];
              final asset = assetMap['asset'] as AssetEntity;
              final albumName = assetMap['albumName'] as String;
              final duration = formatDuration(asset.videoDuration);

              return Card(
                elevation: 0,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () => openVideoPlayer(asset),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 120,
                                height: 68,
                                child: AssetEntityImage(asset, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  duration,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.title ?? 'Untitled',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${asset.createDateTime.toLocal()}'.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                albumName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
