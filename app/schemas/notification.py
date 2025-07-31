from pydantic import BaseModel

class NotificationTokenCreate(BaseModel):
    token: str
