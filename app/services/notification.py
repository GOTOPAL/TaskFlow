from firebase_admin import messaging
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.notification_token import NotificationToken

import app.firebase.init  # sadece initialize etmek için import

async def send_notification_to_user(user_id: int,db: AsyncSession,title: str,body: str):
    # 1️⃣ Token'ları al
    stmt = select(NotificationToken.token).where(NotificationToken.user_id == user_id)
    result = await db.execute(stmt)
    tokens = [row[0] for row in result.fetchall()]

    if not tokens:
        print(f"🚫 Kullanıcının FCM token'ı bulunamadı: user_id={user_id}")
        return

    # 2️⃣ Bildirim oluştur
    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        tokens=tokens
    )

    # 3️⃣ Gönder
    response = messaging.send_multicast(message)
    print(f"📤 Bildirim gönderildi: Başarılı={response.success_count}, Başarısız={response.failure_count}")
