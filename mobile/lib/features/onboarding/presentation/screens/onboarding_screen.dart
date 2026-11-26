import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/aswani_logo.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/eyebrow.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/onboarding_view_model.dart';
import '../widgets/onboarding_hero.dart';
import '../widgets/page_dots.dart';
import '../../../../shared/widgets/motion.dart';

/// "Meet Aswan": three swipeable intro pages.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() => context.go(AppRoutes.signUp);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final page = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);
    final isLast = page == OnboardingViewModel.pageCount - 1;

    final pages = [
      _OnboardingPage(
        number: '01',
        title: l10n.onboarding1Title,
        body: l10n.onboarding1Body,
        hero: OnboardingHero(
          image: AppImages.onboardingNile,
          caption: l10n.onboarding1Label,
          captionIcon: LucideIcons.mapPin,
          badges: const [
            HeroBadge(
              icon: LucideIcons.landmark,
              tone: BadgeTone.gold,
              alignment: AlignmentDirectional(1.17, -0.79),
            ),
            HeroBadge(
              icon: LucideIcons.map,
              tone: BadgeTone.navy,
              alignment: AlignmentDirectional(-1.19, 0.99),
            ),
          ],
        ),
      ),
      _OnboardingPage(
        number: '02',
        title: l10n.onboarding2Title,
        body: l10n.onboarding2Body,
        hero: OnboardingHero(
          image: AppImages.onboardingNubian,
          caption: l10n.onboarding2Label,
          captionIcon: LucideIcons.palette,
          captionStyle: CaptionStyle.card,
          shape: HeroShape.tiltedCard,
          badges: const [
            HeroBadge(
              icon: LucideIcons.sparkles,
              tone: BadgeTone.gold,
              alignment: AlignmentDirectional(-1.1, -0.92),
            ),
            HeroBadge(
              icon: LucideIcons.map,
              tone: BadgeTone.navy,
              alignment: AlignmentDirectional(1.13, 0.98),
            ),
          ],
        ),
      ),
      _OnboardingPage(
        number: '03',
        title: l10n.onboarding3Title,
        body: l10n.onboarding3Body,
        hero: OnboardingHero(
          image: AppImages.onboardingPhilae,
          caption: l10n.onboarding3Label,
          captionIcon: LucideIcons.mapPin,
          sideImages: const [
            AppImages.onboardingTemple,
            AppImages.onboardingMarket,
          ],
          badges: const [
            HeroBadge(
              icon: LucideIcons.landmark,
              tone: BadgeTone.gold,
              alignment: AlignmentDirectional(1.22, -0.78),
            ),
            HeroBadge(
              icon: LucideIcons.users,
              tone: BadgeTone.navy,
              alignment: AlignmentDirectional(-1.24, 1.25),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          maxWidth: 560,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  0,
                ),
                child: Row(
                  children: [
                    CircleIconButton.back(
                      tooltip: l10n.back,
                      onPressed: () =>
                          page == 0 ? context.pop() : _goTo(page - 1),
                    ),
                    const Expanded(child: Center(child: AswaniLogo())),
                    TextButton(onPressed: _finish, child: Text(l10n.skip)),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: viewModel.pageChanged,
                  children: pages,
                ),
              ),
              PageDots(count: OnboardingViewModel.pageCount, index: page),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screen),
                child: PrimaryButton(
                  label: isLast ? l10n.getStarted : l10n.next,
                  showArrow: true,
                  onPressed: isLast ? _finish : () => _goTo(page + 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.number,
    required this.title,
    required this.body,
    required this.hero,
  });

  final String number;
  final String title;
  final String body;
  final Widget hero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: staggered([
                const SizedBox(height: AppSpacing.md),
                // Smaller on short screens (small phones, landscape).
                SizedBox(
                  height: (constraints.maxHeight * 0.6).clamp(220, 390),
                  child: hero,
                ),
                const SizedBox(height: AppSpacing.xl),
                Eyebrow(context.l10n.onboardingEyebrow(number)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.text.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
