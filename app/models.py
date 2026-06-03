from .database import Base
from sqlalchemy import Column,Integer,String,DateTime,text,Boolean,ForeignKey ,Float,UniqueConstraint,Time,CheckConstraint,Date


class Users(Base):
  __tablename__ = "users"
  id = Column(Integer, primary_key=True,nullable=False)
  name = Column(String,nullable=False)
  email = Column(String ,nullable=False,unique=True)
  password =Column(String ,nullable=False)
  created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("now()")
    )
  role = Column(String,default="customer")
  phone = Column(String,nullable = False)
  is_active = Column(Boolean,default=True)
  # Email must be verified via OTP before login is allowed.
  email_verified = Column(Boolean, default=False, nullable=False, server_default=text("false"))
  
  
#service providers

class ServiceProviders(Base):
  __tablename__ = "serviceproviders"
  id = Column(Integer, ForeignKey("users.id"), primary_key=True, nullable=False)
  experience_years = Column(Integer, nullable=False)
  city = Column(String, nullable=False)
  area = Column(String, nullable=False)
  pincode = Column(String, nullable=False)
  verification_status = Column(String, default="PENDING", nullable=False)
  # True only after admin approves every required provider document.
  documents_verified = Column(Boolean, default=False, nullable=False, server_default=text("false"))
  trust_score = Column(Float, default=0.0)
  total_jobs_completed = Column(Integer, default=0)
  total_cancellations = Column(Integer, default=0)
  created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("now()")
    )
  



class Services(Base):
    __tablename__ = "services"

    id = Column(Integer, primary_key=True)

    name = Column(String, nullable=False, unique=True)

    is_active = Column(
        Boolean,
        nullable=False,
        default=True,                 # SQLAlchemy-level default
        server_default=text("true")   # Database-level default
    )

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("now()")
    )
  


class ProviderServices(Base):
    __tablename__ = "provider_services"

    id = Column(Integer, primary_key=True, nullable=False)

    provider_id = Column(
        Integer,
        ForeignKey("serviceproviders.id", ondelete="CASCADE"),
        nullable=False
    )

    service_id = Column(
        Integer,
        ForeignKey("services.id", ondelete="CASCADE"),
        nullable=False
    )

    price = Column(Float, nullable=False)   

    
    estimated_duration_minutes = Column(Integer, nullable=True)

    is_available = Column(Boolean, default=True, nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("now()")
    )

    __table_args__ = (
        UniqueConstraint(
            "provider_id",
            "service_id",
            name="uq_provider_service"
        ),
    )


class ProviderAvailability(Base):
    __tablename__ = "provider_availability"

    id = Column(Integer, primary_key=True, nullable=False)

    provider_id = Column(
        Integer,
        ForeignKey("serviceproviders.id", ondelete="CASCADE"),
        nullable=False
    )

    # 0=Monday ... 6=Sunday (adjust if you prefer 1-7)
    day_of_week = Column(Integer, nullable=False)

    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("now()")
    )

    __table_args__ = (
        CheckConstraint("day_of_week >= 0 AND day_of_week <= 6", name="ck_avail_day_of_week"),
        CheckConstraint("end_time > start_time", name="ck_avail_time_range"),
        UniqueConstraint(
            "provider_id",
            "day_of_week",
            "start_time",
            "end_time",
            name="uq_provider_availability_slot"
        ),
    )
    
    
class ProviderDocuments(Base):
    __tablename__ = "provider_documents"

    id = Column(Integer, primary_key=True)
    provider_id = Column(Integer, ForeignKey("serviceproviders.id", ondelete="CASCADE"), nullable=False)

    document_type = Column(String, nullable=False)  
    # AADHAAR | PROFILE_PHOTO

    file_url = Column(String, nullable=False)

    verification_status = Column(String, default="PENDING", nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("now()")
    )
    
    
    
    
