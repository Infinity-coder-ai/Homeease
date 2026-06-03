# Admin provider request endpoints: list pending/approved/rejected.
from fastapi import APIRouter, Depends
from sqlalchemy.orm import session
from sqlalchemy import func
from ... import database, models, oauth2
from .deps import require_admin

router = APIRouter()


# List only pending provider applications for review.
@router.get("/provider-requests")
def list_provider_requests(
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    require_admin(current_user)

    requests = (
        db.query(
            models.ServiceProviders.id,
            models.Users.name,
            models.Users.email,
            models.Users.phone,
            models.ServiceProviders.city,
            models.ServiceProviders.area,
            models.ServiceProviders.pincode,
            models.ServiceProviders.experience_years,
            models.ServiceProviders.verification_status,
            models.ServiceProviders.documents_verified,
            models.ServiceProviders.created_at,
        )
        .join(models.Users, models.Users.id == models.ServiceProviders.id)
        .filter(models.ServiceProviders.verification_status == "PENDING")
        .all()
    )
    return [
        {
            "id": row.id,
            "name": row.name,
            "email": row.email,
            "phone": row.phone,
            "city": row.city,
            "area": row.area,
            "pincode": row.pincode,
            "experience_years": row.experience_years,
            "verification_status": row.verification_status,
            "documents_verified": row.documents_verified,
            "created_at": row.created_at,
        }
        for row in requests
    ]


# List providers by status (APPROVED/REJECTED/PENDING), with optional city and rating filters.
@router.get("/providers")
def list_providers(
    status: str | None = None,
    city: str | None = None,
    min_rating: float | None = None,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    require_admin(current_user)

    ratings_subquery = (
        db.query(
            models.Ratings.provider_id.label("provider_id"),
            func.avg(models.Ratings.rating).label("avg_rating"),
        )
        .group_by(models.Ratings.provider_id)
        .subquery()
    )

    query = (
        db.query(
            models.ServiceProviders.id,
            models.Users.name,
            models.Users.email,
            models.Users.phone,
            models.Users.role,
            models.ServiceProviders.city,
            models.ServiceProviders.area,
            models.ServiceProviders.pincode,
            models.ServiceProviders.verification_status,
            models.ServiceProviders.documents_verified,
            ratings_subquery.c.avg_rating,
        )
        .join(models.Users, models.Users.id == models.ServiceProviders.id)
        .outerjoin(
            ratings_subquery,
            ratings_subquery.c.provider_id == models.ServiceProviders.id,
        )
    )

    if status:
        query = query.filter(models.ServiceProviders.verification_status == status)

    if city:
        query = query.filter(models.ServiceProviders.city.ilike(f"%{city}%"))

    if min_rating is not None:
        query = query.filter(ratings_subquery.c.avg_rating >= min_rating)

    rows = query.all()
    return [
        {
            "id": row.id,
            "name": row.name,
            "email": row.email,
            "phone": row.phone,
            "role": row.role,
            "city": row.city,
            "area": row.area,
            "pincode": row.pincode,
            "verification_status": row.verification_status,
            "documents_verified": row.documents_verified,
            "average_rating": float(row.avg_rating) if row.avg_rating is not None else None,
        }
        for row in rows
    ]
