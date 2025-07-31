from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.schemas.notification import NotificationTokenCreate
from app.models.notification_token import NotificationToken
from app.models.user import User
from app.auth.dependencies import get_current_user  # Auth için senin kullandığın yol buysa

router = APIRouter()

@router.post("/register-token")
async def register_fcm_token(
    token_data: NotificationTokenCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    stmt = select(NotificationToken).where(NotificationToken.token == token_data.token)
    result = await db.execute(stmt)
    existing_token = result.scalar_one_or_none()

    if existing_token is None:
        new_token = NotificationToken(
            user_id=current_user.id,
            token=token_data.token
        )
        db.add(new_token)
        await db.commit()

    return {"message": "FCM token registered"}
