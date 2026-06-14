import '../utils/shared_import.dart';

class ExerciseListScreen extends StatefulWidget {
  final bool? isBodyPart;
  final bool? isLevel;
  final bool? isEquipment;

  final String? mTitle;

  final int? id;

  ExerciseListScreen({this.mTitle, this.isBodyPart = false, this.isLevel = false, this.isEquipment = false, this.id});

  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> with SingleTickerProviderStateMixin{
  late ScrollController exerciseScrollController;
  late ScrollController workoutScrollController;

  late TextEditingController searchCont;

  List<ExerciseModel> mExerciseList = [];
  List<WorkoutDetailModel> mWorkoutList = [];

  int exercisePage = 1;
  int? exerciseNumPage;
  bool isExerciseLastPage = false;

  int workoutPage = 1;
  int? workoutNumPage;
  bool isWorkoutLastPage = false;

  bool isSearch = false;
  String? mSearchValue = "";

  late VoidCallback _exerciseScrollListener;
  late VoidCallback _workoutScrollListener;
  late TabController _tabController;


  List<String> tabs = ['Exercises', 'Workouts'];

  @override
  void initState() {
    super.initState();

    exerciseScrollController = ScrollController();
    workoutScrollController = ScrollController();
    searchCont = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);

    _exerciseScrollListener = () {
      if (!mounted) return;
      if (exerciseScrollController.position.pixels >= exerciseScrollController.position.maxScrollExtent - 200) {
        if (!appStore.isLoading && !isExerciseLastPage && exercisePage < (exerciseNumPage ?? 1)) {
          exercisePage++;
          getExerciseData();
        }
      }
    };

    _workoutScrollListener = () {
      if (!mounted) return;
      if (workoutScrollController.position.pixels >= workoutScrollController.position.maxScrollExtent - 200) {
        if (!appStore.isLoading && !isWorkoutLastPage && workoutPage < (workoutNumPage ?? 1)) {
          workoutPage++;
          getLevelWorkoutData();
        }
      }
    };

    exerciseScrollController.addListener(_exerciseScrollListener);
    workoutScrollController.addListener(_workoutScrollListener);

    init();
  }

  void init() async {
    getExerciseData();
    getLevelWorkoutData();
  }

  Future<void> getExerciseData() async {
    appStore.setLoading(true);
    await getExerciseApi(page: exercisePage, mSearchValue: mSearchValue, id: widget.id.validate(), isBodyPart: widget.isBodyPart, isEquipment: widget.isEquipment, isLevel: widget.isLevel).then((value) {
      if (!mounted) return;
      appStore.setLoading(false);
      exerciseNumPage = value.pagination!.totalPages;
      isExerciseLastPage = false;
      if (exercisePage == 1) {
        mExerciseList.clear();
      }
      Iterable it = value.data!;
      it.map((e) => mExerciseList.add(e)).toList();
      setState(() {});
    }).catchError((e) {
      if (!mounted) return;
      isExerciseLastPage = true;
      appStore.setLoading(false);
      setState(() {});
    });
  }

  Future<void> getLevelWorkoutData() async {
    appStore.setLoading(true);
    await getLevelWorkoutApi(page: workoutPage, mSearchValue: mSearchValue, id: widget.id.validate()).then((value) {
      if (!mounted) return;
      appStore.setLoading(false);
      workoutNumPage = value.pagination!.totalPages;
      isWorkoutLastPage = false;
      if (workoutPage == 1) {
        mWorkoutList.clear();
      }
      Iterable it = value.data!;
      it.map((e) => mWorkoutList.add(e)).toList();
      setState(() {});
    }).catchError((e) {
      if (!mounted) return;
      isWorkoutLastPage = true;
      appStore.setLoading(false);
      setState(() {});
    });
  }

