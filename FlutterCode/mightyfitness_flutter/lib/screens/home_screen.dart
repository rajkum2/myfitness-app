import '../components/adMob_component.dart';
import '../utils/shared_import.dart';
import '../widget/tracking_card.dart';

bool? isFirstTimeGraph = false;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController mScrollController = ScrollController();
  TextEditingController mSearchCont = TextEditingController();
  String? mSearchValue = "";
  bool _showClearButton = false;
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool shouldShowAds = false;
  StepController stepController = StepController();
  WaterController waterController = WaterController();

  @override
  void initState() {
    shouldShowAds = userStore.showAdsOnBanner == 1 && userStore.isSubscribe == 0 && !getNativeAdUnitId().isEmptyOrNull;
    Future.delayed(Duration.zero).then((val) {
      print("------------75>>>>${getBoolAsync(CRISP_CHAT_ENABLED)}");
      getUserDetailsApiCall();
      // if (isFirstTimeGraph == false) {
      //   graphGet();
      // }
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: appStore.isDarkMode ? Colors.black : Colors.white,
      statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
    ));
    super.initState();
    if (userStore.isLoggedIn) {
      stepController.init();
      waterController.init();
      stepController.start();
    }
  }

  getUserDetailsApiCall() async {
    await getUSerDetail(context, userStore.userId).whenComplete(() {});
  }

  @override
  void dispose() {
    for (final ad in ads.values) {
      ad.dispose();
    }
    ads.clear();
    adLoaded.clear();
    adLoading.clear();
    super.dispose();
  }

  init() async {
    double weightInPounds = userStore.weight.toDouble();
    double weightInKilograms = poundsToKilograms(weightInPounds);
    var saveWeightGraph = userStore.weightStoreGraph.replaceAll('user', '').trim();

    print("------------175>>>>${weightInKilograms.toStringAsFixed(2)}");
    print("------------176>>>>${saveWeightGraph}");
    print("------------177>>>>${userStore.weight}");

    //visible(getStringAsync(TERMS_SERVICE).isNotEmpty)
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mHeading(String? title, {bool? isSeeAll = false, Function? onCall}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title ?? '', style: boldTextStyle(size: 18)).paddingSymmetric(horizontal: 16),
        IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(Feather.chevron_right, color: primaryColor),
            onPressed: () {
              onCall!.call();
            }).paddingRight(2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appStore.selectedLanguageCode == 'ar' ? 85 : 70),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Observer(builder: (context) {
                  return Container(decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, border: Border.all(color: primaryColor, width: 1)), child: cachedImage(userStore.profileImage.validate(), width: 42, height: 42, fit: BoxFit.cover).cornerRadiusWithClipRRect(100).paddingAll(1))
                      .onTap(() {
                    EditProfileScreen().launch(context);
                  });
                }).visible(userStore.isLoggedIn),
                10.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(languages.lblHey + userStore.fName.validate().capitalizeFirstLetter() + " " + userStore.lName.capitalizeFirstLetter() + "👋", style: boldTextStyle(size: 18), overflow: TextOverflow.ellipsis, maxLines: 2),
                    appStore.selectedLanguageCode == 'ar ' ? 0.height : 2.height,
                    Text(languages.lblHomeWelMsg, style: secondaryTextStyle()),
                  ],
                ).expand(),
              ],
            ).expand(),
            Container(
              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(16), border: Border.all(color: appStore.isDarkMode ? Colors.white : context.dividerColor.withValues(alpha: 0.9), width: 0.6), backgroundColor: appStore.isDarkMode ? context.scaffoldBackgroundColor : Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Image.asset(ic_notification, width: 24, height: 24, color: appStore.isDarkMode ? Colors.white : Colors.grey),
            ).onTap(
              () {
                NotificationScreen().launch(context);
              },
            )
          ],
        ).paddingOnly(top: context.statusBarHeight + 16, left: 16, right: 16, bottom: 6),
      ),
      body: RefreshIndicator(
        backgroundColor: context.scaffoldBackgroundColor,
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 1),
            () {
              setState(() {});
            },
          );
        },
        child: FutureBuilder(
          future: getDashboardApi(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              DashboardResponse? mDashboardResponse = snapshot.data;
              userStore.setSubscription(mDashboardResponse?.subscription ?? '');

              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        5.height,
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: Marquee(
                            text: languages.lblHomeScreenTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 20.0,
                            velocity: 50.0,
                            pauseAfterRound: const Duration(seconds: 1),
                          ),
                        ).onTap(
                          () {
                            EditProfileScreen().launch(context);
                          },
                        )
                      ],
                    ).visible(userStore.weight.isEmptyOrNull && userStore.isLoggedIn),
                    16.height.visible(!userStore.weight.isEmptyOrNull),
                    GestureDetector(
                      onTap: () {
                        hideKeyboard(context);
                        if (userStore.isLoggedIn) {
                          SearchScreen().launch(context);
                        } else {
                          SignInScreen().launch(context);
                        }
                      },
                      child: AbsorbPointer(
                        child: AppTextField(
                          controller: mSearchCont,
                          textFieldType: TextFieldType.OTHER,
                          isValidationRequired: false,
                          autoFocus: false,
                          suffix: _getClearButton(),
                          decoration: defaultInputDecoration(context, label: languages.lblSearch, isFocusTExtField: true),
                        ).paddingSymmetric(horizontal: 16),
                      ),
                    ),
                    16.height,
                    if (mDashboardResponse!.bannerSlider != null && mDashboardResponse.bannerSlider!.isNotEmpty)
                      Container(
                        height: 180,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: mDashboardResponse.bannerSlider!.length + (shouldShowAds ? (mDashboardResponse.bannerSlider!.length ~/ 4) : 0),
                          onPageChanged: (index) {
                            setState(() => _currentIndex = index);
                          },
                          itemBuilder: (context, i) {
                            if (shouldShowAds && i != 0 && i % 4 == 0) {
                              final adIndex = (i ~/ 4) - 1;
                              adLoaded[adIndex] ??= ValueNotifier(false);
                              adLoading[adIndex] ??= ValueNotifier(false);
                              if (!ads.containsKey(adIndex) && adLoading[adIndex] != true) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  loadAd(adIndex, shouldShowAds, true);
                                });
                              }
                              return ValueListenableBuilder<bool>(
                                valueListenable: adLoaded[adIndex]!,
                                builder: (context, loaded, _) {
                                  if (!loaded) {
                                    return buildAdPlaceholder();
                                  }
                                  return SizedBox(
                                    height: 200,
                                    child: AdWidget(ad: ads[adIndex]!),
                                  );
                                },
                              );
                            }

                            final index = shouldShowAds ? i - (i ~/ 4) : i;
                            return GestureDetector(
                              onTap: () {
                                WorkoutDetailScreen(id: mDashboardResponse.bannerSlider![index].id).launch(context);
                              },
                              child: cachedImage(mDashboardResponse.bannerSlider![index].bannersliderImage ?? '', height: 140, fit: BoxFit.cover).cornerRadiusWithClipRRect(16),
                            );
                          },
                        ),
                      ),
                    if (mDashboardResponse.bannerSlider != null && mDashboardResponse.bannerSlider!.isNotEmpty) const SizedBox(height: 8),
                    if (mDashboardResponse.bannerSlider != null && mDashboardResponse.bannerSlider!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          mDashboardResponse.bannerSlider!.length + (shouldShowAds ? (mDashboardResponse.bannerSlider!.length ~/ 4) : 0),
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 22 : 10,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == index ? primaryColor : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    16.height,
                    Text(languages.lblDailyTracking, style: boldTextStyle(size: 18)).paddingSymmetric(horizontal: 16),
                    12.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: stepController.steps,
                          builder: (context, steps, _) {
                            debugPrint('---daily goal value-----${stepController.dailyGoal}');
                            double dailyGoal = double.parse(stepController.dailyGoal.toString());
                            double progress = (steps / dailyGoal).clamp(0.0, 1.0);

                            return GestureDetector(
                              onTap: () {
                                if (userStore.isLoggedIn) {
                                  StepsCountScreen().launch(context);
                                } else {
                                  SignInScreen().launch(context);
                                }
                              },
                              child: TrackingCard(
                                background: const Color(0xFFFFF3EC),
                                progressColor: const Color(0xFFFF7A2B),
                                subtitle: languages.lblStpCnt,
                                value: "$steps",
                                label: languages.lblSteps,
                                progress: progress,
                                icon: Icons.directions_walk,
                              ),
                            );
                          },
                        ).expand(),
                        SizedBox(width: 10),
                        ValueListenableBuilder(
                            valueListenable: waterController.updateUI,
                            builder: (context, value, child) {
                              return GestureDetector(
                                onTap: () {
                                  if (userStore.isLoggedIn) {
                                    WaterTrackerScreen().launch(context).then(
                                      (value) {
                                        waterController.init();
                                      },
                                    );
                                  } else {
                                    SignInScreen().launch(context);
                                  }
                                },
                                child: TrackingCard(
                                  background: const Color(0xFFFFF3EC),
                                  progressColor: const Color(0xFF18A6FF),
                                  subtitle: languages.lblWtrInt,
                                  value: "${waterController.consumed}",
                                  label: languages.lblGlass,
                                  progress: (waterController.consumed / waterController.dailyGoal).clamp(0.0, 1.0),
                                  icon: Icons.water_drop,
                                ),
                              );
                            }).expand(),
                      ],
                    ).paddingSymmetric(horizontal: 16),
                    if (userStore.isLoggedIn && mDashboardResponse.assignedWorkout!.isNotEmpty) ...[
                      10.height,
                      mHeading(languages.assignedWorkouts, onCall: () {
                        ViewWorkoutsScreen(isAssign: true).launch(context);
                      }),
                      HorizontalList(
                        physics: BouncingScrollPhysics(),
                        itemCount: mDashboardResponse.assignedWorkout!.length,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        spacing: 16,
                        itemBuilder: (context, index) {
                          return WorkoutComponent(
                            mWorkoutModel: mDashboardResponse.assignedWorkout![index],
                            onCall: () {
                              appStore.setLoading(true);
                              setState(() {});
                              appStore.setLoading(false);
                            },
                          );
                        },
                      ),
                    ],
                    16.height,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mHeading(languages.lblBodyPartExercise, onCall: () {
                          if (userStore.isLoggedIn) {
                            ViewBodyPartScreen().launch(context);
                          } else {
                            SignInScreen().launch(context);
                          }
                        }),
                        HorizontalList(
                          physics: BouncingScrollPhysics(),
                          controller: mScrollController,
                          itemCount: mDashboardResponse!.bodypart!.length,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          spacing: 16,
                          itemBuilder: (context, index) {
                            return BodyPartComponent(bodyPartModel: mDashboardResponse.bodypart![index]);
                          },
                        ),
                      ],
                    ).visible(mDashboardResponse.bodypart!.isNotEmpty),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        10.height,
                        mHeading(languages.lblEquipmentsExercise, onCall: () {
                          if (userStore.isLoggedIn) {
                            ViewEquipmentScreen().launch(context);
                          } else {
                            SignInScreen().launch(context);
                          }
                        }),
                        HorizontalList(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: mDashboardResponse.equipment?.length ?? 0,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          spacing: 16,
                          itemBuilder: (context, index) {
                            return EquipmentComponent(mEquipmentModel: mDashboardResponse.equipment![index]);
                          },
                        ),
                      ],
                    ).visible(mDashboardResponse.equipment!.isNotEmpty),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        10.height,
                        mHeading(languages.lblWorkouts, onCall: () {
                          if (userStore.isLoggedIn) {
                            FilterWorkoutScreen().launch(context).then((value) {
                              setState(() {});
                            });
                          } else {
                            SignInScreen().launch(context);
                          }
                        }),
                        HorizontalList(
                          physics: BouncingScrollPhysics(),
                          itemCount: mDashboardResponse.workout!.length,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          spacing: 16,
                          itemBuilder: (context, index) {
                            return WorkoutComponent(
                              mWorkoutModel: mDashboardResponse.workout![index],
                              onCall: () {
                                appStore.setLoading(true);
                                setState(() {});
                                appStore.setLoading(false);
                              },
                            );
                          },
                        ),
                      ],
                    ).visible(mDashboardResponse.workout!.isNotEmpty),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        10.height,
                        mHeading(languages.lblLevels, onCall: () {
                          if (userStore.isLoggedIn) {
                            ViewLevelScreen().launch(context);
                          } else {
                            SignInScreen().launch(context);
                          }
                        }),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: mDashboardResponse.level!.length,
                          itemBuilder: (context, index) {
                            return LevelComponent(mLevelModel: mDashboardResponse.level![index]);
                          },
                        ),
                        16.height,
                      ],
                    ).visible(mDashboardResponse.level!.isNotEmpty)
                  ],
                ),
              );
            }
            return snapWidgetHelper(snapshot, loadingWidget: Container(height: mq.height, width: mq.width, color: Colors.transparent, child: Loader()));
          },
        ),
      ),
    );
  }

  Widget _getClearButton() {
    if (!_showClearButton) {
      return mSuffixTextFieldIconWidget(ic_search);
    }

    return IconButton(
      onPressed: () => mSearchCont.clear(),
      icon: Icon(Icons.clear),
    );
  }
}
