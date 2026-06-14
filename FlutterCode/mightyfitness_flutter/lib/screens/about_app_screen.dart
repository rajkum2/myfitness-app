import '../components/in_app_webview.dart';
import '../utils/shared_import.dart';

class AboutAppScreen extends StatefulWidget {
  static String tag = '/AboutAppScreen';

  @override
  AboutAppScreenState createState() => AboutAppScreenState();
}

class AboutAppScreenState extends State<AboutAppScreen> {
  List<dynamic> aboutPages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAppSettings();
  }

  Future<void> loadAppSettings() async {
    try {
      AppSettingResponse response = await getAppSettingApi();

      // Save only pages list
      aboutPages = response.pages ?? [];

      // Sort alphabetically by title
      aboutPages.sort((a, b) =>
          a.title.toString().compareTo(b.title.toString()));

      setState(() {
        loading = false;
      });
    } catch (e) {
      print("Error loading settings: $e");
      loading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(languages.lblAboutApp, context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            mOption(ic_rate_us, languages.lblPrivacyPolicy, () {
              PrivacyPolicyScreen()
                  .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
            }, context).visible(getStringAsync(PRIVACY_POLICY).isNotEmpty),
            Divider(height: 0)
                .visible(getStringAsync(PRIVACY_POLICY).isNotEmpty),
            mOption(ic_terms, languages.lblTermsOfServices, () {
              TermsAndConditionScreen()
                  .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
            }, context).visible(getStringAsync(TERMS_SERVICE).isNotEmpty),
            Divider(height: 0)
                .visible(getStringAsync(TERMS_SERVICE).isNotEmpty),
            mOption(ic_info, languages.lblAboutUs, () {
              AboutUsScreen()
                  .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
            }, context),
            Divider(height: 0),
            ...aboutPages.map((page) {
              return Column(
                children: [
                  mOption(
                    ic_info,
                    page.title ?? "",
                        () {
                      InAppWebPage(
                        url: page.url ?? "",
                        title: page.title ?? "",
                      ).launch(context);
                    },
                    context,
                  ),
                  Divider(height: 0),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
