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


class ReviewResponse(ReviewBase):
    id: int
    college_id: int
    user_id: int
    user_name: str
    images: Optional[List[str]] = []
    is_verified: bool = False
    likes_count: int = 0
    is_liked_by_current_user: bool = False
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
