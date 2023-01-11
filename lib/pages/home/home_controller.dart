import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/common/lyric_parser/parser_lrc.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/common/storage.dart';
import 'package:bujuan/pages/home/view/z_comment_view.dart';
import 'package:bujuan/pages/home/view/z_lyric_view.dart';
import 'package:bujuan/pages/home/view/z_playlist_view.dart';
import 'package:bujuan/pages/home/view/z_recommend_view.dart';
import 'package:bujuan/pages/user/user_controller.dart';
import 'package:bujuan/widget/weslide/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'dart:math' as math;

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:tuna_flutter_range_slider/tuna_flutter_range_slider.dart';

import '../../common/lyric_parser/lyrics_reader_model.dart';
import '../../common/netease_api/src/api/bean.dart';
import '../../common/bujuan_audio_handler.dart';
import '../../routes/router.dart';
import '../../widget/mobile/flashy_navbar.dart';
import 'view/home_view.dart';

typedef _ContrastCalculator = double Function(Color a, Color b, int alpha);

class HomeController extends SuperController with GetSingleTickerProviderStateMixin {
  double panelHeaderSize = 100.w;
  double panelMobileMinSize = 100.w;
  final List<LeftMenu> leftMenus = [
    LeftMenu('个人中心', TablerIcons.user, Routes.user, '/home/user'),
    LeftMenu('推荐歌单', TablerIcons.smart_home, Routes.index, '/home/index'),
    LeftMenu('个性设置', TablerIcons.settings, Routes.setting, '/setting'),
  ];

  RxList<FlashyNavbarItem> bottomItems = <FlashyNavbarItem>[].obs;
  List<Widget> pages = [
    const RecommendView(),
    const PlayListView(),
    const LyricView(),
    const CommentView(),
  ];

  RxString currPathUrl = '/home/user'.obs;

  //歌词、播放列表PageView的下标
  RxInt selectIndex = 0.obs;

  //歌词、播放列表PageView控制器
  PreloadPageController pageController = PreloadPageController();

  //第一层滑动高度0-1
  RxDouble slidePosition = 0.0.obs;

  //第二层滑动高度0-1
  RxDouble slidePosition1 = 0.0.obs;

  //专辑颜色数据
  Rx<PaletteColorData> rx = PaletteColorData().obs;

  //是否第二层
  RxBool second = false.obs;

  //当前播放歌曲
  Rx<MediaItem> mediaItem = const MediaItem(id: '', title: '暂无', duration: Duration(seconds: 10)).obs;

  //当前播放列表
  RxList<MediaItem> mediaItems = <MediaItem>[].obs;

  //是否播放中
  RxBool playing = false.obs;

  RxBool fm = false.obs;

  RxBool leftImage = true.obs;

  //是否渐变播放背景
  RxBool gradientBackground = false.obs;

  //上下文
  late BuildContext buildContext;

  //播放器handler
  final BujuanAudioHandler audioServeHandler = GetIt.instance<BujuanAudioHandler>();

  //当前播放进度
  Rx<Duration> duration = Duration.zero.obs;

  //第一层
  PanelController panelControllerHome = PanelController();

  //第二层
  PanelController panelController = PanelController();

  //循环方式
  Rx<AudioServiceRepeatMode> audioServiceRepeatMode = AudioServiceRepeatMode.all.obs;
  Rx<AudioServiceShuffleMode> audioServiceShuffleMode = AudioServiceShuffleMode.none.obs;

  //进度条数组
  List<Map<dynamic, dynamic>> mEffects = [];

  //歌词滚动控制器
  FixedExtentScrollController lyricScrollController = FixedExtentScrollController();

  //播放列表滚动控制器
  ScrollController playListScrollController = ScrollController();

  //侧滑控制器
  ZoomDrawerController myDrawerController = GetIt.instance<ZoomDrawerController>();

  //解析后的歌词数组
  List<LyricsLineModel> lyricsLineModels = <LyricsLineModel>[].obs;

  //是否有翻译歌词
  RxBool hasTran = false.obs;

  //歌词是否被用户滚动中
  RxBool onMove = false.obs;

  //当前歌词下标
  int lastIndex = 0;

