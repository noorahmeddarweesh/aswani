"""
scripts/seed.py
───────────────
Populate the database with initial seed data matching mobile mock data:
  • 4 Core Places (Philae Temple, Elephantine Island, Nubian Village, Nubian Museum)
  • 4 Culture Themes (Nubian heritage, Ancient history, Traditions, Arts & crafts)
  • 4 Community Story Highlights
  • Sample Local Guides
  • Staging Demo Account (Laila Hassan, laila@example.com / Aswan2026)

Run with:
  python -m scripts.seed   (from backend/ directory)
"""
from __future__ import annotations

import logging
from app.core.config import settings
from app.core.security import hash_password
from app.db.models import (
    CultureTheme,
    Guide,
    Highlight,
    Place,
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

        logger.info("Seeding community highlights...")
        for h in HIGHLIGHTS:
            db.merge(Highlight(**h))

        logger.info("Seeding local guides...")
        for g in GUIDES:
            db.merge(Guide(**g))

        logger.info("Checking staging demo user (Laila Hassan)...")
        demo_user = db.query(User).filter_by(identifier=settings.SEED_DEMO_EMAIL).first()
        if not demo_user:
            demo_user = User(
                full_name=settings.SEED_DEMO_FULL_NAME,
                identifier=settings.SEED_DEMO_EMAIL,
                password_hash=hash_password(settings.SEED_DEMO_PASSWORD),
            )
            demo_user.preferences = UserPreferences(
                persona="visitor",
                purpose="tourism",
                stay_length="few_days",
                interests=["historical", "nubian", "nature", "food"],
                travel_styles=["calm", "cultural"],
                companions="solo",
                needs=["finding_places"],
                language="en",
            )
            db.add(demo_user)
            logger.info("Demo user '%s' seeded.", settings.SEED_DEMO_EMAIL)
        else:
            logger.info("Demo user already exists.")

        db.commit()
        logger.info("Database seeding successfully completed!")


if __name__ == "__main__":
    seed()
