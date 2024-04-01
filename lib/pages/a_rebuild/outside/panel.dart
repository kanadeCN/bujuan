import 'dart:ui';

import 'package:animated_background/animated_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/pages/a_rebuild/outside/outside.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../common/lyric_parser/parser_lrc.dart';
import '../../../common/netease_api/src/api/event/bean.dart';
import '../../../common/netease_api/src/api/play/bean.dart';
import '../../../common/netease_api/src/netease_api.dart';

import '../../../widget/slider/slider.dart';

class SongData {
  MediaItem mediaItem;
  PlaybackState? playState;
  bool panelOpen;

  SongData(this.mediaItem, this.playState, this.panelOpen);
}

class PanelWidgetSize {
  static double playBarHeight = 120.w;
  static double imageMinSize = 80.w;
  static double imageMaxSize = 380.w;
}

final mediaItemProvider = StreamProvider((ref) => ref.watch(audioHandler).mediaItem.stream);

final playStateProvider = StreamProvider((ref) => ref.watch(audioHandler).playbackState.stream);

final playTimeProvider = StreamProvider((ref) => AudioService.createPositionStream(minPeriod: Duration(microseconds: 800), steps: 1000));

final duration = StateProvider<int>((ref) {
  return (ref.watch(playTimeProvider).value ?? const Duration(microseconds: 0)).inMilliseconds;
});

final songDataProvider = StateProvider<SongData>((ref) {
  MediaItem? mediaItem = ref.watch(mediaItemProvider).value;
  PlaybackState? playState = ref.watch(playStateProvider).value;
  return SongData(mediaItem ?? const MediaItem(id: '-1', title: '', extras: {'image': ''}), playState, ref.watch(isOpen.notifier).state);
});

final paletteGenerator = FutureProvider.family<PaletteGenerator, String>((ref, url) => OtherUtils.getImageColor(url));

final paletteProvider = StateProvider<PaletteGenerator?>((ref) {
  MediaItem? mediaItem = ref.watch(mediaItemProvider).value;
  return ref.watch(paletteGenerator('${mediaItem?.extras!['image']}?param=120y120')).value;
});

final lyricProvider = FutureProvider((ref) async {
  MediaItem? mediaItem = ref.watch(mediaItemProvider).value;
  SongLyricWrap songLyricWrap = await NeteaseMusicApi().songLyric(mediaItem?.id ?? '');
  String lyric = songLyricWrap.lrc.lyric ?? '';
  return ParserLrc(lyric).parseLines();
});

final isOpen = StateProvider((ref) => ref.read(panelController).isPanelOpen);

final pageController = Provider((ref) => PageController());

final hotTalkProvider = FutureProvider((ref) async {
  CommentItem commentItem = CommentItem();
  MediaItem? mediaItem = ref.watch(mediaItemProvider).value;
  CommentList2Wrap commentListWrap = await NeteaseMusicApi().commentList2(mediaItem?.id ?? '', 'song', pageSize: 1, sortType: 2);
  if (commentListWrap.code == 200) {
    var list = commentListWrap.data.comments ?? [];
    if (list.isNotEmpty) {
      commentItem = list[0];
    }
  }
  return commentItem;
});

final talk = StateProvider((ref) => ref.watch(hotTalkProvider).value);

class Panel extends StatefulWidget {
  const Panel({super.key});

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, value: 0);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [PlayBar(this, animationController: animationController)],
      ),
    );
  }
}

class PlayBar extends ConsumerWidget {
  final AnimationController animationController;
  final TickerProvider tickerProvider;

