import 'package:mobx/mobx.dart';

import '../components/adMob_component.dart';
import '../utils/shared_import.dart';

class OtherUserProfileScreen extends StatefulWidget {
  const OtherUserProfileScreen({super.key,required this.userDetails});
  final Users userDetails;

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> with SingleTickerProviderStateMixin {


  String mFNameCont = "";
  String mLNameCont = "";
  String? profileImg = '';
  LikeComment likeComment = LikeComment();
  ScrollController scrollController = ScrollController();

  bool isBottomSheetOpen = false;

  late AnimationController _controller;
  final Map<int, PageController> _pageControllers = {};
  final Map<int, int> _currentPages = {};

  int page = 1;
  int? numPage;
  bool isLastPage = false;
  ObservableList<PostData> mPostList = ObservableList<PostData>();
  late List<ValueNotifier<bool>> heartVisibleList;
  bool shouldShowAds = false;
  final Post post = Post();
  ValueNotifier<int> likeChange = ValueNotifier(0);
  ValueNotifier<int> pageChange = ValueNotifier(0);
  ValueNotifier<int> bookMarkChange = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    shouldShowAds = userStore.showAdsOnListView == 1 && userStore.isSubscribe == 0 && !getNativeAdUnitId().isEmptyOrNull;
    mFNameCont = widget.userDetails.firstName??'';
    mLNameCont = widget.userDetails.lastName??'';
    profileImg = widget.userDetails.profileImage??'';
    getPostList();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
        if (page < numPage!) {
          page++;
          getPostList();
        }
      }
    });
  }

  @override
  void dispose()  {
    _controller.dispose();
    scrollController.dispose();
    _pageControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Widget profileImage() {
   if (!profileImg.isEmptyOrNull) {
      return Container(
        padding: EdgeInsets.all(1),
        decoration: boxDecorationWithRoundedCorners(
            boxShape: BoxShape.circle,
            border: Border.all(
                width: 2, color: primaryColor.withValues(alpha: 0.5))),
        child: cachedImage(profileImg, width: 90, height: 90, fit: BoxFit.cover)
            .cornerRadiusWithClipRRect(65),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(1),
        decoration: boxDecorationWithRoundedCorners(
            boxShape: BoxShape.circle,
            border: Border.all(
                width: 2, color: primaryColor.withValues(alpha: 0.5))),
        child: CircleAvatar(
            maxRadius: 60,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(ic_logo)),
      );
    }
  }

  Future<void> getPostList() async {
    appStore.setLoading(true);
    await getPostsApi(page: page, userId: widget.userDetails.id).then((value) {
      numPage = value.pagination!.totalPages;
      isLastPage = false;
      if (page == 1) {
        print("-------93>>>fddfdfdfdf");
        mPostList.clear();
      }
      Iterable it = value.data ?? [];
      it.map((e) => mPostList.add(e)).toList();
      heartVisibleList = List.generate(mPostList.length, (_) => ValueNotifier(false));
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e, s) {
      isLastPage = true;
      appStore.setLoading(false);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        appStore.isDarkMode ? Brightness.light : Brightness.light,
        systemNavigationBarIconBrightness:
        appStore.isDarkMode ? Brightness.light : Brightness.light,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          controller: scrollController,
            child: Stack(
              children: [
                Container(height: context.height() * 0.4, color: primaryColor),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                          appStore.selectedLanguageCode == 'ar'
                              ? MaterialIcons.arrow_forward_ios
                              : Octicons.chevron_left,
                          color: white,
                          size: 28)
                          .onTap(() {
                        Navigator.pop(context);
                      }),
                      16.width,
                      Text(languages.lblProfile,
                          style: boldTextStyle(size: 20, color: white)),
                    ],
                  ).paddingOnly(
                      top: context.statusBarHeight + 16,
                      left: 16,
                      right: appStore.selectedLanguageCode == 'ar' ? 16 : 0),
                ),
                Container(
                  margin: EdgeInsets.only(top: context.height() * 0.2),
                  height: context.height() * 0.4,
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radiusOnly(topRight: 16, topLeft: 16),
                      backgroundColor: appStore.isDarkMode
                          ? context.scaffoldBackgroundColor
                          : Colors.white),
                ),
                Column(children: [
                  16.height,
                  profileImage().paddingOnly(top: context.height() * 0.11).center(),
                  20.height,
                  profileRow(
                    label: languages.lblFirstName,
                    value: mFNameCont,
                  ).paddingSymmetric(horizontal: 8),
                  profileRow(
                    label: languages.lblLastName,
                    value: mLNameCont,
                  ).paddingSymmetric(horizontal: 8),
                  15.height,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Row(
                      children: [
                        Expanded(child: Divider(thickness: 0.7,color: primaryColor,)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            languages.lblPosts,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 0.7, color: primaryColor,)),
                      ],
                    ),
                  ),
                  if (mPostList.isNotEmpty) ...[
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: mPostList.length + (shouldShowAds ? (mPostList.length ~/ 4) : 0),
                      itemBuilder: (context, index) {
                        _pageControllers[index] ??= PageController();
                        if (shouldShowAds && index != 0 && index % 4 == 0) {
                          final adIndex = (index ~/ 4) - 1;
                          adLoaded[adIndex] ??= ValueNotifier(false);
                          adLoading[adIndex] ??= ValueNotifier(false);
                          if (!ads.containsKey(adIndex) && adLoading[adIndex]!.value != true) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              loadAd(adIndex, shouldShowAds, false);
                            });
                          }
                          return ValueListenableBuilder<bool>(
                            valueListenable: adLoaded[adIndex]!,
                            builder: (context, loaded, _) {
                              if (!loaded) {
                                return buildAdPlaceholder();
                              }
                              return SizedBox(
                                height: 250,
                                child: AdWidget(ad: ads[adIndex]!),
                              );
                            },
                          );
                        }
                        final realIndex = shouldShowAds ? index - (index ~/ 4) : index;
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 1, vertical: 6),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  cachedImage(
                                    mPostList[realIndex].users?.profileImage ?? '',
                                    fit: BoxFit.cover,
                                    height: 40,
                                    width: 40,
                                  ).cornerRadiusWithClipRRect(20),
                                  8.width,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(mPostList[realIndex].users?.displayName ?? '', style: boldTextStyle(size: 16), maxLines: 3),
                                      5.height,
                                      Text("${languages.posted} ${mPostList[realIndex].createdAt}",
                                          style: secondaryTextStyle(
                                            size: 12,
                                            color: textSecondaryColorGlobal,
                                          )
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  PopupMenuButton<int>(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: primaryOpacity,
                                    itemBuilder: (context) => [
                                      if (mPostList[realIndex].users?.id != userStore.userId) ...[
                                        PopupMenuItem(
                                            height: 38,
                                            onTap: () {
                                              post.showAnimatedDialog(context, mPostList[realIndex].id, (){getPostList();});
                                            },
                                            value: 1,
                                            child: Text(
                                              languages.lblReportPost,
                                              style: primaryTextStyle(color: scaffoldColorDark),
                                            )),
                                      ],
                                      if (mPostList[realIndex].users?.id == userStore.userId) ...[
                                        PopupMenuItem(
                                            height: 38,
                                            onTap: () async {
                                              var data = await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => AddPostScreen(flow: 'EditFlow', postData: mPostList[realIndex])),
                                              );
                                              if (data == "refresh") {
                                                mPostList.clear();
                                                page = 1;
                                                getPostList();
                                              }
                                            },
                                            value: 2,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.pen,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                6.width,
                                                Text(
                                                  languages.lblEditPost,
                                                  style: primaryTextStyle(color: scaffoldColorDark),
                                                ),
                                              ],
                                            )),
                                        PopupMenuItem<int>(
                                          enabled: false,
                                          height: 1,
                                          padding: EdgeInsets.zero,
                                          child: Container(
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PopupMenuItem(
                                            height: 38,
                                            onTap: () {
                                              showConfirmDialogCustom(context, dialogType: DialogType.DELETE, title: languages.lblDeletePost, primaryColor: primaryColor, positiveText: languages.lblDelete, image: ic_delete, onAccept: (buildContext) {
                                                post.deletePost(mPostList[realIndex].id, mPostList);
                                              });
                                            },
                                            value: 3,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.black,
                                                ),
                                                6.width,
                                                Text(
                                                  languages.lblDelPost,
                                                  style: primaryTextStyle(color: scaffoldColorDark),
                                                ),
                                              ],
                                            ))
                                      ],
                                    ],
                                    child: Image.asset(ic_menu, height: 24, width: 24, color: primaryColor),
                                  ),
                                ],
                              ).paddingSymmetric(horizontal: 10, vertical: 16),
                              ValueListenableBuilder(
                                  valueListenable: likeChange,
                                  builder: (context, value, child) {
                                    return GestureDetector(
                                      onDoubleTap: () async {
                                        mPostList[realIndex].isLiked = !(mPostList[realIndex].isLiked ?? false);
                                        if (mPostList[realIndex].isLiked.validate()) {
                                          mPostList[realIndex].postingLikeCount = mPostList[realIndex].postingLikeCount.validate() + 1;
                                          heartVisibleList[realIndex].value = true;
                                          Future.delayed(Duration(seconds: 1), () {
                                            heartVisibleList[realIndex].value = false;
                                          });
                                        } else {
                                          mPostList[realIndex].postingLikeCount = mPostList[realIndex].postingLikeCount.validate() - 1;
                                        }
                                        likeChange.value++;
                                        await post.likePost(mPostList[realIndex].id);
                                        _controller.forward(from: 0.0);
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (mPostList[realIndex].postingMediaArray!.isNotEmpty) ...[
                                                ValueListenableBuilder(
                                                    valueListenable: pageChange,
                                                    builder: (context, value, child) {
                                                      return Column(
                                                        children: [
                                                          if (mPostList[realIndex].postingMediaArray != null && mPostList[realIndex].postingMediaArray!.isNotEmpty)
                                                            LayoutBuilder(builder: (context, constraints) {
                                                              double size = constraints.maxWidth;
                                                              return SizedBox(
                                                                height: size,
                                                                width: size,
                                                                child: PageView.builder(
                                                                  controller: _pageControllers[realIndex],
                                                                  onPageChanged: (page) {
                                                                    _currentPages[realIndex] = page;
                                                                    pageChange.value++;
                                                                  },
                                                                  itemCount: mPostList[realIndex].postingMediaArray!.length,
                                                                  itemBuilder: (context, mediaIndex) {
                                                                    final media = mPostList[realIndex].postingMediaArray![mediaIndex];
                                                                    if (media.mimeType == "image/jpeg" || media.mimeType == "image/png") {
                                                                      return cachedImage(
                                                                        media.url,
                                                                        height: size,
                                                                        width: size,
                                                                        fit: BoxFit.cover,
                                                                      ).cornerRadiusWithClipRRect(10).onTap(() async {
                                                                        List<String> urls = [];
                                                                        mPostList[realIndex].postingMediaArray?.forEach((e) {
                                                                          urls.add(e.url.validate());
                                                                        });
                                                                        post.showFullScreenDialog(
                                                                          context,
                                                                          urls,
                                                                          mPostList[realIndex].users?.displayName ?? '',
                                                                          realIndex,
                                                                        );
                                                                      }).paddingSymmetric(horizontal: 10);
                                                                    } else {
                                                                      return AspectRatio(
                                                                        aspectRatio: 16 / 9,
                                                                        child: ChewieScreen(
                                                                          url: media.url ?? '',
                                                                          image: "",
                                                                          autoPlay: true,
                                                                        ),
                                                                      ).onTap(() async {
                                                                        List<String> urls = [];
                                                                        mPostList[realIndex].postingMediaArray?.forEach((e) {
                                                                          urls.add(e.url.validate());
                                                                        });
                                                                        post.showFullScreenDialog(
                                                                          context,
                                                                          urls,
                                                                          mPostList[realIndex].users?.displayName ?? '',
                                                                          realIndex,
                                                                        );
                                                                      }).paddingSymmetric(horizontal: 10);
                                                                    }
                                                                  },
                                                                ),
                                                              );
                                                            }),
                                                          7.height,
                                                          SmoothPageIndicator(
                                                            controller: _pageControllers[realIndex]!,
                                                            count: mPostList[realIndex].postingMediaArray!.length,
                                                            effect: ExpandingDotsEffect(
                                                              dotHeight: 5,
                                                              dotWidth: 5,
                                                              activeDotColor: primaryColor,
                                                            ),
                                                          ).visible(mPostList[realIndex].postingMediaArray!.length > 1)
                                                        ],
                                                      );
                                                    }),
                                              ],
                                              Container(
                                                width: double.infinity,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                  child: ExpandableLinkify(
                                                    text: mPostList[realIndex].description ?? '',
                                                    style: primaryTextStyle(size: 16),
                                                    linkStyle: TextStyle(
                                                      color: primaryColor,
                                                      decoration: TextDecoration.none,
                                                    ),
                                                  ),
                                                ),
                                              ).visible(!mPostList[realIndex].description.isEmptyOrNull),
                                            ],
                                          ),
                                          // Heart animation overlay
                                          ValueListenableBuilder<bool>(
                                            valueListenable: heartVisibleList[realIndex],
                                            builder: (context, isVisible, _) {
                                              return IgnorePointer(
                                                ignoring: !isVisible,
                                                child: AnimatedOpacity(
                                                  opacity: isVisible ? 1.0 : 0.0,
                                                  duration: Duration(milliseconds: 300),
                                                  child: Icon(Icons.favorite, color: Colors.redAccent, size: 100),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              Divider(
                                thickness: 0.25,
                              ).paddingSymmetric(horizontal: 8),
                              4.height,
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ValueListenableBuilder(
                                      valueListenable: likeChange,
                                      builder: (context, value, child) {
                                        return Image.asset(
                                          mPostList[realIndex].isLiked.validate() ? ic_like_filled : ic_like,
                                          color: mPostList[realIndex].isLiked.validate()
                                              ? Colors.red
                                              : appStore.isDarkMode
                                              ? GreyLightColor
                                              : Colors.black,
                                          height: 21,
                                          width: 21,
                                        ).onTap(() async {
                                          mPostList[realIndex].isLiked = !(mPostList[realIndex].isLiked ?? false);
                                          if (mPostList[realIndex].isLiked.validate()) {
                                            mPostList[realIndex].postingLikeCount = mPostList[realIndex].postingLikeCount.validate() + 1;
                                          } else {
                                            mPostList[realIndex].postingLikeCount = mPostList[realIndex].postingLikeCount.validate() - 1;
                                          }
                                          likeChange.value++;
                                          await post.likePost(mPostList[realIndex].id);
                                        });
                                      }),
                                  5.width,
                                  GestureDetector(
                                    onTap: () async {
                                      if (mPostList[realIndex].postingLikeCount != 0) {
                                        if (isBottomSheetOpen) return;
                                        isBottomSheetOpen = true;
                                        likeComment.mLikeList.clear();
                                        likeComment.pageLike = 1;
                                        likeComment.bottomSheetForLike(realIndex, mPostList[realIndex].id, mPostList[realIndex].users?.id ?? 0,context, isFirstTime: true);
                                        await  likeComment.likesList(mPostList[realIndex].id, isFirstTime: true);
                                        isBottomSheetOpen = false;
                                      }
                                    },
                                    child: ValueListenableBuilder(
                                        valueListenable: likeChange,
                                        builder: (context, value, child) {
                                          return Row(
                                            children: [
                                              Text('${(mPostList[realIndex].postingLikeCount ?? 0)}', style: primaryTextStyle(size: 17)),
                                              Text((mPostList[realIndex].postingLikeCount! <= 1) ? ' ${languages.lblLike}' : ' ${languages.lblLikes}', style: secondaryTextStyle(size: 15, color: textSecondaryColorGlobal)),
                                            ],
                                          );
                                        }),
                                  ),
                                  15.width,
                                  GestureDetector(
                                    onTap: () async {
                                      if (isBottomSheetOpen) return;
                                      isBottomSheetOpen = true;
                                      likeComment.mCommentList.clear();
                                      likeComment.pageComment = 1;
                                      likeComment.bottomSheetBuilder(
                                        realIndex,
                                        mPostList[realIndex].id,
                                        mPostList[realIndex].users?.id ?? 0,
                                        mPostList[realIndex].canEdit.validate(),
                                        context,
                                        mPostList,
                                        isFirstTime: true,
                                      );
                                      await likeComment.commentList(mPostList[realIndex].id, isFirstTime: true);
                                      isBottomSheetOpen = false;
                                    },
                                    child: SizedBox(
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            ic_comment,
                                            height: 20,
                                            width: 20,
                                            color: appStore.isDarkMode ? GreyLightColor : Colors.black,
                                          ),
                                          5.width,
                                          Text('${(mPostList[realIndex].postingCommentCount ?? 0)}', style: primaryTextStyle(size: 17)),
                                          Text((mPostList[realIndex].postingCommentCount! <= 1) ? ' ${languages.lblCmt}' : ' ${languages.lblComments}', style: secondaryTextStyle(size: 15, color: textSecondaryColorGlobal)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  15.width,
                                  GestureDetector(
                                    onTap: () async {
                                      String postLink = '${mBackendURL}/post/${mPostList[realIndex].id}';
                                      Share.share('${languages.checkOutPost} $postLink');
                                    },
                                    child: SizedBox(
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            ic_share_community,
                                            height: 20,
                                            width: 20,
                                            color: appStore.isDarkMode ? GreyLightColor : Colors.black,
                                          ),
                                          5.width,
                                          Text(languages.share, style: secondaryTextStyle(size: 15, color: textSecondaryColorGlobal))
                                        ],
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  ValueListenableBuilder(
                                      valueListenable: bookMarkChange,
                                      builder: (context, value, child) {
                                        return Image.asset(mPostList[realIndex].isBookmark ?? false ? ic_save_filled : ic_save, color: appStore.isDarkMode ? GreyLightColor : Colors.black, height: 20, width: 20).onTap(() async {
                                          mPostList[realIndex].isBookmark = !(mPostList[realIndex].isBookmark ?? false);
                                          bookMarkChange.value++;
                                          await post.bookMarkPost(mPostList[realIndex].id);
                                        });
                                      }),
                                ],
                              ).paddingSymmetric(horizontal: 10),
                              10.height,
                            ],
                          ),
                        );
                      },
                    ),
                    8.height,
                  ] else ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        26.height,
                        Image.asset(no_data_found, height: context.height() * 0.2, width: context.width() * 0.4),
                        16.height,
                        Text(languages.lblNoPost, style: boldTextStyle()),
                      ],
                    ).center().visible(!appStore.isLoading)
                  ],

                    ],
                ).paddingSymmetric(horizontal: 6),
                if (appStore.isLoading)
                  Positioned.fill(
                    child: Container(
                      height: context.height() * 0.5,
                      child: Loader().center(),
                    ),
                  ),
              ],
            ),
        ),
      ),
    );
  }


  Widget profileRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + " :",
              style: primaryTextStyle(
                weight: FontWeight.w700,
                size: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: secondaryTextStyle(
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

