import '../utils/shared_import.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  static String tag = '/WorkoutHistoryScreen';

  @override
  WorkoutHistoryScreenState createState() => WorkoutHistoryScreenState();
}

class WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<WorkoutHistoryData> workoutHistoryList = [];
  ScrollController scrollController = ScrollController();

  int page = 1;
  int? numPage;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
    // scrollController.addListener(() {
    //   if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
    //     if (page < numPage!) {
    //       page++;
    //       init();
    //     }
    //   }
    // });
  }

  void init() async {
    getUserWorkoutExercise();
  }

  Future<void> getUserWorkoutExercise() async {
    appStore.setLoading(true);
    await getUserWorkoutExerciseApi().then((value) {
      appStore.setLoading(false);
      Iterable it = value.data;
      it.map((e) => workoutHistoryList.add(e)).toList();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(languages.lblWOHtr, context: context),
        body: Stack(
          children: [
            workoutHistoryList.isNotEmpty
                ? AnimatedListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: workoutHistoryList.length,
                    itemBuilder: (context, index) {
                      var data = workoutHistoryList[index];
                      return Container(
                        decoration: appStore.isDarkMode ? boxDecorationWithRoundedCorners(borderRadius: radius(12)) : boxDecorationRoundedWithShadow(12),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 8),
                        margin: EdgeInsets.only(bottom: 8, top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                cachedImage(data.exerciseImage.validate(), width: 55, height: 55, fit: BoxFit.cover).cornerRadiusWithClipRRect(10),
                                12.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    6.height,
                                    Text(data.exerciseTitle.validate(), style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    6.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                "Workout:",
                                                style: secondaryTextStyle(),
                                              ),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  data.workoutTitle.validate(),
                                                  style: boldTextStyle(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (userStore.subscription == "1")
                                          if (data.exerciseIsPremium == 1) mPro(),
                                      ],
                                    ),
                                  ],
                                ).expand()
                              ],
                            ).expand(),
                          ],
                        ),
                      ).onTap(() async {
                        final result = userStore.subscription == "1"
                            ? data.exerciseIsPremium == 1
                                ? userStore.isSubscribe == 0
                                    ? await SubscribeScreen().launch(context)
                                    : await ExerciseDetailScreen(mExerciseName: data.exerciseTitle.validate(), mExerciseId: data.exerciseId.validate(), workOutId: data.workoutId.toString(), workoutDayId: data.workoutDayId, isCompleted: true, isFrom: 'workoutHistory').launch(context)
                                : await ExerciseDetailScreen(mExerciseName: data.exerciseTitle.validate(), mExerciseId: data.exerciseId.validate(), workOutId: data.workoutId.toString(), workoutDayId: data.workoutDayId, isCompleted: true, isFrom: 'workoutHistory').launch(context)
                            : await ExerciseDetailScreen(mExerciseName: data.exerciseTitle.validate(), mExerciseId: data.exerciseId.validate(), workOutId: data.workoutId.toString(), workoutDayId: data.workoutDayId, isCompleted: true, isFrom: 'workoutHistory').launch(context);
                        if (result == 'removeWorkout') {
                          setState(() {
                            workoutHistoryList.removeAt(index);
                          });
                        }
                      });
                    },
                  )
                : NoDataScreen(mTitle: languages.lblWorkoutNoFound).visible(!appStore.isLoading),
            Loader().center().visible(appStore.isLoading)
          ],
        ));
  }
}
