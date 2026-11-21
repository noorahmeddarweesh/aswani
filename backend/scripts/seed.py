"""
scripts/seed.py
───────────────
Populate the database with initial seed data matching mobile mock data:
  • 4 Core Places (Philae Temple, Elephantine Island, Nubian Village, Nubian Museum)
  • 4 Culture Themes (Nubian heritage, Ancient history, Traditions, Arts & crafts)
  • 5 Culture Stories with blocks (Featured + Selected Reads)
  • 4 Community Story Highlights
  • 3 Community Posts + Comments
  • Sample Local Guides (Youssef El Nuby, Mariam Ahmed)
  • Demo Users (Laila Hassan, Mariam Ahmed, Omar Ali)

Run with:
  python -m scripts.seed   (from backend/ directory)
"""
from __future__ import annotations

import logging
from app.core.config import settings
from app.core.security import hash_password
from app.db.models import (
    Comment,
    CultureTheme,
    Guide,
    Highlight,
    Place,
    Post,
    Story,
    User,
    UserPreferences,
)
from app.db.session import SessionLocal

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def img_url(path: str) -> str:
    if settings.SUPABASE_URL:
        return f"{settings.SUPABASE_URL}/storage/v1/object/public/{settings.STORAGE_BUCKET}/{path}"
    return f"https://images.unsplash.com/photo-1568322445389-f64ac2515020"


PLACES = [
    {
        "id": "philae",
        "category": "history",
        "name_en": "Philae Temple",
        "name_ar": "معبد فيلة",
        "label_en": "Heritage & history",
        "label_ar": "تراث وتاريخ",
        "tagline_en": "History on an island",
        "tagline_ar": "تاريخ على جزيرة",
        "city_en": "Aswan",
        "city_ar": "أسوان",
        "image": "https://images.unsplash.com/photo-1568322445389-f64ac2515020",
        "is_curated": True,
        "is_editors_pick": True,
        "location_en": "Agilkia Island, Aswan",
        "location_ar": "جزيرة أجيليكا، أسوان",
        "about_en": "An archaeological complex on an island in the Nile, dedicated to goddess Isis.",
        "about_ar": "مجمع أثري عريق على جزيرة في النيل مكرس للإلهة إيزيس.",
        "images": [
            "https://images.unsplash.com/photo-1568322445389-f64ac2515020",
            "https://images.unsplash.com/photo-1539650116574-8efeb43e2750",
        ],
        "facts": [
            {"type": "access", "label_en": "Boat access", "label_ar": "الوصول بالقارب"},
            {"type": "hours", "label_en": "Check before visiting", "label_ar": "تحقق قبل الزيارة"},
        ],
    },
    {
        "id": "nubian-village",
        "category": "nubian",
        "name_en": "Nubian Village",
        "name_ar": "القرية النوبية",
        "label_en": "Local culture",
        "label_ar": "ثقافة محلية",
        "tagline_en": "Colours, music and hospitality",
        "tagline_ar": "ألوان وموسيقى وكرم ضيافة",
        "city_en": "Aswan",
        "city_ar": "أسوان",
        "image": "https://images.unsplash.com/photo-1539650116574-8efeb43e2750",
        "is_curated": True,
        "is_editors_pick": False,
        "location_en": "West Bank, Gharb Soheil",
        "location_ar": "البر الغربي، غرب سهيل",
        "about_en": "Vibrant village famous for colorful architecture and Nubian hospitality.",
        "about_ar": "قرية نابضة بالحياة تشتهر ببيوتها الملونة وتراثها النوبي الأصيل.",
        "images": ["https://images.unsplash.com/photo-1539650116574-8efeb43e2750"],
        "facts": [
            {"type": "access", "label_en": "Boat or taxi", "label_ar": "بالقارب أو التاكسي"},
        ],
    },
    {
        "id": "elephantine",
        "category": "nature",
        "name_en": "Elephantine Island",
        "name_ar": "جزيرة إلفنتين",
        "label_en": "Nature & local life",
        "label_ar": "طبيعة وحياة محلية",
        "tagline_en": "Nile & local life",
        "tagline_ar": "النيل والحياة المحلية",
        "city_en": "Aswan",
        "city_ar": "أسوان",
        "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        "is_curated": True,
        "is_editors_pick": False,
        "location_en": "Nile River, Aswan",
        "location_ar": "نهر النيل، أسوان",
        "about_en": "Ancient island in the Nile with Nubian villages and historical ruins.",
        "about_ar": "جزيرة تاريخية في قلب النيل تضم قرى نوبية ومعالم أثرية.",
        "images": ["https://images.unsplash.com/photo-1506744038136-46273834b3fb"],
        "facts": [
            {"type": "access", "label_en": "Felucca or ferry", "label_ar": "فلوكة أو معدية"},
        ],
    },
    {
        "id": "nubian-museum",
        "category": "history",
        "name_en": "Nubian Museum",
        "name_ar": "متحف النوبة",
        "label_en": "Heritage & history",
        "label_ar": "تراث وتاريخ",
        "tagline_en": "The story of Nubia",
        "tagline_ar": "حكاية النوبة",
        "city_en": "Aswan",
        "city_ar": "أسوان",
        "image": "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7",
        "is_curated": False,
        "is_editors_pick": False,
        "location_en": "Sheikha Haroun, Aswan",
        "location_ar": "الشيخة هارون، أسوان",
        "about_en": "Acclaimed museum dedicated to Nubian culture, history, and artifacts.",
        "about_ar": "متحف حائز على جوائز عالمية يعرض تاريخ وحضارة النوبة عبر العصور.",
        "images": ["https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7"],
        "facts": [
            {"type": "hours", "label_en": "9:00 AM - 9:00 PM", "label_ar": "9:00 ص - 9:00 م"},
        ],
    },
]

