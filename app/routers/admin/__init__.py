# Admin router package: aggregates admin endpoints under /admin.
from fastapi import APIRouter
from . import requests, actions, details

router = APIRouter(prefix="/admin", tags=["Admin"])

# Admin API groups.
router.include_router(requests.router)
router.include_router(actions.router)
router.include_router(details.router)