class Bookings(Base):
    __tablename__ = "bookings"
    id = Column(Integer, primary_key=True)
    customer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    provider_id = Column(Integer, ForeignKey("serviceproviders.id"), nullable=False)
    service_id = Column(Integer, ForeignKey("services.id"), nullable=False)
    price = Column(Float, nullable=False)
    booking_date = Column(Date, nullable=False)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    address = Column(String, nullable=False)
    city = Column(String, nullable=False)
    pincode = Column(String, nullable=False)
    status = Column(String, default="REQUESTED", nullable=False)
    # Tracks whether the provider or the customer canceled this booking.
    canceled_by = Column(String, nullable=True)
    landmark = Column(String)
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("now()")
    )
    __table_args__ = (
        CheckConstraint("end_time > start_time", name="ck_booking_time_range"),
        UniqueConstraint(
            "customer_id",
            "provider_id",
            "service_id",
            "booking_date",
            "start_time",
            "end_time",
            name="uq_booking_exact"
        ),
    )


class Notifications(Base):
    """Stores inbox items shown inside the app.

    Each notification belongs to a single user, which keeps read/unread state
    simple and avoids role-based edge cases later.
    """

    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True)
    recipient_user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String, nullable=False)
    message = Column(String, nullable=False)
    category = Column(String, nullable=False, default="SYSTEM")
    related_type = Column(String, nullable=True)
    related_id = Column(Integer, nullable=True)
    is_read = Column(Boolean, default=False, nullable=False, server_default=text("false"))
    read_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class SupportReports(Base):
    """Stores app support/problem reports submitted by users."""

    __tablename__ = "support_reports"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    user_name = Column(String, nullable=False)
    user_email = Column(String, nullable=False)
    description = Column(String, nullable=False)
    status = Column(String, nullable=False, default="OPEN")
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    
    

class RefreshTokens(Base):
    """Stores hashed refresh tokens for mobile sessions.

    The raw refresh token is shown to the client only once. Persisting the
    hash keeps the database from becoming a token store if it is compromised.
    """

    __tablename__ = "refresh_tokens"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    token_hash = Column(String, nullable=False, unique=True, index=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    revoked_at = Column(DateTime(timezone=True), nullable=True)
    last_used_at = Column(DateTime(timezone=True), nullable=True)
    replaced_by_token_hash = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class Ratings(Base):
    __tablename__ = "ratings"

    id = Column(Integer, primary_key=True)

    booking_id = Column(
        Integer,
        ForeignKey("bookings.id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )

    customer_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )

    provider_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )

    service_id = Column(
        Integer,
        ForeignKey("services.id", ondelete="CASCADE"),
        nullable=False
    )

    rating = Column(Integer, nullable=False)

    review = Column(String, nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        server_default=text("now()")
    )

    __table_args__ = (
        CheckConstraint("rating >= 1 AND rating <= 5", name="rating_range_check"),
    )


class EmailOtps(Base):
  """
  Stores email OTPs for signup verification.
  OTPs are stored as hashes (never plaintext) and expire quickly.
  """
  __tablename__ = "email_otps"
  id = Column(Integer, primary_key=True)
  email = Column(String, nullable=False, index=True)
  purpose = Column(String, nullable=False)  # SIGNUP_VERIFY
  otp_hash = Column(String, nullable=False)
  expires_at = Column(DateTime(timezone=True), nullable=False)
  consumed_at = Column(DateTime(timezone=True), nullable=True)
  created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class PasswordResetTokens(Base):
  """
  Stores password reset tokens for the "forgot password" flow.
  Tokens are stored as hashes (never plaintext) and are single-use.
  """
  __tablename__ = "password_reset_tokens"
  id = Column(Integer, primary_key=True)
  user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
  token_hash = Column(String, nullable=False, unique=True)
  expires_at = Column(DateTime(timezone=True), nullable=False)
  used_at = Column(DateTime(timezone=True), nullable=True)
  created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))


class SignupIntents(Base):
  """
  Temporary holding table for signup data until email OTP verification succeeds.
  This prevents creating real user accounts before email ownership is proven.
  """
  __tablename__ = "signup_intents"
  id = Column(Integer, primary_key=True)
  email = Column(String, nullable=False, unique=True, index=True)
  name = Column(String, nullable=False)
  phone = Column(String, nullable=False)
  password_hash = Column(String, nullable=False)
  otp_hash = Column(String, nullable=False)
  expires_at = Column(DateTime(timezone=True), nullable=False)
  verified_at = Column(DateTime(timezone=True), nullable=True)
  created_at = Column(DateTime(timezone=True), nullable=False, server_default=text("now()"))
    
    
    
