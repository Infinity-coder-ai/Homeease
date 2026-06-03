# Admin provider details endpoints: documents, services, availability.
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import session
from ... import database, models, oauth2
from .deps import require_admin

router = APIRouter()


# Fetch provider documents for admin review.
@router.get("/provider-requests/{provider_id}/documents")
def provider_documents(
    provider_id: int,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    require_admin(current_user)

    return (
        db.query(models.ProviderDocuments)
        .filter(models.ProviderDocuments.provider_id == provider_id)
        .all()
    )


# Fetch provider profile details with services and availability.
@router.get("/providers/{provider_id}/details")
def provider_details(
    provider_id: int,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    require_admin(current_user)

    provider = (
        db.query(models.ServiceProviders)
        .filter(models.ServiceProviders.id == provider_id)
        .first()
    )
    if not provider:
        raise HTTPException(status_code=404, detail="Provider not found")

    services = (
        db.query(
            models.Services.name,
            models.ProviderServices.price,
            models.ProviderServices.estimated_duration_minutes,
        )
        .join(models.Services, models.Services.id == models.ProviderServices.service_id)
        .filter(models.ProviderServices.provider_id == provider_id)
        .all()
    )

    availability = (
        db.query(models.ProviderAvailability)
        .filter(models.ProviderAvailability.provider_id == provider_id)
        .all()
    )

    documents = (
        db.query(models.ProviderDocuments)
        .filter(models.ProviderDocuments.provider_id == provider_id)
        .all()
    )

    return {
        "provider": {
            "id": provider.id,
            "city": provider.city,
            "area": provider.area,
            "pincode": provider.pincode,
            "experience_years": provider.experience_years,
            "verification_status": provider.verification_status,
            "documents_verified": provider.documents_verified,
        },
        "services": [
            {
                "service_name": s.name,
                "price": s.price,
                "estimated_duration_minutes": s.estimated_duration_minutes,
            }
            for s in services
        ],
        "availability": availability,
        "documents": documents,
    }
