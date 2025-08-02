import 'package:get/get.dart';
import 'package:project_1/routes/routes.dart';

import '../features/text_to_speech/view/screen/home.dart';

class AppRoutes {
  static List<GetPage> pages = [
    GetPage(name: MyRoutes.home, page: () => HomeScreen()),
  ];
}
