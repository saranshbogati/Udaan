"""
Seed data script to populate the database with sample colleges and users
Run this after setting up the database: python seed_data.py
"""

import sys
import os
from datetime import datetime, timedelta
from sqlalchemy.orm import Session

# Add the app directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal, engine
from models import Base, User, College, Review
from auth import get_password_hash


def create_sample_data():
    # Create tables
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()

    try:
        # Create sample users
        print("Creating sample users...")
        users = [
            User(
                email="ram@example.com",
                username="ram",
                full_name="Ram Shyam",
                hashed_password=get_password_hash("123456"),
                is_verified=True,
            )
        ]

        for user in users:
            existing_user = db.query(User).filter(User.email == user.email).first()
            if not existing_user:
                db.add(user)

        db.commit()

        # Create sample colleges
        print("Creating sample colleges...")
        colleges = [
            College(
                name="Chelsea International Academy",
                location="Baneshwor, Kathmandu",
                city="Kathmandu",
                state="Bagmati Province",
                website="https://chelseainternational.com.np",
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="Cambridge (A-Levels)",
                description="No description available.",
                programs=["+2 Science", "+2 Management"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="KIST College & School",
                location="Kamalpokhari, Kathmandu",
                city="Kathmandu",
                state="Bagmati Province",
                website="https://kist.edu.np",
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="NEB, TU, Pokhara University",
                description="No description available.",
                programs=["+2 Science", "+2 Management", "BSc", "BBA", "BBS"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Nobel Academy",
                location="New Baneshwor, Kathmandu",
                city="Kathmandu",
                state="Bagmati Province",
                website="https://nobel.edu.np",
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="NEB",
                description="No description available.",
                programs=["+2 Science", "+2 Management"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Prasadi Academy",
                location="Manbhawan, Lalitpur",
                city="Lalitpur",
                state="Bagmati Province",
                website=None,
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="NEB",
                description="No description available.",
                programs=["+2 Science", "+2 Management"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="St. Mary’s Higher Secondary School",
                location="Jawalakhel, Lalitpur",
                city="Lalitpur",
                state="Bagmati Province",
                website=None,
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="NEB",
                description="No description available.",
                programs=["+2 Science", "+2 Management"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Xavier International College",
                location="Kalopul, Kathmandu",
                city="Kathmandu",
                state="Bagmati Province",
                website="https://xaviercollege.edu.np",
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="NEB, TU",
                description="No description available.",
                programs=["+2 Science", "+2 Management", "BBS", "BEd"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Pokhara University School of Business",
                location="Lekhnath, Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website="https://pu.edu.np",
                phone=None,
                email=None,
                established_year=None,
                college_type="Public",
                affiliation="Pokhara University",
                description="No description available.",
                programs=["BBA", "MBA"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Prithvi Narayan Campus",
                location="Bhimkali Patan, Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website="https://pncampus.edu.np",
                phone=None,
                email=None,
                established_year=None,
                college_type="Public",
                affiliation="TU",
                description="No description available.",
                programs=["BSc", "BBS", "BA"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="LA College",
                location="Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website=None,
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="NEB, TU",
                description="No description available.",
                programs=["+2 Science", "+2 Management", "BBS"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Mount Annapurna Campus",
                location="Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website=None,
                phone=None,
                email=None,
                established_year=None,
                college_type="Public",
                affiliation="TU",
                description="No description available.",
                programs=["BBS", "BEd"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Gandaki College of Engineering and Science",
                location="Lamachaur, Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website="https://gces.edu.np",
                phone=None,
                email=None,
                established_year=None,
                college_type="Public",
                affiliation="Pokhara University",
                description="No description available.",
                programs=["BE", "BSc IT"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="SOS Hermann Gmeiner School",
                location="Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website=None,
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="NEB",
                description="No description available.",
                programs=["+2 Science", "+2 Management"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Janapriya Multiple Campus",
                location="Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website=None,
                phone=None,
                email=None,
                established_year=None,
                college_type="Public",
                affiliation="TU",
                description="No description available.",
                programs=["BBS", "BA", "BEd"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Pokhara College of Management",
                location="Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website=None,
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="Pokhara University",
                description="No description available.",
                programs=["BBA", "BHM"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="Infomax College of IT & Management",
                location="Pokhara",
                city="Pokhara",
                state="Gandaki Province",
                website=None,
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="Pokhara University",
                description="No description available.",
                programs=["BCA", "BSc IT"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
            College(
                name="National School of Sciences",
                location="Lainchour, Kathmandu",
                city="Kathmandu",
                state="Bagmati Province",
                website="https://nss.edu.np/",
                phone=None,
                email=None,
                established_year=None,
                college_type="Private",
                affiliation="NEB, TU",
                description="No description available.",
                programs=["+2 Science", "+2 Management"],
                facilities=[],
                average_rating=0.0,
                total_reviews=0,
            ),
        ]

        for college in colleges:
            existing_college = (
                db.query(College).filter(College.name == college.name).first()
            )
            if not existing_college:
                db.add(college)

        db.commit()

        # Get created users and colleges for creating reviews
        user_aditya = db.query(User).filter(User.username == "adityasharma").first()
        user_priya = db.query(User).filter(User.username == "priyapatel").first()
        user_rohan = db.query(User).filter(User.username == "rohanthapa").first()

        iit_delhi = db.query(College).filter(College.name.contains("IIT Delhi")).first()
        srcc = db.query(College).filter(College.name.contains("Shri Ram")).first()
        nit_trichy = (
            db.query(College).filter(College.name.contains("NIT Trichy")).first()
        )

        # Create sample reviews
        print("Creating sample reviews...")
        reviews = []

        if iit_delhi and user_aditya:
            reviews.append(
                Review(
                    college_id=iit_delhi.id,
                    user_id=user_aditya.id,
                    rating=4.5,
                    title="Great college with excellent facilities",
                    content="I studied here for 4 years and had an amazing experience. The professors are knowledgeable and the campus facilities are top-notch.",
                    program="Computer Engineering",
                    graduation_year="2023",
                    is_verified=True,
                    likes_count=12,
                    created_at=datetime.now() - timedelta(days=30),
                )
            )

        if srcc and user_priya:
            reviews.append(
                Review(
                    college_id=srcc.id,
                    user_id=user_priya.id,
                    rating=4.0,
                    title="Good academic environment",
                    content="The academic standards are high and there are many opportunities for extracurricular activities. The library is well-stocked.",
                    program="Business Administration",
                    graduation_year="2024",
                    is_verified=True,
                    likes_count=8,
                    created_at=datetime.now() - timedelta(days=15),
                )
            )

        if nit_trichy and user_rohan:
            reviews.append(
                Review(
                    college_id=nit_trichy.id,
                    user_id=user_rohan.id,
                    rating=3.5,
                    title="Decent college but room for improvement",
                    content="The college is okay but could improve on infrastructure and modernize the curriculum.",
                    program="Civil Engineering",
                    graduation_year="2023",
                    is_verified=False,
                    likes_count=3,
                    created_at=datetime.now() - timedelta(days=7),
                )
            )

        for review in reviews:
            db.add(review)

        db.commit()

        # Update college review counts and ratings
        print("Updating college statistics...")
        colleges_to_update = db.query(College).all()
        for college in colleges_to_update:
            reviews_count = (
                db.query(Review).filter(Review.college_id == college.id).count()
            )
            if reviews_count > 0:
                avg_rating = (
                    db.query(func.avg(Review.rating))
                    .filter(Review.college_id == college.id)
                    .scalar()
                )
                college.total_reviews = reviews_count
                college.average_rating = round(avg_rating, 1) if avg_rating else 0.0

        db.commit()

        print("✅ Sample data created successfully!")
        print("\n📋 Sample users created:")
        print("   • Username: ram, Password: 123456")
        print(f"\n🏫 Created {len(colleges)} colleges")
        print(f"📝 Created {len(reviews)} reviews")

    except Exception as e:
        print(f"❌ Error creating sample data: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    create_sample_data()
