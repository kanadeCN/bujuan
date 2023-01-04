import 'package:bujuan/common/constants/platform_utils.dart';
import 'package:bujuan/pages/home/home_controller.dart';
import 'package:bujuan/pages/home/view/body_view.dart';
import 'package:bujuan/pages/home/view/menu_view.dart';
import 'package:bujuan/pages/home/view/panel_view.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.buildContext = context;
    double bottomHeight = MediaQuery.of(controller.buildContext).padding.bottom * (PlatformUtils.isIOS ? 0.4 : 0.6);
    if (bottomHeight == 0) bottomHeight = 25.w;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
          child: ZoomDrawer(
            dragOffset: Get.width / 1.8,
            menuScreenTapClose: true,
            showShadow: true,
            mainScreenTapClose: true,
            menuScreen: const MenuView(),
            moveMenuScreen: true,
            drawerShadowsBackgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(.6),
            menuBackgroundColor: Theme.of(context).cardColor,
            clipMainScreen: true,
            mainScreen: Obx(() => SlidingUpPanel(
                  controller: controller.panelControllerHome,
                  onPanelSlide: (value) => controller.changeSlidePosition(value),
                  parallaxEnabled: true,
                  boxShadow: const [BoxShadow(blurRadius: 8.0, color: Color.fromRGBO(0, 0, 0, 0.15))],
                  color: Colors.transparent,
                  panel: const PanelView(),
                  body: const BodyView(),
                  header: controller.mediaItem.value.id.isNotEmpty ? _buildPanelHeader(bottomHeight) : const SizedBox.shrink(),
                  minHeight: controller.mediaItem.value.id.isNotEmpty ? controller.panelMobileMinSize + bottomHeight : 0,
                  maxHeight: Get.height,
                )),
            // mainScreen: Obx(() {
            //   //TODO 熱更新时 会重构obx下的组件，WeSlide会走dispose方法，controller被dispose了，会出现问题，暂时没法判断是否被dispose，每次重构是重新实例化一下
            //   controller.weSlideController = WeSlideController();
            //   return WeSlide(
            //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            //     controller: controller.weSlideController,
            //     panelWidth: Get.width,
            //     bodyWidth: Get.width,
            //     panelMaxSize: Get.height,
            //     panelBorderRadiusBegin: 30.w,
            //     panelBorderRadiusEnd: 30.w,
            //     parallax: true,
            //     body: const BodyView(),
            //     panel: const PanelView(),
            //     panelHeader: controller.mediaItem.value.id.isNotEmpty ? _buildPanelHeader(bottomHeight) : const SizedBox.shrink(),
            //     hidePanelHeader: false,
            //     isDownSlide: controller.isDownSlide.value,
            //     panelMinSize: controller.mediaItem.value.id.isNotEmpty ? controller.panelMobileMinSize + bottomHeight : 0,
            //     onPosition: (value) => controller.changeSlidePosition(value),
            //   );
            // }),
            controller: controller.myDrawerController,
          ),
          onWillPop: () => controller.onWillPop()),
    );
  }

  // Container(
  // color: Colors.red,
  // height: bottomHeight,
  // )

  Widget _buildPanelHeader(bottomHeight) {
    return GestureDetector(
      child: Obx(() => Stack(
            children: [
              AnimatedContainer(
                color: Colors.transparent,
                padding: controller.getHeaderPadding().copyWith(bottom: bottomHeight),
                width: Get.width,
                height: controller.getPanelMinSize() + controller.getHeaderPadding().top + bottomHeight,
                duration: const Duration(milliseconds: 0),
                child: _buildPlayBar(),
              ),
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  child: Container(
                    color: Colors.transparent,
                    height: bottomHeight * (1 - controller.slidePosition.value),
                    width: Get.width,
                  ),
                  onVerticalDragDown: (e) {
                    return;
                  },
                ),
              )
            ],
          )),
      onHorizontalDragDown: (e) {
        return;
      },
      onTap: () {
        if (!controller.panelControllerHome.isPanelOpen) {
          controller.panelControllerHome.open();
        } else {
          if (controller.panelController.isPanelOpen) controller.panelController.close();
        }
      },
    );
  }

  Widget _buildPlayBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedPositioned(
                left: controller.getImageLeft(),
                duration: const Duration(milliseconds: 0),
                child: AnimatedScale(
                  scale: 1 + (controller.slidePosition.value / (PlatformUtils.isIOS ? 7.6 : 7.4)),
                  duration: const Duration(milliseconds: 100),
                  child: SizedBox(
                    width: controller.getImageSize(),
                    child: CarouselSlider.builder(
                      itemCount: controller.mediaItems.length,
                      carouselController: controller.buttonCarouselController,
                      itemBuilder: (BuildContext context, int index, int pageViewIndex) => SimpleExtendedImage(
                        '${controller.mediaItems[index].extras?['image']}?param=500y500',
                        fit: BoxFit.cover,
                        height: controller.getImageSize(),
                        width: controller.getImageSize(),
                        borderRadius: BorderRadius.circular(controller.getImageSize() / 2 * (1 - (controller.slidePosition.value >= .8 ? .97 : controller.slidePosition.value))),
                      ),
                      options: CarouselOptions(
                          scrollPhysics:
                              !controller.second.value && controller.slidePosition.value == 0 ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                          autoPlay: false,
                          height: controller.getImageSize(),
                          enlargeCenterPage: true,
                          enlargeFactor: .6,
                          enlargeStrategy: CenterPageEnlargeStrategy.height,
                          viewportFraction: 1,
                          initialPage: controller.playIndex.value,
                          onPageChanged: (index, a) => Future.delayed(const Duration(milliseconds: 300),() => controller.audioServeHandler.playIndex(index))),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: controller.slidePosition.value > 0 ? 0 : 1,
                duration: const Duration(milliseconds: 10),
                child: Padding(
                  padding: EdgeInsets.only(left: controller.panelHeaderSize),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.mediaItem.value.title,
                        style: TextStyle(fontSize: 28.sp, color: controller.getLightTextColor(), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 5.w)),
                      Text(
                        controller.mediaItem.value.artist ?? '',
                        style: TextStyle(fontSize: 22.sp, color: controller.getLightTextColor(), fontWeight: FontWeight.w500),
                        maxLines: 1,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          // child: PageView.builder(
          //   controller: controller.pageController1,
          //   physics: !controller.second.value && controller.slidePosition.value == 0 ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          //   onPageChanged: (index) {
          //     controller.audioServeHandler.playIndex(index);
          //   },
          //   itemBuilder: (context, index) => Stack(
          //     alignment: Alignment.centerLeft,
          //     children: [
          //       AnimatedPositioned(
          //           left: controller.getImageLeft(),
          //           duration: const Duration(milliseconds: 0),
          //           child: AnimatedScale(
          //             scale: 1 + (controller.slidePosition.value / (PlatformUtils.isIOS ? 7.6 : 7)),
          //             duration: const Duration(milliseconds: 100),
          //             child: SimpleExtendedImage(
          //               '${controller.mediaItems[index].extras?['image']}?param=500y500',
          //               fit: BoxFit.cover,
          //               height: controller.getImageSize(),
          //               width: controller.getImageSize(),
          //               borderRadius: BorderRadius.circular(controller.getImageSize() / 2 * (1 - (controller.slidePosition.value >= .8 ? .97 : controller.slidePosition.value))),
          //             ),
          //           )),
          //       AnimatedOpacity(
          //         opacity: controller.slidePosition.value > 0 ? 0 : 1,
          //         duration: const Duration(milliseconds: 10),
          //         child: Padding(
          //           padding: EdgeInsets.only(left: controller.panelHeaderSize),
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 controller.mediaItems[index].title,
          //                 style: TextStyle(fontSize: 28.sp, color: controller.getLightTextColor(), fontWeight: FontWeight.w500),
          //                 maxLines: 1,
          //                 overflow: TextOverflow.ellipsis,
          //               ),
          //               Padding(padding: EdgeInsets.symmetric(vertical: 5.w)),
          //               Text(
          //                 controller.mediaItems[index].artist ?? '',
          //                 style: TextStyle(fontSize: 22.sp, color: controller.getLightTextColor(), fontWeight: FontWeight.w500),
          //                 maxLines: 1,
          //               )
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          //   itemCount: controller.mediaItems.length,
          // ),
        ),
        Visibility(
          visible: controller.slidePosition.value == 0,
          child: IconButton(
              onPressed: () => controller.playOrPause(),
              icon: Icon(
                controller.playing.value ? TablerIcons.player_pause : TablerIcons.player_play,
                size: controller.playing.value ? 46.w : 42.w,
                color: controller.getLightTextColor(),
              )),
        ),
        Visibility(
          visible: controller.slidePosition.value == 0,
          child: IconButton(
              onPressed: () {
                if (controller.intervalClick(1)) controller.buttonCarouselController.jumpToPage(controller.playIndex.value + 1);
              },
              icon: Icon(
                TablerIcons.player_skip_forward,
                size: 40.w,
                color: controller.getLightTextColor(),
              )),
        )
      ],
    );
  }
}

class LeftMenu {
  String title;
  IconData icon;
  String path;
  String pathUrl;

  LeftMenu(this.title, this.icon, this.path, this.pathUrl);
}