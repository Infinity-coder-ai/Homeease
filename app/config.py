
from pydantic_settings import BaseSettings
from pydantic import Field, ConfigDict

class Settings(BaseSettings):
    database_hostname: str          
    database_port: str
    database_username: str
    database_password: str
    database_name: str
    secret_key: str
    algorithm: str
    access_token_expire_minutes: int
    cloudinary_cloud_name :str
    cloudinary_api_key : str
    cloudinary_api_secret :str
    smtp_server: str = Field(..., alias="SMTP_SERVER")
    smtp_port: int = Field(..., alias="SMTP_PORT")
    smtp_email: str = Field(..., alias="SMTP_EMAIL")
    smtp_password: str = Field(..., alias="SMTP_PASSWORD")
    from_name: str = Field("HomeEase", alias="FROM_NAME")
    



    # Allow extra environment variables so leftover keys in .env won't crash startup.
    model_config = ConfigDict(
        env_file=".env",
        extra="ignore",
    )


settings = Settings()  
