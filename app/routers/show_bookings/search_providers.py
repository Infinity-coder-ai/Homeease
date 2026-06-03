from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from ... import models, database, schemas,oauth2

router = APIRouter()

@router.get("/providers/search", response_model=list[schemas.ProviderSearchResponse])
def search_providers(
    service_id: int = Query(...),# Query(...) tells FastAPI that this value should come from the URL query string.
    city: str | None = None,
    area: str | None = None,
    db: Session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user)
):

    query = db.query(
        models.ServiceProviders.id,
        models.Users.name,
        models.ServiceProviders.city,
        models.ServiceProviders.area,
        models.ServiceProviders.trust_score,
        models.ServiceProviders.total_jobs_completed,
        models.ProviderServices.price
        
    ).join(
        models.ProviderServices,
        models.ServiceProviders.id == models.ProviderServices.provider_id
    ).join(
        models.Users,
        models.Users.id == models.ServiceProviders.id
    ).filter(
        models.ServiceProviders.id !=current_user.id,
        models.ProviderServices.service_id == service_id,
        models.ProviderServices.is_available == True,
        models.ServiceProviders.verification_status=="APPROVED",
        models.Users.is_active==True
    )

    if city:
        query = query.filter(models.ServiceProviders.city.ilike(f"%{city}%"))

    if area:
        query = query.filter(models.ServiceProviders.area.ilike(f"%{area}%"))

    providers = query.all()

    return providers
    # result = []

    # for provider, user in providers:
    #     result.append({
    #         "id": provider.id,
    #         "name": user.name,
    #         "city": provider.city,
    #         "area": provider.area,
    #         "trust_score": provider.trust_score,
    #         "total_jobs_completed": provider.total_jobs_completed
    #     })

    # return result