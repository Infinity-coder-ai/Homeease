from fastapi import FastAPI
from sqlalchemy import text
from .database import engine
from . import models

from .routers import user,auth,create_provider,create_services,provider_availability,provider_documents,bookings,booking_status,service_catalog ,provider_services,provider_stats,notifications,support
from .routers import email_auth
from .routers.admin import router as admin_router
from .routers.show_bookings import customer_bookings ,provider_bookings,search_providers
from .routers.booking_rating import rating


models.Base.metadata.create_all(bind=engine)


def ensure_provider_workflow_columns():
    # create_all does not alter existing PostgreSQL tables, so this keeps older
    # local databases compatible with the new provider verification workflow.
    with engine.begin() as conn:
        conn.execute(
            text(
                "ALTER TABLE bookings "
                "ADD COLUMN IF NOT EXISTS canceled_by VARCHAR NULL"
            )
        )
        conn.execute(
            text(
                "ALTER TABLE serviceproviders "
                "ADD COLUMN IF NOT EXISTS documents_verified "
                "BOOLEAN NOT NULL DEFAULT FALSE"
            )
        )
        conn.execute(
            text(
                "ALTER TABLE users "
                "ADD COLUMN IF NOT EXISTS email_verified "
                "BOOLEAN NOT NULL DEFAULT FALSE"
            )
        )
        conn.execute(
            text(
                "CREATE TABLE IF NOT EXISTS email_otps ("
                "id SERIAL PRIMARY KEY, "
                "email VARCHAR NOT NULL, "
                "purpose VARCHAR NOT NULL, "
                "otp_hash VARCHAR NOT NULL, "
                "expires_at TIMESTAMPTZ NOT NULL, "
                "consumed_at TIMESTAMPTZ NULL, "
                "created_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                ")"
            )
        )
        conn.execute(text("CREATE INDEX IF NOT EXISTS ix_email_otps_email ON email_otps(email)"))
        conn.execute(
            text(
                "CREATE TABLE IF NOT EXISTS password_reset_tokens ("
                "id SERIAL PRIMARY KEY, "
                "user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                "token_hash VARCHAR NOT NULL UNIQUE, "
                "expires_at TIMESTAMPTZ NOT NULL, "
                "used_at TIMESTAMPTZ NULL, "
                "created_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                ")"
            )
        )
        conn.execute(text("CREATE INDEX IF NOT EXISTS ix_password_reset_tokens_user_id ON password_reset_tokens(user_id)"))
        conn.execute(
            text(
                "CREATE TABLE IF NOT EXISTS signup_intents ("
                "id SERIAL PRIMARY KEY, "
                "email VARCHAR NOT NULL UNIQUE, "
                "name VARCHAR NOT NULL, "
                "phone VARCHAR NOT NULL, "
                "password_hash VARCHAR NOT NULL, "
                "otp_hash VARCHAR NOT NULL, "
                "expires_at TIMESTAMPTZ NOT NULL, "
                "verified_at TIMESTAMPTZ NULL, "
                "created_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                ")"
            )
        )
        conn.execute(text("CREATE INDEX IF NOT EXISTS ix_signup_intents_email ON signup_intents(email)"))
        conn.execute(
            text(
                "CREATE TABLE IF NOT EXISTS notifications ("
                "id SERIAL PRIMARY KEY, "
                "recipient_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                "title VARCHAR NOT NULL, "
                "message VARCHAR NOT NULL, "
                "category VARCHAR NOT NULL DEFAULT 'SYSTEM', "
                "related_type VARCHAR NULL, "
                "related_id INTEGER NULL, "
                "is_read BOOLEAN NOT NULL DEFAULT FALSE, "
                "read_at TIMESTAMPTZ NULL, "
                "created_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                ")"
            )
        )
        conn.execute(
            text(
                "CREATE TABLE IF NOT EXISTS support_reports ("
                "id SERIAL PRIMARY KEY, "
                "user_id INTEGER NULL REFERENCES users(id) ON DELETE SET NULL, "
                "user_name VARCHAR NOT NULL, "
                "user_email VARCHAR NOT NULL, "
                "description VARCHAR NOT NULL, "
                "status VARCHAR NOT NULL DEFAULT 'OPEN', "
                "created_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                ")"
            )
        )
        conn.execute(text("CREATE INDEX IF NOT EXISTS ix_support_reports_user_id ON support_reports(user_id)"))
        conn.execute(text("CREATE INDEX IF NOT EXISTS ix_notifications_recipient_user_id ON notifications(recipient_user_id)"))
        conn.execute(
            text(
                "CREATE TABLE IF NOT EXISTS refresh_tokens ("
                "id SERIAL PRIMARY KEY, "
                "user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, "
                "token_hash VARCHAR NOT NULL UNIQUE, "
                "expires_at TIMESTAMPTZ NOT NULL, "
                "revoked_at TIMESTAMPTZ NULL, "
                "last_used_at TIMESTAMPTZ NULL, "
                "replaced_by_token_hash VARCHAR NULL, "
                "created_at TIMESTAMPTZ NOT NULL DEFAULT now()"
                ")"
            )
        )
        conn.execute(text("CREATE INDEX IF NOT EXISTS ix_refresh_tokens_user_id ON refresh_tokens(user_id)"))
        conn.execute(
            text(
                "UPDATE provider_documents "
                "SET document_type = 'AADHAAR' "
                "WHERE document_type = 'ID_PROOF'"
            )
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
