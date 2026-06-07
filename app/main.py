from fastapi import FastAPI
from sqlalchemy import update
from .database import engine
from . import models

from .routers import user,auth,create_provider,create_services,provider_availability,provider_documents,bookings,booking_status,service_catalog ,provider_services,provider_stats,notifications,support
from .routers import email_auth
from .routers.admin import router as admin_router
from .routers.show_bookings import customer_bookings ,provider_bookings,search_providers
from .routers.booking_rating import rating


def ensure_provider_workflow_columns():
    """Keep the database compatible with the current SQLAlchemy models."""
    models.Base.metadata.create_all(bind=engine)

    with engine.begin() as conn:
        conn.execute(
            update(models.ProviderDocuments)
            .where(models.ProviderDocuments.document_type == 'ID_PROOF')
            .values(document_type='AADHAAR')
        )


ensure_provider_workflow_columns()
app = FastAPI()

app.include_router(user.router) # added new route in app object
app.include_router(auth.router)
app.include_router(create_provider.router)
app.include_router(create_services.router)
app.include_router(provider_availability.router)
app.include_router(provider_documents.router)
app.include_router(bookings.router)
app.include_router(booking_status.router)
app.include_router(customer_bookings.router)
app.include_router(provider_bookings.router)
app.include_router(rating.router)
app.include_router(search_providers.router)
app.include_router(service_catalog.router)
app.include_router(provider_services.router)
app.include_router(provider_stats.router)
app.include_router(notifications.router)
app.include_router(support.router)
app.include_router(admin_router)
app.include_router(email_auth.router)
