from pydantic import BaseModel, EmailStr
from typing import Optional, List, Dict, Any
from datetime import datetime


# User Schemas
class UserBase(BaseModel):
    email: EmailStr
    username: str
    full_name: Optional[str] = None


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    profile_picture: Optional[str] = None


class UserResponse(UserBase):
    id: int
    is_active: bool
    is_verified: bool
    profile_picture: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class UserInDB(UserResponse):
    hashed_password: str


class UserStats(BaseModel):
    total_reviews: int
    total_likes_received: int
    people_helped: int
    saved_colleges_count: int
    joined_date: datetime


# Saved College Schemas
class SavedCollegeBase(BaseModel):
    college_id: int


class SavedCollegeCreate(SavedCollegeBase):
    pass


class SavedCollegeResponse(BaseModel):
    id: int
    user_id: int
    college_id: int
    college_name: str
    college_location: Optional[str] = None
    college_logo_url: Optional[str] = None
    college_average_rating: float
    college_total_reviews: int
    saved_at: datetime

    class Config:
        from_attributes = True


# College Schemas
class CollegeBase(BaseModel):
    name: str
    location: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    country: str = "India"
    website: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    established_year: Optional[int] = None
    college_type: Optional[str] = None
    affiliation: Optional[str] = None
    description: Optional[str] = None


class CollegeCreate(CollegeBase):
    logo_url: Optional[str] = None
    images: Optional[List[str]] = []
    programs: Optional[List[str]] = []
    facilities: Optional[List[str]] = []
    college_metadata: Optional[Dict[str, Any]] = {}


class CollegeResponse(CollegeBase):
    id: int
    logo_url: Optional[str] = None
    images: Optional[List[str]] = []
    programs: Optional[List[str]] = []
    facilities: Optional[List[str]] = []
    average_rating: float = 0.0
    total_reviews: int = 0
    college_metadata: Optional[Dict[str, Any]] = {}
    is_saved_by_current_user: Optional[bool] = False
    created_at: datetime

    class Config:
        from_attributes = True


# Review Schemas
class ReviewBase(BaseModel):
    rating: float
    title: str
    content: str
    program: Optional[str] = None
    graduation_year: Optional[str] = None


class ReviewCreate(ReviewBase):
    college_id: int
    images: Optional[List[str]] = []


class ReviewUpdate(BaseModel):
    rating: Optional[float] = None
    title: Optional[str] = None
    content: Optional[str] = None
    program: Optional[str] = None
    graduation_year: Optional[str] = None
    images: Optional[List[str]] = None


class ReviewResponse(ReviewBase):
    id: int
    college_id: int
    user_id: int
    user_name: str = ""
    images: Optional[List[str]] = []
    is_verified: bool = False
    likes_count: int = 0
    is_liked_by_current_user: bool = False
    is_owned_by_current_user: bool = False
    college_name: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# Auth Schemas
class Token(BaseModel):
    access_token: str
    token_type: str


class AuthResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


class TokenData(BaseModel):
    username: Optional[str] = None


class LoginRequest(BaseModel):
    username: str
    password: str


# Response Models
class ReviewListResponse(BaseModel):
    reviews: List[ReviewResponse]
    total: int
    page: int
    pages: int


class CollegeListResponse(BaseModel):
    colleges: List[CollegeResponse]
    total: int
    page: int
    pages: int

    class config:
        from_attributes: True


class SavedCollegeListResponse(BaseModel):
    saved_colleges: List[SavedCollegeResponse]
    total: int
    page: int
    pages: int
