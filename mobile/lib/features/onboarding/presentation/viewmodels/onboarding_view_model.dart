import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current onboarding page (0-based). The screen's PageView follows it.
class OnboardingViewModel extends Notifier<int> {
  static const int pageCount = 3;

  @override
  int build() => 0;

  bool get isLast => state == pageCount - 1;

  void pageChanged(int index) => state = index;

  void next() {
    if (state < pageCount - 1) state = state + 1;
  }

  void previous() {
    if (state > 0) state = state - 1;
  }
}

final onboardingViewModelProvider =
    NotifierProvider.autoDispose<OnboardingViewModel, int>(
      OnboardingViewModel.new,
    );