CULTURE_THEMES = [
    {
        "id": "nubian_heritage",
        "title_en": "Nubian heritage",
        "title_ar": "التراث النوبي",
        "image": "https://images.unsplash.com/photo-1539650116574-8efeb43e2750",
    },
    {
        "id": "ancient_history",
        "title_en": "Ancient history",
        "title_ar": "التاريخ القديم",
        "image": "https://images.unsplash.com/photo-1568322445389-f64ac2515020",
    },
    {
        "id": "traditions",
        "title_en": "Traditions",
        "title_ar": "العادات والتقاليد",
        "image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
    },
    {
        "id": "arts_crafts",
        "title_en": "Arts & crafts",
        "title_ar": "الفنون والحرف",
        "image": "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7",
    },
]

STORIES = [
    {
        "id": "s_homes",
        "theme": "nubian_heritage",
        "title_en": "Homes that speak in color",
        "title_ar": "بيوت تتحدث بالألوان",
        "label_en": "Nubian heritage",
        "label_ar": "تراث نوبي",
        "location_en": "Gharb Soheil",
        "location_ar": "غرب سهيل",
        "cover_image": "https://images.unsplash.com/photo-1539650116574-8efeb43e2750",
        "read_minutes": 5,
        "is_sample": True,
        "is_featured": True,
        "blocks": [
            {
                "type": "lead",
                "text_en": "In Nubian villages, color becomes a language of welcome and a living memory of place.",
                "text_ar": "في القرى النوبية يصبح اللون لغةً للترحيب وذاكرةً حيّة للمكان.",
            },
            {
                "type": "quote",
                "text_en": "A home here is more than a form; it is a space for memory and hospitality.",
                "text_ar": "البيت هنا أكثر من شكل؛ إنه مساحة للذاكرة والضيافة.",
            },
            {
                "type": "heading",
                "text_en": "Read the place slowly",
                "text_ar": "اقرأ المكان على مهل",
            },
            {
                "type": "paragraph",
                "text_en": "Aswan invites visitors to pause and listen. When we speak about heritage, we make space for its people to tell their own story.",
                "text_ar": "تدعو أسوان زوارها إلى التمهّل والإصغاء. وحين نتحدث عن التراث، نفسح المجال لأهله ليحكوا قصتهم بأنفسهم.",
            },
        ],
    },
    {
        "id": "s_nile",
        "theme": "traditions",
        "title_en": "The Nile in Aswan's memory",
        "title_ar": "النيل في ذاكرة أسوان",
        "label_en": "Local life",
        "label_ar": "حياة محلية",
        "location_en": "Aswan",
        "location_ar": "أسوان",
        "cover_image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        "read_minutes": 4,
        "is_sample": True,
        "is_featured": False,
        "blocks": [
            {
                "type": "lead",
                "text_en": "For people in Aswan, the river is a neighbour, a road and a calendar all at once.",
                "text_ar": "النهر لأهل أسوان جارٌ وطريقٌ وتقويمٌ في آنٍ واحد.",
            },
            {
                "type": "heading",
                "text_en": "Mornings on the water",
                "text_ar": "صباحات على الماء",
            },
            {
                "type": "paragraph",
                "text_en": "Feluccas leave early, when the wind is gentle and the light is soft on the hills of the west bank.",
                "text_ar": "تنطلق المراكب الشراعية مبكرًا حين تكون الريح هادئة والضوء ناعمًا على تلال البر الغربي.",
            },
        ],
    },
    {
        "id": "s_stones",
        "theme": "ancient_history",
        "title_en": "Stones that keep the time",
        "title_ar": "حجارة تحفظ الزمن",
        "label_en": "Ancient history",
        "label_ar": "تاريخ قديم",
        "location_en": "Philae",
        "location_ar": "فيلة",
        "cover_image": "https://images.unsplash.com/photo-1568322445389-f64ac2515020",
        "read_minutes": 6,
        "is_sample": True,
        "is_featured": False,
        "blocks": [
            {
                "type": "lead",
                "text_en": "Temples around Aswan were moved, rebuilt and cared for so their stories could stay with us.",
                "text_ar": "نُقلت معابد حول أسوان وأُعيد بناؤها والعناية بها لتبقى قصصها معنا.",
            },
            {
                "type": "quote",
                "text_en": "Every column is a sentence; every wall, a page.",
                "text_ar": "كل عمود جملة، وكل جدار صفحة.",
            },
        ],
    },
    {
        "id": "s_souq",
        "theme": "traditions",
        "title_en": "Market mornings",
        "title_ar": "صباحات السوق",
        "label_en": "Traditions",
        "label_ar": "عادات وتقاليد",
        "location_en": "Aswan Souq",
        "location_ar": "سوق أسوان",
        "cover_image": "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7",
        "read_minutes": 3,
        "is_sample": True,
        "is_featured": False,
        "blocks": [
            {
                "type": "lead",
                "text_en": "Spices, hibiscus and woven baskets: the souq is where the city meets every day.",
                "text_ar": "توابل وكركديه وسلال مجدولة: السوق هو المكان الذي تلتقي فيه المدينة كل يوم.",
            },
        ],
    },
    {
        "id": "s_walls",
        "theme": "arts_crafts",
        "title_en": "Walls painted by hand",
        "title_ar": "جدران رُسمت باليد",
        "label_en": "Arts & crafts",
        "label_ar": "فنون وحرف",
        "location_en": "Nubian villages",
        "location_ar": "القرى النوبية",
        "cover_image": "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
        "read_minutes": 4,
        "is_sample": True,
        "is_featured": False,
        "blocks": [
            {
                "type": "lead",
                "text_en": "Patterns on doors and walls are painted again and again, each season adding a new layer.",
                "text_ar": "تُرسم الزخارف على الأبواب والجدران مرة بعد مرة، ويضيف كل موسم طبقة جديدة.",
            },
        ],
    },
]

