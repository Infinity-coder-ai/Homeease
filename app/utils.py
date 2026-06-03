from pwdlib import PasswordHash
from sqlalchemy import func
from . import models

password_hash = PasswordHash.recommended()

def hash_pass(password : str):
  return password_hash.hash(password)

def verify_password(plain_password, hashed_password):
    return password_hash.verify(plain_password, hashed_password)

# recalculation of trust score after jobs done or not

def recalculate_trust_score(db, provider_id: int) -> float:
  provider = db.query(models.ServiceProviders).filter(
    models.ServiceProviders.id == provider_id
  ).first()
  if not provider:
    return 0.0

  jobs_comp = provider.total_jobs_completed or 0
  jobs_cancel = provider.total_cancellations or 0
  total_jobs = jobs_comp + jobs_cancel
  performance_score = (jobs_comp / total_jobs) * 5 if total_jobs > 0 else 0.0

  avg_rating = db.query(func.avg(models.Ratings.rating)).filter(
    models.Ratings.provider_id == provider_id
  ).scalar()
  rating_score = float(avg_rating) if avg_rating is not None else 0.0

  trust_score = round(((rating_score + performance_score) / 2), 2)
  provider.trust_score = trust_score
  return trust_score
  
  