  const PlayBar(this.tickerProvider, {super.key, required this.animationController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    animationController.value = ref.watch(slideProvider.notifier).state;
    PaletteGenerator paletteGenerator = ref.watch(paletteProvider.notifier).state ?? PaletteGenerator.fromColors([]);
    SongData songData = ref.watch(songDataProvider.notifier).state;

    return GestureDetector(
      child: buildContent(context, paletteGenerator, songData, ref),
      onHorizontalDragEnd: (e) {},
      onTap: () {
        if (!ref.read(panelController).isPanelOpen) {
          ref.read(panelController).open();
        }
      },
    );
  }

  Widget buildContent(BuildContext context, PaletteGenerator p, SongData songData, WidgetRef ref) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        // 定义一个原始颜色
        Color originalColor = p.dominantColor?.color ?? p.lightMutedColor?.color ?? p.darkMutedColor?.color ?? Colors.white;
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.w), color: Colors.white),
          margin: EdgeInsets.symmetric(horizontal: 15.w * (1 - animationController.value)),
          height: PanelWidgetSize.playBarHeight + (MediaQuery.of(context).size.height - PanelWidgetSize.playBarHeight) * animationController.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.w),
              gradient: LinearGradient(colors: [
                Colors.white,
                Theme.of(context).scaffoldBackgroundColor,
                originalColor.withOpacity(animationController.value),
              ], begin: Alignment.bottomCenter, end: Alignment.topLeft),
            ),
            height: PanelWidgetSize.playBarHeight + (MediaQuery.of(context).size.height - PanelWidgetSize.playBarHeight) * animationController.value,
            // margin: EdgeInsets.symmetric(horizontal: 15.w * (1 - animationController.value)),
            child: child,
          ),
        );
      },
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: ref.watch(pageController),
        children: [
          _buildWidget(context, p, songData),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [],
            ),
            floatingActionButton: IconButton(
                onPressed: () {
                  ref.read(pageController).animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                icon: const Icon(Icons.clear)),
          )
        ],
      ),
      // child: AnimatedBackground(
      //   vsync: tickerProvider,
      //   behaviour: RandomParticleBehaviour(
      //       options: ParticleOptions(
      //           baseColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(animationController.value),
      //           spawnMaxSpeed: 100,
      //           spawnMinSpeed: 50,
      //           spawnOpacity: .2,
      //           particleCount: (animationController.value * 16).toInt(),
      //           spawnMaxRadius: 10.w)),
      //   child: PageView(
      //     physics: const NeverScrollableScrollPhysics(),
      //     children: [
      //       _buildWidget(context, p, songData),
      //       const Center(
      //         child: Text('lyric'),
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildWidget(BuildContext context, PaletteGenerator p, SongData songData) {
    Color originalColor = p.dominantColor?.color ?? p.lightMutedColor?.color ?? p.darkMutedColor?.color ?? Colors.white;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          AnimatedBuilder(
              animation: animationController,
              builder: (BuildContext context, Widget? child) => AnimatedOpacity(
                    opacity: animationController.value,
                    duration: Duration.zero,
                    child: SizedBox(
                      height: 20.w + (MediaQuery.of(context).size.height * .45 - 20.w) * animationController.value,
                      child: child,
                    ),
                  ),
              child: Container(
                alignment: Alignment.topCenter,
                height: MediaQuery.of(context).size.height * .45,
                child: _buildTopWidget(p, songData),
              )),
          AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget? child) => SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100.w + (MediaQuery.of(context).size.height * .55 - 100.w) * animationController.value,
              child: child,
            ),
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                AnimatedBuilder(
                  animation: animationController,
                  builder: (BuildContext context, Widget? child) => AnimatedPositioned(
                      duration: const Duration(milliseconds: 0),
                      left: 10.w * animationController.value,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 40),
                        width: PanelWidgetSize.imageMinSize + ((PanelWidgetSize.imageMaxSize - PanelWidgetSize.imageMinSize) * animationController.value),
                        height: PanelWidgetSize.imageMinSize + ((PanelWidgetSize.imageMaxSize - PanelWidgetSize.imageMinSize) * animationController.value),
                        child: child,
                      )),
                  child: SimpleExtendedImage(
                    '${songData.mediaItem.extras!['image'] ?? ''}?param=480y480',
                    width: PanelWidgetSize.imageMaxSize,
                    height: PanelWidgetSize.imageMaxSize,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
                Positioned(
                  height: 80.w,
                  left: 10.w + 90.w * (1 - animationController.value),
                  top: 400.w * animationController.value,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 80.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                            songData.mediaItem.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 28.sp + animationController.value * 8,
                              color: const Color(0xFF464545),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          AnimatedOpacity(
                            opacity: animationController.value,
                            duration: Duration.zero,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.more_vert,
                                  size: 42.w,
                                  color: const Color(0xFF464545),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: AnimatedBuilder(
                    animation: animationController,
                    builder: (BuildContext context, Widget? child) => AnimatedContainer(
                      duration: const Duration(milliseconds: 30),
                      alignment: Alignment.center,
                      height: 80.w + (380.w - 80.w) * animationController.value,
                      width: 80.w + (380.w - 80.w) * animationController.value,
                      margin: EdgeInsets.only(
                        left: (MediaQuery.of(context).size.width - 180.w) * (1 - animationController.value),
                      ),
                      child: Consumer(
                        builder: (BuildContext context, WidgetRef ref, Widget? child) => GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(40.w)),
                            child: Icon(
                              songData.playState?.playing ?? false ? Icons.pause : Icons.play_arrow,
                              size: 48.w + animationController.value * 30.w,
                              color: const Color(0xFF464545),
                            ),
                          ),
                          onTap: () {
                            if (songData.playState?.playing ?? false) {
                              ref.read(audioHandler).pause();
                            } else {
                              ref.read(audioHandler).play();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                    animation: animationController,
                    builder: (BuildContext context, Widget? child) => AnimatedPositioned(
                        duration: const Duration(milliseconds: 80),
                        top: 480.w,
                        left: 10.w,
                        child: AnimatedOpacity(
                          opacity: animationController.value,
                          duration: const Duration(milliseconds: 200),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 80.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  songData.mediaItem.artist ?? 'Post malne',
                                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w500, color: Colors.grey),
                                ),
                                Padding(padding: EdgeInsets.symmetric(vertical: 25.w)),
                                Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
                                  int durationValue = ref.watch(duration);
                                  return SquigglySlider(
                                    thumbColor: originalColor.withOpacity(.6),
                                    activeColor: Colors.grey,
                                    inactiveColor: Colors.grey.withOpacity(.6),
                                    squiggleAmplitude: 5.0,
                                    squiggleWavelength: 6.0,
                                    max: 1,
                                    squiggleSpeed: 0,
                                    value: durationValue / (songData.mediaItem.duration ?? const Duration(milliseconds: 300)).inMilliseconds,
                                    onChanged: (double value) {
                                      int changeValue = (value * (songData.mediaItem.duration ?? const Duration(milliseconds: 300)).inMilliseconds).toInt();
                                      ref.refresh(duration.notifier).state = changeValue;
                                      ref.read(audioHandler).seek(Duration(milliseconds: changeValue));
                                    },
                                  );
                                }),
                                Container(
                                  margin: EdgeInsets.only(top: 50.w, left: 10.w, right: 10.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Consumer(
                                            builder: (BuildContext context, WidgetRef ref, Widget? child) => GestureDetector(
                                              child: Icon(
                                                Icons.skip_previous,
                                                size: 66.w,
                                                color: const Color(0xFF464545),
                                              ),
                                              onTap: () {
                                                ref.read(audioHandler).skipToPrevious();

                                                // ref.read(panelController).close();
                                              },
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.symmetric(horizontal: 50.w)),
                                          Consumer(
                                            builder: (BuildContext context, WidgetRef ref, Widget? child) => GestureDetector(
                                              child: Icon(
                                                Icons.skip_next,
                                                size: 66.w,
                                                color: const Color(0xFF464545),
                                              ),
                                              onTap: () {
                                                ref.read(audioHandler).skipToNext();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        child: Icon(
                                          Icons.favorite,
                                          size: 42.w,
                                          color: const Color(0xFF464545),
                                        ),
                                        onTap: () {
                                          print('喜欢歌曲');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopWidget(PaletteGenerator p, SongData songData) {
    return SafeArea(
        bottom: false,
        child: Container(
          child: AnimatedBackground(
            vsync: tickerProvider,
            behaviour: RandomParticleBehaviour(
                options: ParticleOptions(
                    baseColor: (p.dominantColor?.bodyTextColor ?? Colors.grey).withOpacity(.3),
                    spawnMaxSpeed: 100,
                    spawnMinSpeed: 50,
                    spawnOpacity: .01,
                    particleCount: (animationController.value * 10).toInt(),
                    spawnMaxRadius: 10.w)), child: const SizedBox.shrink(),
          ),
        ));
  }
}
