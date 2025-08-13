from fastapi import FastAPI, Depends, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from typing import List, Optional
from datetime import timedelta, datetime
import math

from database import get_db, engine
from models import Base, User, College, Review, ReviewLike
from schemas import *
from auth import *

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Udaan API",
    description="API for college reviews and user management",
    version="1.0.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Auth endpoints
@app.post("/auth/register", response_model=AuthResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    db_user = (
        db.query(User)
        .filter((User.email == user.email) | (User.username == user.username))
        .first()
    )
    if db_user:
        raise HTTPException(
            status_code=400, detail="User with this email or username already exists"
        )

    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        username=user.username,
        full_name=user.full_name,
        hashed_password=hashed_password,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    # Create access token for the newly registered user
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": db_user.username}, expires_delta=access_token_expires
    )

    return {"access_token": access_token, "token_type": "bearer", "user": db_user}


@app.post("/auth/login", response_model=Token)
def login_user(login_data: LoginRequest, db: Session = Depends(get_db)):
    user = authenticate_user(db, login_data.username, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/auth/me", response_model=UserResponse)
def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user


# College endpoints
@app.post("/colleges", response_model=CollegeResponse)
def create_college(
    college: CollegeCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    db_college = College(**college.dict())
    db.add(db_college)
    db.commit()
    db.refresh(db_college)
    return db_college


@app.get("/colleges", response_model=CollegeListResponse)
def get_colleges(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    search: Optional[str] = None,
    city: Optional[str] = None,
    state: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(College)

    # Apply filters
    if search:
        query = query.filter(College.name.ilike(f"%{search}%"))
    if city:
        query = query.filter(College.city.ilike(f"%{city}%"))
    if state:
        query = query.filter(College.state.ilike(f"%{state}%"))

    # Get total count
    total = query.count()

    # Apply pagination
    offset = (page - 1) * limit
    colleges = query.offset(offset).limit(limit).all()

    pages = math.ceil(total / limit)
    print("colleges are ", colleges)
    return CollegeListResponse(colleges=colleges, total=total, page=page, pages=pages)


@app.get("/colleges/{college_id}", response_model=CollegeResponse)
def get_college(college_id: int, db: Session = Depends(get_db)):
    college = db.query(College).filter(College.id == college_id).first()
    if not college:
        raise HTTPException(status_code=404, detail="College not found")
    return college


# Review endpoints
@app.post("/reviews", response_model=ReviewResponse)
def create_review(
    review: ReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    # Check if college exists
    college = db.query(College).filter(College.id == review.college_id).first()
    if not college:
        raise HTTPException(status_code=404, detail="College not found")

    # Check if user already reviewed this college
    existing_review = (
        db.query(Review)
        .filter(
            Review.college_id == review.college_id, Review.user_id == current_user.id
        )
        .first()
    )
    if existing_review:
        raise HTTPException(
            status_code=400, detail="You have already reviewed this college"
        )

    # Create review
    db_review = Review(**review.dict(), user_id=current_user.id)
    db.add(db_review)
    db.flush()  # Ensure the review is visible to subsequent queries

    # Update college ratings
    college.total_reviews += 1
    avg_rating = (
        db.query(func.avg(Review.rating))
        .filter(Review.college_id == review.college_id)
        .scalar()
    )
    if avg_rating is None:
        college.average_rating = round(review.rating, 1)
    else:
        college.average_rating = round(avg_rating, 1)

    db.commit()
    db.refresh(db_review)

    # Return review with user name
    response = ReviewResponse.from_orm(db_review)
    response.user_name = current_user.username
    response.is_liked_by_current_user = False

    return response


@app.get("/colleges/{college_id}/reviews", response_model=ReviewListResponse)
def get_college_reviews(
    college_id: int,
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional),
):
    # Check if college exists
    college = db.query(College).filter(College.id == college_id).first()
    if not college:
        raise HTTPException(status_code=404, detail="College not found")

    # Get reviews with user information
    query = db.query(Review).filter(Review.college_id == college_id).join(User)
    total = query.count()

    offset = (page - 1) * limit
    reviews = query.offset(offset).limit(limit).all()

    # Convert to response format
    review_responses = []
    for review in reviews:
        review_response = ReviewResponse.from_orm(review)
        review_response.user_name = review.user.username

        # Check if current user liked this review
        if current_user:
            liked = (
                db.query(ReviewLike)
                .filter(
                    ReviewLike.review_id == review.id,
                    ReviewLike.user_id == current_user.id,
                )
                .first()
            )
            review_response.is_liked_by_current_user = liked is not None
        else:
            review_response.is_liked_by_current_user = False

        review_responses.append(review_response)

    pages = math.ceil(total / limit)

    return ReviewListResponse(
        reviews=review_responses, total=total, page=page, pages=pages
    )


@app.post("/reviews/{review_id}/like")
def toggle_review_like(
    review_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    # Check if review exists
    review = db.query(Review).filter(Review.id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")

    # Check if already liked
    existing_like = (
        db.query(ReviewLike)
        .filter(
            ReviewLike.review_id == review_id, ReviewLike.user_id == current_user.id
        )
        .first()
    )

    if existing_like:
        # Unlike
        db.delete(existing_like)
        review.likes_count -= 1
        liked = False
    else:
        # Like
        new_like = ReviewLike(review_id=review_id, user_id=current_user.id)
        db.add(new_like)
        review.likes_count += 1
        liked = True

    db.commit()

    return {"liked": liked, "likes_count": review.likes_count}


# Health check
@app.get("/")
def root():
    return {"message": "College Review API is running!"}


@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.now()}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
