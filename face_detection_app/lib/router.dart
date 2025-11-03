

import 'package:face_detection_app/router_constants.dart';
import 'package:face_detection_app/view/camera_view.dart';
import 'package:face_detection_app/view/home_view.dart';
import 'package:face_detection_app/view/result_view.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/${Routes.HOME_VIEW}',
    routes: [
      // Home View
      GoRoute(
        path: '/${Routes.HOME_VIEW}',
        name: Routes.HOME_VIEW,
        builder: (context, state) => HomeView(),
      ),
      // Camera View
      GoRoute(
        path: '/${Routes.CAMERA_VIEW}',
        name: Routes.CAMERA_VIEW,
        builder: (context, state) => const CameraView(),
      ),
      // Photo Analysis View
      GoRoute(
        path: '/${Routes.PHOTO_ANALYSIS_VIEW}',
        name: Routes.PHOTO_ANALYSIS_VIEW,
        builder: (context, state) {
          final dynamic data = state.extra;
          return PhotoAnalysisView(imagePath: data);
        },
      ),
    ],
  );
}
