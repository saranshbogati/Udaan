from fastapi import FastAPI, Depends, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from sqlalchemy import and_, or_, desc
from typing import List, Optional
from datetime import timedelta, datetime
import math

from database import get_db, engine
from models import Base, User, College, Review, ReviewLike, SavedCollege
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


# Profile endpoints
@app.get("/profile/stats", response_model=UserStats)
def get_user_stats(current_user: User = Depends(get_current_active_user), db: Session = Depends(get_db)):
    # Get total reviews by user
    total_reviews = db.query(Review).filter(Review.user_id == current_user.id).count()
    
    # Get total likes received on user's reviews
    total_likes_received = (
        db.query(func.sum(Review.likes_count))
        .filter(Review.user_id == current_user.id)
        .scalar() or 0
    )
    
    # People helped is same as total likes received for now
    people_helped = total_likes_received
    
    # Get saved colleges count
    saved_colleges_count = db.query(SavedCollege).filter(SavedCollege.user_id == current_user.id).count()
    
    return UserStats(
        total_reviews=total_reviews,
        total_likes_received=total_likes_received,
        people_helped=people_helped,
        saved_colleges_count=saved_colleges_count,
        joined_date=current_user.created_at
    )


@app.put("/profile", response_model=UserResponse)
def update_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Check if email already exists (if being updated)
    if user_update.email and user_update.email != current_user.email:
        existing_user = db.query(User).filter(User.email == user_update.email).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already exists")
    
    # Update user fields
    for field, value in user_update.dict(exclude_unset=True).items():
        setattr(current_user, field, value)
    
    db.commit()
    db.refresh(current_user)
    return current_user


