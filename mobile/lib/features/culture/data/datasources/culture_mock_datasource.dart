import '../../../../core/assets/app_images.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/pagination/paged.dart';
import 'culture_datasource.dart';

/// Sample culture content in both languages, answering like contract v0.2.
/// The texts are illustrative ("Sample editorial") until real editors and
/// researchers write and review them.
class CultureMockDataSource implements CultureDataSource {
  CultureMockDataSource({
    this.delay = const Duration(milliseconds: 500),
    this.pageSize = kPageSize,
  });

  final Duration delay;
  final int pageSize;
  final Set<String> _saved = {};

  static const List<Map<String, dynamic>> _themes = [
    {
      'id': 'nubian_heritage',
      'title_en': 'Nubian heritage',
      'title_ar': 'التراث النوبي',
      'image': AppImages.nubianMuseum,
    },
    {
      'id': 'ancient_history',
      'title_en': 'Ancient history',
      'title_ar': 'التاريخ القديم',
      'image': AppImages.philaeTemple,
    },
    {
      'id': 'traditions',
      'title_en': 'Traditions',
      'title_ar': 'العادات والتقاليد',
      'image': AppImages.onboardingMarket,
    },
    {
      'id': 'arts_crafts',
      'title_en': 'Arts & crafts',
      'title_ar': 'الفنون والحِرف',
      'image': AppImages.onboardingNubian,
    },
  ];

  static const _note = {
    'type': 'paragraph',
    'text_en':
        'This is illustrative editorial copy, not a historical reference. '
        'Before publication, the story should be reviewed with local '
        'writers, researchers, and trusted sources to respect cultural '
        'accuracy and nuance.',
    'text_ar':
        'هذا نص تحريري توضيحي وليس مرجعًا تاريخيًا. قبل النشر يجب مراجعة '
        'القصة مع كتّاب وباحثين محليين ومصادر موثوقة احترامًا للدقة '
        'الثقافية وتفاصيلها.',
  };

  static const List<Map<String, dynamic>> _stories = [
    {
      'id': 's_homes',
      'theme': 'nubian_heritage',
      'title_en': 'Homes that speak in color',
      'title_ar': 'بيوت تتحدث بالألوان',
      'label_en': 'Nubian heritage',
      'label_ar': 'تراث نوبي',
      'location_en': 'Gharb Soheil',
      'location_ar': 'غرب سهيل',
      'cover_image': AppImages.nubianVillage,
      'read_minutes': 5,
      'is_sample': true,
      'blocks': [
        {
          'type': 'lead',
          'text_en':
              'In Nubian villages, color becomes a language of welcome and '
              'a living memory of place.',
          'text_ar':
              'في القرى النوبية يصبح اللون لغةً للترحيب وذاكرةً حيّة '
              'للمكان.',
        },
        _note,
        {
          'type': 'quote',
          'text_en':
              'A home here is more than a form; it is a space for memory '
              'and hospitality.',
          'text_ar': 'البيت هنا أكثر من شكل؛ إنه مساحة للذاكرة والضيافة.',
        },
        {'type': 'image', 'image': AppImages.onboardingMarket},
        {
          'type': 'heading',
          'text_en': 'Read the place slowly',
          'text_ar': 'اقرأ المكان على مهل',
        },
        {
          'type': 'paragraph',
          'text_en':
              'Aswan invites visitors to pause and listen. When we speak '
              'about heritage, we make space for its people to tell their '
              'own story.',
          'text_ar':
              'تدعو أسوان زوارها إلى التمهّل والإصغاء. وحين نتحدث عن '
              'التراث، نفسح المجال لأهله ليحكوا قصتهم بأنفسهم.',
        },
      ],
    },
    {
      'id': 's_nile',
      'theme': 'traditions',
      'title_en': "The Nile in Aswan's memory",
      'title_ar': 'النيل في ذاكرة أسوان',
      'label_en': 'Local life',
      'label_ar': 'حياة محلية',
      'location_en': 'Aswan',
      'location_ar': 'أسوان',
      'cover_image': AppImages.homeHero,
      'read_minutes': 4,
      'is_sample': true,
      'blocks': [
        {
          'type': 'lead',
          'text_en':
              'For people in Aswan, the river is a neighbour, a road and a '
              'calendar all at once.',
          'text_ar': 'النهر لأهل أسوان جارٌ وطريقٌ وتقويمٌ في آنٍ واحد.',
        },
        _note,
        {
          'type': 'heading',
          'text_en': 'Mornings on the water',
          'text_ar': 'صباحات على الماء',
        },
        {
          'type': 'paragraph',
          'text_en':
              'Feluccas leave early, when the wind is gentle and the light '
              'is soft on the hills of the west bank.',
          'text_ar':
              'تنطلق المراكب الشراعية مبكرًا حين تكون الريح هادئة والضوء '
              'ناعمًا على تلال البر الغربي.',
        },
        {'type': 'image', 'image': AppImages.homeHero2},
      ],
    },
    {
      'id': 's_stones',
      'theme': 'ancient_history',
      'title_en': 'Stones that keep the time',
      'title_ar': 'حجارة تحفظ الزمن',
      'label_en': 'Ancient history',
      'label_ar': 'تاريخ قديم',
      'location_en': 'Philae',
      'location_ar': 'فيلة',
      'cover_image': AppImages.philaeTemple,
      'read_minutes': 6,
      'is_sample': true,
      'blocks': [
        {
          'type': 'lead',
          'text_en':
              'Temples around Aswan were moved, rebuilt and cared for so '
              'their stories could stay with us.',
          'text_ar':
              'نُقلت معابد حول أسوان وأُعيد بناؤها والعناية بها لتبقى '
              'قصصها معنا.',
        },
        _note,
        {
          'type': 'quote',
          'text_en': 'Every column is a sentence; every wall, a page.',
          'text_ar': 'كل عمود جملة، وكل جدار صفحة.',
        },
      ],
    },
    {
      'id': 's_souq',
      'theme': 'traditions',
      'title_en': 'Market mornings',
      'title_ar': 'صباحات السوق',
      'label_en': 'Traditions',
      'label_ar': 'عادات وتقاليد',
      'location_en': 'Aswan Souq',
      'location_ar': 'سوق أسوان',
      'cover_image': AppImages.onboardingMarket,
      'read_minutes': 3,
      'is_sample': true,
      'blocks': [
        {
          'type': 'lead',
          'text_en':
              'Spices, hibiscus and woven baskets: the souq is where the '
              'city meets every day.',
          'text_ar':
              'توابل وكركديه وسلال مجدولة: السوق هو المكان الذي تلتقي فيه '
              'المدينة كل يوم.',
        },
        _note,
      ],
    },
    {
      'id': 's_walls',
      'theme': 'arts_crafts',
      'title_en': 'Walls painted by hand',
      'title_ar': 'جدران رُسمت باليد',
      'label_en': 'Arts & crafts',
      'label_ar': 'فنون وحِرف',
      'location_en': 'Nubian villages',
      'location_ar': 'القرى النوبية',
      'cover_image': AppImages.homeStory,
      'read_minutes': 4,
      'is_sample': true,
      'blocks': [
        {
          'type': 'lead',
          'text_en':
              'Patterns on doors and walls are painted again and again, '
              'each season adding a new layer.',
          'text_ar':
              'تُرسم الزخارف على الأبواب والجدران مرة بعد مرة، ويضيف كل '
              'موسم طبقة جديدة.',
        },
        _note,
      ],
    },
  ];

