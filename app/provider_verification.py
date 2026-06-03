from . import models


# Required documents for provider verification. A provider cannot be approved
# until at least one approved document exists for every type in this tuple.
REQUIRED_PROVIDER_DOCUMENT_TYPES = ("AADHAAR", "PROFILE_PHOTO")


def normalize_document_type(document_type: str) -> str:
    normalized = document_type.strip().upper()
    # ID_PROOF was used by the older UI. Treat it as Aadhaar so old clients
    # do not break while the new workflow shows Aadhaar explicitly.
    if normalized == "ID_PROOF":
        return "AADHAAR"
    return normalized


def sync_documents_verified(db, provider_id: int) -> bool:
    provider = (
        db.query(models.ServiceProviders)
        .filter(models.ServiceProviders.id == provider_id)
        .first()
    )
    if not provider:
        return False

    approved_types = {
        document.document_type
        for document in db.query(models.ProviderDocuments)
        .filter(
            models.ProviderDocuments.provider_id == provider_id,
            models.ProviderDocuments.verification_status == "APPROVED",
        )
        .all()
    }

    # This field is the durable flag the app can show to providers/admins.
    provider.documents_verified = all(
        required_type in approved_types
        for required_type in REQUIRED_PROVIDER_DOCUMENT_TYPES
    )
    return provider.documents_verified
