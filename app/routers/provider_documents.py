from fastapi import APIRouter, HTTPException, File, UploadFile, Depends, Form, status
from .. import models, database, oauth2,schemas
from ..cloudinary import cloudinary_config  # <-- remove the space
from ..provider_verification import (
    REQUIRED_PROVIDER_DOCUMENT_TYPES,
    normalize_document_type,
    sync_documents_verified,
)
from sqlalchemy.orm import session
from sqlalchemy.exc import SQLAlchemyError
import cloudinary.uploader  # <-- important

router = APIRouter(tags=["Provider Documents"])

@router.post("/provider/documents", status_code=status.HTTP_201_CREATED)
def upload_provider_document(
    document_type: str = Form(...),
    file: UploadFile = File(...),
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    document_type = normalize_document_type(document_type)
    
    # check first wheteher provideer exst ot not
    provider = (
    db.query(models.ServiceProviders)
    .filter(models.ServiceProviders.id == current_user.id)
    .first()
    )
    if not provider:
        raise HTTPException(
        status_code=400,
        detail="Create provider profile before uploading documents",
    )
        
        
    if document_type not in REQUIRED_PROVIDER_DOCUMENT_TYPES:
        raise HTTPException(status_code=400, detail="Invalid document type")

    try:
        result = cloudinary.uploader.upload(
            file.file,
            folder=f"providers/{current_user.id}",
        )
        file_url = result["secure_url"]

        doc = models.ProviderDocuments(
            provider_id=current_user.id,
            document_type=document_type,
            file_url=file_url,
            # Every upload starts as pending and must be reviewed by admin.
            verification_status="PENDING",
        )
        db.add(doc)
        sync_documents_verified(db, current_user.id)
        db.commit()
        db.refresh(doc)

        return {"message": "Document uploaded successfully", "file_url": file_url}

    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(status_code=500, detail="Database error")
    
  # get request to get those documents  
@router.get("/provider/documents", response_model=list[schemas.ProviderDocumentOut])
def list_provider_documents(
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    return (
        db.query(models.ProviderDocuments)
        .filter(models.ProviderDocuments.provider_id == current_user.id)
        .all()
    )


@router.get("/provider/application-status")
def provider_application_status(
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    provider = (
        db.query(models.ServiceProviders)
        .filter(models.ServiceProviders.id == current_user.id)
        .first()
    )
    if not provider:
        return {
            "has_application": False,
            "message": "Provider application not started",
        }

    documents = (
        db.query(models.ProviderDocuments)
        .filter(models.ProviderDocuments.provider_id == current_user.id)
        .all()
    )
    document_status = {
        required_type: "NOT_UPLOADED"
        for required_type in REQUIRED_PROVIDER_DOCUMENT_TYPES
    }
    for document in documents:
        if document.document_type in document_status:
            if document_status[document.document_type] == "APPROVED":
                continue
            document_status[document.document_type] = document.verification_status

    documents_verified = sync_documents_verified(db, current_user.id)
    db.commit()

    # This response drives the provider-facing timeline/status screen.
    return {
        "has_application": True,
        "provider_id": provider.id,
        # application_status represents background verification status on the provider profile.
        # Final approval is only when user.role becomes "provider".
        "application_status": provider.verification_status,
        "documents_verified": documents_verified,
        "background_verified": provider.verification_status == "APPROVED",
        "final_approved": current_user.role == "provider",
        "required_documents": list(REQUIRED_PROVIDER_DOCUMENT_TYPES),
        "document_status": document_status,
        "documents": [
            {
                "id": document.id,
                "document_type": document.document_type,
                "file_url": document.file_url,
                "verification_status": document.verification_status,
                "created_at": document.created_at,
            }
            for document in documents
        ],
        "role": current_user.role,
        "created_at": provider.created_at,
    }