  Future<void> _wait() => Future<void>.delayed(delay);

  Map<String, dynamic> _summary(Map<String, dynamic> s) => {
    for (final e in s.entries)
      if (e.key != 'blocks') e.key: e.value,
    'is_saved': _saved.contains(s['id']),
  };

  Paged<Map<String, dynamic>> _page(List<Map<String, dynamic>> all, int page) {
    final totalPages = all.isEmpty ? 1 : (all.length / pageSize).ceil();
    return Paged(
      items: all.skip((page - 1) * pageSize).take(pageSize).toList(),
      page: page,
      totalPages: totalPages,
      total: all.length,
    );
  }

  Map<String, dynamic> _find(String id) => _stories.firstWhere(
    (s) => s['id'] == id,
    orElse: () => throw const AppException(
      code: ErrorCodes.storyNotFound,
      statusCode: 404,
    ),
  );

  @override
  Future<Map<String, dynamic>> getHome() async {
    await _wait();
    return {
      'featured': _summary(_find('s_homes')),
      'themes': _themes,
      'selected_reads': [
        for (final id in ['s_nile', 's_souq', 's_stones']) _summary(_find(id)),
      ],
    };
  }

  @override
  Future<Paged<Map<String, dynamic>>> getStories({
    String? theme,
    int page = 1,
  }) async {
    await _wait();
    if (theme != null && !_themes.any((t) => t['id'] == theme)) {
      throw const AppException(
        code: ErrorCodes.validation,
        statusCode: 422,
        details: {'theme': ErrorCodes.validation},
      );
    }
    return _page([
      for (final s in _stories)
        if (theme == null || s['theme'] == theme) _summary(s),
    ], page);
  }

  @override
  Future<Map<String, dynamic>> getStory(String id) async {
    await _wait();
    final story = _find(id);
    return {..._summary(story), 'blocks': story['blocks']};
  }

  @override
  Future<bool> setSaved(String storyId, {required bool saved}) async {
    await _wait();
    _find(storyId);
    saved ? _saved.add(storyId) : _saved.remove(storyId);
    return saved;
  }

  @override
  Future<Paged<Map<String, dynamic>>> getSaved({int page = 1}) async {
    await _wait();
    return _page([
      for (final s in _stories)
        if (_saved.contains(s['id'])) _summary(s),
    ], page);
  }

  /// For the profile's "saved stories" count.
  int get savedCount => _saved.length;
}
