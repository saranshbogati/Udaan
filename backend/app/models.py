from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    Text,
    DateTime,
    Boolean,
    ForeignKey,
    JSON,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    profile_picture = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    reviews = relationship("Review", back_populates="user")
    review_likes = relationship("ReviewLike", back_populates="user")
    saved_colleges = relationship("SavedCollege", back_populates="user")


class College(Base):
    __tablename__ = "colleges"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    location = Column(String)
    city = Column(String)
    state = Column(String)
    country = Column(String, default="Nepal")
    website = Column(String)
    phone = Column(String)
    email = Column(String)
    established_year = Column(Integer)
    college_type = Column(String)  # Public/Private/Autonomous
    affiliation = Column(String)  # University affiliation
    description = Column(Text)
    logo_url = Column(String)
    images = Column(JSON)  # Array of image URLs
    programs = Column(JSON)  # Array of programs offered
    facilities = Column(JSON)  # Array of facilities
    average_rating = Column(Float, default=0.0)
    total_reviews = Column(Integer, default=0)
    college_metadata = Column(JSON)  # Flexible field for additional data
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    reviews = relationship("Review", back_populates="college")
    saved_by_users = relationship("SavedCollege", back_populates="college")


class Review(Base):
    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, index=True)
    college_id = Column(Integer, ForeignKey("colleges.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    rating = Column(Float, nullable=False)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    program = Column(String)  # Course/Program studied
    graduation_year = Column(String)
    images = Column(JSON)  # Array of image URLs
    is_verified = Column(Boolean, default=False)
    likes_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="reviews")
    college = relationship("College", back_populates="reviews")
    likes = relationship("ReviewLike", back_populates="review")


class ReviewLike(Base):
    __tablename__ = "review_likes"

    id = Column(Integer, primary_key=True, index=True)
    review_id = Column(Integer, ForeignKey("reviews.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    review = relationship("Review", back_populates="likes")
    user = relationship("User", back_populates="review_likes")

    # Ensure unique constraint
    __table_args__ = ({"sqlite_autoincrement": True},)


class SavedCollege(Base):
    __tablename__ = "saved_colleges"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    college_id = Column(Integer, ForeignKey("colleges.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="saved_colleges")
    college = relationship("College", back_populates="saved_by_users")

    # Ensure unique constraint
    __table_args__ = ({"sqlite_autoincrement": True},)