  //相似歌单
  RxList<Play> simiSongs = <Play>[].obs;

  //歌曲评论
  RxList<CommentItem> comments = <CommentItem>[].obs;

  //路由相关
  AutoRouterDelegate? autoRouterDelegate;

  RxBool isAurora = false.obs;

  var lastPopTime = DateTime.now();

  bool intervalClick(int needTime) {
    // 防重复提交
    if (DateTime.now().difference(lastPopTime) > const Duration(milliseconds: 800)) {
      lastPopTime = DateTime.now();
      return true;
    } else {
      return false;
    }
  }

  //进度
  @override
  void onInit() async {
    StorageUtil().setBool(noFirstOpen, true);
    leftImage.value = StorageUtil().getBool(leftImageSp);
    gradientBackground.value = StorageUtil().getBool(gradientBackgroundSp);
    fm.value = StorageUtil().getBool(fmSp);
    super.onInit();
  }

  @override
  void onReady() {
    autoRouterDelegate = AutoRouterDelegate.of(buildContext);
    var rng = Random();
    for (double i = 0; i < 100; i++) {
      mEffects.add({"percent": i, "size": 3 + rng.nextInt(30 - 5).toDouble()});
    }
    audioServeHandler.setRepeatMode(audioServiceRepeatMode.value);
    audioServeHandler.queue.listen((value) => mediaItems
      ..clear()
      ..addAll(value));
    audioServeHandler.mediaItem.listen((value) async {
      lyricsLineModels.clear();
      if (value == null) return;
      mediaItem.value = value;
      _getAlbumColor();
      _getSimiSheet();
      _getLyric();
      _getSongTalk();
      _setPlayListOffset();
    });
    //监听实时进度变化
    AudioService.position.listen((event) {
      //如果没有展示播放页面就先不监听（节省资源）
      if (!second.value && slidePosition.value == 0) return;
      //如果监听到的毫秒大于歌曲的总时长 置0并stop
      if (event.inMilliseconds > (mediaItem.value.duration?.inMilliseconds ?? 0)) {
        duration.value = Duration.zero;
        return;
      }
      //赋值
      duration.value = event;
      //如果歌词列表没有滑动，根据歌词的开始时间自动滚动歌词列表
      if (!onMove.value) {
        int index = lyricsLineModels.indexWhere((element) => (element.startTime ?? 0) >= event.inMilliseconds && (element.endTime ?? 0) <= event.inMilliseconds);
        if (index != -1 && index != lastIndex) {
          lyricScrollController.animateToItem((index > 0 ? index - 1 : index), duration: const Duration(milliseconds: 300), curve: Curves.linear);
          lastIndex = index;
        }
      }
    });
    audioServeHandler.playbackState.listen((value) {
      playing.value = value.playing;
    });

    //监听路由变化
    autoRouterDelegate?.addListener(listenRouter);
    myDrawerController.stateNotifier?.addListener(() {
      if (myDrawerController.isOpen!()) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarBrightness: Get.isPlatformDarkMode ? Brightness.light : Brightness.dark,
          statusBarIconBrightness: Get.isPlatformDarkMode ? Brightness.dark : Brightness.light,
        ));
      }
      if (!myDrawerController.isOpen!()) {
        didChangePlatformBrightness();
      }
    });
    super.onReady();
  }

  //获取歌词
  _getLyric() async {
    //获取歌词
    SongLyricWrap songLyricWrap = await NeteaseMusicApi().songLyric(mediaItem.value.id);
    String lyric = songLyricWrap.lrc.lyric ?? "";
    String lyricTran = songLyricWrap.tlyric.lyric ?? "";
    hasTran.value = false;
    if (lyric.isNotEmpty) {
      var list = ParserLrc(lyric).parseLines();
      var listTran = ParserLrc(lyricTran).parseLines();
      if (lyricTran.isNotEmpty) {
        hasTran.value = true;
        lyricsLineModels.addAll(list.map((e) {
          int index = listTran.indexWhere((element) => element.startTime == e.startTime);
          if (index != -1) e.extText = listTran[index].mainText;
          return e;
        }).toList());
      } else {
        lyricsLineModels.addAll(list);
      }
    }
  }

  //获取专辑颜色
  _getAlbumColor() async {
    rx.value = await ImageUtils.getImageColor('${mediaItem.value.extras?['image'] ?? ''}?param=500y500');
    if (slidePosition.value == 1 || second.value) changeStatusIconColor(true);
  }

  changeStatusIconColor(bool changed) {
    const Color white = Color(0xffffffff);
    var color = rx.value.main?.color ?? Colors.white;
    int? lightBodyAlpha = _calculateMinimumAlpha(white, color, 4.5);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: changed
          ? lightBodyAlpha == null
              ? Brightness.light
              : Brightness.dark
          : Get.isPlatformDarkMode
              ? Brightness.dark
              : Brightness.light,
      statusBarIconBrightness: changed
          ? lightBodyAlpha == null
              ? Brightness.dark
              : Brightness.light
          : Get.isPlatformDarkMode
              ? Brightness.light
              : Brightness.dark,
    ));
  }

  //获取相似歌单
  _getSimiSheet() async {
    //获取相似歌曲
    MultiPlayListWrap songListWrap = await NeteaseMusicApi().playListSimiList(mediaItem.value.id);
    simiSongs
      ..clear()
      ..addAll(songListWrap.playlists ?? []);
  }

  //获取歌曲评论
  _getSongTalk() async {
    CommentListWrap commentListWrap = await NeteaseMusicApi().commentList(mediaItem.value.id, 'song',limit: 10);
    if (commentListWrap.code == 200) {
      comments
        ..clear()
        ..addAll(commentListWrap.comments ?? []);
    }
  }

  listenRouter() {
    String path = autoRouterDelegate?.urlState.url ?? '';
    if (path == '/home/user' || path == '/home/index') {
      currPathUrl.value = path;
    }
  }

  static HomeController get to => Get.find();

  //改变循环模式
  changeRepeatMode() {
    switch (audioServiceRepeatMode.value) {
      case AudioServiceRepeatMode.one:
        audioServiceRepeatMode.value = AudioServiceRepeatMode.none;
        break;
      case AudioServiceRepeatMode.none:
        audioServiceRepeatMode.value = AudioServiceRepeatMode.all;
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        audioServiceRepeatMode.value = AudioServiceRepeatMode.one;
        break;
    }
    audioServeHandler.setRepeatMode(audioServiceRepeatMode.value);
  }

  //获取当前循环icon
  IconData getRepeatIcon() {
    IconData icon;
    switch (audioServiceRepeatMode.value) {
      case AudioServiceRepeatMode.one:
        icon = TablerIcons.repeat_once;
        break;
      case AudioServiceRepeatMode.none:
        icon = TablerIcons.arrows_shuffle;
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        icon = TablerIcons.repeat;
        break;
    }
    return icon;
  }

  //播放 or 暂停
  void playOrPause() async {
    if (playing.value) {
      await audioServeHandler.pause();
    } else {
      await audioServeHandler.play();
    }
  }

  //喜欢歌曲
  likeSong({bool? liked}) async {
    bool isLiked = UserController.to.likeIds.contains(int.parse(mediaItem.value.id));
    if (liked != null) {
      isLiked = liked;
    }
    ServerStatusBean serverStatusBean = await NeteaseMusicApi().likeSong(mediaItem.value.id, !isLiked);
    if (serverStatusBean.code == 200) {
      await audioServeHandler.updateMediaItem(mediaItem.value..extras?['liked'] = !isLiked);
      if (PlatformUtils.isAndroid) {
        audioServeHandler.playbackState.add(audioServeHandler.playbackState.value.copyWith(
          controls: [
            (mediaItem.value.extras?['liked'] ?? false)
                ? const MediaControl(label: 'fastForward', action: MediaAction.fastForward, androidIcon: 'drawable/audio_service_like')
                : const MediaControl(label: 'rewind', action: MediaAction.rewind, androidIcon: 'drawable/audio_service_unlike'),
            MediaControl.skipToPrevious,
            if (playing.value) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop
          ],
          systemActions: {MediaAction.playPause, MediaAction.seek, MediaAction.skipToPrevious, MediaAction.skipToNext},
          androidCompactActionIndices: [1, 2, 3],
          processingState: AudioProcessingState.completed,
        ));
      }
      WidgetUtil.showToast(isLiked ? '取消喜欢成功' : '喜欢成功');
      if (isLiked) {
        UserController.to.likeIds.remove(int.parse(mediaItem.value.id));
      } else {
        UserController.to.likeIds.add(int.parse(mediaItem.value.id));
      }
    }
  }

  //改变panel位置
  void changeSlidePosition(value) {
    slidePosition.value = value;
    // SystemChrome.setEnabledSystemUIMode(value>0.5?SystemUiMode.manual:SystemUiMode.edgeToEdge,overlays: []);
    _setPlayListOffset();
  }

  double _calculateContrast(Color foreground, Color background) {
    assert(background.alpha == 0xff, 'background can not be translucent: $background.');
    if (foreground.alpha < 0xff) {
      // If the foreground is translucent, composite the foreground over the
      // background
      foreground = Color.alphaBlend(foreground, background);
    }
    final double lightness1 = foreground.computeLuminance() + 0.05;
    final double lightness2 = background.computeLuminance() + 0.05;
    return math.max(lightness1, lightness2) / math.min(lightness1, lightness2);
  }

  int? _calculateMinimumAlpha(Color foreground, Color background, double minContrastRatio) {
    assert(background.alpha == 0xff, 'The background cannot be translucent: $background.');
    double contrastCalculator(Color fg, Color bg, int alpha) {
      final Color testForeground = fg.withAlpha(alpha);
      return _calculateContrast(testForeground, bg);
    }

    // First lets check that a fully opaque foreground has sufficient contrast
    final double testRatio = contrastCalculator(foreground, background, 0xff);
    if (testRatio < minContrastRatio) {
      // Fully opaque foreground does not have sufficient contrast, return error
      return null;
    }
    foreground = foreground.withAlpha(0xff);
    return _binaryAlphaSearch(foreground, background, minContrastRatio, contrastCalculator);
  }

  int _binaryAlphaSearch(
    Color foreground,
    Color background,
    double minContrastRatio,
    _ContrastCalculator calculator,
  ) {
    assert(background.alpha == 0xff, 'The background cannot be translucent: $background.');
    const int minAlphaSearchMaxIterations = 10;
    const int minAlphaSearchPrecision = 1;

    // Binary search to find a value with the minimum value which provides
    // sufficient contrast
    int numIterations = 0;
    int minAlpha = 0;
    int maxAlpha = 0xff;
    while (numIterations <= minAlphaSearchMaxIterations && (maxAlpha - minAlpha) > minAlphaSearchPrecision) {
      final int testAlpha = (minAlpha + maxAlpha) ~/ 2;
      final double testRatio = calculator(foreground, background, testAlpha);
      if (testRatio < minContrastRatio) {
        minAlpha = testAlpha;
      } else {
        maxAlpha = testAlpha;
      }
      numIterations++;
    }
    // Conservatively return the max of the range of possible alphas, which is
    // known to pass.
    return maxAlpha;
  }

  //设置歌词列表偏移量
  Future<void> _setPlayListOffset() async {
    if(fm.value) return;
    if (slidePosition.value < 1 && !second.value) return;
    bool maxOffset = playListScrollController.position.pixels >= playListScrollController.position.maxScrollExtent;
    int index = mediaItems.indexWhere((element) => element.id == mediaItem.value.id);
    if (index != -1 && !maxOffset) {
      double offset = 110.w * index;
      await playListScrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
  }

  //当按下返回键
  Future<bool> onWillPop() async {
    if (panelController.isPanelOpen) {
      panelController.close();
      return false;
    }
    if (panelControllerHome.isPanelOpen) {
      panelControllerHome.close();
      return false;
    }
    if (myDrawerController.isOpen!()) {
      myDrawerController.close!();
      return false;
    }
    return true;
  }

  //播放歌曲根据下标
  playByIndex(int index, String queueTitle, {List<MediaItem>? mediaItem}) async {
    String title = audioServeHandler.queueTitle.value;
    if (title.isEmpty || title != queueTitle) {
      audioServeHandler.queueTitle.value = queueTitle;
      audioServeHandler
        ..changeQueueLists(mediaItem ?? [], index: index)
        ..playIndex(index);
    } else {
      audioServeHandler.playIndex(index);
    }
  }

  getFmSongList() async {
    SongListWrap2 songListWrap2 = await NeteaseMusicApi().userRadio();
    if (songListWrap2.code == 200) {
      List<Song> songs = songListWrap2.data ?? [];
      List<MediaItem> medias = songs
          .map((e) => MediaItem(
              id: e.id,
              duration: Duration(milliseconds: e.duration ?? 0),
              artUri: Uri.parse('${e.album?.picUrl ?? ''}?param=500y500'),
              extras: {
                'image': e.album?.picUrl ?? '',
                'liked': UserController.to.likeIds.contains(int.tryParse(e.id)),
                'artist': (e.artists ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / ')
              },
              title: e.name ?? "",
              album: jsonEncode(e.album!.toJson()),
              artist: (e.artists ?? []).map((e) => e.name).toList().join(' / ')))
          .toList();
      audioServeHandler.addFmItems(medias, false);
    }
  }

  //获取图片亮色背景下文字显示的颜色
  Color getLightTextColor() {
    return Theme.of(buildContext).iconTheme.color?.withOpacity(.8) ?? Colors.transparent;
  }

  //获取Header的padding
  EdgeInsets getHeaderPadding() {
    return EdgeInsets.only(
      left: 30.w,
      right: 30.w,
      top: (MediaQuery.of(buildContext).padding.top + 70.h * (slidePosition.value)) * (second.value ? (1 - slidePosition.value) : slidePosition.value),
    );
  }

  getHomeBottomPadding() {
    return (panelHeaderSize * .5);
  }

  //外层panel的高度和颜色
  double getPanelMinSize() {
    return panelHeaderSize * (1 + slidePosition.value * 6);
  }

  //获取图片的宽高
  double getImageSize() {
    return (panelHeaderSize * .8) * (1 + slidePosition.value * 5.65);
  }

  //获取图片离左侧的间距
  double getImageLeft() {
    return ((Get.width - 60.w) - getImageSize()) / 2 * slidePosition.value;
  }

  List<FlutterSliderHatchMarkLabel> updateEffects(double leftPercent, double rightPercent) {
    List<FlutterSliderHatchMarkLabel> newLabels = mEffects.map((e) => FlutterSliderHatchMarkLabel()).toList();
    return newLabels;
  }

  Color getPlayPageTheme(BuildContext context) {
    return isAurora.value ? Theme.of(context).cardColor.withOpacity(.8) : rx.value.main?.titleTextColor.withOpacity(.7) ?? Colors.transparent;
  }

  @override
  void onClose() {
    super.onClose();
    // panelControllerHome.d();
    lyricScrollController.dispose();
    autoRouterDelegate?.removeListener(listenRouter);
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
    // WidgetUtil.showToast('onDetached');
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
    // WidgetUtil.showToast('onInactive');
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
    // WidgetUtil.showToast('onPaused');
  }

  @override
  void onResumed() {
    // WidgetUtil.showToast('onResumed');
  }

  @override
  void didChangePlatformBrightness() {
    if (second.value || slidePosition.value == 1) return;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Get.isPlatformDarkMode ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: Get.isPlatformDarkMode ? Brightness.light : Brightness.dark,
    ));
    super.didChangePlatformBrightness();
  }

  List<MediaItem> song2ToMedia(List<Song2> songs) {
    return songs
        .map((e) => MediaItem(
            id: e.id,
            duration: Duration(milliseconds: e.dt ?? 0),
            artUri: Uri.parse('${e.al?.picUrl ?? ''}?param=500y500'),
            extras: {
              'url': '',
              'image': e.al?.picUrl ?? '',
              'type': '',
              'liked': UserController.to.likeIds.contains(int.tryParse(e.id)),
              'artist': (e.ar ?? []).map((e) => jsonEncode(e.toJson())).toList().join(' / '),
              'mv':e.mv
            },
            title: e.name ?? "",
            album: jsonEncode(e.al?.toJson()),
            artist: (e.ar ?? []).map((e) => e.name).toList().join(' / ')))
        .toList();
  }
}