HIGHLIGHTS = [
    {
        "id": "h_nubia",
        "title_en": "Nubian colors",
        "title_ar": "ألوان النوبة",
        "cover_image": "https://images.unsplash.com/photo-1539650116574-8efeb43e2750",
        "category": "nubian",
        "sort_order": 1,
    },
    {
        "id": "h_nile",
        "title_en": "On the Nile",
        "title_ar": "على النيل",
        "cover_image": "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        "category": "nile",
        "sort_order": 2,
    },
    {
        "id": "h_local",
        "title_en": "Local life",
        "title_ar": "حياة محلية",
        "cover_image": "https://images.unsplash.com/photo-1568322445389-f64ac2515020",
        "category": "local_experience",
        "sort_order": 3,
    },
    {
        "id": "h_souq",
        "title_en": "From the souq",
        "title_ar": "من السوق",
        "cover_image": "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7",
        "category": "food",
        "sort_order": 4,
    },
]

GUIDES = [
    {
        "id": "youssef-el-nuby",
        "full_name": "Youssef El Nuby",
        "photo": "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
        "city": "Aswan",
        "tagline": "Nubian stories • History walks • Arabic & English",
        "languages": ["ar", "en"],
        "specialties": ["nubian_culture", "historical_sites", "local_experiences"],
        "durations": ["few_hours", "one_day", "multiple_days"],
        "bio": "Passionate about local stories, Nubian architecture, and Nile experiences.",
        "is_featured": True,
        "is_verified": False,
    },
    {
        "id": "mariam-ahmed",
        "full_name": "Mariam Ahmed",
        "photo": "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
        "city": "Aswan",
        "tagline": "Local & family experiences",
        "languages": ["ar", "en"],
        "specialties": ["nubian_culture", "local_experiences"],
        "durations": ["few_hours", "one_day"],
        "bio": "Certified explorer with rich stories of Nubian traditions and family heritage.",
        "is_featured": False,
        "is_verified": False,
    },
]


