
from pydantic_settings import BaseSettings
from pydantic import Field, ConfigDict

class Settings(BaseSettings):
    database_hostname: str = Field(..., env="DATABASE_HOSTNAME")
    database_port: int = Field(..., env="DATABASE_PORT")
    database_username: str = Field(..., env="DATABASE_USERNAME")
    database_password: str = Field(..., env="DATABASE_PASSWORD")
    database_name: str = Field(..., env="DATABASE_NAME")
    secret_key: str = Field(..., env="SECRET_KEY")
    algorithm: str = Field(..., env="ALGORITHM")
    access_token_expire_minutes: int = Field(..., env="ACCESS_TOKEN_EXPIRE_MINUTES")
    cloudinary_cloud_name: str = Field(..., env="CLOUDINARY_CLOUD_NAME")
    cloudinary_api_key: str = Field(..., env="CLOUDINARY_API_KEY")
    cloudinary_api_secret: str = Field(..., env="CLOUDINARY_API_SECRET")
    from_name: str = Field("HomeEase", env="FROM_NAME")
    brevo_api_key: str = Field("", env="BREVO_API_KEY")
    brevo_sender_email: str = Field("", env="BREVO_SENDER_EMAIL")
    brevo_sender_name: str = Field("HomeEase", env="BREVO_SENDER_NAME")
    brevo_smtp_server: str = Field("smtp-relay.brevo.com", env="BREVO_SMTP_SERVER")
    brevo_smtp_port: int = Field(587, env="BREVO_SMTP_PORT")
    brevo_smtp_login: str = Field("", env="BREVO_SMTP_LOGIN")
    brevo_smtp_key: str = Field("", env="BREVO_SMTP_KEY")




    # Allow extra environment variables so leftover keys in .env won't crash startup.
    model_config = ConfigDict(
        env_file=".env",
        extra="ignore",
        case_sensitive=False,
        populate_by_name=True,
    )


settings = Settings()