  @override
  void dispose() {
    exerciseScrollController.removeListener(_exerciseScrollListener);
    exerciseScrollController.dispose();
    searchCont.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = context.width();
    var height = 185.0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBarWidget(
          isSearch ? "" : widget.mTitle.validate().capitalizeFirstLetter(),
          context: context,
          actions: [
            AnimatedContainer(
              margin: EdgeInsets.only(left: 8, top: 4),
              duration: Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (isSearch)
                    TextField(
                      autofocus: true,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: primaryColor,
                      controller: searchCont,
                      onChanged: (v) {
                        mSearchValue = v;
                        mExerciseList.clear();
                        if (_tabController.index == 0) {
                          exercisePage = 1;
                          getExerciseData();
                        } else {
                          workoutPage = 1;
                          getLevelWorkoutData();
                        }
                      },
                      onSubmitted: (v) {
                        setState(() {
                          mSearchValue = v;
                          mExerciseList.clear();
                          if (_tabController.index == 0) {
                            exercisePage = 1;
                            getExerciseData();
                          } else {
                            workoutPage = 1;
                            getLevelWorkoutData();
                          }
                        });
                      },
                      style: primaryTextStyle(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: languages.lblSearch,
                        hintStyle: primaryTextStyle(),
                      ),
                    ).paddingBottom(10).expand(),
                  IconButton(
                    icon: isSearch ? Icon(Icons.close) : Image.asset(ic_search, height: 20, width: 20, color: primaryColor),
                    onPressed: () async {
                      isSearch = !isSearch;
                      mSearchValue = "";
                      if (!searchCont.text.isEmptyOrNull) {
                        exercisePage = 1;
                        if (_tabController.index == 0) {
                          exercisePage = 1;
                          getExerciseData();
                        } else {
                          workoutPage = 1;
                          getLevelWorkoutData();
                        }
                      }
                      searchCont.clear();
                      setState(() {});
                    },
                    color: primaryColor,
                  )
                ],
              ),
              width: isSearch ? context.width() - 80 : 50,
            ),
          ],
        ),
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryColor,
              tabs: [
                Tab(text: 'Exercises'),
                Tab(text: 'Workouts'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  /// ---------------- EXERCISES TAB ----------------
                  Stack(
                    children: [
                      mExerciseList.isNotEmpty
                          ? AnimatedListView(
                              controller: exerciseScrollController,
                              itemCount: mExerciseList.length,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ExerciseComponent(
                                  mExerciseModel: mExerciseList[index],
                                );
                              },
                            )
                          : NoDataScreen(
                              mTitle: languages.lblExerciseNoFound,
                            ).visible(!appStore.isLoading),
                      Observer(builder: (context) {
                        return Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                          child: Loader().center(),
                        ).visible(appStore.isLoading);
                      }),
                    ],
                  ),

                  /// ---------------- WORKOUT TAB ----------------
                  Stack(
                    children: [
                      mWorkoutList.isNotEmpty
                          ? AnimatedListView(
                              controller: workoutScrollController,
                              itemCount: mWorkoutList.length,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              shrinkWrap: true,
                              itemBuilder: (context, i) {
                                return InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onTap: () async {
                                    final workout = mWorkoutList[i];
                                    final bool isSubscriptionEnabled = userStore.subscription == "1";
                                    final bool isPremiumWorkout = workout.isPremium == 1;
                                    final bool isUserSubscribed = userStore.isSubscribe == 1;

                                    if (isSubscriptionEnabled && isPremiumWorkout && !isUserSubscribed) {
                                      await SubscribeScreen().launch(context);
                                      return;
                                    }
                                    await WorkoutDetailScreen(
                                      id: workout.id,
                                      mWorkoutModel: workout,
                                      onCall: (status) {
                                        print("Workout callback status: $status");
                                        mWorkoutList.clear();
                                      },
                                    ).launch(context);
                                  },
                                  child: Stack(
                                    children: [
                                      cachedImage(mWorkoutList[i].workoutImage.validate(), height: height, fit: BoxFit.cover, width: width).cornerRadiusWithClipRRect(16),
                                      mBlackEffect(width, height, radiusValue: 16),
                                      Positioned(
                                        left: 16,
                                        top: 8,
                                        right: 12,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            userStore.subscription == "1"
                                                ? mWorkoutList[i].isPremium == 1
                                                ? mPro()
                                                : SizedBox()
                                                : SizedBox(),
                                            Container(
                                                decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.white.withValues(alpha: 0.5), boxShape: BoxShape.circle),
                                                padding: EdgeInsets.all(5),
                                                child: Image.asset(
                                                  mWorkoutList[i].isFavouriteLocally == 1 || mWorkoutList[i].isFavourite == 1 ? ic_favorite_fill : ic_favorite,
                                                  color: mWorkoutList[i].isFavouriteLocally == 1 || mWorkoutList[i].isFavourite == 1 ? primaryColor : white,
                                                  width: 20,
                                                  height: 20,
                                                ).center())
                                                .onTap(() {
                                              if (mWorkoutList[i].isFavourite == 0 && (mWorkoutList[i].isFavouriteLocally == null || mWorkoutList[i].isFavouriteLocally == 0)) {
                                                mWorkoutList[i].isFavouriteLocally = 1;
                                                mWorkoutList[i].isFavourite = 1;
                                              } else {
                                                mWorkoutList[i].isFavouriteLocally = 0;
                                                mWorkoutList[i].isFavourite = 0;
                                              }
                                              print("-------358>>${mWorkoutList[i].isFavouriteLocally}");
                                              setState(() {});
                                              // setWorkout(mWorkoutList[i].id.validate(), mWorkoutList[i].isFavourite);
                                            }),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        left: 16,
                                        right: 16,
                                        bottom: 16,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(mWorkoutList[i].title.capitalizeFirstLetter().validate(), style: boldTextStyle(color: white)),
                                            2.height,
                                            Row(
                                              children: [
                                                Container(margin: EdgeInsets.only(right: 6), height: 6, width: 6, decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: white)),
                                                Text('${mWorkoutList[i].workoutTypeTitle.validate()}', style: secondaryTextStyle(color: white)),
                                                8.width,
                                                Container(height: 14, width: 2, color: primaryColor),
                                                8.width,
                                                Text(mWorkoutList[i].levelTitle.validate(), style: secondaryTextStyle(color: white)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ).paddingBottom(16),
                                );
                              },
                            )
                          : NoDataScreen(
                              mTitle: languages.lblWorkoutNoFound,
                            ).visible(!appStore.isLoading),
                      Observer(builder: (context) {
                        return Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                          child: Loader().center(),
                        ).visible(appStore.isLoading);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
