from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import session
from .. import database, models, schemas, oauth2

router = APIRouter()

@router.get("/providers/stats", response_model=schemas.ProviderStatsOut)
def get_provider_stats(
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user),
):
    provider = (
        db.query(models.ServiceProviders)
        .filter(models.ServiceProviders.id == current_user.id)
        .first()
    )
    if not provider:
        raise HTTPException(status_code=404, detail="Provider not found")
    return provider