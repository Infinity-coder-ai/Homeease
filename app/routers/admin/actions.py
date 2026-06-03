# Admin provider action endpoints: approve, reject, deactivate.
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import session
from ... import database, models, oauth2
from ...provider_verification import sync_documents_verified
from ...services.notifications import (
    notify_provider_application_approved,
    notify_provider_application_rejected,
    notify_provider_document_decision,
    notify_provider_role_assigned,
)
from .deps import require_admin

router = APIRouter()


# Approve a pending provider and grant provider role.
@router.patch("/provider-requests/{provider_id}/approve")
def approve_provider(
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

    sync_documents_verified(db, provider_id)
    if not provider.documents_verified:
        raise HTTPException(
            status_code=400,
            detail="Approve all required documents before approving provider",
        )

    provider.verification_status = "APPROVED"

    # Background approval should be visible to the provider immediately.
    notify_provider_application_approved(db, provider_id)

    db.commit()
    return {"message": "Provider background verification approved"}


# Approve one provider document. All required documents must be approved before
# documents_verified becomes true and provider approval is allowed.
@router.patch("/provider-requests/{provider_id}/documents/{document_id}/approve")
def approve_provider_document(
    provider_id: int,
    document_id: int,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    require_admin(current_user)

    document = (
        db.query(models.ProviderDocuments)
        .filter(
            models.ProviderDocuments.id == document_id,
            models.ProviderDocuments.provider_id == provider_id,
        )
        .first()
    )
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")

    document.verification_status = "APPROVED"
    documents_verified = sync_documents_verified(db, provider_id)

    notify_provider_document_decision(
        db,
        provider_id=provider_id,
        document_type=document.document_type,
        approved=True,
    )
    db.commit()

    return {
        "message": "Document approved",
        "documents_verified": documents_verified,
    }


# Reject one provider document and mark the overall document gate incomplete.
@router.patch("/provider-requests/{provider_id}/documents/{document_id}/reject")
def reject_provider_document(
    provider_id: int,
    document_id: int,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    require_admin(current_user)

    document = (
        db.query(models.ProviderDocuments)
        .filter(
            models.ProviderDocuments.id == document_id,
            models.ProviderDocuments.provider_id == provider_id,
        )
        .first()
    )
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")

    document.verification_status = "REJECTED"
    sync_documents_verified(db, provider_id)

    notify_provider_document_decision(
        db,
        provider_id=provider_id,
        document_type=document.document_type,
        approved=False,
    )
    db.commit()

    return {"message": "Document rejected", "documents_verified": False}


# Reject a pending provider and keep role as customer.
@router.patch("/provider-requests/{provider_id}/reject")
def reject_provider(
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

    provider.verification_status = "REJECTED"

    user = db.query(models.Users).filter(models.Users.id == provider_id).first()
    if user:
        user.role = "customer"

    # Rejected applications should still leave a clear inbox trail for the provider.
    notify_provider_application_rejected(db, provider_id)

    db.commit()
    return {"message": "Provider rejected"}


# Assign the provider role to a background-verified provider.
# This is the final step that unlocks the provider dashboard for the user.
@router.patch("/providers/{provider_id}/assign-role")
def assign_provider_role(
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

    if provider.verification_status != "APPROVED":
        raise HTTPException(
            status_code=400,
            detail="Background verification must be approved before assigning provider role",
        )

    user = db.query(models.Users).filter(models.Users.id == provider_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.role == "provider":
        return {"message": "Provider role already assigned"}

    user.role = "provider"

    # Final role assignment is the moment the provider dashboard becomes active.
    notify_provider_role_assigned(db, provider_id)
    db.commit()
    return {"message": "Provider role assigned successfully"}


# Soft-deactivate a provider account (hides them from the app).
@router.patch("/providers/{provider_id}/deactivate")
def deactivate_provider(
    provider_id: int,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    require_admin(current_user)

    user = db.query(models.Users).filter(models.Users.id == provider_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_active = False
    db.commit()
    return {"message": "Provider deactivated"}
