from fastapi import APIRouter, Depends
from sqlalchemy.orm import session

from .. import database, models, oauth2, schemas
from .admin.deps import require_admin

router = APIRouter()


@router.post("/support/reports", status_code=201, response_model=schemas.SupportReportOut)
def create_support_report(
    payload: schemas.SupportReportCreate,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    # Save the report to the database so support requests are not lost.
    report = models.SupportReports(
        user_id=current_user.id,
        user_name=current_user.name,
        user_email=current_user.email,
        description=payload.description.strip(),
        status="OPEN",
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report


@router.get("/admin/support/reports", response_model=list[schemas.SupportReportOut])
def list_support_reports(
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    require_admin(current_user)
    return (
        db.query(models.SupportReports)
        .order_by(models.SupportReports.created_at.desc())
        .all()
    )
