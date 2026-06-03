# return the service available 
from .. import schemas,database,models
from sqlalchemy.orm import Session
from fastapi import APIRouter,status,Depends

router = APIRouter()
@router.get("/services_catalog",response_model = list[schemas.ServiceOut])
def list_serrvices(db:Session = Depends(database.get_db)):
  return db.query(models.Services).filter(models.Services.is_active==True).all()