def seed() -> None:
    with SessionLocal() as db:
        logger.info("Seeding places...")
        for p in PLACES:
            db.merge(Place(**p))

        logger.info("Seeding culture themes...")
        for t in CULTURE_THEMES:
            db.merge(CultureTheme(**t))

        logger.info("Seeding culture stories...")
        for s in STORIES:
            db.merge(Story(**s))

        logger.info("Seeding community highlights...")
        for h in HIGHLIGHTS:
            db.merge(Highlight(**h))

        logger.info("Seeding local guides...")
        for g in GUIDES:
            db.merge(Guide(**g))

        logger.info("Checking staging demo users...")
        # 1. Laila Hassan
        laila = db.query(User).filter_by(identifier=settings.SEED_DEMO_EMAIL).first()
        if not laila:
            laila = User(
                full_name=settings.SEED_DEMO_FULL_NAME,
                identifier=settings.SEED_DEMO_EMAIL,
                password_hash=hash_password(settings.SEED_DEMO_PASSWORD),
            )
            laila.preferences = UserPreferences(
                persona="visitor",
                purpose="tourism",
                stay_length="few_days",
                interests=["historical", "nubian", "nature", "food"],
                travel_styles=["calm", "cultural"],
                companions="solo",
                needs=["finding_places"],
                language="en",
            )
            db.add(laila)
            db.flush()
            logger.info("Demo user '%s' seeded.", settings.SEED_DEMO_EMAIL)
        else:
            logger.info("Demo user '%s' already exists.", settings.SEED_DEMO_EMAIL)

        # 2. Mariam Ahmed
        mariam = db.query(User).filter_by(identifier="mariam@example.com").first()
        if not mariam:
            mariam = User(
                full_name="Mariam Ahmed",
                identifier="mariam@example.com",
                password_hash=hash_password("Aswan2026"),
                avatar="https://images.unsplash.com/photo-1494790108377-be9c29b29330",
            )
            db.add(mariam)
            db.flush()

        # 3. Omar Ali
        omar = db.query(User).filter_by(identifier="omar@example.com").first()
        if not omar:
            omar = User(
                full_name="Omar Ali",
                identifier="omar@example.com",
                password_hash=hash_password("Aswan2026"),
                avatar="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
            )
            db.add(omar)
            db.flush()

        logger.info("Seeding community posts...")
        posts_data = [
            {
                "id": "p_sunset",
                "user_id": laila.id,
                "caption": "A quiet sunset and a sail passing through the story. This is the Aswan I love. #NileMoments",
                "location": "Aswan Corniche",
                "category": "nile",
                "images": [
                    "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
                    "https://images.unsplash.com/photo-1568322445389-f64ac2515020",
                ],
                "like_count": 124,
                "comment_count": 2,
            },
            {
                "id": "p_mariam",
                "user_id": mariam.id,
                "caption": "Every door in Gharb Soheil tells you who lives behind it. #NubianColors",
                "location": "Gharb Soheil",
                "category": "nubian",
                "images": [
                    "https://images.unsplash.com/photo-1539650116574-8efeb43e2750",
                    "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7",
                ],
                "like_count": 87,
                "comment_count": 1,
            },
            {
                "id": "p_souq",
                "user_id": omar.id,
                "caption": "Fresh spices and warm morning smiles at Aswan Souq.",
                "location": "Aswan Souq",
                "category": "food",
                "images": [
                    "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7",
                ],
                "like_count": 52,
                "comment_count": 0,
            },
        ]
        for p in posts_data:
            db.merge(Post(**p))
        db.flush()

        comments_data = [
            {
                "id": "c_1",
                "post_id": "p_sunset",
                "user_id": mariam.id,
                "text": "The golden hour in Aswan is truly unmatched!",
            },
            {
                "id": "c_2",
                "post_id": "p_sunset",
                "user_id": omar.id,
                "text": "Beautiful shot! Which felucca was this taken from?",
            },
            {
                "id": "c_3",
                "post_id": "p_mariam",
                "user_id": laila.id,
                "text": "The blues and yellows are breathtaking.",
            },
        ]
        for c in comments_data:
            db.merge(Comment(**c))

        db.commit()
        logger.info("Database seeding successfully completed!")


if __name__ == "__main__":
    seed()