@app.get("/profile/reviews", response_model=ReviewListResponse)
def get_user_reviews(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    query = (
        db.query(Review)
        .filter(Review.user_id == current_user.id)
        .join(College)
        .order_by(desc(Review.created_at))
    )
    
    total = query.count()
    offset = (page - 1) * limit
    reviews = query.offset(offset).limit(limit).all()
    
    # Convert to response format
    review_responses = []
    for review in reviews:
        review_response = ReviewResponse.from_orm(review)
        review_response.user_name = current_user.username
        review_response.college_name = review.college.name
        review_response.is_owned_by_current_user = True
        review_response.is_liked_by_current_user = False
        review_responses.append(review_response)
    
    pages = math.ceil(total / limit)
    return ReviewListResponse(
        reviews=review_responses, total=total, page=page, pages=pages
    )


@app.get("/profile/liked-reviews", response_model=ReviewListResponse)
def get_liked_reviews(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Get reviews that the current user has liked
    query = (
        db.query(Review)
        .join(ReviewLike, Review.id == ReviewLike.review_id)
        .join(User, Review.user_id == User.id)
        .join(College, Review.college_id == College.id)
        .filter(ReviewLike.user_id == current_user.id)
        .order_by(desc(ReviewLike.created_at))
    )
    
    total = query.count()
    offset = (page - 1) * limit
    reviews = query.offset(offset).limit(limit).all()
    
    # Convert to response format
    review_responses = []
    for review in reviews:
        review_response = ReviewResponse.from_orm(review)
        review_response.user_name = review.user.username
        review_response.college_name = review.college.name
        review_response.is_liked_by_current_user = True
        review_response.is_owned_by_current_user = review.user_id == current_user.id
        review_responses.append(review_response)
    
    pages = math.ceil(total / limit)
    return ReviewListResponse(
        reviews=review_responses, total=total, page=page, pages=pages
    )


@app.get("/profile/saved-colleges", response_model=SavedCollegeListResponse)
def get_saved_colleges(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    query = (
        db.query(SavedCollege)
        .join(College)
        .filter(SavedCollege.user_id == current_user.id)
        .order_by(desc(SavedCollege.created_at))
    )
    
    total = query.count()
    offset = (page - 1) * limit
    saved_colleges = query.offset(offset).limit(limit).all()
    
    # Convert to response format
    saved_college_responses = []
    for saved_college in saved_colleges:
        response = SavedCollegeResponse(
            id=saved_college.id,
            user_id=saved_college.user_id,
            college_id=saved_college.college_id,
            college_name=saved_college.college.name,
            college_location=saved_college.college.location,
            college_logo_url=saved_college.college.logo_url,
            college_average_rating=saved_college.college.average_rating,
            college_total_reviews=saved_college.college.total_reviews,
            saved_at=saved_college.created_at
        )
        saved_college_responses.append(response)
    
    pages = math.ceil(total / limit)
    return SavedCollegeListResponse(
        saved_colleges=saved_college_responses, total=total, page=page, pages=pages
    )


# College bookmark endpoints
@app.post("/colleges/{college_id}/bookmark")
def toggle_college_bookmark(
    college_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Check if college exists
    college = db.query(College).filter(College.id == college_id).first()
    if not college:
        raise HTTPException(status_code=404, detail="College not found")
    
    # Check if already saved
    existing_save = (
        db.query(SavedCollege)
        .filter(
            SavedCollege.college_id == college_id,
            SavedCollege.user_id == current_user.id
        )
        .first()
    )
    
    if existing_save:
        # Remove bookmark
        db.delete(existing_save)
        saved = False
    else:
        # Add bookmark
        new_save = SavedCollege(college_id=college_id, user_id=current_user.id)
        db.add(new_save)
        saved = True
    
    db.commit()
    return {"saved": saved, "college_id": college_id}


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
    current_user: Optional[User] = Depends(get_current_user),
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

    # Convert to response format with bookmark status
    college_responses = []
    for college in colleges:
        college_response = CollegeResponse.from_orm(college)
        
        # Check if saved by current user
        if current_user:
            is_saved = (
                db.query(SavedCollege)
                .filter(
                    SavedCollege.college_id == college.id,
                    SavedCollege.user_id == current_user.id
                )
                .first() is not None
            )
            college_response.is_saved_by_current_user = is_saved
        else:
            college_response.is_saved_by_current_user = False
        
        college_responses.append(college_response)

    pages = math.ceil(total / limit)
    return CollegeListResponse(colleges=college_responses, total=total, page=page, pages=pages)


@app.get("/colleges/{college_id}", response_model=CollegeResponse)
def get_college(
    college_id: int, 
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user)
):
    college = db.query(College).filter(College.id == college_id).first()
    if not college:
        raise HTTPException(status_code=404, detail="College not found")
    
    college_response = CollegeResponse.from_orm(college)
    
    # Check if saved by current user
    if current_user:
        is_saved = (
            db.query(SavedCollege)
            .filter(
                SavedCollege.college_id == college.id,
                SavedCollege.user_id == current_user.id
            )
            .first() is not None
        )
        college_response.is_saved_by_current_user = is_saved
    else:
        college_response.is_saved_by_current_user = False
    
    return college_response


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

    # Update college ratings
    college.total_reviews += 1
    avg_rating = (
        db.query(func.avg(Review.rating))
        .filter(Review.college_id == review.college_id)
        .scalar()
    )
    college.average_rating = round(avg_rating, 1)

    db.commit()
    db.refresh(db_review)

    # Return review with user name
    response = ReviewResponse.from_orm(db_review)
    response.user_name = current_user.username
    response.college_name = college.name
    response.is_liked_by_current_user = False
    response.is_owned_by_current_user = True

    return response


@app.put("/reviews/{review_id}", response_model=ReviewResponse)
def update_review(
    review_id: int,
    review_update: ReviewUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    # Get the review
    review = db.query(Review).filter(Review.id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    
    # Check if user owns the review
    if review.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this review")
    
    # Update review fields
    for field, value in review_update.dict(exclude_unset=True).items():
        setattr(review, field, value)
    
    # Update college average rating if rating changed
    if review_update.rating is not None:
        college = db.query(College).filter(College.id == review.college_id).first()
        avg_rating = (
            db.query(func.avg(Review.rating))
            .filter(Review.college_id == review.college_id)
            .scalar()
        )
        college.average_rating = round(avg_rating, 1)
    
    db.commit()
    db.refresh(review)
    
    # Return updated review
    response = ReviewResponse.from_orm(review)
    response.user_name = current_user.username
    response.college_name = review.college.name
    response.is_owned_by_current_user = True
    
    # Check if current user liked this review
    liked = (
        db.query(ReviewLike)
        .filter(
            ReviewLike.review_id == review.id,
            ReviewLike.user_id == current_user.id,
        )
        .first()
    )
    response.is_liked_by_current_user = liked is not None
    
    return response


@app.delete("/reviews/{review_id}")
def delete_review(
    review_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    # Get the review
    review = db.query(Review).filter(Review.id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    
    # Check if user owns the review
    if review.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this review")
    
    college_id = review.college_id
    
    # Delete the review (cascade will handle review likes)
    db.delete(review)
    
    # Update college ratings
    college = db.query(College).filter(College.id == college_id).first()
    college.total_reviews -= 1
    
    if college.total_reviews > 0:
        avg_rating = (
            db.query(func.avg(Review.rating))
            .filter(Review.college_id == college_id)
            .scalar()
        )
        college.average_rating = round(avg_rating, 1)
    else:
        college.average_rating = 0.0
    
    db.commit()
    
    return {"message": "Review deleted successfully"}


@app.get("/colleges/{college_id}/reviews", response_model=ReviewListResponse)
def get_college_reviews(
    college_id: int,
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user),
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
        review_response.college_name = college.name

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
            review_response.is_owned_by_current_user = review.user_id == current_user.id
        else:
            review_response.is_liked_by_current_user = False
            review_response.is_owned_by_current_user = False

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
