# this return the sevices a provider is providing for provider dashboard
from fastapi import APIRouter, Depends,HTTPException,status
from sqlalchemy.orm import session
from .. import database, models, schemas, oauth2

router = APIRouter()

@router.get("/providers/services", response_model=list[schemas.ProviderServiceOut])
def list_provider_services(
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user),
):
    services = (
        db.query(
            models.ProviderServices.id,
            models.ProviderServices.service_id,
            models.Services.name.label("service_name"),
            models.ProviderServices.price,
            models.ProviderServices.estimated_duration_minutes,
        )
        .join(models.Services, models.Services.id == models.ProviderServices.service_id)
        .filter(models.ProviderServices.provider_id == current_user.id)
        .all()
    )
    return services



@router.delete("/providers/services/{service_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_provider_service(
    service_id: int,
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user),
):
    service = (
        db.query(models.ProviderServices)
        .filter(
            models.ProviderServices.provider_id == current_user.id,
            models.ProviderServices.service_id == service_id,
        )
        .first()
    )
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")

    db.delete(service)
    db.commit()
    return