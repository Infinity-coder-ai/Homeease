from fastapi import File, UploadFile
from pydantic import BaseModel,conint, model_validator
from typing import Optional
from datetime import date, time, datetime

class UserCreate(BaseModel):
  name :str
  email: str
  password: str
  phone :str


class UserOut(BaseModel):
  name :str
  email :str

class UserMe(BaseModel):
  id: int
  name: str
  email: str
  role: str
  email_verified: bool

  class Config:
    from_attributes = True


class AuthTokens(BaseModel):
  """Token pair returned by login and refresh endpoints.

  Access tokens are short-lived JWTs. Refresh tokens are opaque strings that
  the mobile app stores securely and uses only when the access token expires.
  """

  access_token: str
  refresh_token: str
  token_type: str = "bearer"
  expires_in: int = 1800


class RefreshTokenRequest(BaseModel):
  refresh_token: str
  
class TokenData(BaseModel):
  id : Optional[int] = None
  
  
class ProviderCreate(BaseModel):
  experience_years:int
  city :str
  area :str
  pincode :str
  

class ProviderServiceCreate(BaseModel):
    price: float
    estimated_duration_minutes: int | None = None
    service_id :Optional[int]=None
    
    
    # this is for input
class ProviderAvailability(BaseModel):
  day_of_week: conint(ge=0, le=6) # type: ignore
  start_time :time
  end_time :time
  
  # this is for returning to ui that when is provider available 
class ProviderAvailabilityOut(ProviderAvailability):
    id: int

    class Config:
        from_attributes = True
  
  
class ProviderAvailabilityBulkCreate(BaseModel):
  slots: list[ProviderAvailability]
  
  
class ProviderDocument(BaseModel):
   document_type: str
   file: UploadFile = File(...),#In Python, ... is called Ellipsis. 3 dots means “This parameter must be provided.


class BookingCreate(BaseModel):
    provider_id: int
    service_id: int
    booking_date: date
    start_time: time
    end_time: time
    address: str
    city: str
    pincode: str
    landmark: str | None = None
    @model_validator(mode="after") #It runs automatically when FastAPI is turning the incoming request body into your BookingCreate object.
    def validate_time_range(self):
      if self.end_time <= self.start_time:
        raise ValueError("end_time must be greater than start_time")
      return self
  
  # this will return service available to provider whhen he is regisetering as a provider
class ServiceOut(BaseModel):
    id: int
    name: str
    class Config:
        from_attributes = True
    
  # for customer response model
class BookingHistory(BaseModel):
    id: int
    provider_id: int
    provider_name: str
    service_id: int
    service_name: str
    booking_date: date
    start_time: time
    end_time: time
    price: float
    status: str
    canceled_by: str | None = None
    rating: int | None = None
    review: str | None = None

    class Config:
        from_attributes = True
# if whatever we are returnign is sqlalchemy orm object  then from_attributes should be true
     


class Rating(BaseModel):
  rating : int
  review : str | None = None
  @model_validator(mode = "after")
  def validate_rating(self):
    if self.rating > 5 or self.rating <1 :
      raise ValueError("rating should be between 1 to 5")
    return self
  
  # when user search for a provider 
class ProviderSearchResponse(BaseModel):
    id: int
    name: str
    city: str
    area: str
    trust_score: float
    total_jobs_completed: int
    price :int 

    class Config:
        from_attributes = True
  
#   Pydantic (conint): rejects bad input before hitting the DB, returning a clear 422 like “ensure this value is <= 6”. No DB round trip.
# DB CheckConstraint: final safety net if data is inserted outside your API (admin scripts, migrations, direct SQL, bugs).


# this give details about the service a provider is providing 
class ProviderServiceOut(BaseModel):
    id: int
    service_id: int
    service_name: str
    price: float
    estimated_duration_minutes: int | None = None

    class Config:
        from_attributes = True
        
        
# to show the documents on provider dashboard
class ProviderDocumentOut(BaseModel):
    id: int
    document_type: str
    file_url: str
    verification_status: str

    class Config:
        from_attributes = True

# for getting stats of provider 
class ProviderStatsOut(BaseModel):
    trust_score: float
    total_jobs_completed: int
    total_cancellations: int
    verification_status: str
    documents_verified: bool

    class Config:
        from_attributes = True
        
        
# provider dashboard showing all the requested bookings to him
class ProviderBookingOut(BaseModel):
    id: int
    customer_id: int
    customer_name: str
    customer_phone: str
    service_id: int
    booking_date: date
    start_time: time
    end_time: time
    price: float
    status: str
    canceled_by: str | None = None
    address: str
    city: str
    pincode: str
    landmark: str | None = None

    class Config:
        from_attributes = True


class NotificationOut(BaseModel):
    id: int
    recipient_user_id: int
    title: str
    message: str
    category: str
    related_type: str | None = None
    related_id: int | None = None
    is_read: bool
    read_at: datetime | None = None
    created_at: datetime
class SupportReportCreate(BaseModel):
    description: str


class SupportReportOut(BaseModel):
    id: int
    user_id: int | None = None
    user_name: str
    user_email: str
    description: str
    status: str
    created_at: datetime

    class Config:
        from_attributes = True
