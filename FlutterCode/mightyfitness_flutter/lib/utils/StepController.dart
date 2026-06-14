import 'shared_import.dart';
import 'package:daily_pedometer2/daily_pedometer2.dart';

class StepController {
  static final StepController _instance = StepController._internal();
  factory StepController() => _instance;
  StepController._internal();
  bool isLoading = false;

  WaterChartFilter currentFilter = WaterChartFilter.week;

  ValueNotifier<int> updateUI = ValueNotifier(0);

  /// TODAY steps only
  final ValueNotifier<int> steps = ValueNotifier<int>(0);
  final ValueNotifier<int> totalSteps = ValueNotifier<int>(0);

  List<WaterGraphData> logList = [];

  StreamSubscription<StepCount>? _dailyStepSubscription;
  StreamSubscription<StepCount>? _totalStepSubscription;
  DateTime? _lastApiCallTime;

  Timer? _inactivityTimer;
  int _lastStepsSent = 0;

  static const int inactivitySeconds = 10; // tweak as needed


  int dailyGoal = 0;

  /// Start pedometer (daily steps only)
  void start() {
    if (_dailyStepSubscription != null) return;
    if (_totalStepSubscription != null) return;

    _dailyStepSubscription =
        DailyPedometer2.dailyStepCountStream.listen(
          onDailyStepCount,
          onError: (e) => debugPrint("Daily step error: $e"),
        );
    _totalStepSubscription = DailyPedometer2.stepCountStream.listen(
      totalStepsCount,
      onError: (e) => debugPrint("Total step error: $e"),
    );
  }

  void totalStepsCount(StepCount event)async{
    debugPrint('----Total Steps---${event.steps}-----');
    totalSteps.value = event.steps;
  }

  Future<void> applyFilter(WaterChartFilter filter) async {
    currentFilter = filter;
    setLoading(true);
    WaterGraph res = await getUserDailyStepGraph(filter: currentFilter.name.toString());
    logList = res.data ?? [];
    setLoading(false);
  }

  /// DAILY steps callback
  void onDailyStepCount(StepCount event) {
    /// Update UI immediately
     if(event.steps <= 0) return;
    steps.value = event.steps;

    /// Reset inactivity timer
    _resetInactivityTimer();

    /// Optional: still keep periodic API call (2 min)
    _tryPeriodicApiCall(event.steps);
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();

    _inactivityTimer = Timer(
      const Duration(seconds: inactivitySeconds),
          () async {
        debugPrint('🛑 User stopped walking');

        /// Avoid duplicate API calls
        if (steps.value == _lastStepsSent) return;

        _lastStepsSent = steps.value;

        final now = DateTime.now();

        await setDailyStepsGoalApi({
          "value": steps.value,
          "date": DateFormat('yyyy-MM-dd').format(now),
          "time": DateFormat('HH:mm:ss').format(now),
        });

        await init();
      },
    );
  }

  void _tryPeriodicApiCall(int stepValue) async {
    if (dailyGoal == 0) return;

    final now = DateTime.now();

    if (_lastApiCallTime == null ||
        now.difference(_lastApiCallTime!).inMinutes >= 1) {
      _lastApiCallTime = now;
      _lastStepsSent = stepValue;

      await setDailyStepsGoalApi({
        "value": stepValue,
        "date": DateFormat('yyyy-MM-dd').format(now),
        "time": DateFormat('HH:mm:ss').format(now),
      });
      await init();
    }
  }

  Future<void> getLogs() async {
    setLoading(true);
    WaterGraph res = await getUserDailyStepGraph();
    logList = res.data ?? [];
    logList.sort((a, b) {
      return DateTime.parse(a.date.validate()).compareTo(DateTime.parse(b.date.validate()));
    });
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    steps.value = (logList.isNotEmpty) ? logList.firstWhere((e) => e.date == today, orElse: () => WaterGraphData(date: today,value: 0)).value.validate() : 0;
    setLoading(false);
  }

  Future<void> syncGoal() async {
    setLoading(true);
    try {
      final graph = await getUserGraphApi(STEP_TRACK);
      setLoading(false);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (graph.data?.date != today && graph.data != null) {
        var req = {
          "value": graph.data!.value,
          "type": STEP_TRACK,
          "unit": STEP_UNIT,
          "date": today,
        };
        await setProgressApi(req);
      }
    } catch (_) {
      setLoading(false);
    }
  }

  Future<void> getGoal() async {
    setLoading(true);
    GraphResponse graph = await getProgressApi(STEP_TRACK);
    if (graph.data!.isNotEmpty && graph.data != null) {
      final data = graph.data!.first;
      await setValue(STEP_TRACK_ID, data.id);
      dailyGoal =  int.tryParse(data.value ?? '0') ?? 0;
    } else {
      dailyGoal = 0;
      await setValue(WATER_TRACK_ID, 0);
    }
    setLoading(false);
  }

  Future<void> init() async {
    await syncGoal();
    await getGoal();
    await getLogs();
  }

  void dispose() {
    _dailyStepSubscription?.cancel();
    _dailyStepSubscription = null;
  }

  void setLoading(bool value) {
    isLoading = value;
    updateUI.value++;
  }
}
